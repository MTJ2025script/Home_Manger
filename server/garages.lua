-- ====================================================================================================
-- 🚗 GARAGE BACKEND SYSTEM
-- Vehicle storage, retrieval, state management
-- ====================================================================================================

-- ====================================================================================================
-- 🏗️ CREATE GARAGE FOR PROPERTY
-- ====================================================================================================

function CreateGarageForProperty(propertyId, garageType)
    if not Config.Garages.enabled then return false end
    
    local garageConfig = Config.Garages.types[garageType] or Config.Garages.types.small
    
    MySQL.Async.execute([[
        INSERT INTO property_garages (
            property_id, garage_type, max_vehicles, interior,
            spawn_x, spawn_y, spawn_z, spawn_h,
            entry_x, entry_y, entry_z, entry_h
        ) VALUES (
            @property, @type, @max, @interior,
            @spawn_x, @spawn_y, @spawn_z, @spawn_h,
            @entry_x, @entry_y, @entry_z, @entry_h
        ) ON DUPLICATE KEY UPDATE
            garage_type = @type,
            max_vehicles = @max,
            interior = @interior
    ]], {
        ['@property'] = propertyId,
        ['@type'] = garageType,
        ['@max'] = garageConfig.slots,
        ['@interior'] = garageConfig.interior,
        ['@spawn_x'] = garageConfig.spawn.x,
        ['@spawn_y'] = garageConfig.spawn.y,
        ['@spawn_z'] = garageConfig.spawn.z,
        ['@spawn_h'] = garageConfig.spawn.w,
        ['@entry_x'] = garageConfig.entry.x,
        ['@entry_y'] = garageConfig.entry.y,
        ['@entry_z'] = garageConfig.entry.z,
        ['@entry_h'] = garageConfig.entry.w
    })
    
    return true
end

-- ====================================================================================================
-- 🚗 STORE VEHICLE
-- ====================================================================================================

RegisterNetEvent('property:storeVehicle')
AddEventHandler('property:storeVehicle', function(propertyId, vehicleData)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    if not Config.Garages.enabled then
        SendNotification(source, 'error', _('error'), 'Garage system is not enabled')
        return
    end
    
    -- Check if player has garage access
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder AND can_access_garage = 1', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    }, function(keys)
        if #keys == 0 then
            SendNotification(source, 'error', _('error'), _('no_permission'))
            return
        end
        
        -- Get garage data
        MySQL.Async.fetchAll('SELECT * FROM property_garages WHERE property_id = @property', {
            ['@property'] = propertyId
        }, function(garages)
            if not garages[1] then
                SendNotification(source, 'error', _('error'), 'No garage found')
                return
            end
            
            local garage = garages[1]
            
            -- Check if garage is full
            MySQL.Async.fetchAll('SELECT COUNT(*) as count FROM garage_vehicles WHERE garage_id = @garage AND stored = 1', {
                ['@garage'] = garage.id
            }, function(countResult)
                if countResult[1].count >= garage.max_vehicles then
                    SendNotification(source, 'error', _('error'), _('garage_full'))
                    return
                end
                
                -- Check if vehicle is already stored
                MySQL.Async.fetchAll('SELECT * FROM garage_vehicles WHERE vehicle_plate = @plate AND property_id = @property', {
                    ['@plate'] = vehicleData.plate,
                    ['@property'] = propertyId
                }, function(existing)
                    if #existing > 0 and existing[1].stored == 1 then
                        SendNotification(source, 'error', _('error'), _('vehicle_already_stored'))
                        return
                    end
                    
                    -- Store or update vehicle
                    if #existing > 0 then
                        MySQL.Async.execute('UPDATE garage_vehicles SET stored = 1, stored_at = NOW(), vehicle_data = @data WHERE id = @id', {
                            ['@data'] = json.encode(vehicleData),
                            ['@id'] = existing[1].id
                        })
                    else
                        MySQL.Async.execute([[
                            INSERT INTO garage_vehicles (
                                garage_id, property_id, owner, vehicle_plate, vehicle_model, vehicle_data
                            ) VALUES (
                                @garage, @property, @owner, @plate, @model, @data
                            )
                        ]], {
                            ['@garage'] = garage.id,
                            ['@property'] = propertyId,
                            ['@owner'] = identifier,
                            ['@plate'] = vehicleData.plate,
                            ['@model'] = vehicleData.model,
                            ['@data'] = json.encode(vehicleData)
                        })
                    end
                    
                    -- Log action
                    LogAction(propertyId, identifier, 'store_vehicle', 'Stored vehicle: ' .. vehicleData.plate)
                    
                    -- Notify player
                    SendNotification(source, 'success', _('success'), _('vehicle_stored'))
                    
                    -- Trigger client to delete vehicle
                    TriggerClientEvent('property:deleteVehicle', source, vehicleData.netId)
                end)
            end)
        end)
    end)
