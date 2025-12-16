-- ====================================================================================================
-- 🎮 PROPERTY MANAGER - MAIN CLIENT
-- Main client interactions, markers, blips
-- ====================================================================================================

local ESX = nil
local QBCore = nil
local PlayerData = {}
local properties = {}
local playerProperties = {}
local playerKeys = {}
local nearbyProperties = {}
local currentProperty = nil
local insideProperty = false

-- ====================================================================================================
-- 🚀 INITIALIZATION
-- ====================================================================================================

CreateThread(function()
    if Config.Framework == 'ESX' then
        ESX = exports['es_extended']:getSharedObject()
        
        while ESX.GetPlayerData().job == nil do
            Wait(100)
        end
        
        PlayerData = ESX.GetPlayerData()
    elseif Config.Framework == 'QBCore' then
        QBCore = exports['qb-core']:GetCoreObject()
        
        while QBCore.Functions.GetPlayerData().job == nil do
            Wait(100)
        end
        
        PlayerData = QBCore.Functions.GetPlayerData()
    end
    
    -- Request properties from server
    TriggerServerEvent('property:getAll')
    TriggerServerEvent('property:getByOwner')
    TriggerServerEvent('property:getMyKeys')
end)

-- ====================================================================================================
-- 📡 NETWORK EVENTS
-- ====================================================================================================

-- Receive all properties
RegisterNetEvent('property:receiveAll')
AddEventHandler('property:receiveAll', function(data)
    properties = data
    CreatePropertyBlips()
end)

-- Receive owned properties
RegisterNetEvent('property:receiveOwned')
AddEventHandler('property:receiveOwned', function(data)
    playerProperties = data
end)

-- Receive player keys
RegisterNetEvent('property:receiveMyKeys')
AddEventHandler('property:receiveMyKeys', function(data)
    playerKeys = data
end)

-- Update single property
RegisterNetEvent('property:updateProperty')
AddEventHandler('property:updateProperty', function(propertyId, updates)
    for i, prop in ipairs(properties) do
        if prop.id == propertyId then
            for k, v in pairs(updates) do
                properties[i][k] = v
            end
            break
        end
    end
    
    -- Update blip
    UpdatePropertyBlip(propertyId)
end)

-- Add new property
RegisterNetEvent('property:addProperty')
AddEventHandler('property:addProperty', function(propertyData)
    table.insert(properties, propertyData)
    CreatePropertyBlip(propertyData)
end)

-- Remove property
RegisterNetEvent('property:removeProperty')
AddEventHandler('property:removeProperty', function(propertyId)
    for i, prop in ipairs(properties) do
        if prop.id == propertyId then
            RemovePropertyBlip(propertyId)
            table.remove(properties, i)
            break
        end
    end
end)

-- ====================================================================================================
-- 🗺️ BLIPS & MARKERS
-- ====================================================================================================

local propertyBlips = {}

function CreatePropertyBlips()
    -- Remove existing blips
    for _, blip in pairs(propertyBlips) do
        RemoveBlip(blip)
    end
    propertyBlips = {}
    
    -- WICHTIG: Nur gebuchte/eigene Immobilien anzeigen!
    -- Verfügbare Häuser werden NICHT auf der Karte gezeigt (nur im Makler-Katalog)
    for _, property in ipairs(properties) do
        -- Nur Blips für gebuchte, vermietete oder eigene Immobilien
        if property.status == 'owned' or property.status == 'rented' or property.status == 'viewing' then
            CreatePropertyBlip(property)
        end
    end
end

function CreatePropertyBlip(property)
    -- Sicherheitscheck: Keine Blips für verfügbare Häuser!
    if property.status == 'available' then
        return
    end
    
    local blipConfig = Config.Properties.blips.available
    
    if property.status == 'owned' then
        blipConfig = Config.Properties.blips.owned
    elseif property.status == 'rented' then
        blipConfig = Config.Properties.blips.rented
    elseif property.status == 'viewing' then
        blipConfig = Config.Properties.blips.viewing
    end
    
    local blip = AddBlipForCoord(property.entrance_x, property.entrance_y, property.entrance_z)
    SetBlipSprite(blip, blipConfig.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipConfig.scale)
    SetBlipColour(blip, blipConfig.color)
    SetBlipAsShortRange(blip, blipConfig.shortRange)
    SetBlipAlpha(blip, blipConfig.alpha)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(property.name)
    EndTextCommandSetBlipName(blip)
    
    propertyBlips[property.id] = blip
end

function UpdatePropertyBlip(propertyId)
    for _, property in ipairs(properties) do
        if property.id == propertyId then
            RemovePropertyBlip(propertyId)
            CreatePropertyBlip(property)
            break
        end
    end
end

