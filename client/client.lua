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
-- 🔒 GLOBAL UI STATE (Prevent Threading Conflicts)
-- ====================================================================================================

-- Initialize global UI state for cross-script coordination
if not _G.PropertyUIState then
    _G.PropertyUIState = {
        isOpen = false,
        currentUI = nil,
        lastClose = 0
    }
    print('[Property Manager] ✅ Global UI state initialized')
end

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
    -- DO NOT create blips here! Properties should NOT have blips until player books them.
    -- Blips are only created when server confirms booking via 'property:bookingConfirmed'
    -- CreatePropertyBlips() -- REMOVED: No automatic blips for all properties
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

-- ====================================================================================================
-- 🎫 BOOKING EVENTS (Event-Driven Blip Creation)
-- ====================================================================================================

-- Booking confirmed - CREATE blip for this player
RegisterNetEvent('property:bookingConfirmed')
AddEventHandler('property:bookingConfirmed', function(payload)
    --[[
        payload = {
            propertyId = string,
            coords = {x, y, z},
            bookingType = 'viewing'|'rent'|'buy',
            expiresAt = timestamp (for viewing/rent) or nil,
            propertyName = string,
            enableRoute = boolean (true for viewing)
        }
    ]]
    
    CreateOrUpdatePropertyBlip(payload.propertyId, payload.coords, {
        name = payload.propertyName or 'Gebuchte Immobilie',
        enableRoute = payload.enableRoute or false,
        sprite = 40,
        scale = 0.8
    })
    
    -- Show notification
    local message = 'Blip erstellt für: ' .. (payload.propertyName or 'Immobilie')
    if payload.bookingType == 'viewing' then
        message = message .. ' (Besichtigung - 30 Min)'
    elseif payload.bookingType == 'rent' then
        message = message .. ' (Miete aktiv)'
    elseif payload.bookingType == 'buy' then
        message = message .. ' (Eigentum)'
    end
    
    ShowNotification(message, 'success')
end)

-- Booking expired - REMOVE blip
RegisterNetEvent('property:bookingExpired')
AddEventHandler('property:bookingExpired', function(propertyId)
    RemovePropertyBlip(propertyId)
    ShowNotification('Besichtigung abgelaufen', 'info')
end)

-- Lease ended - REMOVE blip
RegisterNetEvent('property:leaseEnded')
AddEventHandler('property:leaseEnded', function(propertyId)
    RemovePropertyBlip(propertyId)
    ShowNotification('Mietvertrag beendet', 'info')
end)

-- Evicted - REMOVE blip
RegisterNetEvent('property:evicted')
AddEventHandler('property:evicted', function(propertyId, reason)
    RemovePropertyBlip(propertyId)
    ShowNotification('Aus Immobilie entfernt: ' .. (reason or 'Räumung'), 'error')
end)

-- Ownership transferred - UPDATE blip (old owner loses, new owner gets)
RegisterNetEvent('property:ownershipTransferred')
AddEventHandler('property:ownershipTransferred', function(propertyId, newOwnerId)
    local playerId = PlayerId()
    local playerServerId = GetPlayerServerId(playerId)
    
    -- If I'm the new owner, I'll get a bookingConfirmed event
    -- If I was the old owner, remove my blip
    if playerServerId ~= newOwnerId then
        RemovePropertyBlip(propertyId)
        ShowNotification('Eigentum übertragen', 'info')
    end
end)

