-- ====================================================================================================
-- 🖥️ NUI EVENT HANDLERS
-- Handle NUI callbacks and messages
-- ====================================================================================================

-- ====================================================================================================
-- 🔒 CENTRALIZED UI CLOSE FUNCTION (Prevents UI Freeze)
-- ====================================================================================================

local uiOpen = false

function CloseUI()
    -- Always clean up focus properly to prevent freeze
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    
    -- Send close message to NUI
    SendNUIMessage({
        action = 'close'
    })
    
    uiOpen = false
    
    if Config.Debug then
        print('[Property Manager] UI closed properly - focus cleaned')
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
    
    if action == 'purchase' then
        -- Open purchase dialog
        CloseUI()
        TriggerEvent('property:openPurchaseDialog', propertyId)
    elseif action == 'rent' then
        -- Open rent dialog
        CloseUI()
        TriggerEvent('property:openRentDialog', propertyId)
    elseif action == 'viewing' then
        -- Book viewing
        CloseUI()
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
