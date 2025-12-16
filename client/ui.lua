-- ====================================================================================================
-- 🖥️ NUI EVENT HANDLERS
-- Handle NUI callbacks and messages
-- ====================================================================================================

-- ====================================================================================================
-- 📥 NUI CALLBACKS
-- ====================================================================================================

-- Close NUI
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Property action
RegisterNUICallback('propertyAction', function(data, cb)
    local action = data.action
    local propertyId = data.propertyId
    
    if action == 'purchase' then
        -- Open purchase dialog
        SetNuiFocus(false, false)
        TriggerEvent('property:openPurchaseDialog', propertyId)
    elseif action == 'rent' then
        -- Open rent dialog
        SetNuiFocus(false, false)
        TriggerEvent('property:openRentDialog', propertyId)
    elseif action == 'viewing' then
        -- Book viewing
        TriggerServerEvent('property:bookViewing', propertyId)
        SetNuiFocus(false, false)
    elseif action == 'enter' then
        -- Enter property
        TriggerEvent('property:enter', propertyId)
        SetNuiFocus(false, false)
    elseif action == 'lock' then
        -- Toggle lock
        TriggerServerEvent('property:toggleLock', propertyId)
        SetNuiFocus(false, false)
    elseif action == 'garage' then
        -- Open garage
        TriggerEvent('property:openGarage', propertyId)
        SetNuiFocus(false, false)
    elseif action == 'storage' then
        -- Open storage
        TriggerServerEvent('property:openStorage', propertyId, 'safe')
        SetNuiFocus(false, false)
    elseif action == 'sell' then
        -- Sell property
        TriggerServerEvent('property:sell', propertyId)
        SetNuiFocus(false, false)
    end
    
    cb('ok')
end)

-- Purchase property
RegisterNUICallback('purchaseProperty', function(data, cb)
    TriggerServerEvent('property:purchase', data.propertyId, data.paymentMethod, data.useMortgage, data.mortgageData)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Rent property
RegisterNUICallback('rentProperty', function(data, cb)
    TriggerServerEvent('property:rent', data.propertyId, data.duration, data.paymentMethod)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Book short-term rental
RegisterNUICallback('bookRental', function(data, cb)
    TriggerServerEvent('property:bookRental', data.propertyId, data.days)
    SetNuiFocus(false, false)
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
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        uiType = uiType,
        data = data
    })
end)

exports('CloseUI', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end)
