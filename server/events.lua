-- ====================================================================================================
-- 🎭 EVENT HANDLERS
-- Additional server events and callbacks
-- ====================================================================================================

-- ====================================================================================================
-- 🎮 PLAYER EVENTS
-- ====================================================================================================

-- Player loaded
AddEventHandler('playerConnecting', function()
    local source = source
    if Config.Debug then
        print('^3[Property Manager]^0 Player ' .. source .. ' connecting')
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local source = source
    local identifier = xPlayer.identifier
    
    if Config.Debug then
        print('^2[Property Manager]^0 Player loaded: ' .. identifier)
    end
    
    -- Send player their properties
    Wait(2000) -- Wait for client to be fully loaded
    TriggerEvent('property:getByOwner', source)
    TriggerEvent('property:getMyKeys', source)
end)

RegisterNetEvent('QBCore:Server:PlayerLoaded')
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local source = Player.PlayerData.source
    local identifier = Player.PlayerData.citizenid
    
    if Config.Debug then
        print('^2[Property Manager]^0 Player loaded: ' .. identifier)
    end
    
    -- Send player their properties
    Wait(2000)
    TriggerEvent('property:getByOwner', source)
    TriggerEvent('property:getMyKeys', source)
end)

-- Player dropped
AddEventHandler('playerDropped', function(reason)
    local source = source
    if Config.Debug then
        print('^3[Property Manager]^0 Player ' .. source .. ' disconnected: ' .. reason)
    end
end)

-- ====================================================================================================
-- 🔔 NOTIFICATION EVENTS
-- ====================================================================================================

-- Send notification to all online property owners
function NotifyPropertyOwners(message, notifType)
    MySQL.Async.fetchAll('SELECT DISTINCT owner FROM properties WHERE owner IS NOT NULL', {}, function(owners)
        local xPlayers = Framework == 'ESX' and ESX.GetPlayers() or QBCore.Functions.GetPlayers()
        
        for _, playerId in ipairs(xPlayers) do
            local playerIdentifier = GetPlayerIdentifier(playerId)
            
            for _, ownerData in ipairs(owners) do
                if playerIdentifier == ownerData.owner then
                    SendNotification(playerId, notifType or 'info', 'Property Manager', message)
                    break
                end
            end
        end
    end)
end

-- Send notification to specific property owner
function NotifyPropertyOwner(propertyId, message, notifType)
    MySQL.Async.fetchAll('SELECT owner FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if result[1] and result[1].owner then
            local xPlayers = Framework == 'ESX' and ESX.GetPlayers() or QBCore.Functions.GetPlayers()
            
            for _, playerId in ipairs(xPlayers) do
                local playerIdentifier = GetPlayerIdentifier(playerId)
                if playerIdentifier == result[1].owner then
                    SendNotification(playerId, notifType or 'info', 'Property Manager', message, propertyId)
                    break
                end
            end
        end
    end)
end

-- ====================================================================================================
-- 🔍 SEARCH & FILTER
-- ====================================================================================================