-- Sync player access - called on PlayerLoaded/relog
RegisterNetEvent('property:syncPlayerAccess')
AddEventHandler('property:syncPlayerAccess', function(accessList)
    --[[
        accessList = {
            { propertyId, coords, bookingType, propertyName, expiresAt, enableRoute },
            ...
        }
    ]]
    
    -- Clear existing property blips
    ClearAllPropertyBlips()
    
    -- Create blips for all active access
    for _, access in ipairs(accessList) do
        CreateOrUpdatePropertyBlip(access.propertyId, access.coords, {
            name = access.propertyName,
            enableRoute = access.enableRoute or false,
            sprite = 40,
            scale = 0.8
        })
    end
    
    if Config.Debug then
        print('[Property Manager] Synced ' .. #accessList .. ' property blips')
    end
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

-- ====================================================================================================
-- 🗺️ BLIP MANAGER (Player-Specific, Event-Driven)
-- ====================================================================================================

local BranchBlips = {} -- 3 permanent realtor office blips
local PropertyBlips = {} -- Dynamic player-specific property blips (by propertyId)

-- Create or update a property blip (called when server confirms booking)
function CreateOrUpdatePropertyBlip(propertyId, coords, opts)
    opts = opts or {}
    
    -- Remove existing blip if any
    if PropertyBlips[propertyId] then
        RemoveBlip(PropertyBlips[propertyId])
    end
    
    -- Create new blip
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, opts.sprite or 40) -- House icon
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, opts.scale or 0.8)
    SetBlipColour(blip, 2) -- GREEN for all player properties (viewing/rent/owned)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(opts.name or 'Gebuchte Immobilie')
    EndTextCommandSetBlipName(blip)
    
    -- Set GPS route if requested (e.g., for viewing bookings)
    if opts.enableRoute then
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, 2) -- Green route
        
        -- NEW: Also set GPS waypoint for easier navigation
        SetNewWaypoint(coords.x, coords.y)
        
        -- Notify player that GPS is active
        Notify('info', 'GPS aktiviert', 'Folge dem GPS-Wegpunkt zur Immobilie')
    end
    
    PropertyBlips[propertyId] = blip
    
    if Config.Debug then
        print('[Property Manager] Created blip for property: ' .. propertyId)
    end
end

-- Remove a property blip
function RemovePropertyBlip(propertyId)
    if PropertyBlips[propertyId] then
        RemoveBlip(PropertyBlips[propertyId])
        PropertyBlips[propertyId] = nil
        
        if Config.Debug then
            print('[Property Manager] Removed blip for property: ' .. propertyId)
        end
    end
end

-- Clear all property blips (on resource stop)
function ClearAllPropertyBlips()
    for propertyId, blip in pairs(PropertyBlips) do
        RemoveBlip(blip)
    end
    PropertyBlips = {}
end

-- Legacy function - now only used for player-specific sync
function CreatePropertyBlips()
    -- This function is now only called when player needs to sync their active properties
    -- It should NOT be called on resource start or when receiving all properties
    -- Instead, use the event-driven approach with bookingConfirmed events
end

-- Legacy function - kept for compatibility but should not be used
function CreatePropertyBlip(property)
    -- DEPRECATED: Use CreateOrUpdatePropertyBlip instead
    -- This ensures blips are only created via server events
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

-- Load realtor branches from data file
-- ====================================================================================================
-- REALTOR BRANCH DATA (Embedded directly to avoid file loading issues)
-- ====================================================================================================
local RealtorBranches = {
    -- Downtown Realty - Klassisches Geschäftsviertel
    {
        id = 1,
        name = 'Downtown Realty',
        description = 'Ihr vertrauenswürdiger Partner für Immobilien im Geschäftsviertel',
        location = vector4(1124.5, 226.5, 69.0, 0.0),
        blip = {
            sprite = 375,
            color = 3,
            scale = 0.8,
            shortRange = true,
            display = 4
        },
        marker = {
            type = 27,
            size = vector3(1.5, 1.5, 0.5),
            color = {r = 0, g = 255, b = 0, a = 100},
            drawDistance = 25.0,
            interactionDistance = 2.0
        },
        jobRestriction = nil,
        commission = 5.0,
        active = true
    },
    
    -- Vinewood Luxury Realty - Premium Verkäufer
    {
        id = 2,
        name = 'Vinewood Luxury Realty',
        description = 'Exklusive Immobilien für anspruchsvolle Kunden',
        location = vector4(1302.8, -528.5, 71.4, 90.0),
        blip = {
            sprite = 375,
            color = 5,
            scale = 0.8,
            shortRange = true,
            display = 4
        },
        marker = {
            type = 27,
            size = vector3(1.5, 1.5, 0.5),
            color = {r = 255, g = 215, b = 0, a = 100},
            drawDistance = 25.0,
            interactionDistance = 2.0
        },
        jobRestriction = nil,
        commission = 7.5,
        active = true
    },
    
    -- Del Perro Beach Properties - Casual Beach-Office
    {
        id = 3,
        name = 'Del Perro Beach Properties',
        description = 'Traumhafte Strandimmobilien und mehr',
        location = vector4(150.2, -1044.3, 29.4, 180.0),
        blip = {
            sprite = 375,
            color = 38,
            scale = 0.8,
            shortRange = true,
            display = 4
        },
        marker = {
            type = 27,
            size = vector3(1.5, 1.5, 0.5),
            color = {r = 0, g = 191, b = 255, a = 100},
            drawDistance = 25.0,
            interactionDistance = 2.0
        },
        jobRestriction = nil,
        commission = 5.0,
        active = true
    }
}

