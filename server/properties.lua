-- ====================================================================================================
-- 🏠 PROPERTY CRUD & MANAGEMENT
-- Create, Read, Update, Delete operations for properties
-- ====================================================================================================

-- ====================================================================================================
-- 📊 GET PROPERTIES
-- ====================================================================================================

-- Get all properties
RegisterNetEvent('property:getAll')
AddEventHandler('property:getAll', function()
    local source = source
    MySQL.Async.fetchAll('SELECT * FROM properties', {}, function(properties)
        TriggerClientEvent('property:receiveAll', source, properties)
    end)
end)

-- Get property by ID
RegisterNetEvent('property:getById')
AddEventHandler('property:getById', function(propertyId)
    local source = source
    MySQL.Async.fetchAll('SELECT * FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if result[1] then
            TriggerClientEvent('property:receiveOne', source, result[1])
        end
    end)
end)

-- Get properties by owner
RegisterNetEvent('property:getByOwner')
AddEventHandler('property:getByOwner', function()
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    MySQL.Async.fetchAll('SELECT * FROM properties WHERE owner = @owner', {
        ['@owner'] = identifier
    }, function(properties)
        TriggerClientEvent('property:receiveOwned', source, properties)
    end)
end)

-- Get properties by tenant
RegisterNetEvent('property:getByTenant')
AddEventHandler('property:getByTenant', function()
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    MySQL.Async.fetchAll('SELECT * FROM properties WHERE tenant = @tenant', {
        ['@tenant'] = identifier
    }, function(properties)
        TriggerClientEvent('property:receiveRented', source, properties)
    end)
end)

-- ====================================================================================================
-- 🛒 PURCHASE PROPERTY
-- ====================================================================================================

RegisterNetEvent('property:purchase')
AddEventHandler('property:purchase', function(propertyId, paymentMethod, useMortgage, mortgageData)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        SendNotification(source, 'error', _('error'), _('player_not_found'))
        return
    end
    
    -- Get property data
    MySQL.Async.fetchAll('SELECT * FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if not result[1] then
            SendNotification(source, 'error', _('error'), _('property_not_found'))
            return
        end
        
        local property = result[1]
        
        -- Check if property is available
        if property.status ~= 'available' then
            SendNotification(source, 'error', _('error'), _('property_not_available'))
            return
        end
        
        -- Check max properties limit
        MySQL.Async.fetchAll('SELECT COUNT(*) as count FROM properties WHERE owner = @owner', {
            ['@owner'] = identifier
        }, function(countResult)
            local ownedCount = countResult[1].count
            
            if ownedCount >= Config.Properties.maxPropertiesPerPlayer then
                SendNotification(source, 'error', _('error'), _('max_properties_reached'))
                return
            end
            
            local finalPrice = property.price
            local downPayment = finalPrice
            
            -- Handle mortgage
            if useMortgage and Config.Payment.mortgage.enabled and mortgageData then
                downPayment = math.floor(finalPrice * (mortgageData.downPaymentPercent / 100))
                
                -- Validate down payment
                if mortgageData.downPaymentPercent < Config.Payment.mortgage.minDownPayment or
                   mortgageData.downPaymentPercent > Config.Payment.mortgage.maxDownPayment then
                    SendNotification(source, 'error', _('error'), 'Invalid down payment percentage')
                    return
                end
            end
            
            -- Check player money
            local playerMoney = GetPlayerMoney(source, paymentMethod)
            if playerMoney < downPayment then
                SendNotification(source, 'error', _('error'), _('insufficient_funds'))
                return
            end
            
            -- Remove money
            if not RemovePlayerMoney(source, paymentMethod, downPayment) then
                SendNotification(source, 'error', _('error'), _('payment_failed'))
                return
            end
            
            -- Update property
            MySQL.Async.execute('UPDATE properties SET owner = @owner, status = @status, for_sale = 0 WHERE id = @id', {
                ['@owner'] = identifier,
                ['@status'] = 'owned',
                ['@id'] = propertyId
            })
            
            -- Give keys
            GivePropertyKey(propertyId, identifier, 'owner', identifier)
            
            -- Create transaction record
            MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
                ['@property'] = propertyId,
                ['@player'] = identifier,
                ['@type'] = useMortgage and 'mortgage_payment' or 'purchase',
                ['@amount'] = downPayment,
                ['@method'] = paymentMethod,
                ['@desc'] = useMortgage and 'Down payment for mortgage' or 'Full property purchase'
            })
            
            -- Create mortgage if applicable
            if useMortgage and mortgageData then
                local remainingAmount = finalPrice - downPayment
                local monthlyInterest = Config.Payment.mortgage.interestRate / 12 / 100
                local totalPayments = mortgageData.durationMonths * (30 / Config.Payment.mortgage.paymentInterval)
                local paymentAmount = math.floor(remainingAmount * (monthlyInterest * math.pow(1 + monthlyInterest, totalPayments)) / (math.pow(1 + monthlyInterest, totalPayments) - 1))
                
                MySQL.Async.execute([[
                    INSERT INTO property_mortgages (
                        property_id, owner_id, total_amount, down_payment,
                        remaining_amount, interest_rate, payment_amount,
                        payment_interval, duration_months, total_payments, next_payment
                    ) VALUES (
                        @property, @owner, @total, @down,
                        @remaining, @rate, @payment,
                        @interval, @duration, @totalPayments, DATE_ADD(NOW(), INTERVAL @interval DAY)
                    )
                ]], {
                    ['@property'] = propertyId,
                    ['@owner'] = identifier,
                    ['@total'] = finalPrice,
                    ['@down'] = downPayment,
                    ['@remaining'] = remainingAmount,
                    ['@rate'] = Config.Payment.mortgage.interestRate,
                    ['@payment'] = paymentAmount,
                    ['@interval'] = Config.Payment.mortgage.paymentInterval,
                    ['@duration'] = mortgageData.durationMonths,
                    ['@totalPayments'] = totalPayments
                })
            end
            
            -- Log action
            LogAction(propertyId, identifier, 'purchase', 'Purchased property for $' .. downPayment)
            
            -- Send notification
            SendNotification(source, 'success', _('success'), _('property_purchased'), propertyId)
            
            -- Update all clients
            TriggerClientEvent('property:updateProperty', -1, propertyId, {
                owner = identifier,
                status = 'owned',
                for_sale = 0
            })
        end)
    end)
