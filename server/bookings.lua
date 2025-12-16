-- ====================================================================================================
-- 📅 BOOKING SYSTEM (AIRBNB-STYLE)
-- Viewing, Short-term rental, Purchase bookings
-- ====================================================================================================

-- ====================================================================================================
-- 👁️ BOOK VIEWING
-- ====================================================================================================

RegisterNetEvent('property:bookViewing')
AddEventHandler('property:bookViewing', function(propertyId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    if not Config.Booking.enabled or not Config.Booking.viewing.enabled then
        SendNotification(source, 'error', _('error'), 'Viewings are not enabled')
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
        
        if property.status ~= 'available' then
            SendNotification(source, 'error', _('error'), _('property_not_available'))
            return
        end
        
        -- Check if player has money for deposit
        if Config.Booking.viewing.requireDeposit then
            if GetPlayerMoney(source, 'bank') < Config.Booking.viewing.depositAmount then
                SendNotification(source, 'error', _('error'), _('insufficient_funds'))
                return
            end
            
            -- Remove deposit
            if not RemovePlayerMoney(source, 'bank', Config.Booking.viewing.depositAmount) then
                SendNotification(source, 'error', _('error'), _('payment_failed'))
                return
            end
        end
        
        -- Generate access code
        local accessCode = GenerateCode(Config.Booking.viewing.codeLength)
        local duration = Config.Booking.viewing.duration
        
        -- Create booking
        MySQL.Async.insert([[
            INSERT INTO property_bookings (
                property_id, player_id, booking_type, access_code,
                duration_minutes, amount_paid, end_time
            ) VALUES (
                @property, @player, @type, @code,
                @duration, @amount, DATE_ADD(NOW(), INTERVAL @duration MINUTE)
            )
        ]], {
            ['@property'] = propertyId,
            ['@player'] = identifier,
            ['@type'] = 'viewing',
            ['@code'] = accessCode,
            ['@duration'] = duration,
            ['@amount'] = Config.Booking.viewing.requireDeposit and Config.Booking.viewing.depositAmount or 0
        }, function(bookingId)
            -- Create short-term key
            CreateShortTermKey(propertyId, identifier, 'viewing', duration, bookingId)
            
            -- Update property status
            MySQL.Async.execute('UPDATE properties SET status = @status WHERE id = @id', {
                ['@status'] = 'viewing',
                ['@id'] = propertyId
            })
            
            -- Create transaction if deposit was paid
            if Config.Booking.viewing.requireDeposit then
                MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
                    ['@property'] = propertyId,
                    ['@player'] = identifier,
                    ['@type'] = 'deposit',
                    ['@amount'] = Config.Booking.viewing.depositAmount,
                    ['@method'] = 'bank',
                    ['@desc'] = 'Viewing deposit'
                })
            end
            
            -- Log action
            LogAction(propertyId, identifier, 'book_viewing', 'Booked viewing with code: ' .. accessCode)
            
            -- Send notification with access code
            SendNotification(source, 'success', _('success'), _('viewing_booked') .. '\nAccess Code: ' .. accessCode .. '\nDuration: ' .. duration .. ' minutes', propertyId)
            
            -- Set GPS to property
            TriggerClientEvent('property:setGPS', source, property.entrance_x, property.entrance_y, property.entrance_z)
            
            -- Update clients
            TriggerClientEvent('property:updateProperty', -1, propertyId, {status = 'viewing'})
            
            -- Send booking data to client
            TriggerClientEvent('property:bookingCreated', source, {
                id = bookingId,
                propertyId = propertyId,
                type = 'viewing',
                accessCode = accessCode,
                duration = duration,
                expiresAt = os.time() + (duration * 60)
            })
        end)
    end)
end)

-- ====================================================================================================
-- 🏠 BOOK SHORT-TERM RENTAL
-- ====================================================================================================