function RemovePropertyBlip(propertyId)
    if propertyBlips[propertyId] then
        RemoveBlip(propertyBlips[propertyId])
        propertyBlips[propertyId] = nil
    end
end

-- ====================================================================================================
-- 🚪 PROPERTY MARKERS & INTERACTIONS
-- ====================================================================================================

CreateThread(function()
    while true do
        local sleep = 500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        nearbyProperties = {}
        
        -- Check nearby properties
        -- WICHTIG: Nur gebuchte/eigene Immobilien zeigen Marker!
        for _, property in ipairs(properties) do
            -- Nur Marker für gebuchte, vermietete oder eigene Immobilien
            local showProperty = (property.status == 'owned' or property.status == 'rented' or property.status == 'viewing')
            
            if showProperty then
                local propertyCoords = vector3(property.entrance_x, property.entrance_y, property.entrance_z)
                local distance = #(playerCoords - propertyCoords)
                
                if distance < 50.0 then
                    sleep = 0
                    
                    if distance < Config.Properties.markers.drawDistance then
                        DrawMarker(
                            Config.Properties.markers.type,
                            property.entrance_x, property.entrance_y, property.entrance_z,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            Config.Properties.markers.size.x, Config.Properties.markers.size.y, Config.Properties.markers.size.z,
                            Config.Properties.markers.color.r, Config.Properties.markers.color.g, Config.Properties.markers.color.b, Config.Properties.markers.color.a,
                            Config.Properties.markers.bobUpAndDown, false, 2, Config.Properties.markers.rotate, nil, nil, false
                        )
                    end
                    
                    if distance < Config.Properties.markers.interactionDistance then
                        table.insert(nearbyProperties, {property = property, distance = distance})
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- Interaction thread
CreateThread(function()
    while true do
        local sleep = 500
        
        if #nearbyProperties > 0 then
            sleep = 0
            
            -- Sort by distance
            table.sort(nearbyProperties, function(a, b)
                return a.distance < b.distance
            end)
            
            local nearest = nearbyProperties[1].property
            
            -- Show help text
            ShowHelpNotification(_('press_to_open'))
            
            -- Check for interaction
            if IsControlJustReleased(0, 38) then -- E key
                OpenPropertyMenu(nearest)
            end
        end
        
        Wait(sleep)
    end
end)

-- ====================================================================================================
-- 📋 PROPERTY MENU
-- ====================================================================================================

function OpenPropertyMenu(property)
    local hasAccess = HasPropertyAccess(property.id)
    local isOwner = IsPropertyOwner(property.id)
    
    local elements = {}
    
    -- Property info
    table.insert(elements, {
        label = '🏠 ' .. property.name,
        value = 'info',
        disabled = true
    })
    
    table.insert(elements, {
        label = '💰 Price: $' .. property.price,
        value = 'price',
        disabled = true
    })
    
    table.insert(elements, {
        label = '📍 Area: ' .. property.area,
        value = 'area',
        disabled = true
    })
    
    table.insert(elements, {
        label = '🛏️ Bedrooms: ' .. property.bedrooms,
        value = 'bedrooms',
        disabled = true
    })
    
    table.insert(elements, {
        label = '-------------------',
        value = 'separator',
        disabled = true
    })
    
    -- Actions based on access
    if property.status == 'available' then
        if property.for_sale == 1 then
            table.insert(elements, {
                label = '✓ Purchase Property',
                value = 'purchase'
            })
        end
        
        if property.for_rent == 1 and Config.Payment.rent.enabled then
            table.insert(elements, {
                label = '🏠 Rent Property',
                value = 'rent'
            })
        end
        
        if Config.Booking.viewing.enabled then
            table.insert(elements, {
                label = '👁️ Book Viewing',
                value = 'viewing'
            })
        end
    elseif isOwner then
        table.insert(elements, {
            label = '🚪 Enter Property',
            value = 'enter'
        })
        
        table.insert(elements, {
            label = '🔒 Toggle Lock',
            value = 'lock'
        })
        
        table.insert(elements, {
            label = '🔑 Manage Keys',
            value = 'keys'
        })
        
        if Config.Garages.enabled then
            table.insert(elements, {
                label = '🚗 Open Garage',
                value = 'garage'
            })
        end
        
        if Config.Storage.enabled then
            table.insert(elements, {
                label = '📦 Open Storage',
                value = 'storage'
            })
        end
        
        table.insert(elements, {
            label = '💵 Sell Property',
            value = 'sell'
        })
    elseif hasAccess then
        table.insert(elements, {
            label = '🚪 Enter Property',
            value = 'enter'
        })
        
        if CanLockProperty(property.id) then
            table.insert(elements, {
                label = '🔒 Toggle Lock',
                value = 'lock'
            })
        end
        
        if Config.Garages.enabled and CanAccessGarage(property.id) then
            table.insert(elements, {
                label = '🚗 Open Garage',
                value = 'garage'
            })
        end
        
        if Config.Storage.enabled and CanAccessStorage(property.id) then
            table.insert(elements, {
                label = '📦 Open Storage',
                value = 'storage'
            })
        end
    else
        table.insert(elements, {
            label = '🚫 No Access',
            value = 'no_access',
            disabled = true
        })
        
        if Config.Booking.viewing.enabled and property.status == 'available' then
            table.insert(elements, {
                label = '👁️ Book Viewing',
                value = 'viewing'
            })
        end
    end
    
    -- Open menu (ESX/QB menu system or custom NUI)
    OpenMenu(elements, property)
end

function OpenMenu(elements, property)
    -- This should be implemented with your preferred menu system
    -- For now, we'll trigger NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openPropertyMenu',
        property = property,
        elements = elements
    })
