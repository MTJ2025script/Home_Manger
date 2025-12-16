-- ====================================================================================================
-- 👑 ADMIN PANEL & COMMANDS
-- Administrative functions for property management
-- ====================================================================================================

-- ====================================================================================================
-- 🔨 ADMIN COMMANDS
-- ====================================================================================================

-- Create property (admin command)
RegisterCommand('createproperty', function(source, args, rawCommand)
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    -- Open admin property creation UI
    TriggerClientEvent('property:openAdminCreate', source)
end, false)

-- Edit property (admin command)
RegisterCommand('editproperty', function(source, args, rawCommand)
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    if not args[1] then
        SendNotification(source, 'error', _('error'), 'Usage: /editproperty [property_id]')
        return
    end
    
    local propertyId = args[1]
    
    -- Get property data
    MySQL.Async.fetchAll('SELECT * FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if result[1] then
            TriggerClientEvent('property:openAdminEdit', source, result[1])
        else
            SendNotification(source, 'error', _('error'), _('property_not_found'))
        end
    end)
end, false)

-- Delete property (admin command)
RegisterCommand('deleteproperty', function(source, args, rawCommand)
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    if not args[1] then
        SendNotification(source, 'error', _('error'), 'Usage: /deleteproperty [property_id]')
        return
    end
    
    local propertyId = args[1]
    
    MySQL.Async.execute('DELETE FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(affectedRows)
        if affectedRows > 0 then
            LogAction(propertyId, GetPlayerIdentifier(source), 'admin_delete', 'Admin deleted property')
            SendNotification(source, 'success', _('success'), _('property_deleted'))
            TriggerClientEvent('property:removeProperty', -1, propertyId)
        else
            SendNotification(source, 'error', _('error'), _('property_not_found'))
        end
    end)
end, false)

-- Transfer ownership (admin command)
RegisterCommand('transferproperty', function(source, args, rawCommand)
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    if not args[1] or not args[2] then
        SendNotification(source, 'error', _('error'), 'Usage: /transferproperty [property_id] [player_id]')
        return
    end
    
    local propertyId = args[1]
    local targetId = tonumber(args[2])
    local targetIdentifier = GetPlayerIdentifier(targetId)
    
    if not targetIdentifier then
        SendNotification(source, 'error', _('error'), _('player_not_found'))
        return
    end
    
    -- Transfer ownership
    MySQL.Async.execute('UPDATE properties SET owner = @owner, status = @status WHERE id = @id', {
        ['@owner'] = targetIdentifier,
        ['@status'] = 'owned',
        ['@id'] = propertyId
    }, function(affectedRows)
        if affectedRows > 0 then
            -- Update keys
            MySQL.Async.execute('DELETE FROM property_keys WHERE property_id = @property', {
                ['@property'] = propertyId
            })
            GivePropertyKey(propertyId, targetIdentifier, 'owner', 'admin')
            
            LogAction(propertyId, GetPlayerIdentifier(source), 'admin_transfer', 'Admin transferred property to ' .. targetIdentifier)
            SendNotification(source, 'success', _('success'), _('ownership_transferred'))
            SendNotification(targetId, 'success', _('success'), 'You have been given ownership of a property', propertyId)
            
            TriggerClientEvent('property:updateProperty', -1, propertyId, {
                owner = targetIdentifier,
                status = 'owned'
            })
        else
            SendNotification(source, 'error', _('error'), _('property_not_found'))
        end
    end)
end, false)

-- Evict tenant (admin command)
RegisterCommand('evictproperty', function(source, args, rawCommand)
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    if not args[1] then
        SendNotification(source, 'error', _('error'), 'Usage: /evictproperty [property_id]')
        return
    end
    
    local propertyId = args[1]
    
    TriggerEvent('property:adminEvict', source, propertyId)
end, false)

-- Open admin panel
RegisterCommand('adminprop', function(source, args, rawCommand)
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    TriggerClientEvent('property:openAdminPanel', source)
end, false)