RegisterNetEvent('property:bookRental')
AddEventHandler('property:bookRental', function(propertyId, days)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    if not Config.Booking.enabled or not Config.Booking.shortTermRental.enabled then
        SendNotification(source, 'error', _('error'), 'Short-term rentals are not enabled')
        return
    end
    
    -- Validate duration
    if days < Config.Booking.shortTermRental.minDuration or days > Config.Booking.shortTermRental.maxDuration then
        SendNotification(source, 'error', _('error'), 'Invalid rental duration')
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
        
        if property.status ~= 'available' then
            SendNotification(source, 'error', _('error'), _('property_not_available'))
            return
        end
        
        -- Calculate rental price
        local dailyRate = property.price * Config.Booking.shortTermRental.discountRate / 30
        local totalPrice = math.floor(dailyRate * days)
        local depositAmount = Config.Booking.shortTermRental.requireDeposit and Config.Booking.shortTermRental.depositAmount or 0
        local totalCost = totalPrice + depositAmount
        
        -- Check money
        if GetPlayerMoney(source, 'bank') < totalCost then
            SendNotification(source, 'error', _('error'), _('insufficient_funds'))
            return
        end
        
        -- Remove money
        if not RemovePlayerMoney(source, 'bank', totalCost) then
            SendNotification(source, 'error', _('error'), _('payment_failed'))
            return
        end
        
        -- Generate access code
        local accessCode = GenerateCode(Config.Booking.shortTermRental.codeLength)
        local durationMinutes = days * 24 * 60
        
        -- Create booking
        MySQL.Async.insert([[
            INSERT INTO property_bookings (
                property_id, player_id, booking_type, access_code,
                duration_minutes, amount_paid, end_time
            ) VALUES (
                @property, @player, @type, @code,
                @duration, @amount, DATE_ADD(NOW(), INTERVAL @days DAY)
            )
        ]], {
            ['@property'] = propertyId,
            ['@player'] = identifier,
            ['@type'] = 'rental',
            ['@code'] = accessCode,
            ['@duration'] = durationMinutes,
            ['@amount'] = totalCost,
            ['@days'] = days
        }, function(bookingId)
            -- Create short-term key
            CreateShortTermKey(propertyId, identifier, 'rental', durationMinutes, bookingId)
            
            -- Update property status
            MySQL.Async.execute('UPDATE properties SET status = @status, tenant = @tenant WHERE id = @id', {
                ['@status'] = 'rented',
                ['@tenant'] = identifier,
                ['@id'] = propertyId
            })
            
            -- Create transaction
            MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
                ['@property'] = propertyId,
                ['@player'] = identifier,
                ['@type'] = 'rent',
                ['@amount'] = totalPrice,
                ['@method'] = 'bank',
                ['@desc'] = 'Short-term rental for ' .. days .. ' days'
            })
            
            if Config.Booking.shortTermRental.requireDeposit then
                MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
                    ['@property'] = propertyId,
                    ['@player'] = identifier,
                    ['@type'] = 'deposit',
                    ['@amount'] = depositAmount,
                    ['@method'] = 'bank',
                    ['@desc'] = 'Rental deposit'
                })
            end
            
            -- Log action
            LogAction(propertyId, identifier, 'book_rental', 'Booked rental for ' .. days .. ' days with code: ' .. accessCode)
            
            -- Send notification
            SendNotification(source, 'success', _('success'), _('rental_booked') .. '\nAccess Code: ' .. accessCode .. '\nDuration: ' .. days .. ' days', propertyId)
            
            -- Set GPS
            TriggerClientEvent('property:setGPS', source, property.entrance_x, property.entrance_y, property.entrance_z)
            
            -- Update clients
            TriggerClientEvent('property:updateProperty', -1, propertyId, {status = 'rented', tenant = identifier})
            
            -- Send booking data to client
            TriggerClientEvent('property:bookingCreated', source, {
                id = bookingId,
                propertyId = propertyId,
                type = 'rental',
                accessCode = accessCode,
                duration = days,
                expiresAt = os.time() + (days * 24 * 60 * 60)
            })
        end)
    end)
end)

