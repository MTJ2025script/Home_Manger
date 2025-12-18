-- ====================================================================================================
-- 🖥️ NUI EVENT HANDLERS
-- Handle NUI callbacks and messages
-- ====================================================================================================

-- ====================================================================================================
-- 🔒 CENTRALIZED UI CLOSE FUNCTION (Prevents UI Freeze)
-- ====================================================================================================

local uiOpen = false

function CloseUI()
    -- STEP 1: Send immediate force close to NUI
    SendNUIMessage({
        action = 'forceClose'
    })
    
    -- STEP 2: Wait tiny moment for NUI to process
    Citizen.Wait(10)
    
    -- STEP 3: Remove NUI focus completely
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    
    -- STEP 4: Force camera and control freedom
    local playerId = PlayerId()
    SetPlayerControl(playerId, true, 0)
    
    -- STEP 5: Restore HUD
    DisplayRadar(true)
    
    -- STEP 6: Ensure all script cameras disabled
    RenderScriptCams(false, false, 0, true, true)
    
    -- STEP 7: Additional camera freedom check
    SetCamActive(GetRenderingCam(), false)
    DestroyAllCams(true)
    
    -- STEP 8: Update state
    uiOpen = false
    
    -- Update global state
    if _G.PropertyUIState then
        _G.PropertyUIState.isOpen = false
        _G.PropertyUIState.currentUI = nil
        _G.PropertyUIState.lastClose = GetGameTimer()
    end
    
    if Config.Debug then
        print('[Property Manager] Force Close - All systems freed')
    end
end

-- Export for external use
exports('CloseUI', CloseUI)

-- ====================================================================================================
-- 📥 NUI CALLBACKS
-- ====================================================================================================

-- Close NUI - Use centralized function
RegisterNUICallback('close', function(data, cb)
    CloseUI()
    cb('ok')
end)

-- Property action - Use CloseUI for all paths
RegisterNUICallback('propertyAction', function(data, cb)
    local action = data.action
    local propertyId = data.propertyId
    local property = data.property
    local paymentMethod = data.paymentMethod
    
    if action == 'purchase' then
        -- Direct purchase with payment method
        CloseUI()
        
        -- Show notification
        TriggerEvent('property:notify', 'info', 'Kauf', 'Immobilie wird gekauft...')
        
        -- Send to server with payment method
        TriggerServerEvent('property:purchase', propertyId, paymentMethod or 'cash', false, nil)
        
    elseif action == 'rent' then
        -- Direct rent
        CloseUI()
        
        -- Show notification
        TriggerEvent('property:notify', 'info', 'Miete', 'Mietvertrag wird erstellt...')
        
        -- Calculate rent (10% of price monthly)
        local monthlyRent = math.floor(property.price * 0.1)
        TriggerServerEvent('property:rent', propertyId, 30, 'cash') -- 30 days
        
    elseif action == 'viewing' then
        -- Book viewing (30 min, $500)
        CloseUI()
        
        -- Show notification
        TriggerEvent('property:notify', 'info', 'Besichtigung', 'Besichtigung wird gebucht...')
        
        -- Send to server
        TriggerServerEvent('property:bookViewing', propertyId)
        
    elseif action == 'enter' then
        -- Enter property
        CloseUI()
        TriggerEvent('property:enter', propertyId)
    elseif action == 'lock' then
        -- Toggle lock
        CloseUI()
        TriggerServerEvent('property:toggleLock', propertyId)
    elseif action == 'garage' then
        -- Open garage
        CloseUI()
        TriggerEvent('property:openGarage', propertyId)
    elseif action == 'storage' then
        -- Open storage
        CloseUI()
        TriggerServerEvent('property:openStorage', propertyId, 'safe')
    elseif action == 'sell' then
        -- Sell property
        CloseUI()
        TriggerServerEvent('property:sell', propertyId)
    end
    
    cb('ok')
end)

-- Purchase property
RegisterNUICallback('purchaseProperty', function(data, cb)
    CloseUI()
    TriggerServerEvent('property:purchase', data.propertyId, data.paymentMethod, data.useMortgage, data.mortgageData)
    cb('ok')
end)

-- Rent property
RegisterNUICallback('rentProperty', function(data, cb)
    CloseUI()
    TriggerServerEvent('property:rent', data.propertyId, data.duration, data.paymentMethod)
    cb('ok')
end)

-- Book short-term rental
RegisterNUICallback('bookRental', function(data, cb)
    CloseUI()
    TriggerServerEvent('property:bookRental', data.propertyId, data.days)
    cb('ok')
end)

-- Filter properties
RegisterNUICallback('filterProperties', function(data, cb)
    TriggerServerEvent('property:search', data.filters)
    cb('ok')
end)

-- Get property details
RegisterNUICallback('getPropertyDetails', function(data, cb)
    TriggerServerEvent('property:getById', data.propertyId)
    cb('ok')
end)

-- ====================================================================================================
-- 📡 RECEIVE EVENTS FROM SERVER
-- ====================================================================================================

-- Receive single property
RegisterNetEvent('property:receiveOne')
AddEventHandler('property:receiveOne', function(property)
    SendNUIMessage({
        action = 'setPropertyDetails',
        property = property
    })
end)

-- Receive search results
RegisterNetEvent('property:searchResults')
AddEventHandler('property:searchResults', function(properties)
    SendNUIMessage({
        action = 'setSearchResults',
        properties = properties
    })
end)

-- ====================================================================================================
-- 🔔 NOTIFICATION EVENT
-- ====================================================================================================

RegisterNetEvent('property:notify')
AddEventHandler('property:notify', function(type, title, message)
    SendNUIMessage({
        action = 'showNotification',
        type = type,
        title = title,
        message = message
    })
end)

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('OpenUI', function(uiType, data)
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        uiType = uiType,
        data = data
    })
end)

-- CloseUI export already defined above

-- ====================================================================================================
-- ⌨️ KEY HANDLERS
-- ====================================================================================================

-- ESC key handler to close UI
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if uiOpen then
            -- Check for ESC key (ID: 322)
            if IsControlJustReleased(0, 322) then
                CloseUI()
            end
        else
            Citizen.Wait(500)
        end
    end
end)

-- ====================================================================================================
-- 🛑 RESOURCE STOP HANDLER
-- ====================================================================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Close UI on resource stop to prevent freeze
    if uiOpen then
        CloseUI()
    end
end)