-- Search properties
RegisterNetEvent('property:search')
AddEventHandler('property:search', function(filters)
    local source = source
    
    local query = 'SELECT * FROM properties WHERE 1=1'
    local params = {}
    
    -- Apply filters
    if filters.type and filters.type ~= 'all' then
        query = query .. ' AND type = @type'
        params['@type'] = filters.type
    end
    
    if filters.area and filters.area ~= 'all' then
        query = query .. ' AND area = @area'
        params['@area'] = filters.area
    end
    
    if filters.status and filters.status ~= 'all' then
        query = query .. ' AND status = @status'
        params['@status'] = filters.status
    end
    
    if filters.minPrice then
        query = query .. ' AND price >= @minPrice'
        params['@minPrice'] = filters.minPrice
    end
    
    if filters.maxPrice then
        query = query .. ' AND price <= @maxPrice'
        params['@maxPrice'] = filters.maxPrice
    end
    
    if filters.minBedrooms then
        query = query .. ' AND bedrooms >= @minBedrooms'
        params['@minBedrooms'] = filters.minBedrooms
    end
    
    if filters.forSale then
        query = query .. ' AND for_sale = 1'
    end
    
    if filters.forRent then
        query = query .. ' AND for_rent = 1'
    end
    
    -- Sort
    if filters.sort then
        if filters.sort == 'price_asc' then
            query = query .. ' ORDER BY price ASC'
        elseif filters.sort == 'price_desc' then
            query = query .. ' ORDER BY price DESC'
        elseif filters.sort == 'bedrooms' then
            query = query .. ' ORDER BY bedrooms DESC'
        else
            query = query .. ' ORDER BY name ASC'
        end
    else
        query = query .. ' ORDER BY area, name'
    end
    
    -- Limit
    if filters.limit then
        query = query .. ' LIMIT ' .. tonumber(filters.limit)
    end
    
    MySQL.Async.fetchAll(query, params, function(properties)
        TriggerClientEvent('property:searchResults', source, properties)
    end)
end)

-- Get nearby properties
RegisterNetEvent('property:getNearby')
AddEventHandler('property:getNearby', function(coords, radius)
    local source = source
    
    MySQL.Async.fetchAll('SELECT * FROM properties', {}, function(properties)
        local nearbyProperties = {}
        
        for _, property in ipairs(properties) do
            local distance = #(vector3(coords.x, coords.y, coords.z) - vector3(property.entrance_x, property.entrance_y, property.entrance_z))
            
            if distance <= radius then
                property.distance = distance
                table.insert(nearbyProperties, property)
            end
        end
        
        -- Sort by distance
        table.sort(nearbyProperties, function(a, b)
            return a.distance < b.distance
        end)
        
        TriggerClientEvent('property:receiveNearby', source, nearbyProperties)
    end)
end)

-- ====================================================================================================
-- 📊 STATISTICS & REPORTS
-- ====================================================================================================

-- Get player statistics
RegisterNetEvent('property:getPlayerStats')
AddEventHandler('property:getPlayerStats', function()
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    MySQL.Async.fetchAll([[
        SELECT
            (SELECT COUNT(*) FROM properties WHERE owner = @id) as owned_properties,
            (SELECT COUNT(*) FROM properties WHERE tenant = @id) as rented_properties,
            (SELECT COUNT(*) FROM property_keys WHERE holder = @id) as total_keys,
            (SELECT COUNT(*) FROM garage_vehicles WHERE owner = @id AND stored = 1) as stored_vehicles,
            (SELECT SUM(remaining_amount) FROM property_mortgages WHERE owner_id = @id AND status = 'active') as total_mortgage_debt,
            (SELECT SUM(amount) FROM property_transactions WHERE player_id = @id AND transaction_type = 'purchase') as total_spent,
            (SELECT SUM(amount) FROM property_transactions WHERE player_id = @id AND transaction_type = 'sale') as total_earned
    ]], {
        ['@id'] = identifier
    }, function(result)
        TriggerClientEvent('property:receivePlayerStats', source, result[1])
    end)
end)

-- ====================================================================================================
-- 🔒 DOOR LOCK SYNC
-- ====================================================================================================

-- Sync door lock state to nearby players
RegisterNetEvent('property:syncDoorLock')
AddEventHandler('property:syncDoorLock', function(propertyId, locked)
    local source = source
    
    -- Get property coords
    MySQL.Async.fetchAll('SELECT entrance_x, entrance_y, entrance_z FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if result[1] then
            -- Trigger for all nearby players
            TriggerClientEvent('property:updateLock', -1, propertyId, locked)
        end
    end)
end)

-- ====================================================================================================
-- 📍 GPS & WAYPOINT
-- ====================================================================================================

