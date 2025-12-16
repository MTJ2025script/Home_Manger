-- ====================================================================================================
-- 🛠️ CLIENT UTILITY FUNCTIONS
-- Helper functions for client-side operations
-- ====================================================================================================

-- ====================================================================================================
-- 📢 NOTIFICATIONS
-- ====================================================================================================

function Notify(type, title, message, duration)
    if not Config.Notifications.enabled then return end
    
    SendNUIMessage({
        action = 'notify',
        data = {
            type = type,
            title = title,
            message = message,
            duration = duration or Config.Notifications.duration
        }
    })
end

RegisterNetEvent('property:notify')
AddEventHandler('property:notify', function(data)
    Notify(data.type, data.title, data.message, data.duration)
end)

-- ====================================================================================================
-- 🎨 DRAWING FUNCTIONS
-- ====================================================================================================

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
end

-- ====================================================================================================
-- 📝 INPUT FUNCTIONS
-- ====================================================================================================

function KeyboardInput(textEntry, inputText, maxLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, 'FMMC_KEY_TIP1', '', inputText, '', '', '', maxLength)
    
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        return result
    else
        Wait(500)
        return nil
    end
end

-- ====================================================================================================
-- 🔢 NUMBER FORMATTING
-- ====================================================================================================

function FormatNumber(num)
    local formatted = tostring(num)
    local k
    
    while true do
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
        if k == 0 then
            break
        end
    end
    
    return formatted
end

function FormatMoney(amount)
    return Config.Payment.currency .. FormatNumber(amount)
end

-- ====================================================================================================
-- ⏰ TIME FUNCTIONS
-- ====================================================================================================

function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format('%02d:%02d:%02d', hours, minutes, secs)
    else
        return string.format('%02d:%02d', minutes, secs)
    end
end

function FormatDate(timestamp)
    return os.date('%Y-%m-%d %H:%M:%S', timestamp)
end

-- ====================================================================================================
-- 📊 TABLE FUNCTIONS
-- ====================================================================================================

function TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function TableCount(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- ====================================================================================================
-- 🎯 VECTOR FUNCTIONS
-- ====================================================================================================

function GetDistanceBetweenCoords(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
end

function IsPlayerNearCoords(coords, distance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return #(playerCoords - coords) <= distance
end

-- ====================================================================================================
-- 🚗 VEHICLE FUNCTIONS
-- ====================================================================================================

function GetVehicleInDirection()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local inDirection = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local rayHandle = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
    local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
    
    if hit and IsEntityAVehicle(entityHit) then
        return entityHit
    end
    
    return nil
end

function GetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then return nil end
    
    local color1, color2 = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local extras = {}
    
    for i = 0, 12 do
        if DoesExtraExist(vehicle, i) then
            local state = IsVehicleExtraTurnedOn(vehicle, i)
            extras[tostring(i)] = state
        end
    end
    
    return {
        model = GetEntityModel(vehicle),
        plate = GetVehicleNumberPlateText(vehicle),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
        bodyHealth = GetVehicleBodyHealth(vehicle),
        engineHealth = GetVehicleEngineHealth(vehicle),
        tankHealth = GetVehiclePetrolTankHealth(vehicle),
        fuelLevel = GetVehicleFuelLevel(vehicle),
        dirtLevel = GetVehicleDirtLevel(vehicle),
        color1 = color1,
        color2 = color2,
        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,
        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        neonEnabled = {
            IsVehicleNeonLightEnabled(vehicle, 0),
            IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2),
            IsVehicleNeonLightEnabled(vehicle, 3)
        },
        extras = extras,
        neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
        tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
        modSpoilers = GetVehicleMod(vehicle, 0),
        modFrontBumper = GetVehicleMod(vehicle, 1),
        modRearBumper = GetVehicleMod(vehicle, 2),
        modSideSkirt = GetVehicleMod(vehicle, 3),
        modExhaust = GetVehicleMod(vehicle, 4),
        modFrame = GetVehicleMod(vehicle, 5),
        modGrille = GetVehicleMod(vehicle, 6),
        modHood = GetVehicleMod(vehicle, 7),
        modFender = GetVehicleMod(vehicle, 8),
        modRightFender = GetVehicleMod(vehicle, 9),
        modRoof = GetVehicleMod(vehicle, 10),
        modEngine = GetVehicleMod(vehicle, 11),
        modBrakes = GetVehicleMod(vehicle, 12),
        modTransmission = GetVehicleMod(vehicle, 13),
        modHorns = GetVehicleMod(vehicle, 14),
        modSuspension = GetVehicleMod(vehicle, 15),
        modArmor = GetVehicleMod(vehicle, 16),
        modTurbo = IsToggleModOn(vehicle, 18),
        modSmokeEnabled = IsToggleModOn(vehicle, 20),
        modXenon = IsToggleModOn(vehicle, 22),
        modFrontWheels = GetVehicleMod(vehicle, 23),
        modBackWheels = GetVehicleMod(vehicle, 24),
        modPlateHolder = GetVehicleMod(vehicle, 25),
        modVanityPlate = GetVehicleMod(vehicle, 26),
        modTrimA = GetVehicleMod(vehicle, 27),
        modOrnaments = GetVehicleMod(vehicle, 28),
        modDashboard = GetVehicleMod(vehicle, 29),
        modDial = GetVehicleMod(vehicle, 30),
        modDoorSpeaker = GetVehicleMod(vehicle, 31),
        modSeats = GetVehicleMod(vehicle, 32),
        modSteeringWheel = GetVehicleMod(vehicle, 33),
        modShifterLeavers = GetVehicleMod(vehicle, 34),
        modAPlate = GetVehicleMod(vehicle, 35),
        modSpeakers = GetVehicleMod(vehicle, 36),
        modTrunk = GetVehicleMod(vehicle, 37),
        modHydrolic = GetVehicleMod(vehicle, 38),
        modEngineBlock = GetVehicleMod(vehicle, 39),
        modAirFilter = GetVehicleMod(vehicle, 40),
        modStruts = GetVehicleMod(vehicle, 41),
        modArchCover = GetVehicleMod(vehicle, 42),
        modAerials = GetVehicleMod(vehicle, 43),
        modTrimB = GetVehicleMod(vehicle, 44),
        modTank = GetVehicleMod(vehicle, 45),
        modWindows = GetVehicleMod(vehicle, 46),
        modLivery = GetVehicleMod(vehicle, 48)
    }
end

function SetVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) then return end
    
    if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
    if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
    if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
    if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
    if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
    if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
    if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
    if props.color1 then SetVehicleColours(vehicle, props.color1, props.color2 or 0) end
    if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor or 0) end
    if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
    if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end
    
    if props.neonEnabled then
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(vehicle, i, props.neonEnabled[i + 1])
        end
    end
    
    if props.extras then
        for id, enabled in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(id), not enabled)
        end
    end
    
    if props.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end
    
    if props.modTurbo then
        ToggleVehicleMod(vehicle, 18, true)
    end
    
    if props.modSmokeEnabled then
        ToggleVehicleMod(vehicle, 20, true)
    end
    
    if props.modXenon then
        ToggleVehicleMod(vehicle, 22, true)
    end
    
    -- Set all mods
    local modKeys = {
        'modSpoilers', 'modFrontBumper', 'modRearBumper', 'modSideSkirt',
        'modExhaust', 'modFrame', 'modGrille', 'modHood', 'modFender',
        'modRightFender', 'modRoof', 'modEngine', 'modBrakes',
        'modTransmission', 'modHorns', 'modSuspension', 'modArmor',
        'modFrontWheels', 'modBackWheels', 'modPlateHolder', 'modVanityPlate',
        'modTrimA', 'modOrnaments', 'modDashboard', 'modDial',
        'modDoorSpeaker', 'modSeats', 'modSteeringWheel', 'modShifterLeavers',
        'modAPlate', 'modSpeakers', 'modTrunk', 'modHydrolic',
        'modEngineBlock', 'modAirFilter', 'modStruts', 'modArchCover',
        'modAerials', 'modTrimB', 'modTank', 'modWindows', 'modLivery'
    }
    
    for _, modKey in ipairs(modKeys) do
        if props[modKey] then
            local modIndex = string.match(modKey, '%d+')
            SetVehicleMod(vehicle, tonumber(modIndex) or 0, props[modKey], false)
        end
    end
end

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('Notify', Notify)
exports('DrawText3D', DrawText3D)
exports('KeyboardInput', KeyboardInput)
exports('FormatNumber', FormatNumber)
exports('FormatMoney', FormatMoney)
exports('FormatTime', FormatTime)
exports('GetVehicleProperties', GetVehicleProperties)
exports('SetVehicleProperties', SetVehicleProperties)