local realtorNPCs = {}

CreateThread(function()
    -- Branches are now embedded directly, no file loading needed
    print('[Property Manager] Loaded ' .. #RealtorBranches .. ' realtor branches (embedded data)')
    
    if type(RealtorBranches) ~= 'table' or #RealtorBranches == 0 then
        print('[Property Manager] ERROR: No realtor branches available!')
        RealtorBranches = {}
    end
    
    -- Wait for game to be ready
    Wait(1000)
    
    -- Create blips and NPCs for realtor offices
    for i, branch in ipairs(RealtorBranches) do
        if branch and branch.active then
            -- Extract coordinates from vec4
            local x, y, z, w = branch.location.x, branch.location.y, branch.location.z, branch.location.w
            
            -- Create blip
            local blip = AddBlipForCoord(x, y, z)
            SetBlipSprite(blip, branch.blip.sprite)
            SetBlipDisplay(blip, branch.blip.display)
            SetBlipScale(blip, branch.blip.scale)
            SetBlipColour(blip, branch.blip.color)
            SetBlipAsShortRange(blip, branch.blip.shortRange)
            
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(branch.name)
            EndTextCommandSetBlipName(blip)
            
            -- Spawn NPC at ground level
            local npcHash = GetHashKey('a_m_y_business_01') -- Business NPC model
            RequestModel(npcHash)
            while not HasModelLoaded(npcHash) do
                Wait(100)
            end
            
            -- Get proper ground Z coordinate with better detection
            local groundZ = z
            -- Request collision at location
            RequestCollisionAtCoord(x, y, z)
            Wait(100)
            
            -- Try multiple times to get accurate ground
            for i = 1, 5 do
                local foundGround, zCoord = GetGroundZFor_3dCoord(x, y, z + 100.0, false)
                if foundGround then
                    groundZ = zCoord + 1.0 -- Add 1 meter to ensure above ground
                    break
                end
                Wait(100)
            end
            
            -- Create NPC at ground level
            local npc = CreatePed(4, npcHash, x, y, groundZ, w, false, true)
            
            -- Wait for ped to be created
            Wait(100)
            
            -- Set ped properties
            SetEntityHeading(npc, w)
            SetEntityCoordsNoOffset(npc, x, y, groundZ, false, false, false)
            FreezeEntityPosition(npc, true)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            SetPedDiesWhenInjured(npc, false)
            SetPedCanPlayAmbientAnims(npc, true)
            SetPedRelationshipGroupHash(npc, GetHashKey('CIVMALE'))
            SetPedFleeAttributes(npc, 0, false)
            SetPedCombatAttributes(npc, 17, true)
            
            -- Force entity to collision
            SetEntityCollision(npc, true, true)
            
            -- Store NPC reference
            table.insert(realtorNPCs, {
                entity = npc,
                branch = branch
            })
            
            print('[Property Manager] Created realtor office: ' .. branch.name)
        end
    end
end)

-- Realtor office markers and interactions
CreateThread(function()
    while true do
        local sleep = 500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Check if RealtorBranches is valid
        if RealtorBranches and type(RealtorBranches) == 'table' then
            for i, branch in ipairs(RealtorBranches) do
                if branch and branch.active then
                    local officeCoords = vector3(branch.location.x, branch.location.y, branch.location.z)
                    local distance = #(playerCoords - officeCoords)
                    
                    if distance < 50.0 then
                        sleep = 0
                        
                        if distance < branch.marker.drawDistance then
                            -- Draw marker slightly above ground
                            DrawMarker(
                                branch.marker.type,
                                branch.location.x, branch.location.y, branch.location.z + 0.1,
                                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                                branch.marker.size.x, branch.marker.size.y, branch.marker.size.z,
                                branch.marker.color.r, branch.marker.color.g, branch.marker.color.b, branch.marker.color.a,
                                false, true, 2, false, nil, nil, false
                            )
                        end
                        
                        if distance < branch.marker.interactionDistance then
                            ShowHelpNotification(_('press_to_open') .. ' ' .. branch.name)
                            
                            if IsControlJustReleased(0, 38) then
                                OpenPropertyCatalog()
                            end
                        end
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, npcData in ipairs(realtorNPCs) do
            if DoesEntityExist(npcData.entity) then
                DeleteEntity(npcData.entity)
            end
        end
    end
end)

function OpenPropertyCatalog()
    -- CRITICAL: Check cooldown from last UI close (prevent rapid re-open causing freeze)
    if _G.PropertyUIState and _G.PropertyUIState.lastClose then
        local timeSinceClose = GetGameTimer() - _G.PropertyUIState.lastClose
        if timeSinceClose < 2000 then -- 2 second cooldown
            local remaining = math.ceil((2000 - timeSinceClose) / 1000)
            print('[Property Manager] ⚠️ UI COOLDOWN ACTIVE - Wait', remaining, 'more seconds')
            if Config.Framework == 'ESX' then
                if ESX then
                    ESX.ShowNotification('Bitte warte ' .. remaining .. ' Sekunden', 'error')
                end
            elseif Config.Framework == 'QBCore' then
                if QBCore then
                    QBCore.Functions.Notify('Bitte warte ' .. remaining .. ' Sekunden', 'error')
                end
            end
            return
        end
    end
    
    -- Check if properties are loaded
    if not properties or #properties == 0 then
        -- Show notification that properties are loading
        if Config.Framework == 'ESX' then
            if ESX then
                ESX.ShowNotification('Lade Immobilien...', 'info')
            end
        elseif Config.Framework == 'QBCore' then
            if QBCore then
                QBCore.Functions.Notify('Lade Immobilien...', 'info')
            end
        end
        
        -- Request properties from server
        TriggerServerEvent('property:getAll')
        
        -- Wait up to 5 seconds for properties to load
        local timeout = 50 -- 5 seconds (50 x 100ms)
        local attempts = 0
        
        while (not properties or #properties == 0) and attempts < timeout do
            Wait(100)
            attempts = attempts + 1
        end
        
        -- If still no properties, show error
        if not properties or #properties == 0 then
            if Config.Framework == 'ESX' then
                if ESX then
                    ESX.ShowNotification('Fehler beim Laden der Immobilien', 'error')
                end
            elseif Config.Framework == 'QBCore' then
                if QBCore then
                    QBCore.Functions.Notify('Fehler beim Laden der Immobilien', 'error')
                end
            end
            return
        end
    end
    
    print('[Property Manager] ✅ Opening catalog - cooldown passed')
    -- Open catalog with loaded properties
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openCatalog',
        properties = properties
    })