end)

-- ====================================================================================================
-- 🔑 SELL PROPERTY
-- ====================================================================================================

RegisterNetEvent('property:sell')
AddEventHandler('property:sell', function(propertyId, sellPrice)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    -- Verify ownership
    MySQL.Async.fetchAll('SELECT * FROM properties WHERE id = @id AND owner = @owner', {
        ['@id'] = propertyId,
        ['@owner'] = identifier
    }, function(result)
        if not result[1] then
            SendNotification(source, 'error', _('error'), _('not_owner'))
            return
        end
        
        local property = result[1]
        
        -- Check for active mortgage
        MySQL.Async.fetchAll('SELECT * FROM property_mortgages WHERE property_id = @property AND status = @status', {
            ['@property'] = propertyId,
            ['@status'] = 'active'
        }, function(mortgages)
            local mortgage = mortgages[1]
            local finalPayout = sellPrice or property.price
            
            -- Deduct remaining mortgage
            if mortgage then
                finalPayout = finalPayout - mortgage.remaining_amount
                if finalPayout < 0 then finalPayout = 0 end
                
                -- Mark mortgage as completed
                MySQL.Async.execute('UPDATE property_mortgages SET status = @status, completed_at = NOW() WHERE id = @id', {
                    ['@status'] = 'completed',
                    ['@id'] = mortgage.id
                })
            end
            
            -- Give money to player
            AddPlayerMoney(source, 'bank', finalPayout)
            
            -- Reset property
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
            MySQL.Async.fetchAll('SELECT * FROM garage_vehicles WHERE property_id = @property', {
                ['@property'] = propertyId
            }, function(vehicles)
                for _, vehicle in ipairs(vehicles) do
                    -- Return vehicles to public garage
                    -- TODO: Implement vehicle return logic
                end
                
                MySQL.Async.execute('DELETE FROM garage_vehicles WHERE property_id = @property', {
                    ['@property'] = propertyId
                })
            end)
            
            -- Create transaction
            MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
                ['@property'] = propertyId,
                ['@player'] = identifier,
                ['@type'] = 'sale',
                ['@amount'] = finalPayout,
                ['@method'] = 'bank',
                ['@desc'] = 'Property sold'
            })
            
            -- Log action
            LogAction(propertyId, identifier, 'sell', 'Sold property for $' .. finalPayout)
            
            -- Send notification
            SendNotification(source, 'success', _('success'), 'Property sold for $' .. finalPayout, propertyId)
            
            -- Update all clients
            TriggerClientEvent('property:updateProperty', -1, propertyId, {
                owner = nil,
                tenant = nil,
                status = 'available',
                for_sale = 1
            })
        end)
    end)
end)

-- ====================================================================================================
-- 🏠 RENT PROPERTY
-- ====================================================================================================

