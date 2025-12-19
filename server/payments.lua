-- ====================================================================================================
-- 💰 PAYMENT SYSTEM
-- Mortgages, Rent, Transactions
-- ====================================================================================================

-- ====================================================================================================
-- 🏦 MORTGAGE PAYMENTS
-- ====================================================================================================

-- Process missed mortgage payment
function ProcessMissedMortgagePayment(mortgage)
    local missedPayments = mortgage.missed_payments + 1
    local gracePeriod = mortgage.grace_period_remaining - 1
    
    if gracePeriod <= 0 or missedPayments >= Config.Payment.mortgage.repossessAfterMissed then
        -- Repossess property
        RepossessProperty(mortgage.property_id, mortgage.owner_id, 'mortgage_default')
        
        -- Update mortgage status
        MySQL.Async.execute('UPDATE property_mortgages SET status = @status WHERE id = @id', {
            ['@status'] = 'defaulted',
            ['@id'] = mortgage.id
        })
        
        -- Log action
        LogAction(mortgage.property_id, mortgage.owner_id, 'repossession', 'Property repossessed due to missed mortgage payments')
        
        -- Notify player if online
        local xPlayers = Framework == 'ESX' and ESX.GetPlayers() or QBCore.Functions.GetPlayers()
        for _, playerId in ipairs(xPlayers) do
            local playerIdentifier = GetPlayerIdentifier(playerId)
            if playerIdentifier == mortgage.owner_id then
                SendNotification(playerId, 'error', 'Property Repossessed', 'Your property has been repossessed due to missed payments', mortgage.property_id)
                break
            end
        end
    else
        -- Update missed payments
        MySQL.Async.execute([[
            UPDATE property_mortgages 
            SET missed_payments = @missed,
                grace_period_remaining = @grace,
                next_payment = DATE_ADD(next_payment, INTERVAL @interval DAY),
                status = @status
            WHERE id = @id
        ]], {
            ['@missed'] = missedPayments,
            ['@grace'] = gracePeriod,
            ['@interval'] = Config.Payment.mortgage.paymentInterval,
            ['@status'] = 'overdue',
            ['@id'] = mortgage.id
        })
        
        -- Notify player if online
        local xPlayers = Framework == 'ESX' and ESX.GetPlayers() or QBCore.Functions.GetPlayers()
        for _, playerId in ipairs(xPlayers) do
            local playerIdentifier = GetPlayerIdentifier(playerId)
            if playerIdentifier == mortgage.owner_id then
                SendNotification(playerId, 'warning', _('warning'), _('mortgage_payment_due') .. ' Grace period: ' .. gracePeriod, mortgage.property_id)
                break
            end
        end
        
        -- Log action
        LogAction(mortgage.property_id, mortgage.owner_id, 'missed_payment', 'Missed mortgage payment. Remaining grace: ' .. gracePeriod)
    end
end

