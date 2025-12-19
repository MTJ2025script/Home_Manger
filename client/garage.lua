-- ====================================================================================================
-- 🚗 GARAGE CLIENT
-- Garage UI & Vehicle Management
-- ====================================================================================================

-- Placeholder for garage client-side logic
-- This file handles vehicle storage and retrieval on the client side

-- Open garage
RegisterNetEvent('property:openGarage')
AddEventHandler('property:openGarage', function(propertyId)
    -- Request garage vehicles from server
    TriggerServerEvent('property:getGarageVehicles', propertyId)
end)

-- Receive garage vehicles
RegisterNetEvent('property:receiveGarageVehicles')
AddEventHandler('property:receiveGarageVehicles', function(propertyId, vehicles)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openGarage',
        propertyId = propertyId,
        vehicles = vehicles
    })
end)

-- Store vehicle
RegisterNUICallback('storeVehicle', function(data, cb)
    local vehicle = GetVehicleInDirection()
    
    if vehicle then
        local vehicleData = GetVehicleProperties(vehicle)
        vehicleData.netId = NetworkGetNetworkIdFromEntity(vehicle)
        
        TriggerServerEvent('property:storeVehicle', data.propertyId, vehicleData)
    else
        Notify('error', _('error'), _('no_vehicle'))
    end
    
    cb('ok')
end)

-- Retrieve vehicle
RegisterNUICallback('retrieveVehicle', function(data, cb)
    TriggerServerEvent('property:retrieveVehicle', data.propertyId, data.vehicleId)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    -- Force camera and control freedom
    SetPlayerControl(PlayerId(), true, 0)
    DisplayRadar(true)
    RenderScriptCams(false, false, 0, true, true)
    cb('ok')
end)

-- Delete vehicle from client (after storing)
RegisterNetEvent('property:deleteVehicle')
AddEventHandler('property:deleteVehicle', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end)

-- Spawn vehicle (after retrieving)
RegisterNetEvent('property:spawnVehicle')
AddEventHandler('property:spawnVehicle', function(propertyId, vehicleData)
    -- TODO: Implement vehicle spawn logic
    -- This would spawn the vehicle near the player with saved properties
    Notify('success', _('success'), _('vehicle_retrieved'))
end)