end)

-- ====================================================================================================
-- 🚗 RETRIEVE VEHICLE
-- ====================================================================================================

RegisterNetEvent('property:retrieveVehicle')
AddEventHandler('property:retrieveVehicle', function(propertyId, vehicleId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    -- Check if player has garage access
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder AND can_access_garage = 1', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    }, function(keys)
        if #keys == 0 then
            SendNotification(source, 'error', _('error'), _('no_permission'))
            return
        end
        
        -- Get vehicle data
        MySQL.Async.fetchAll('SELECT * FROM garage_vehicles WHERE id = @id AND property_id = @property AND stored = 1', {
            ['@id'] = vehicleId,
            ['@property'] = propertyId
        }, function(vehicles)
            if not vehicles[1] then
                SendNotification(source, 'error', _('error'), 'Vehicle not found')
                return
            end
            
            local vehicle = vehicles[1]
            local vehicleData = json.decode(vehicle.vehicle_data)
            
            -- Mark as retrieved
            MySQL.Async.execute('UPDATE garage_vehicles SET stored = 0, retrieved_at = NOW() WHERE id = @id', {
                ['@id'] = vehicleId
            })
            
            -- Log action
            LogAction(propertyId, identifier, 'retrieve_vehicle', 'Retrieved vehicle: ' .. vehicle.vehicle_plate)
            
            -- Notify player
            SendNotification(source, 'success', _('success'), _('vehicle_retrieved'))
            
            -- Trigger client to spawn vehicle
            TriggerClientEvent('property:spawnVehicle', source, propertyId, vehicleData)
        end)
    end)
end)

-- ====================================================================================================
-- 📋 GET GARAGE VEHICLES
-- ====================================================================================================

RegisterNetEvent('property:getGarageVehicles')
AddEventHandler('property:getGarageVehicles', function(propertyId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    -- Check if player has garage access
    MySQL.Async.fetchAll('SELECT * FROM property_keys WHERE property_id = @property AND holder = @holder AND can_access_garage = 1', {
        ['@property'] = propertyId,
        ['@holder'] = identifier
    }, function(keys)
        if #keys == 0 then
            SendNotification(source, 'error', _('error'), _('no_permission'))
            TriggerClientEvent('property:receiveGarageVehicles', source, propertyId, {})
            return
        end
        
        -- Get vehicles
        MySQL.Async.fetchAll('SELECT * FROM garage_vehicles WHERE property_id = @property AND stored = 1', {
            ['@property'] = propertyId
        }, function(vehicles)
            TriggerClientEvent('property:receiveGarageVehicles', source, propertyId, vehicles)
        end)
    end)
end)

-- ====================================================================================================
-- 🗑️ REMOVE VEHICLE FROM GARAGE
-- ====================================================================================================

RegisterNetEvent('property:removeVehicle')
AddEventHandler('property:removeVehicle', function(propertyId, vehicleId)
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
        
        -- Delete vehicle
        MySQL.Async.execute('DELETE FROM garage_vehicles WHERE id = @id AND property_id = @property', {
            ['@id'] = vehicleId,
            ['@property'] = propertyId
        }, function(affectedRows)
            if affectedRows > 0 then
                LogAction(propertyId, identifier, 'remove_vehicle', 'Removed vehicle from garage')
                SendNotification(source, 'success', _('success'), 'Vehicle removed from garage')
            else
                SendNotification(source, 'error', _('error'), 'Vehicle not found')
            end
        end)
    end)
end)

-- ====================================================================================================
-- 🏢 GET GARAGE INFO
-- ====================================================================================================

RegisterNetEvent('property:getGarageInfo')
AddEventHandler('property:getGarageInfo', function(propertyId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then return end
    
    MySQL.Async.fetchAll([[
        SELECT g.*, COUNT(v.id) as vehicle_count
        FROM property_garages g
        LEFT JOIN garage_vehicles v ON g.id = v.garage_id AND v.stored = 1
        WHERE g.property_id = @property
        GROUP BY g.id
    ]], {
        ['@property'] = propertyId
    }, function(result)
        if result[1] then
            TriggerClientEvent('property:receiveGarageInfo', source, propertyId, result[1])
        else
            TriggerClientEvent('property:receiveGarageInfo', source, propertyId, nil)
        end
    end)
end)

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('CreateGarageForProperty', CreateGarageForProperty)

exports('GetGarageVehicles', function(propertyId)
    return MySQL.Sync.fetchAll('SELECT * FROM garage_vehicles WHERE property_id = @property AND stored = 1', {
        ['@property'] = propertyId
    })
end)

exports('GetGarageInfo', function(propertyId)
    return MySQL.Sync.fetchAll('SELECT * FROM property_garages WHERE property_id = @property', {
        ['@property'] = propertyId
    })[1]
end)