-- Manual mortgage payment
RegisterNetEvent('property:payMortgage')
AddEventHandler('property:payMortgage', function(propertyId, paymentMethod)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    -- Get mortgage data
    MySQL.Async.fetchAll('SELECT * FROM property_mortgages WHERE property_id = @property AND owner_id = @owner AND status IN (@active, @overdue)', {
        ['@property'] = propertyId,
        ['@owner'] = identifier,
        ['@active'] = 'active',
        ['@overdue'] = 'overdue'
    }, function(result)
        if not result[1] then
            SendNotification(source, 'error', _('error'), 'No active mortgage found')
            return
        end
        
        local mortgage = result[1]
        
        -- Check player money
        if GetPlayerMoney(source, paymentMethod) < mortgage.payment_amount then
            SendNotification(source, 'error', _('error'), _('insufficient_funds'))
            return
        end
        
        -- Remove money
        if not RemovePlayerMoney(source, paymentMethod, mortgage.payment_amount) then
            SendNotification(source, 'error', _('error'), _('payment_failed'))
            return
        end
        
        -- Update mortgage
        local newRemainingAmount = mortgage.remaining_amount - mortgage.payment_amount
        local newPaymentsMade = mortgage.payments_made + 1
        local isCompleted = newPaymentsMade >= mortgage.total_payments or newRemainingAmount <= 0
        
        if isCompleted then
            -- Mortgage completed
            MySQL.Async.execute([[
                UPDATE property_mortgages 
                SET remaining_amount = 0,
                    payments_made = @payments,
                    status = @status,
                    completed_at = NOW()
                WHERE id = @id
            ]], {
                ['@payments'] = newPaymentsMade,
                ['@status'] = 'completed',
                ['@id'] = mortgage.id
            })
            
            SendNotification(source, 'success', _('success'), 'Mortgage paid off! Property is now fully yours.', propertyId)
            LogAction(propertyId, identifier, 'mortgage_completed', 'Mortgage fully paid off')
        else
            -- Update mortgage
            MySQL.Async.execute([[
                UPDATE property_mortgages 
                SET remaining_amount = @remaining,
                    payments_made = @payments,
                    missed_payments = 0,
                    grace_period_remaining = @grace,
                    last_payment = NOW(),
                    next_payment = DATE_ADD(NOW(), INTERVAL @interval DAY),
                    status = @status
                WHERE id = @id
            ]], {
                ['@remaining'] = newRemainingAmount,
                ['@payments'] = newPaymentsMade,
                ['@grace'] = Config.Payment.mortgage.gracePeriod,
                ['@interval'] = Config.Payment.mortgage.paymentInterval,
                ['@status'] = 'active',
                ['@id'] = mortgage.id
            })
            
            SendNotification(source, 'success', _('success'), _('payment_successful') .. ' Remaining: $' .. newRemainingAmount, propertyId)
            LogAction(propertyId, identifier, 'mortgage_payment', 'Paid $' .. mortgage.payment_amount)
        end
        
        -- Create transaction record
        MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
            ['@property'] = propertyId,
            ['@player'] = identifier,
            ['@type'] = 'mortgage_payment',
            ['@amount'] = mortgage.payment_amount,
            ['@method'] = paymentMethod,
            ['@desc'] = 'Mortgage payment ' .. newPaymentsMade .. '/' .. mortgage.total_payments
        })
    end)
end)

-- ====================================================================================================
-- 🏠 RENT PAYMENTS
-- ====================================================================================================

-- Process missed rent payment
function ProcessMissedRentPayment(tenant)
    local missedPayments = tenant.missed_payments + 1
    local gracePeriod = tenant.grace_period_remaining - 1
    
    if gracePeriod <= 0 or missedPayments >= Config.Payment.rent.evictAfterMissed then
        -- Evict tenant
        EvictTenant(tenant.property_id, tenant.tenant_id, 'rent_default')
        
        -- Update tenant status
        MySQL.Async.execute('UPDATE property_tenants SET status = @status WHERE id = @id', {
            ['@status'] = 'evicted',
            ['@id'] = tenant.id
        })
        
        -- Log action
        LogAction(tenant.property_id, tenant.tenant_id, 'eviction', 'Tenant evicted due to missed rent payments')
        
        -- Notify player if online
        local xPlayers = Framework == 'ESX' and ESX.GetPlayers() or QBCore.Functions.GetPlayers()
        for _, playerId in ipairs(xPlayers) do
            local playerIdentifier = GetPlayerIdentifier(playerId)
            if playerIdentifier == tenant.tenant_id then
                SendNotification(playerId, 'error', 'Evicted', 'You have been evicted due to missed rent payments', tenant.property_id)
                break
            end
        end
    else
        -- Update missed payments
        MySQL.Async.execute([[
            UPDATE property_tenants 
            SET missed_payments = @missed,
                grace_period_remaining = @grace,
                next_payment = DATE_ADD(next_payment, INTERVAL @interval DAY),
                status = @status
            WHERE id = @id
        ]], {
            ['@missed'] = missedPayments,
            ['@grace'] = gracePeriod,
            ['@interval'] = Config.Payment.rent.paymentInterval,
            ['@status'] = 'overdue',
            ['@id'] = tenant.id
        })
        
        -- Notify player if online
        local xPlayers = Framework == 'ESX' and ESX.GetPlayers() or QBCore.Functions.GetPlayers()
        for _, playerId in ipairs(xPlayers) do
            local playerIdentifier = GetPlayerIdentifier(playerId)
            if playerIdentifier == tenant.tenant_id then
                SendNotification(playerId, 'warning', _('warning'), _('rent_payment_due') .. ' Grace period: ' .. gracePeriod, tenant.property_id)
                break
            end
        end
        
        -- Log action
        LogAction(tenant.property_id, tenant.tenant_id, 'missed_payment', 'Missed rent payment. Remaining grace: ' .. gracePeriod)
    end
