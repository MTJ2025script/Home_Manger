-- ====================================================================================================
-- 🖥️ NUI EVENT HANDLERS
-- Handle NUI callbacks and messages
-- ====================================================================================================

-- ====================================================================================================
-- 🔒 CENTRALIZED UI CLOSE FUNCTION (Prevents UI Freeze)
-- ====================================================================================================

local uiOpen = false

function CloseUI()
    print('[Property Manager] ========== CLOSE UI START ==========')
    local playerId = PlayerId()
    local playerPed = PlayerPedId()
    print('[Property Manager] Player ID:', playerId, 'Ped:', playerPed)
    
    -- STEP 1: Remove NUI focus FIRST (most critical)
    print('[Property Manager] Step 1: Removing NUI focus...')
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    print('[Property Manager] Step 1: NUI focus removed ✓')
    
    -- STEP 2: Unfreeze player entity
    print('[Property Manager] Step 2: Unfreezing player entity...')
    local wasFrozen = IsEntityPositionFrozen(playerPed)
    print('[Property Manager] Player was frozen:', wasFrozen)
    FreezeEntityPosition(playerPed, false)
    local isFrozenNow = IsEntityPositionFrozen(playerPed)
    print('[Property Manager] Player frozen now:', isFrozenNow)
    print('[Property Manager] Step 2: Player unfrozen ✓')
    
    -- STEP 3: Force all controls enabled
    print('[Property Manager] Step 3: Enabling all controls...')
    SetPlayerControl(playerId, true, 0)
    EnableAllControlActions(0)
    EnableAllControlActions(1)
    EnableAllControlActions(2)
    print('[Property Manager] Step 3: Controls enabled ✓')
    
    -- STEP 4: Destroy all cameras
    print('[Property Manager] Step 4: Destroying cameras...')
    local renderCam = GetRenderingCam()
    print('[Property Manager] Render camera handle:', renderCam)
    if renderCam and renderCam ~= -1 then
        SetCamActive(renderCam, false)
        print('[Property Manager] Deactivated render camera')
    end
    DestroyAllCams(true)
    RenderScriptCams(false, false, 0, true, true)
    print('[Property Manager] Step 4: Cameras destroyed ✓')
    
    -- STEP 5: Restore HUD
    print('[Property Manager] Step 5: Restoring HUD...')
    DisplayRadar(true)
    DisplayHud(true)
    print('[Property Manager] Step 5: HUD restored ✓')
    
    -- STEP 6: Send NUI close message (after everything freed)
    print('[Property Manager] Step 6: Sending NUI close message...')
    SendNUIMessage({
        action = 'forceClose'
    })
    print('[Property Manager] Step 6: NUI message sent ✓')
    
    -- STEP 7: Small wait for cleanup
    print('[Property Manager] Step 7: Waiting 5ms for cleanup...')
    Citizen.Wait(5)
    print('[Property Manager] Step 7: Wait complete ✓')
    
    -- STEP 8: Additional control restoration
    print('[Property Manager] Step 8: Additional cleanup...')
    SetPlayerInvincible(playerId, false)
    print('[Property Manager] Step 8: Invincibility disabled ✓')
    
    -- STEP 9: Clear ped tasks
    print('[Property Manager] Step 9: Clearing ped tasks...')
    ClearPedTasksImmediately(playerPed)
    print('[Property Manager] Step 9: Ped tasks cleared ✓')
    
    -- STEP 10: Update state
    print('[Property Manager] Step 10: Updating state...')
    uiOpen = false
    
    -- Update global state
    if _G.PropertyUIState then
        _G.PropertyUIState.isOpen = false
        _G.PropertyUIState.currentUI = nil
        _G.PropertyUIState.lastClose = GetGameTimer()
        print('[Property Manager] Global state updated - lastClose:', _G.PropertyUIState.lastClose)
    end
    print('[Property Manager] Step 10: State updated ✓')
    
    -- FINAL CHECK
    print('[Property Manager] ========== FINAL CHECK ==========')
    print('[Property Manager] NUI Focus should be false')
    print('[Property Manager] Player frozen:', IsEntityPositionFrozen(playerPed))
    print('[Property Manager] Can player move:', not IsEntityPositionFrozen(playerPed))
    print('[Property Manager] UI Open state:', uiOpen)
    print('[Property Manager] ========== CLOSE UI COMPLETE ==========')
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
