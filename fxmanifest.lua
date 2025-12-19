fx_version 'cerulean'
game 'gta5'

author 'MTJ2025script'
description 'MEGA Property Manager System - Komplettes Immobilien-Verwaltungssystem für FiveM'
version '1.0.0'

lua54 'yes'

-- Shared Scripts
shared_scripts {
    '@es_extended/imports.lua',
    'data/config.lua',
    'data/locales.lua'
}

-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/properties.lua',
    'server/payments.lua',
    'server/keys.lua',
    'server/garages.lua',
    'server/bookings.lua',
    'server/admin.lua',
    'server/events.lua',
    'data/properties.lua',
    'data/branches.lua'
}

-- Client Scripts
client_scripts {
    'client/client.lua',
    'client/garage.lua',
    'client/booking.lua',
    'client/notifications.lua',
    'client/ui.lua',
    'client/utils.lua'
}

-- UI Files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/garage.html',
    'html/booking.html',
    'html/admin.html',
    'html/css/*.css',
    'html/js/*.js'
}

-- Dependencies
dependencies {
    'es_extended',
    'oxmysql'
}

-- Exports
exports {
    'GetPropertyData',
    'IsPropertyOwner',
    'HasPropertyAccess',
    'GetPlayerProperties'
}

server_exports {
    'CreateProperty',
    'DeleteProperty',
    'TransferOwnership',
    'AddPropertyKey',
    'RemovePropertyKey'
}