end

-- Manual rent payment
RegisterNetEvent('property:payRent')
AddEventHandler('property:payRent', function(propertyId, paymentMethod)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    -- Get tenant data
    MySQL.Async.fetchAll('SELECT * FROM property_tenants WHERE property_id = @property AND tenant_id = @tenant AND status IN (@active, @overdue)', {
        ['@property'] = propertyId,
        ['@tenant'] = identifier,
        ['@active'] = 'active',
        ['@overdue'] = 'overdue'
    }, function(result)
        if not result[1] then
            SendNotification(source, 'error', _('error'), 'No active lease found')
            return
        end
        
        local tenant = result[1]
        
        -- Check player money
        if GetPlayerMoney(source, paymentMethod) < tenant.rent_amount then
            SendNotification(source, 'error', _('error'), _('insufficient_funds'))
            return
        end
        
        -- Remove money
        if not RemovePlayerMoney(source, paymentMethod, tenant.rent_amount) then
            SendNotification(source, 'error', _('error'), _('payment_failed'))
            return
        end
        
        -- Update tenant
        MySQL.Async.execute([[
            UPDATE property_tenants 
            SET missed_payments = 0,
                grace_period_remaining = @grace,
                last_payment = NOW(),
                next_payment = DATE_ADD(NOW(), INTERVAL @interval DAY),
                status = @status
            WHERE id = @id
        ]], {
            ['@grace'] = Config.Payment.rent.gracePeriod,
            ['@interval'] = Config.Payment.rent.paymentInterval,
            ['@status'] = 'active',
            ['@id'] = tenant.id
        })
        
        -- Give money to property owner
        MySQL.Async.fetchAll('SELECT owner FROM properties WHERE id = @id', {
            ['@id'] = propertyId
        }, function(propertyResult)
            if propertyResult[1] and propertyResult[1].owner then
                -- Find owner online
                local xPlayers = Framework == 'ESX' and ESX.GetPlayers() or QBCore.Functions.GetPlayers()
                for _, playerId in ipairs(xPlayers) do
                    local playerIdentifier = GetPlayerIdentifier(playerId)
                    if playerIdentifier == propertyResult[1].owner then
                        AddPlayerMoney(playerId, 'bank', tenant.rent_amount)
                        SendNotification(playerId, 'success', 'Rent Received', 'You received $' .. tenant.rent_amount .. ' rent payment', propertyId)
                        break
                    end
                end
            end
        end)
        
        SendNotification(source, 'success', _('success'), _('payment_successful'), propertyId)
        LogAction(propertyId, identifier, 'rent_payment', 'Paid $' .. tenant.rent_amount)
        
        -- Create transaction record
        MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
            ['@property'] = propertyId,
            ['@player'] = identifier,
            ['@type'] = 'rent',
            ['@amount'] = tenant.rent_amount,
            ['@method'] = paymentMethod,
            ['@desc'] = 'Rent payment'
        })
    end)
end)

-- ====================================================================================================
-- 🏚️ REPOSSESSION & EVICTION
-- ====================================================================================================

