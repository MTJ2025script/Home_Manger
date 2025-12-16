-- ====================================================================================================
-- 🔑 KEY MANAGEMENT SYSTEM
-- Physical keys, permissions, short-term access
-- ====================================================================================================

-- ====================================================================================================
-- 🔑 GIVE PROPERTY KEY
-- ====================================================================================================

function GivePropertyKey(propertyId, holder, permissionLevel, givenBy)
    if not Config.Keys.enabled then return false end
    
    -- Get permission template
    local permissions = Config.Keys.permissions[permissionLevel] or Config.Keys.permissions.guest
    
    -- Check if key already exists
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder', {
        ['@property'] = propertyId,
        ['@holder'] = holder
    }, function(existing)
        if #existing > 0 then
            -- Update existing key
            MySQL.Async.execute([[
                UPDATE property_keys 
                SET permission_level = @permission,
                    can_enter = @enter,
                    can_lock = @lock,
                    can_invite = @invite,
                    can_manage_keys = @manage,
                    can_access_storage = @storage,
                    can_access_garage = @garage,
                    can_sell = @sell,
                    can_rent = @rent,
                    given_by = @given_by
                WHERE property_id = @property AND holder = @holder
            ]], {
                ['@permission'] = permissionLevel,
                ['@enter'] = permissions.canEnter and 1 or 0,
                ['@lock'] = permissions.canLock and 1 or 0,
                ['@invite'] = permissions.canInvite and 1 or 0,
                ['@manage'] = permissions.canManageKeys and 1 or 0,
                ['@storage'] = permissions.canAccessStorage and 1 or 0,
                ['@garage'] = permissions.canAccessGarage and 1 or 0,
                ['@sell'] = permissions.canSell and 1 or 0,
                ['@rent'] = permissions.canRent and 1 or 0,
                ['@given_by'] = givenBy,
                ['@property'] = propertyId,
                ['@holder'] = holder
            })
        else
            -- Create new key
            MySQL.Async.execute([[
                INSERT INTO property_keys (
                    property_id, holder, permission_level,
                    can_enter, can_lock, can_invite, can_manage_keys,
                    can_access_storage, can_access_garage, can_sell, can_rent, given_by
                ) VALUES (
                    @property, @holder, @permission,
                    @enter, @lock, @invite, @manage,
                    @storage, @garage, @sell, @rent, @given_by
                )
            ]], {
                ['@property'] = propertyId,
                ['@holder'] = holder,
                ['@permission'] = permissionLevel,
                ['@enter'] = permissions.canEnter and 1 or 0,
                ['@lock'] = permissions.canLock and 1 or 0,
                ['@invite'] = permissions.canInvite and 1 or 0,
                ['@manage'] = permissions.canManageKeys and 1 or 0,
                ['@storage'] = permissions.canAccessStorage and 1 or 0,
                ['@garage'] = permissions.canAccessGarage and 1 or 0,
                ['@sell'] = permissions.canSell and 1 or 0,
                ['@rent'] = permissions.canRent and 1 or 0,
                ['@given_by'] = givenBy
            })
        end
        
        -- Give physical key item if enabled
        if Config.Keys.usePhysicalKeys then
            -- Note: Requires inventory integration (ox_inventory, qb-inventory, etc.)
            -- Uncomment and adapt to your inventory system:
            -- exports['ox_inventory']:AddItem(holder, Config.Keys.keyItem, 1, {property_id = propertyId, permission = permissionLevel})
        end
    end)
    
    return true
end

-- ====================================================================================================
-- 🔑 REMOVE PROPERTY KEY
-- ====================================================================================================

function RemovePropertyKey(propertyId, holder)
    if not Config.Keys.enabled then return false end
    
    MySQL.Async.execute('DELETE FROM property_keys WHERE property_id = @property AND holder = @holder', {
        ['@property'] = propertyId,
        ['@holder'] = holder
    })
    
    -- Remove physical key item if enabled
    if Config.Keys.usePhysicalKeys then
        -- Note: Requires inventory integration (ox_inventory, qb-inventory, etc.)
        -- Uncomment and adapt to your inventory system:
        -- exports['ox_inventory']:RemoveItem(holder, Config.Keys.keyItem, 1, {property_id = propertyId})
    end
    
    return true