end

-- ====================================================================================================
-- 🛒 PURCHASE & RENT HANDLERS
-- ====================================================================================================

-- Open purchase dialog
RegisterNetEvent('property:openPurchaseDialog')
AddEventHandler('property:openPurchaseDialog', function(propertyId)
    -- Find the property
    local property = nil
    for _, prop in ipairs(properties) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    if not property then
        if Config.Framework == 'ESX' and ESX then
            ESX.ShowNotification('Immobilie nicht gefunden', 'error')
        elseif Config.Framework == 'QBCore' and QBCore then
            QBCore.Functions.Notify('Immobilie nicht gefunden', 'error')
        end
        return
    end
    
    -- Show purchase confirmation dialog
    local paymentMethod = 'cash' -- Default to cash
    local alert = ('Möchten Sie %s für $%s kaufen?'):format(property.name, property.price)
    
    -- Simple confirmation
    TriggerServerEvent('property:purchase', propertyId, paymentMethod, false, nil)
end)

-- Open rent dialog
RegisterNetEvent('property:openRentDialog')
AddEventHandler('property:openRentDialog', function(propertyId)
    -- Find the property
    local property = nil
    for _, prop in ipairs(properties) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    if not property then
        if Config.Framework == 'ESX' and ESX then
            ESX.ShowNotification('Immobilie nicht gefunden', 'error')
        elseif Config.Framework == 'QBCore' and QBCore then
            QBCore.Functions.Notify('Immobilie nicht gefunden', 'error')
        end
        return
    end
    
    -- Calculate rent (10% of property price per month)
    local monthlyRent = math.floor(property.price * 0.1)
    local duration = 30 -- Default 30 days
    
    -- Show rent confirmation
    local paymentMethod = 'cash'
    TriggerServerEvent('property:rent', propertyId, duration, paymentMethod)
end)