end

-- ====================================================================================================
-- 🎯 HELPER FUNCTIONS
-- ====================================================================================================

function HasPropertyAccess(propertyId)
    for _, key in ipairs(playerKeys) do
        if key.property_id == propertyId then
            return true
        end
    end
    return false
end

function IsPropertyOwner(propertyId)
    for _, property in ipairs(playerProperties) do
        if property.id == propertyId then
            return true
        end
    end
    return false
end

function CanLockProperty(propertyId)
    for _, key in ipairs(playerKeys) do
        if key.property_id == propertyId and key.can_lock == 1 then
            return true
        end
    end
    return false
end

function CanAccessGarage(propertyId)
    for _, key in ipairs(playerKeys) do
        if key.property_id == propertyId and key.can_access_garage == 1 then
            return true
        end
    end
    return false
end

function CanAccessStorage(propertyId)
    for _, key in ipairs(playerKeys) do
        if key.property_id == propertyId and key.can_access_storage == 1 then
            return true
        end
    end
    return false
end

function ShowHelpNotification(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- ====================================================================================================
-- 📍 GPS & WAYPOINT
-- ====================================================================================================

RegisterNetEvent('property:setGPS')
AddEventHandler('property:setGPS', function(x, y, z)
    SetNewWaypoint(x, y)
    Notify('success', _('success'), _('gps_set'))
end)

RegisterNetEvent('property:teleport')
AddEventHandler('property:teleport', function(x, y, z, h)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, x, y, z, false, false, false, false)
    SetEntityHeading(playerPed, h or 0.0)
end)

-- ====================================================================================================
-- 🔒 DOOR LOCK SYNC
-- ====================================================================================================

RegisterNetEvent('property:updateLock')
AddEventHandler('property:updateLock', function(propertyId, locked)
    -- Update local property data
    for i, prop in ipairs(properties) do
        if prop.id == propertyId then
            properties[i].locked = locked and 1 or 0
            break
        end
    end
    
    -- Play sound
    if Config.Properties.doors.lockSound or Config.Properties.doors.unlockSound then
        PlaySoundFrontend(-1, locked and 'DOOR_LOCK' or 'DOOR_UNLOCK', 'DLC_HEIST_FLEECA_SOUNDSET', true)
    end
end)

-- ====================================================================================================
-- 🏢 REALTOR OFFICES
-- ====================================================================================================

CreateThread(function()
    -- Create blips for realtor offices
    for _, office in ipairs(Config.RealtorOffices) do
        local blip = AddBlipForCoord(office.blip.x, office.blip.y, office.blip.z)
        SetBlipSprite(blip, office.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, office.scale)
        SetBlipColour(blip, office.color)
        SetBlipAsShortRange(blip, true)
        
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(office.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Realtor office markers and interactions
CreateThread(function()
    while true do
        local sleep = 500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for _, office in ipairs(Config.RealtorOffices) do
            local officeCoords = vector3(office.marker.x, office.marker.y, office.marker.z)
            local distance = #(playerCoords - officeCoords)
            
            if distance < 50.0 then
                sleep = 0
                
                if distance < 25.0 then
                    DrawMarker(
                        27, officeCoords.x, officeCoords.y, officeCoords.z,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        1.5, 1.5, 0.5,
                        0, 255, 0, 100,
                        false, false, 2, false, nil, nil, false
                    )
                end
                
                if distance < 2.0 then
                    ShowHelpNotification(_('press_to_open') .. ' ' .. office.name)
                    
                    if IsControlJustReleased(0, 38) then
                        OpenPropertyCatalog()
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

function OpenPropertyCatalog()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openCatalog',
        properties = properties
    })
end

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('GetNearbyProperties', function()
    return nearbyProperties
end)

exports('GetPlayerProperties', function()
    return playerProperties
end)

exports('HasPropertyAccess', HasPropertyAccess)
exports('IsPropertyOwner', IsPropertyOwner)