-- ====================================================================================================
-- 🏠 GET PLAYER BOOKINGS
-- ====================================================================================================

RegisterNetEvent('property:getMyBookings')
AddEventHandler('property:getMyBookings', function()
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    MySQL.Async.fetchAll([[
        SELECT b.*, p.name, p.area, p.entrance_x, p.entrance_y, p.entrance_z
        FROM property_bookings b
        JOIN properties p ON b.property_id = p.id
        WHERE b.player_id = @player AND b.status = @status
        ORDER BY b.created_at DESC
    ]], {
        ['@player'] = identifier,
        ['@status'] = 'active'
    }, function(bookings)
        TriggerClientEvent('property:receiveMyBookings', source, bookings)
    end)
end)

-- ====================================================================================================
-- ❌ CANCEL BOOKING
-- ====================================================================================================

RegisterNetEvent('property:cancelBooking')
AddEventHandler('property:cancelBooking', function(bookingId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    -- Get booking
    MySQL.Async.fetchAll('SELECT * FROM property_bookings WHERE id = @id AND player_id = @player', {
        ['@id'] = bookingId,
        ['@player'] = identifier
    }, function(result)
        if not result[1] then
            SendNotification(source, 'error', _('error'), 'Booking not found')
            return
        end
        
        local booking = result[1]
        
        -- Update booking status
        MySQL.Async.execute('UPDATE property_bookings SET status = @status WHERE id = @id', {
            ['@status'] = 'cancelled',
            ['@id'] = bookingId
        })
        
        -- Update property status
        MySQL.Async.execute('UPDATE properties SET status = @status, tenant = NULL WHERE id = @id', {
            ['@status'] = 'available',
            ['@id'] = booking.property_id
        })
        
        -- Refund if applicable
        if booking.booking_type == 'viewing' and Config.Booking.viewing.requireDeposit and Config.Booking.viewing.autoRefund then
            AddPlayerMoney(source, 'bank', booking.amount_paid)
            
            MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
                ['@property'] = booking.property_id,
                ['@player'] = identifier,
                ['@type'] = 'refund',
                ['@amount'] = booking.amount_paid,
                ['@method'] = 'bank',
                ['@desc'] = 'Booking cancellation refund'
            })
        elseif booking.booking_type == 'rental' and Config.Booking.shortTermRental.requireDeposit and Config.Booking.shortTermRental.autoRefund then
            AddPlayerMoney(source, 'bank', Config.Booking.shortTermRental.depositAmount)
            
            MySQL.Async.execute('INSERT INTO property_transactions (property_id, player_id, transaction_type, amount, payment_method, description) VALUES (@property, @player, @type, @amount, @method, @desc)', {
                ['@property'] = booking.property_id,
                ['@player'] = identifier,
                ['@type'] = 'refund',
                ['@amount'] = Config.Booking.shortTermRental.depositAmount,
                ['@method'] = 'bank',
                ['@desc'] = 'Deposit refund'
            })
        end
        
        -- Revoke short-term keys
        MySQL.Async.execute('DELETE FROM shortterm_keys WHERE booking_id = @booking', {
            ['@booking'] = bookingId
        })
        
        -- Log action
        LogAction(booking.property_id, identifier, 'cancel_booking', 'Cancelled ' .. booking.booking_type .. ' booking')
        
        -- Send notification
        SendNotification(source, 'success', _('success'), 'Booking cancelled')
        
        -- Update clients
        TriggerClientEvent('property:updateProperty', -1, booking.property_id, {status = 'available', tenant = nil})
    end)
end)

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('GetBooking', function(bookingId)
    return MySQL.Sync.fetchAll('SELECT * FROM property_bookings WHERE id = @id', {
        ['@id'] = bookingId
    })[1]
end)

exports('GetActiveBookings', function(propertyId)
    return MySQL.Sync.fetchAll('SELECT * FROM property_bookings WHERE property_id = @property AND status = @status', {
        ['@property'] = propertyId,
        ['@status'] = 'active'
    })
end)
