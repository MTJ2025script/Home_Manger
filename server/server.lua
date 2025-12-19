-- ====================================================================================================
-- 🚀 PROPERTY MANAGER - MAIN SERVER
-- Startup, Initialization, Framework Detection
-- ====================================================================================================

ESX = nil
QBCore = nil
Framework = nil

-- Framework Detection and Initialization
CreateThread(function()
    if Config.Framework == 'ESX' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'ESX'
        print('^2[Property Manager]^0 ESX Framework detected and loaded')
    elseif Config.Framework == 'QBCore' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'QBCore'
        print('^2[Property Manager]^0 QBCore Framework detected and loaded')
    else
        print('^1[Property Manager]^0 ERROR: No framework configured!')
    end
end)

-- ====================================================================================================
-- 💾 DATABASE INITIALIZATION
-- ====================================================================================================

-- Initialize properties from data file to database
CreateThread(function()
    Wait(2000) -- Wait for database connection
    
    local allProperties = GetAllProperties()
    
    if Config.Debug then
        print('^3[Property Manager]^0 Syncing ' .. #allProperties .. ' properties to database...')
    end
    
    for _, prop in ipairs(allProperties) do
        MySQL.Async.execute([[
            INSERT INTO properties (
                id, name, type, area,
                entrance_x, entrance_y, entrance_z, entrance_h,
                interior, price, garage_type,
                bedrooms, bathrooms, description
            ) VALUES (
                @id, @name, @type, @area,
                @entrance_x, @entrance_y, @entrance_z, @entrance_h,
                @interior, @price, @garage_type,
                @bedrooms, @bathrooms, @description
            ) ON DUPLICATE KEY UPDATE
                name = @name,
                type = @type,
                area = @area,
                entrance_x = @entrance_x,
                entrance_y = @entrance_y,
                entrance_z = @entrance_z,
                entrance_h = @entrance_h,
                interior = @interior,
                price = @price,
                garage_type = @garage_type,
                bedrooms = @bedrooms,
                bathrooms = @bathrooms,
                description = @description
        ]], {
            ['@id'] = prop.id,
            ['@name'] = prop.name,
            ['@type'] = prop.type,
            ['@area'] = prop.area,
            ['@entrance_x'] = prop.entrance.x,
            ['@entrance_y'] = prop.entrance.y,
            ['@entrance_z'] = prop.entrance.z,
            ['@entrance_h'] = prop.entrance.w,
            ['@interior'] = prop.interior,
            ['@price'] = prop.price,
            ['@garage_type'] = prop.garage,
            ['@bedrooms'] = prop.bedrooms,
            ['@bathrooms'] = prop.bathrooms,
            ['@description'] = prop.description
        })
    end
    
    if Config.Debug then
        print('^2[Property Manager]^0 Properties synced successfully!')
    end
    
    -- Auto-create garages for properties that don't have one
    if Config.Garages.enabled and Config.Garages.autoAssign then
        CreateThread(function()
            Wait(1000)
            MySQL.Async.fetchAll('SELECT id, garage_type FROM properties WHERE id NOT IN (SELECT property_id FROM property_garages)', {}, function(properties)
                for _, prop in ipairs(properties) do
                    CreateGarageForProperty(prop.id, prop.garage_type)
                end
                if Config.Debug then
                    print('^2[Property Manager]^0 Auto-created ' .. #properties .. ' garages')
                end
            end)
        end)
    end
end)

-- ====================================================================================================
-- 🔄 PERIODIC TASKS
-- ====================================================================================================

-- Payment checker - runs every 5 minutes
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        
        -- Check mortgage payments
        MySQL.Async.fetchAll('SELECT * FROM property_mortgages WHERE status = @status AND next_payment < NOW()', {
            ['@status'] = 'active'
        }, function(mortgages)
            for _, mortgage in ipairs(mortgages) do
                ProcessMissedMortgagePayment(mortgage)
            end
        end)
        
        -- Check rent payments
        MySQL.Async.fetchAll('SELECT * FROM property_tenants WHERE status = @status AND next_payment < NOW()', {
            ['@status'] = 'active'
        }, function(tenants)
            for _, tenant in ipairs(tenants) do
                ProcessMissedRentPayment(tenant)
            end
        end)
        
        -- Cleanup expired bookings
        MySQL.Async.execute('UPDATE property_bookings SET status = @expired WHERE status = @active AND end_time < NOW()', {
            ['@expired'] = 'expired',
            ['@active'] = 'active'
        })
        
        -- Cleanup expired shortterm keys
        if Config.Keys.shortTermKeys.autoCleanup then
            MySQL.Async.execute('DELETE FROM shortterm_keys WHERE expires_at < NOW()')
        end
    end
end)

-- Version check
if Config.VersionCheck.enabled then
    CreateThread(function()
        Wait(5000)
        PerformHttpRequest(Config.VersionCheck.url, function(statusCode, response, headers)
            if statusCode == 200 then
                local data = json.decode(response)
                if data and data.tag_name then
                    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
                    if data.tag_name ~= currentVersion then
                        print('^3[Property Manager]^0 New version available: ' .. data.tag_name)
                        print('^3[Property Manager]^0 Current version: ' .. currentVersion)
                        print('^3[Property Manager]^0 Download: https://github.com/MTJ2025script/Home_Manger/releases')
                    else
                        print('^2[Property Manager]^0 You are running the latest version (' .. currentVersion .. ')')
                    end
                end
            end
        end, 'GET')
    end)
end

-- ====================================================================================================
-- 🛠️ UTILITY FUNCTIONS
-- ====================================================================================================

-- Get player identifier based on framework
function GetPlayerIdentifier(source)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
    elseif Framework == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    end
    return nil
end

-- Get player money
function GetPlayerMoney(source, account)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return 0 end
        return xPlayer.getAccount(account).money
    elseif Framework == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return 0 end
        if account == 'bank' then
            return Player.PlayerData.money.bank
        else
            return Player.PlayerData.money.cash
        end
    end
    return 0
end

-- Remove player money
function RemovePlayerMoney(source, account, amount)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        if xPlayer.getAccount(account).money >= amount then
            xPlayer.removeAccountMoney(account, amount)
            return true
        end
        return false
    elseif Framework == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        local moneyType = account == 'bank' and 'bank' or 'cash'
        if Player.PlayerData.money[moneyType] >= amount then
            Player.Functions.RemoveMoney(moneyType, amount)
            return true
        end
        return false
    end
    return false
end

-- Add player money
function AddPlayerMoney(source, account, amount)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        xPlayer.addAccountMoney(account, amount)
        return true
    elseif Framework == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        local moneyType = account == 'bank' and 'bank' or 'cash'
        Player.Functions.AddMoney(moneyType, amount)
        return true
    end
    return false
end

-- Check if player has permission (admin)
function HasPermission(source, permission)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        return xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin'
    elseif Framework == 'QBCore' then
        return QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god')
    end
    return false
end

-- Log action to database
function LogAction(propertyId, playerId, action, details)
    if not Config.Logging.enabled then return end
    
    MySQL.Async.execute('INSERT INTO property_logs (property_id, player_id, action, details) VALUES (@property, @player, @action, @details)', {
        ['@property'] = propertyId,
        ['@player'] = playerId,
        ['@action'] = action,
        ['@details'] = details
    })
    
    if Config.Debug then
        print('^3[Property Manager Log]^0 ' .. action .. ' - ' .. (playerId or 'System') .. ' - ' .. (propertyId or 'N/A'))
    end
end

-- Send notification to player
function SendNotification(source, notifType, title, message, propertyId)
    if not Config.Notifications.enabled then return end
    
    local identifier = GetPlayerIdentifier(source)
    if not identifier then return end
    
    -- Store in database
    MySQL.Async.execute('INSERT INTO property_notifications (player_id, property_id, notification_type, title, message) VALUES (@player, @property, @type, @title, @message)', {
        ['@player'] = identifier,
        ['@property'] = propertyId,
        ['@type'] = notifType,
        ['@title'] = title,
        ['@message'] = message
    })
    
    -- Send to client
    TriggerClientEvent('property:notify', source, {
        type = notifType,
        title = title,
        message = message,
        duration = Config.Notifications.duration
    })
end

-- Generate random code
function GenerateCode(length)
    local code = ''
    for i = 1, length do
        code = code .. math.random(0, 9)
    end
    return code
end

-- ====================================================================================================
-- 📤 EXPORTS
-- ====================================================================================================

exports('GetPlayerIdentifier', GetPlayerIdentifier)
exports('GetPlayerMoney', GetPlayerMoney)
exports('RemovePlayerMoney', RemovePlayerMoney)
exports('AddPlayerMoney', AddPlayerMoney)
exports('HasPermission', HasPermission)
exports('LogAction', LogAction)
exports('SendNotification', SendNotification)
exports('GenerateCode', GenerateCode)

-- ====================================================================================================
-- 🎮 STARTUP MESSAGE
-- ====================================================================================================

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print([[
    ^2====================================================================================================
    🏠 PROPERTY MANAGER SYSTEM v1.0.0
    ====================================================================================================
    Framework: ^3]] .. (Framework or 'Not Detected') .. [[^0
    Properties Loaded: ^3]] .. #GetAllProperties() .. [[^0
    Market Mode: ^3]] .. Config.MarketMode .. [[^0
    Garages: ^3]] .. (Config.Garages.enabled and 'Enabled' or 'Disabled') .. [[^0
    Booking System: ^3]] .. (Config.Booking.enabled and 'Enabled' or 'Disabled') .. [[^0
    ====================================================================================================^0
    ]])
end)