-- Get property info (admin command)
RegisterCommand('propertyinfo', function(source, args, rawCommand)
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    if not args[1] then
        SendNotification(source, 'error', _('error'), 'Usage: /propertyinfo [property_id]')
        return
    end
    
    local propertyId = args[1]
    
    MySQL.Async.fetchAll([[
        SELECT p.*,
               (SELECT COUNT(*) FROM property_keys WHERE property_id = p.id) as key_count,
               (SELECT COUNT(*) FROM garage_vehicles WHERE property_id = p.id AND stored = 1) as vehicle_count
        FROM properties p
        WHERE p.id = @id
    ]], {
        ['@id'] = propertyId
    }, function(result)
        if result[1] then
            TriggerClientEvent('property:receiveAdminInfo', source, result[1])
        else
            SendNotification(source, 'error', _('error'), _('property_not_found'))
        end
    end)
end, false)

-- Get all properties (admin command)
RegisterCommand('listproperties', function(source, args, rawCommand)
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    MySQL.Async.fetchAll('SELECT id, name, area, status, owner, tenant FROM properties ORDER BY area, name', {}, function(properties)
        TriggerClientEvent('property:receiveAdminList', source, properties)
    end)
end, false)

-- ====================================================================================================
-- 🛠️ ADMIN EVENTS
-- ====================================================================================================

-- Create property from admin panel
RegisterNetEvent('property:adminCreate')
AddEventHandler('property:adminCreate', function(propertyData)
    local source = source
    
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    MySQL.Async.execute([[
        INSERT INTO properties (
            id, name, type, area,
            entrance_x, entrance_y, entrance_z, entrance_h,
            interior, price, garage_type,
            bedrooms, bathrooms, description
        ) VALUES (
            @id, @name, @type, @area,
            @x, @y, @z, @h,
            @interior, @price, @garage,
            @bedrooms, @bathrooms, @desc
        )
    ]], {
        ['@id'] = propertyData.id,
        ['@name'] = propertyData.name,
        ['@type'] = propertyData.type,
        ['@area'] = propertyData.area,
        ['@x'] = propertyData.entrance.x,
        ['@y'] = propertyData.entrance.y,
        ['@z'] = propertyData.entrance.z,
        ['@h'] = propertyData.entrance.w or 0.0,
        ['@interior'] = propertyData.interior,
        ['@price'] = propertyData.price,
        ['@garage'] = propertyData.garage_type,
        ['@bedrooms'] = propertyData.bedrooms,
        ['@bathrooms'] = propertyData.bathrooms,
        ['@desc'] = propertyData.description
    }, function()
        -- Create garage
        if Config.Garages.autoAssign then
            CreateGarageForProperty(propertyData.id, propertyData.garage_type)
        end
        
        LogAction(propertyData.id, GetPlayerIdentifier(source), 'admin_create', 'Admin created property')
        SendNotification(source, 'success', _('success'), _('property_created'))
        
        -- Notify all clients
        TriggerClientEvent('property:addProperty', -1, propertyData)
    end)
end)

-- Update property from admin panel
RegisterNetEvent('property:adminUpdate')
AddEventHandler('property:adminUpdate', function(propertyId, propertyData)
    local source = source
    
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    MySQL.Async.execute([[
        UPDATE properties SET
            name = @name,
            type = @type,
            area = @area,
            entrance_x = @x,
            entrance_y = @y,
            entrance_z = @z,
            entrance_h = @h,
            interior = @interior,
            price = @price,
            garage_type = @garage,
            bedrooms = @bedrooms,
            bathrooms = @bathrooms,
            description = @desc
        WHERE id = @id
    ]], {
        ['@id'] = propertyId,
        ['@name'] = propertyData.name,
        ['@type'] = propertyData.type,
        ['@area'] = propertyData.area,
        ['@x'] = propertyData.entrance.x,
        ['@y'] = propertyData.entrance.y,
        ['@z'] = propertyData.entrance.z,
        ['@h'] = propertyData.entrance.w or 0.0,
        ['@interior'] = propertyData.interior,
        ['@price'] = propertyData.price,
        ['@garage'] = propertyData.garage_type,
        ['@bedrooms'] = propertyData.bedrooms,
        ['@bathrooms'] = propertyData.bathrooms,
        ['@desc'] = propertyData.description
    }, function(affectedRows)
        if affectedRows > 0 then
            LogAction(propertyId, GetPlayerIdentifier(source), 'admin_update', 'Admin updated property')
            SendNotification(source, 'success', _('success'), _('property_updated'))
            
            -- Notify all clients
            TriggerClientEvent('property:updateProperty', -1, propertyId, propertyData)
        else
            SendNotification(source, 'error', _('error'), _('property_not_found'))
        end
    end)
end)