function RepossessProperty(propertyId, ownerId, reason)
    -- Update property
    MySQL.Async.execute('UPDATE properties SET owner = NULL, tenant = NULL, status = @status, for_sale = 1, locked = 1 WHERE id = @id', {
        ['@status'] = 'available',
        ['@id'] = propertyId
    })
    
    -- Remove all keys
    MySQL.Async.execute('DELETE FROM property_keys WHERE property_id = @property', {
        ['@property'] = propertyId
    })
    
    -- Clear storage
    MySQL.Async.execute('DELETE FROM property_storage WHERE property_id = @property', {
        ['@property'] = propertyId
    })
    
    -- Remove vehicles from garage
    MySQL.Async.execute('DELETE FROM garage_vehicles WHERE property_id = @property', {
        ['@property'] = propertyId
    })
    
    -- Log action
    LogAction(propertyId, ownerId, 'repossession', 'Property repossessed: ' .. reason)
    
    -- Update clients
    TriggerClientEvent('property:updateProperty', -1, propertyId, {
        owner = nil,
        tenant = nil,
        status = 'available',
        for_sale = 1
    })
end

function EvictTenant(propertyId, tenantId, reason)
    -- Update property
    MySQL.Async.execute('UPDATE properties SET tenant = NULL, status = @status, for_rent = 1 WHERE id = @id', {
        ['@status'] = 'available',
        ['@id'] = propertyId
    })
    
    -- Remove tenant keys
    MySQL.Async.execute('DELETE FROM property_keys WHERE property_id = @property AND holder = @holder', {
        ['@property'] = propertyId,
        ['@holder'] = tenantId
    })
    
    -- Log action
    LogAction(propertyId, tenantId, 'eviction', 'Tenant evicted: ' .. reason)
    
    -- Update clients
    TriggerClientEvent('property:updateProperty', -1, propertyId, {
        tenant = nil,
        status = 'available'
    })
end

-- Admin evict tenant
RegisterNetEvent('property:adminEvict')
AddEventHandler('property:adminEvict', function(propertyId)
    local source = source
    
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    -- Get property
    MySQL.Async.fetchAll('SELECT tenant FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if not result[1] or not result[1].tenant then
            SendNotification(source, 'error', _('error'), 'No tenant to evict')
            return
        end
        
        EvictTenant(propertyId, result[1].tenant, 'admin_eviction')
        
        -- Update tenant record
        MySQL.Async.execute('UPDATE property_tenants SET status = @status WHERE property_id = @property', {
            ['@status'] = 'evicted',
            ['@property'] = propertyId
        })
        
        SendNotification(source, 'success', _('success'), _('tenant_evicted'))
        LogAction(propertyId, GetPlayerIdentifier(source), 'admin_eviction', 'Admin evicted tenant')
    end)
end)

-- ====================================================================================================
-- 📊 GET PAYMENT INFO
-- ====================================================================================================

-- Get mortgage info
RegisterNetEvent('property:getMortgageInfo')
AddEventHandler('property:getMortgageInfo', function(propertyId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    MySQL.Async.fetchAll('SELECT * FROM property_mortgages WHERE property_id = @property AND owner_id = @owner', {
        ['@property'] = propertyId,
        ['@owner'] = identifier
    }, function(result)
        TriggerClientEvent('property:receiveMortgageInfo', source, result[1])
    end)
end)

-- Get rent info
RegisterNetEvent('property:getRentInfo')
AddEventHandler('property:getRentInfo', function(propertyId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    MySQL.Async.fetchAll('SELECT * FROM property_tenants WHERE property_id = @property AND tenant_id = @tenant', {
        ['@property'] = propertyId,
        ['@tenant'] = identifier
    }, function(result)
        TriggerClientEvent('property:receiveRentInfo', source, result[1])
    end)
end)

-- Get transaction history
RegisterNetEvent('property:getTransactions')
AddEventHandler('property:getTransactions', function(propertyId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    MySQL.Async.fetchAll('SELECT * FROM property_transactions WHERE property_id = @property AND player_id = @player ORDER BY created_at DESC LIMIT 50', {
        ['@property'] = propertyId,
        ['@player'] = identifier
    }, function(result)
        TriggerClientEvent('property:receiveTransactions', source, result)
    end)
end)