-- ====================================================================================================
-- 🏠 PROPERTY INTERACTION SYSTEM
-- On-property menus, access control, key management
-- ====================================================================================================

local nearPropertyCheck = false
local currentPropertyInteraction = nil
local playerKeys = {}
local playerBookings = {}

-- Check if player is near a property they have access to
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        
        if not nearPropertyCheck and LoadedProperties and #LoadedProperties > 0 then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, property in ipairs(LoadedProperties) do
                local propertyCoords = vector3(property.entrance_x, property.entrance_y, property.entrance_z)
                local distance = #(playerCoords - propertyCoords)
                
                -- Player is near property entrance (within 2.5 meters)
                if distance < 2.5 then
                    currentPropertyInteraction = property
                    break
                else
                    if currentPropertyInteraction and currentPropertyInteraction.id == property.id then
                        currentPropertyInteraction = nil
                    end
                end
            end
        end
    end
end)

-- Draw property interaction markers and text
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if currentPropertyInteraction then
            local property = currentPropertyInteraction
            local propertyCoords = vector3(property.entrance_x, property.entrance_y, property.entrance_z)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - propertyCoords)
            
            if distance < 2.5 then
                -- Draw marker
                DrawMarker(1, property.entrance_x, property.entrance_y, property.entrance_z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                
                -- Draw text
                SetTextComponentFormat('STRING')
                AddTextComponentString('[E] ' .. property.name .. ' - Interagieren')
                SetDrawOrigin(property.entrance_x, property.entrance_y, property.entrance_z + 0.5, 0)
                EndTextCommandDisplayText(0.0, 0.0)
                ClearDrawOrigin()
                
                -- Check for key press
                if IsControlJustReleased(0, 38) then -- E key
                    OpenPropertyMenu(property.id)
                end
            end
        end
    end
end)

-- Open property interaction menu
function OpenPropertyMenu(propertyId)
    -- Check access first
    TriggerServerEvent('property:checkAccess', propertyId)
end

-- Receive access check result
RegisterNetEvent('property:accessResult')
AddEventHandler('property:accessResult', function(propertyId, hasAccess, keyData)
    if currentPropertyInteraction and currentPropertyInteraction.id == propertyId then
        if hasAccess then
            -- Player has keys, show full menu
            ShowPropertyMenuWithAccess(propertyId, keyData)
        else
            -- Player doesn't have keys, show limited menu (access code input)
            ShowPropertyMenuNoAccess(propertyId)
        end
    end
end)

-- Show property menu for players WITH access (have keys)
function ShowPropertyMenuWithAccess(propertyId, keyData)
    local property = currentPropertyInteraction
    if not property then return end
    
    SendNUIMessage({
        action = 'openPropertyMenu',
        property = property,
        keyData = keyData,
        hasAccess = true
    })
    SetNuiFocus(true, true)
end

-- Show property menu for players WITHOUT access (no keys)
function ShowPropertyMenuNoAccess(propertyId)
    local property = currentPropertyInteraction
    if not property then return end
    
    SendNUIMessage({
        action = 'openPropertyMenu',
        property = property,
        hasAccess = false
    })
    SetNuiFocus(true, true)
end

-- Handle property menu actions
RegisterNUICallback('propertyMenuAction', function(data, cb)
    local action = data.action
    local propertyId = data.propertyId
    
    if action == 'enter' then
        -- Enter property (teleport to interior or open door)
        EnterProperty(propertyId)
    elseif action == 'lock' then
        -- Lock/unlock property
        TogglePropertyLock(propertyId)
    elseif action == 'manageKeys' then
        -- Open key management UI
        OpenKeyManagementUI(propertyId)
    elseif action == 'sell' then
        -- Open sell property dialog
        TriggerServerEvent('property:sell', propertyId)
    elseif action == 'garage' then
        -- Open garage
        TriggerEvent('property:openGarage', propertyId)
    elseif action == 'enterCode' then
        -- Open access code input
        OpenAccessCodeInput(propertyId)
    elseif action == 'close' then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        -- Force camera and control freedom
        SetPlayerControl(PlayerId(), true, 0)
        DisplayRadar(true)
        RenderScriptCams(false, false, 0, true, true)
    end
    
    cb('ok')
end)

