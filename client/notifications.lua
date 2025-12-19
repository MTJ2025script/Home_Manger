-- ====================================================================================================
-- 🔔 NOTIFICATION SYSTEM
-- Custom notification display system
-- ====================================================================================================

local activeNotifications = {}

-- ====================================================================================================
-- 📢 SHOW NOTIFICATION
-- ====================================================================================================

function ShowNotification(type, title, message, duration)
    if not Config.Notifications.enabled then return end
    
    local notif = {
        id = GetGameTimer(),
        type = type,
        title = title,
        message = message,
        duration = duration or Config.Notifications.duration,
        timestamp = GetGameTimer()
    }
    
    table.insert(activeNotifications, notif)
    
    -- Play sound if enabled
    local soundConfig = Config.Notifications.types[type]
    if soundConfig and soundConfig.sound then
        PlaySoundFrontend(-1, 'CLICK_BACK', 'WEB_NAVIGATION_SOUNDS_PHONE', 1)
    end
    
    -- Send to NUI
    SendNUIMessage({
        action = 'showNotification',
        data = notif
    })
    
    -- Auto-remove after duration
    CreateThread(function()
        Wait(duration or Config.Notifications.duration)
        RemoveNotification(notif.id)
    end)
    
    -- Manage stack size
    if #activeNotifications > Config.Notifications.maxStack then
        RemoveNotification(activeNotifications[1].id)
    end
end

function RemoveNotification(id)
    for i, notif in ipairs(activeNotifications) do
        if notif.id == id then
            table.remove(activeNotifications, i)
            
            SendNUIMessage({
                action = 'removeNotification',
                id = id
            })
            
            break
        end
    end
end

-- ====================================================================================================
-- 📡 NETWORK EVENTS
-- ====================================================================================================

RegisterNetEvent('property:showNotification')
AddEventHandler('property:showNotification', function(type, title, message, duration)
    ShowNotification(type, title, message, duration)
end)

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('ShowNotification', ShowNotification)
exports('RemoveNotification', RemoveNotification)