end

-- ====================================================================================================
-- 🎫 SHORT-TERM KEYS (VIEWING/RENTAL)
-- ====================================================================================================

function CreateShortTermKey(propertyId, holder, keyType, durationMinutes, bookingId)
    if not Config.Keys.shortTermKeys.enabled then return nil end
    
    local accessCode = GenerateCode(Config.Keys.shortTermKeys.codeLength)
    local expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (durationMinutes * 60))
    
    MySQL.Async.execute([[
        INSERT INTO shortterm_keys (
            property_id, booking_id, holder, access_code, key_type, expires_at
        ) VALUES (
            @property, @booking, @holder, @code, @type, @expires
        )
    ]], {
        ['@property'] = propertyId,
        ['@booking'] = bookingId,
        ['@holder'] = holder,
        ['@code'] = accessCode,
        ['@type'] = keyType,
        ['@expires'] = expiresAt
    })
    
    return accessCode
end

function ValidateShortTermKey(propertyId, accessCode)
    local result = MySQL.Sync.fetchAll([[
        SELECT * FROM shortterm_keys 
        WHERE property_id = @property 
        AND access_code = @code 
        AND expires_at > NOW()
        AND used = 0
    ]], {
        ['@property'] = propertyId,
        ['@code'] = accessCode
    })
    
    if result[1] then
        -- Mark as used
        MySQL.Async.execute('UPDATE shortterm_keys SET used = 1, used_at = NOW() WHERE id = @id', {
            ['@id'] = result[1].id
        })
        return true, result[1]
    end
    
    return false, nil
end

-- ====================================================================================================
-- 🔑 PLAYER KEY MANAGEMENT EVENTS
-- ====================================================================================================

-- Give keys to another player
RegisterNetEvent('property:giveKeys')
AddEventHandler('property:giveKeys', function(propertyId, targetPlayerId, permissionLevel)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    local targetIdentifier = GetPlayerIdentifier(targetPlayerId)
    
    if not identifier or not targetIdentifier then
        SendNotification(source, 'error', _('error'), _('player_not_found'))
        return
    end
    
    -- Check if source has permission to give keys
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder AND can_manage_keys = 1', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    }, function(keys)
        if #keys == 0 then
            SendNotification(source, 'error', _('error'), _('no_permission'))
            return
        end
        
        -- Give key
        GivePropertyKey(propertyId, targetIdentifier, permissionLevel or 'guest', identifier)
        
        -- Log action
        LogAction(propertyId, identifier, 'give_keys', 'Gave ' .. permissionLevel .. ' keys to ' .. targetIdentifier)
        
        -- Notify both players
        SendNotification(source, 'success', _('success'), _('keys') .. ' given to player')
        SendNotification(targetPlayerId, 'success', _('success'), _('key_received'), propertyId)
    end)
end)

-- Remove keys from player
RegisterNetEvent('property:removeKeys')
AddEventHandler('property:removeKeys', function(propertyId, targetPlayerId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    local targetIdentifier = GetPlayerIdentifier(targetPlayerId)
    
    if not identifier or not targetIdentifier then
        SendNotification(source, 'error', _('error'), _('player_not_found'))
        return
    end
    
    -- Check if source has permission to remove keys
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder AND can_manage_keys = 1', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    }, function(keys)
        if #keys == 0 then
            SendNotification(source, 'error', _('error'), _('no_permission'))
            return
        end
        
        -- Remove key
        RemovePropertyKey(propertyId, targetIdentifier)
        
        -- Log action
        LogAction(propertyId, identifier, 'remove_keys', 'Removed keys from ' .. targetIdentifier)
        
        -- Notify both players
        SendNotification(source, 'success', _('success'), _('keys') .. ' removed from player')
        SendNotification(targetPlayerId, 'warning', _('warning'), _('key_removed'), propertyId)
    end)
end)