-- ====================================================================================================
-- 🔑 ACCESS CODE SYSTEM (FOR VIEWING/SHORT-TERM KEYS)
-- ====================================================================================================

function OpenAccessCodeInput(propertyId)
    SendNUIMessage({
        action = 'openAccessCodeDialog',
        propertyId = propertyId
    })
    SetNuiFocus(true, true)
end

-- Handle access code submission
RegisterNUICallback('submitAccessCode', function(data, cb)
    local propertyId = data.propertyId
    local accessCode = data.accessCode
    
    if not accessCode or #accessCode ~= 4 then
        SendNUIMessage({
            action = 'showNotification',
            type = 'error',
            message = 'Code muss 4-stellig sein'
        })
        cb('error')
        return
    end
    
    -- Validate code on server
    TriggerServerEvent('property:validateCode', propertyId, accessCode)
    cb('ok')
end)

-- Receive code validation result
RegisterNetEvent('property:codeValidated')
AddEventHandler('property:codeValidated', function(propertyId, keyData)
    SendNUIMessage({
        action = 'showNotification',
        type = 'success',
        message = 'Zugang gewährt! Code gültig für ' .. math.floor((keyData.expires_at - os.time()) / 60) .. ' Minuten'
    })
    
    SendNUIMessage({
        action = 'closeAccessCodeDialog'
    })
    
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    -- Force camera and control freedom
    SetPlayerControl(PlayerId(), true, 0)
    DisplayRadar(true)
    RenderScriptCams(false, false, 0, true, true)
    
    -- Now player can enter
    EnterProperty(propertyId)
end)

RegisterNetEvent('property:codeInvalid')
AddEventHandler('property:codeInvalid', function(propertyId)
    SendNUIMessage({
        action = 'showNotification',
        type = 'error',
        message = 'Ungültiger oder abgelaufener Code'
    })
end)

-- ====================================================================================================
-- 🔑 KEY MANAGEMENT UI
-- ====================================================================================================

function OpenKeyManagementUI(propertyId)
    -- Request key holders from server
    TriggerServerEvent('property:getKeyHolders', propertyId)
end

-- Receive key holders data
RegisterNetEvent('property:receiveKeyHolders')
AddEventHandler('property:receiveKeyHolders', function(propertyId, keyHolders)
    SendNUIMessage({
        action = 'openKeyManagement',
        propertyId = propertyId,
        keyHolders = keyHolders
    })
    SetNuiFocus(true, true)
end)

-- Handle key management actions
RegisterNUICallback('keyManagementAction', function(data, cb)
    local action = data.action
    local propertyId = data.propertyId
    
    if action == 'giveKey' then
        local targetId = data.targetPlayerId
        local permissionLevel = data.permissionLevel or 'guest'
        TriggerServerEvent('property:giveKeys', propertyId, targetId, permissionLevel)
    elseif action == 'removeKey' then
        local targetId = data.targetPlayerId
        TriggerServerEvent('property:removeKeys', propertyId, targetId)
    elseif action == 'duplicateKey' then
        local paymentMethod = data.paymentMethod or 'cash'
        TriggerServerEvent('property:duplicateKeys', propertyId, paymentMethod)
    elseif action == 'close' then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        -- Force camera and control freedom
        SetPlayerControl(PlayerId(), true, 0)
        DisplayRadar(true)
        RenderScriptCams(false, false, 0, true, true)
    end
    
    cb('ok')
end)

-- Request player's keys on resource start
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait for player to spawn
    TriggerServerEvent('property:getMyKeys')
    TriggerServerEvent('property:getMyBookings')
end)

-- Receive player's keys
RegisterNetEvent('property:receiveMyKeys')
AddEventHandler('property:receiveMyKeys', function(keys)
    playerKeys = keys
end)

-- Receive player's bookings
RegisterNetEvent('property:receiveMyBookings')
AddEventHandler('property:receiveMyBookings', function(bookings)
    playerBookings = bookings
end)

-- ====================================================================================================
-- 🏠 PROPERTY ENTRY SYSTEM
-- ====================================================================================================

