-- ====================================================================================================
-- 🏠 GTA V IMMOBILIEN
-- Verifizierte Koordinaten mit VEC4-Format (x, y, z, heading)
-- WICHTIG: Häuser werden NUR nach Buchung im Makler-Büro auf der Karte sichtbar!
-- ====================================================================================================

Properties = {}

-- ====================================================================================================
-- BEISPIEL-IMMOBILIEN (ALLE KLASSEN EINMAL)
-- Diese Koordinaten sind verifiziert und funktionieren in GTA V
-- Später können weitere 700+ Häuser hinzugefügt werden
-- ====================================================================================================

Properties['all'] = {
    -- 🏢 OFFICE - Bürogebäude (für Geschäfte)
    {
        id = 'office_downtown_1',
        name = 'Downtown Business Center',
        type = 'office',
        entrance = vec4(-141.24, -620.09, 168.82, 70.0),  -- Maze Bank Tower Area
        interior = 'apa_v_mp_h_02_a',
        price = 450000,
        garage = 'medium',
        bedrooms = 0,  -- Keine Schlafzimmer in Büros
        bathrooms = 2,
        area = 'Downtown',
        description = 'Modernes Büro im Geschäftsviertel mit Panoramablick auf Los Santos'
    },
    
    -- 🏠 HOUSE - Einfamilienhaus
    {
        id = 'house_grove_1',
        name = 'Grove Street Familienhaus',
        type = 'house',
        entrance = vec4(-14.32, -1440.53, 31.10, 180.0),  -- Grove Street
        interior = 'apa_v_mp_h_01_a',
        price = 165000,
        garage = 'small',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Grove Street',
        description = 'Gemütliches Familienhaus in beliebter Nachbarschaft'
    },
    
    -- 🏨 HOTEL - Hotel-Zimmer (für Kurzzeitmiete)
    {
        id = 'hotel_ls_1',
        name = 'Los Santos Hotel Suite',
        type = 'hotel',
        entrance = vec4(285.24, -160.74, 64.62, 160.0),  -- Casino/Hotel Area
        interior = 'apa_v_mp_h_01_a',
        price = 95000,  -- Günstiger für Kurzzeitmiete
        garage = 'small',
        bedrooms = 1,
        bathrooms = 1,
        area = 'Downtown',
        description = 'Luxuriöse Hotel-Suite im Herzen von Los Santos'
    },
    
    -- 🏘️ APARTMENT - Wohnung/Apartment
    {
        id = 'apt_eclipse_1',
        name = 'Eclipse Towers Apartment',
        type = 'apartment',
        entrance = vec4(-773.41, 312.44, 85.70, 180.0),  -- Eclipse Towers
        interior = 'apa_v_mp_h_01_a',
        price = 125000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 1,
        area = 'Rockford Hills',
        description = 'Moderne Wohnung in prestigeträchtigem Hochhaus'
    },
    
    -- 🏡 VILLA - Große Villa mit Pool
    {
        id = 'villa_vinewood_1',
        name = 'Vinewood Hills Villa',
        type = 'villa',
        entrance = vec4(119.16, 564.10, 184.30, 10.0),  -- Vinewood Hills
        interior = 'apa_v_mp_h_03_a',
        price = 875000,
        garage = 'large',
        bedrooms = 6,
        bathrooms = 4,
        area = 'Vinewood Hills',
        description = 'Traumhafte Villa mit Pool, Tennisplatz und atemberaubendem Blick'
    },
    
    -- 🏰 MANSION - Riesen-Anwesen für Elite
    {
        id = 'mansion_richman_1',
        name = 'Richman Mansion',
        type = 'mansion',
        entrance = vec4(-1289.45, 439.23, 97.89, 180.0),  -- Richman
        interior = 'apa_v_mp_h_03_a',
        price = 1485000,
        garage = 'large',
        bedrooms = 10,
        bathrooms = 6,
        area = 'Richman',
        description = 'Majestätische Villa für die Elite - Das Kronjuwel von Los Santos'
    }
}

-- ====================================================================================================
-- EXPORT FÜR SERVER-SIDE
-- ====================================================================================================

return Properties