RegisterNetEvent('property:rent')
AddEventHandler('property:rent', function(propertyId, duration, paymentMethod)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    if not Config.Payment.rent.enabled then
        SendNotification(source, 'error', _('error'), 'Renting is not enabled')
        return
    end
    
    -- Get property
    MySQL.Async.fetchAll('SELECT * FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if not result[1] then
            SendNotification(source, 'error', _('error'), _('property_not_found'))
            return
        end
        
        local property = result[1]
        
        -- Check if property can be rented
        if property.status ~= 'available' or property.for_rent == 0 then
            SendNotification(source, 'error', _('error'), 'Property not available for rent')
            return
        end
        
        -- Calculate rent
        local rentPrice = property.rent_price or math.floor(property.price * Config.Payment.rent.monthlyRate / 30 * duration)
        
        -- Check money
        if GetPlayerMoney(source, paymentMethod) < rentPrice then
            SendNotification(source, 'error', _('error'), _('insufficient_funds'))
            return
        end
        
        -- Remove money
        if not RemovePlayerMoney(source, paymentMethod, rentPrice) then
            SendNotification(source, 'error', _('error'), _('payment_failed'))
            return
        end
        
        -- Update property
        MySQL.Async.execute('UPDATE properties SET tenant = @tenant, status = @status WHERE id = @id', {
            ['@tenant'] = identifier,
            ['@status'] = 'rented',
            ['@id'] = propertyId
        })
        
        -- Create tenant record
        MySQL.Async.execute([[
            INSERT INTO property_tenants (
                property_id, tenant_id, rent_amount, payment_interval,
                next_payment, lease_start, lease_end
            ) VALUES (
                @property, @tenant, @rent, @interval,
                DATE_ADD(NOW(), INTERVAL @interval DAY),
                NOW(),
                DATE_ADD(NOW(), INTERVAL @duration DAY)
            )
        ]], {
            ['@property'] = propertyId,
            ['@tenant'] = identifier,
            ['@rent'] = rentPrice,
            ['@interval'] = Config.Payment.rent.paymentInterval,
            ['@duration'] = duration
        })
        
        -- Give keys
        GivePropertyKey(propertyId, identifier, 'tenant', identifier)
        
        -- Create transaction
        MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
            ['@property'] = propertyId,
            ['@player'] = identifier,
            ['@type'] = 'rent',
            ['@amount'] = rentPrice,
            ['@method'] = paymentMethod,
            ['@desc'] = 'Rent payment for ' .. duration .. ' days'
        })
        
        -- Log action
        LogAction(propertyId, identifier, 'rent', 'Rented property for ' .. duration .. ' days')
        
        -- Send notification
        SendNotification(source, 'success', _('success'), _('rental_booked'), propertyId)
        
        -- Update clients
        TriggerClientEvent('property:updateProperty', -1, propertyId, {
            tenant = identifier,
            status = 'rented'
        })
    end)
end)

-- ====================================================================================================
-- 🚪 LOCK/UNLOCK PROPERTY
-- ====================================================================================================

RegisterNetEvent('property:toggleLock')
AddEventHandler('property:toggleLock', function(propertyId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    -- Check if player has permission
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder AND can_lock = 1', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    }, function(keys)
        if #keys == 0 then
            SendNotification(source, 'error', _('error'), _('no_permission'))
            return
        end
        
        -- Toggle lock
        MySQL.Async.fetchAll('SELECT locked FROM properties WHERE id = @id', {
            ['@id'] = propertyId
        }, function(result)
            if result[1] then
                local newLockState = result[1].locked == 1 and 0 or 1
                
                MySQL.Async.execute('UPDATE properties SET locked = @locked WHERE id = @id', {
                    ['@locked'] = newLockState,
                    ['@id'] = propertyId
                })
                
                -- Log action
                LogAction(propertyId, identifier, newLockState == 1 and 'lock' or 'unlock', 'Door lock toggled')
                
                -- Notify
                SendNotification(source, 'success', _('success'), newLockState == 1 and 'Property locked' or 'Property unlocked')
                
                -- Update clients nearby
                TriggerClientEvent('property:updateLock', -1, propertyId, newLockState == 1)
            end
        end)
    end)
end)

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('GetPropertyData', function(propertyId)
    return MySQL.Sync.fetchAll('SELECT * FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    })[1]
end)

exports('IsPropertyOwner', function(identifier, propertyId)
    local result = MySQL.Sync.fetchAll('SELECT owner FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    })
    return result[1] and result[1].owner == identifier
end)

exports('HasPropertyAccess', function(identifier, propertyId)
    local result = MySQL.Sync.fetchAll('SELECT COUNT(*) as count FROM property_keys WHERE property_id = @property AND holder = @holder', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    })
    return result[1] and result[1].count > 0
end)

exports('GetPlayerProperties', function(identifier)
    return MySQL.Sync.fetchAll('SELECT * FROM properties WHERE owner = @owner OR tenant = @tenant', {
        ['@owner'] = identifier,
        ['@tenant'] = identifier
    })
end)
