-- ====================================================================================================
-- 📅 BOOKING CLIENT
-- Booking dialogs and code entry
-- ====================================================================================================

-- Placeholder for booking client-side logic

-- Booking created
RegisterNetEvent('property:bookingCreated')
AddEventHandler('property:bookingCreated', function(booking)
    Notify('success', _('success'), 'Access Code: ' .. booking.accessCode)
    
    -- Show booking UI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showBooking',
        booking = booking
    })
end)

-- Open code entry
RegisterCommand('entercode', function()
    local input = KeyboardInput('Enter Access Code', '', 4)
    if input and #input > 0 then
        -- Find nearest property
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearestProperty = nil
        local nearestDist = 999999
        
        for _, property in ipairs(properties) do
            local propCoords = vector3(property.entrance_x, property.entrance_y, property.entrance_z)
            local dist = #(playerCoords - propCoords)
            
            if dist < nearestDist and dist < 5.0 then
                nearestDist = dist
                nearestProperty = property
            end
        end
        
        if nearestProperty then
            TriggerServerEvent('property:validateCode', nearestProperty.id, input)
        else
            Notify('error', _('error'), 'No property nearby')
        end
    end
end)

-- Code validated
RegisterNetEvent('property:codeValidated')
AddEventHandler('property:codeValidated', function(propertyId, keyData)
    Notify('success', _('success'), _('valid_code'))
end)

-- Code invalid
RegisterNetEvent('property:codeInvalid')
AddEventHandler('property:codeInvalid', function(propertyId)
    Notify('error', _('error'), _('invalid_code'))
end)
