-- ====================================================================================================
-- 🏢 MAKLER-BÜROS (3 LOCATIONS)
-- Diese Büros zeigen alle denselben Live-Katalog (MySQL-Sync)
-- ====================================================================================================

RealtorBranches = {
    -- Downtown Realty - Klassisches Geschäftsviertel
    {
        id = 1,
        name = 'Downtown Realty',
        description = 'Ihr vertrauenswürdiger Partner für Immobilien im Geschäftsviertel',
        location = vec4(1124.5, 226.5, 69.0, 0.0),
        blip = {
            sprite = 375,
            color = 3,
            scale = 0.8,
            shortRange = true,
            display = 4
        },
        marker = {
            type = 27,
            size = vec3(1.5, 1.5, 0.5),
            color = {r = 0, g = 255, b = 0, a = 100},
            drawDistance = 25.0,
            interactionDistance = 2.0
        },
        jobRestriction = nil,  -- nil = alle Spieler können nutzen
        commission = 5.0,      -- Provision in Prozent
        active = true
    },
    
    -- Vinewood Luxury Realty - Premium Verkäufer
    {
        id = 2,
        name = 'Vinewood Luxury Realty',
        description = 'Exklusive Immobilien für anspruchsvolle Kunden',
        location = vec4(1302.8, -528.5, 71.4, 90.0),
        blip = {
            sprite = 375,
            color = 5,
            scale = 0.8,
            shortRange = true,
            display = 4
        },
        marker = {
            type = 27,
            size = vec3(1.5, 1.5, 0.5),
            color = {r = 255, g = 215, b = 0, a = 100},
            drawDistance = 25.0,
            interactionDistance = 2.0
        },
        jobRestriction = nil,
        commission = 7.5,  -- Höhere Provision für Luxus-Immobilien
        active = true
    },
    
    -- Del Perro Beach Properties - Casual Beach-Office
    {
        id = 3,
        name = 'Del Perro Beach Properties',
        description = 'Traumhafte Strandimmobilien und mehr',
        location = vec4(150.2, -1044.3, 29.4, 180.0),
        blip = {
            sprite = 375,
            color = 38,
            scale = 0.8,
            shortRange = true,
            display = 4
        },
        marker = {
            type = 27,
            size = vec3(1.5, 1.5, 0.5),
            color = {r = 0, g = 191, b = 255, a = 100},
            drawDistance = 25.0,
            interactionDistance = 2.0
        },
        jobRestriction = nil,
        commission = 5.0,
        active = true
    }
}

return RealtorBranches