-- Duplicate keys
RegisterNetEvent('property:duplicateKeys')
AddEventHandler('property:duplicateKeys', function(propertyId, paymentMethod)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    if not Config.Keys.duplication.enabled then
        SendNotification(source, 'error', _('error'), 'Key duplication is not enabled')
        return
    end
    
    -- Check if player has keys
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    }, function(keys)
        if #keys == 0 then
            SendNotification(source, 'error', _('error'), _('no_keys'))
            return
        end
        
        -- Check money
        if GetPlayerMoney(source, paymentMethod) < Config.Keys.duplication.cost then
            SendNotification(source, 'error', _('error'), _('insufficient_funds'))
            return
        end
        
        -- Remove money
        if not RemovePlayerMoney(source, paymentMethod, Config.Keys.duplication.cost) then
            SendNotification(source, 'error', _('error'), _('payment_failed'))
            return
        end
        
        -- Give duplicate key item
        if Config.Keys.usePhysicalKeys then
            -- Note: Requires inventory integration (ox_inventory, qb-inventory, etc.)
            -- Uncomment and adapt to your inventory system:
            -- local keyData = keys[1]
            -- exports['ox_inventory']:AddItem(identifier, Config.Keys.keyItem, 1, {property_id = propertyId, permission = keyData.permission_level})
        end
        
        -- Log action
        LogAction(propertyId, identifier, 'duplicate_keys', 'Duplicated keys for $' .. Config.Keys.duplication.cost)
        
        SendNotification(source, 'success', _('success'), 'Keys duplicated!')
    end)
end)

-- Get player keys
RegisterNetEvent('property:getMyKeys')
AddEventHandler('property:getMyKeys', function()
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    MySQL.Async.fetchAll([[
        SELECT pk.*, p.name, p.area, p.entrance_x, p.entrance_y, p.entrance_z
        FROM property_keys pk
        JOIN properties p ON pk.property_id = p.id
        WHERE pk.holder = @holder
    ]], {
        ['@holder'] = identifier
    }, function(keys)
        TriggerClientEvent('property:receiveMyKeys', source, keys)
    end)
end)

-- Check property access
RegisterNetEvent('property:checkAccess')
AddEventHandler('property:checkAccess', function(propertyId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('property:accessResult', source, propertyId, false)
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    }, function(keys)
        if #keys > 0 then
            TriggerClientEvent('property:accessResult', source, propertyId, true, keys[1])
        else
            TriggerClientEvent('property:accessResult', source, propertyId, false)
        end
    end)
end)

-- Validate access code (for short-term keys)
RegisterNetEvent('property:validateCode')
AddEventHandler('property:validateCode', function(propertyId, accessCode)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    local valid, keyData = ValidateShortTermKey(propertyId, accessCode)
    
    if valid then
        -- Grant temporary access
        SendNotification(source, 'success', _('success'), _('valid_code'))
        LogAction(propertyId, identifier, 'code_access', 'Used access code: ' .. accessCode)
        TriggerClientEvent('property:codeValidated', source, propertyId, keyData)
    else
        SendNotification(source, 'error', _('error'), _('invalid_code'))
        LogAction(propertyId, identifier, 'invalid_code', 'Invalid access code: ' .. accessCode)
        TriggerClientEvent('property:codeInvalid', source, propertyId)
    end
end)

-- Get key holders for a property (for owners)
RegisterNetEvent('property:getKeyHolders')
AddEventHandler('property:getKeyHolders', function(propertyId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    -- Check if player is owner
    MySQL.Async.fetchAll('SELECT owner FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if not result[1] or result[1].owner ~= identifier then
            SendNotification(source, 'error', _('error'), _('not_owner'))
            return
        end
        
        -- Get all key holders
        MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property', {
            ['@property'] = propertyId
        }, function(keys)
            TriggerClientEvent('property:receiveKeyHolders', source, propertyId, keys)
        end)
    end)
end)

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('GivePropertyKey', GivePropertyKey)
exports('RemovePropertyKey', RemovePropertyKey)
exports('CreateShortTermKey', CreateShortTermKey)
exports('ValidateShortTermKey', ValidateShortTermKey)

exports('AddPropertyKey', function(propertyId, identifier, permissionLevel)
    return GivePropertyKey(propertyId, identifier, permissionLevel, 'system')
end)