function EnterProperty(propertyId)
    local property = nil
    for _, prop in ipairs(LoadedProperties or {}) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    if not property then return end
    
    -- Check if has access
    local hasAccess = false
    for _, key in ipairs(playerKeys) do
        if key.property_id == propertyId and key.can_enter == 1 then
            hasAccess = true
            break
        end
    end
    
    if not hasAccess then
        -- Check active bookings
        for _, booking in ipairs(playerBookings) do
            if booking.property_id == propertyId and booking.status == 'active' then
                hasAccess = true
                break
            end
        end
    end
    
    if not hasAccess then
        SendNUIMessage({
            action = 'showNotification',
            type = 'error',
            message = 'Kein Zutritt - Schlüssel oder Code benötigt'
        })
        return
    end
    
    -- Teleport to interior or show interior (depending on setup)
    if property.interior and property.interior ~= '' then
        -- Load interior IPL if needed
        -- RequestIpl(property.interior)
        
        SendNUIMessage({
            action = 'showNotification',
            type = 'success',
            message = 'Betrete ' .. property.name
        })
        
        -- Note: Actual interior teleport logic would go here
        -- This depends on your interior system setup
    end
end

function TogglePropertyLock(propertyId)
    -- Check if player has lock permission
    local canLock = false
    for _, key in ipairs(playerKeys) do
        if key.property_id == propertyId and key.can_lock == 1 then
            canLock = true
            break
        end
    end
    
    if not canLock then
        SendNUIMessage({
            action = 'showNotification',
            type = 'error',
            message = 'Keine Berechtigung zum Abschließen'
        })
        return
    end
    
    -- Toggle lock (play animation, sound, etc.)
    SendNUIMessage({
        action = 'showNotification',
        type = 'info',
        message = 'Türschloss umgeschaltet'
    })
    
    -- Play lock sound
    PlaySoundFrontend(-1, 'DOOR_BUZZ', 'MP_PLAYER_APARTMENT', true)
end

-- ====================================================================================================
-- 📍 SET GPS TO PROPERTY
-- ====================================================================================================

RegisterNetEvent('property:setGPS')
AddEventHandler('property:setGPS', function(x, y, z)
    SetNewWaypoint(x, y)
    
    SendNUIMessage({
        action = 'showNotification',
        type = 'success',
        message = 'GPS-Route zur Immobilie gesetzt'
    })
end)

-- ====================================================================================================
-- 🔔 BOOKING NOTIFICATIONS
-- ====================================================================================================

RegisterNetEvent('property:bookingCreated')
AddEventHandler('property:bookingCreated', function(booking)
    SendNUIMessage({
        action = 'showNotification',
        type = 'success',
        message = 'Buchung erstellt!\nZugangscode: ' .. booking.accessCode
    })
    
    -- Refresh bookings
    TriggerServerEvent('property:getMyBookings')
end)

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
exports('GetPlayerKeys', function() return playerKeys end)
exports('GetPlayerBookings', function() return playerBookings end)
exports('OpenPropertyMenu', OpenPropertyMenu)
exports('OpenAccessCodeInput', OpenAccessCodeInput)
exports('OpenKeyManagementUI', OpenKeyManagementUI)

-- ====================================================================================================
-- 🎮 PLAYER LOADED - SYNC ACCESS ON RELOG
-- ====================================================================================================

-- ESX Framework
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    -- Request sync of player's active property access
    Citizen.Wait(2000) -- Wait for server to be ready
    TriggerServerEvent('property:requestAccessSync')
end)

-- QBCore Framework
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    -- Request sync of player's active property access
    Citizen.Wait(2000) -- Wait for server to be ready
    TriggerServerEvent('property:requestAccessSync')
end)

-- ====================================================================================================
-- 🛑 RESOURCE STOP - CLEANUP
-- ====================================================================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Clear all property blips
    ClearAllPropertyBlips()
    
    -- Clear branch blips
    for _, blip in pairs(BranchBlips) do
        RemoveBlip(blip)
    end
    
    -- Close any open UIs
    if exports['Home_Manger'] and exports['Home_Manger'].CloseUI then
        exports['Home_Manger']:CloseUI()
    end
    
    print('[Property Manager] Resource stopped - cleaned up blips and UI')
end)