-- Set GPS to property
RegisterNetEvent('property:setGPSToProperty')
AddEventHandler('property:setGPSToProperty', function(propertyId)
    local source = source
    
    MySQL.Async.fetchAll('SELECT entrance_x, entrance_y, entrance_z FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if result[1] then
            TriggerClientEvent('property:setGPS', source, result[1].entrance_x, result[1].entrance_y, result[1].entrance_z)
            SendNotification(source, 'success', _('success'), _('gps_set'))
        else
            SendNotification(source, 'error', _('error'), _('property_not_found'))
        end
    end)
end)

-- ====================================================================================================
-- 💾 STORAGE SYNC
-- ====================================================================================================

-- Open storage
RegisterNetEvent('property:openStorage')
AddEventHandler('property:openStorage', function(propertyId, storageType)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    -- Check permission
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder AND can_access_storage = 1', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    }, function(keys)
        if #keys == 0 then
            SendNotification(source, 'error', _('error'), _('no_permission'))
            return
        end
        
        -- Get or create storage
        MySQL.Async.fetchAll('SELECT * FROM property_storage WHERE property_id = @property AND storage_type = @type', {
            ['@property'] = propertyId,
            ['@type'] = storageType
        }, function(storage)
            if #storage > 0 then
                -- Check PIN if required
                if storage[1].pin_code and storage[1].pin_code ~= '' then
                    TriggerClientEvent('property:requestPIN', source, propertyId, storageType, storage[1])
                else
                    TriggerClientEvent('property:openStorageInventory', source, propertyId, storageType, storage[1])
                end
            else
                -- Create storage
                local storageConfig = Config.Storage.safes[storageType] or Config.Storage.stash
                
                MySQL.Async.insert([[
                    INSERT INTO property_storage (property_id, storage_type, storage_name, slots, max_weight)
                    VALUES (@property, @type, @name, @slots, @weight)
                ]], {
                    ['@property'] = propertyId,
                    ['@type'] = storageType,
                    ['@name'] = propertyId .. '_' .. storageType,
                    ['@slots'] = storageConfig.slots,
                    ['@weight'] = storageConfig.weight
                }, function(storageId)
                    MySQL.Async.fetchAll('SELECT * FROM property_storage WHERE id = @id', {
                        ['@id'] = storageId
                    }, function(newStorage)
                        TriggerClientEvent('property:openStorageInventory', source, propertyId, storageType, newStorage[1])
                    end)
                end)
            end
        end)
    end)
end)

-- Validate PIN
RegisterNetEvent('property:validatePIN')
AddEventHandler('property:validatePIN', function(propertyId, storageType, pin)
    local source = source
    
    MySQL.Async.fetchAll('SELECT * FROM property_storage WHERE property_id = @property AND storage_type = @type', {
        ['@property'] = propertyId,
        ['@type'] = storageType
    }, function(storage)
        if storage[1] and storage[1].pin_code == pin then
            TriggerClientEvent('property:openStorageInventory', source, propertyId, storageType, storage[1])
            SendNotification(source, 'success', _('success'), _('pin_correct'))
        else
            SendNotification(source, 'error', _('error'), _('pin_incorrect'))
        end
    end)
end)

-- Change PIN
RegisterNetEvent('property:changePIN')
AddEventHandler('property:changePIN', function(propertyId, storageType, newPin)
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
        
        -- Update PIN
        MySQL.Async.execute('UPDATE property_storage SET pin_code = @pin WHERE property_id = @property AND storage_type = @type', {
            ['@pin'] = newPin,
            ['@property'] = propertyId,
            ['@type'] = storageType
        }, function(affectedRows)
            if affectedRows > 0 then
                SendNotification(source, 'success', _('success'), _('pin_changed'))
                LogAction(propertyId, identifier, 'change_pin', 'Changed PIN for ' .. storageType)
            end
        end)
    end)
end)

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('NotifyPropertyOwners', NotifyPropertyOwners)
exports('NotifyPropertyOwner', NotifyPropertyOwner)