-- Get statistics (admin panel)
RegisterNetEvent('property:getStatistics')
AddEventHandler('property:getStatistics', function()
    local source = source
    
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    MySQL.Async.fetchAll([[
        SELECT
            (SELECT COUNT(*) FROM properties) as total_properties,
            (SELECT COUNT(*) FROM properties WHERE status = 'available') as available,
            (SELECT COUNT(*) FROM properties WHERE status = 'owned') as owned,
            (SELECT COUNT(*) FROM properties WHERE status = 'rented') as rented,
            (SELECT COUNT(*) FROM property_mortgages WHERE status = 'active') as active_mortgages,
            (SELECT COUNT(*) FROM property_tenants WHERE status = 'active') as active_tenants,
            (SELECT COUNT(*) FROM property_bookings WHERE status = 'active') as active_bookings,
            (SELECT SUM(remaining_amount) FROM property_mortgages WHERE status = 'active') as total_mortgage_debt,
            (SELECT COUNT(*) FROM garage_vehicles WHERE stored = 1) as stored_vehicles
    ]], {}, function(result)
        TriggerClientEvent('property:receiveStatistics', source, result[1])
    end)
end)

-- Get recent logs (admin panel)
RegisterNetEvent('property:getRecentLogs')
AddEventHandler('property:getRecentLogs', function(limit)
    local source = source
    
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    local queryLimit = limit or 100
    
    MySQL.Async.fetchAll('SELECT * FROM property_logs ORDER BY created_at DESC LIMIT ?', {queryLimit}, function(logs)
        TriggerClientEvent('property:receiveRecentLogs', source, logs)
    end)
end)

-- Reset property (admin)
RegisterNetEvent('property:adminReset')
AddEventHandler('property:adminReset', function(propertyId)
    local source = source
    
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    -- Reset property to default state
    MySQL.Async.execute([[
        UPDATE properties SET
            owner = NULL,
            tenant = NULL,
            status = 'available',
            for_sale = 1,
            for_rent = 1,
            locked = 1
        WHERE id = @id
    ]], {
        ['@id'] = propertyId
    }, function(affectedRows)
        if affectedRows > 0 then
            -- Clear all related data
            MySQL.Async.execute('DELETE FROM property_keys WHERE property_id = @property', {['@property'] = propertyId})
            MySQL.Async.execute('DELETE FROM property_storage WHERE property_id = @property', {['@property'] = propertyId})
            MySQL.Async.execute('DELETE FROM garage_vehicles WHERE property_id = @property', {['@property'] = propertyId})
            MySQL.Async.execute('UPDATE property_bookings SET status = @status WHERE property_id = @property', {
                ['@status'] = 'cancelled',
                ['@property'] = propertyId
            })
            MySQL.Async.execute('UPDATE property_tenants SET status = @status WHERE property_id = @property', {
                ['@status'] = 'ended',
                ['@property'] = propertyId
            })
            MySQL.Async.execute('UPDATE property_mortgages SET status = @status WHERE property_id = @property', {
                ['@status'] = 'cancelled',
                ['@property'] = propertyId
            })
            
            LogAction(propertyId, GetPlayerIdentifier(source), 'admin_reset', 'Admin reset property')
            SendNotification(source, 'success', _('success'), 'Property reset to default state')
            
            -- Notify all clients
            TriggerClientEvent('property:updateProperty', -1, propertyId, {
                owner = nil,
                tenant = nil,
                status = 'available'
            })
        else
            SendNotification(source, 'error', _('error'), _('property_not_found'))
        end
    end)
end)

-- Teleport to property (admin)
RegisterCommand('tpprop', function(source, args, rawCommand)
    if not HasPermission(source, 'admin') then
        SendNotification(source, 'error', _('error'), _('no_permission'))
        return
    end
    
    if not args[1] then
        SendNotification(source, 'error', _('error'), 'Usage: /tpprop [property_id]')
        return
    end
    
    local propertyId = args[1]
    
    MySQL.Async.fetchAll('SELECT entrance_x, entrance_y, entrance_z, entrance_h FROM properties WHERE id = @id', {
        ['@id'] = propertyId
    }, function(result)
        if result[1] then
            TriggerClientEvent('property:teleport', source, result[1].entrance_x, result[1].entrance_y, result[1].entrance_z, result[1].entrance_h)
        else
            SendNotification(source, 'error', _('error'), _('property_not_found'))
        end
    end)
end, false)
