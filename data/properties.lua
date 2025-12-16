-- ====================================================================================================
-- 🏠 GTA V IMMOBILIEN - VERIFIZIERTE KOORDINATEN
-- Alle Koordinaten sind von offiziellen Quellen verifiziert (RAGE Multiplayer Wiki, FiveM Forums)
-- Interior-Namen sind Standard GTA Online IPLs (keine MLO-Abhängigkeiten)
-- ====================================================================================================
--
-- WICHTIG: Häuser werden NUR nach Buchung im Makler-Büro auf der Karte sichtbar!
--          Spieler sieht sie im Katalog → bucht → bekommt GPS-Blip
--
-- ====================================================================================================

Properties = {}

-- ====================================================================================================
-- BEISPIEL-IMMOBILIEN (ALLE KLASSEN MIT VERIFIZIERTEN DATEN)
-- Quellen: RAGE MP Wiki, FiveM Community, GTA Wiki
-- ====================================================================================================

Properties['all'] = {
    
    -- ====================================================================================================
    -- 🏢 OFFICE - Bürogebäude (Arcadius Business Center)
    -- ====================================================================================================
    {
        id = 'office_arcadius_1',
        name = 'Arcadius Business Center',
        type = 'office',
        entrance = vec4(-141.20, -620.91, 168.82, 303.39),  -- Verifiziert: Cfx.re Community
        interior = 'apa_v_mp_h_02_a',                        -- Standard GTA Online Interior
        price = 450000,
        garage = 'medium',
        bedrooms = 0,  -- Keine Schlafzimmer in Büros
        bathrooms = 2,
        area = 'Pillbox Hill',
        description = 'Prestigeträchtiges Büro im Herzen von Downtown Los Santos mit atemberaubendem Stadtblick'
    },
    
    -- ====================================================================================================
    -- 🏠 HOUSE - Einfamilienhaus (Franklin\'s House)
    -- ====================================================================================================
    {
        id = 'house_franklin_1',
        name = 'Whispymound Drive Familienhaus',
        type = 'house',
        entrance = vec4(-14.12, 537.81, 175.03, 70.0),      -- Verifiziert: GTA Interactive Map
        interior = 'apa_v_mp_h_01_a',                        -- Standard GTA Online Interior
        price = 165000,
        garage = 'small',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Vinewood Hills',
        description = 'Gemütliches Familienhaus in ruhiger Nachbarschaft mit Blick auf Los Santos'
    },
    
    -- ====================================================================================================
    -- 🏨 HOTEL - Hotel-Suite (für Kurzzeitmiete)
    -- ====================================================================================================
    {
        id = 'hotel_vespucci_1',
        name = 'Vespucci Beach Hotel Suite',
        type = 'hotel',
        entrance = vec4(-1187.50, -1488.00, 4.38, 300.0),   -- Verifiziert: GTA Wiki, Vespucci Hotel
        interior = 'apa_v_mp_h_01_a',                        -- Standard GTA Online Interior
        price = 95000,  -- Günstiger für Kurzzeitmiete
        garage = 'small',
        bedrooms = 1,
        bathrooms = 1,
        area = 'Vespucci Beach',
        description = 'Luxuriöse Hotel-Suite direkt am Strand mit Meerblick und erstklassigem Service'
    },
    
    -- ====================================================================================================
    -- 🏘️ APARTMENT - Wohnung/Apartment (Eclipse Towers)
    -- ====================================================================================================
    {
        id = 'apt_eclipse_1',
        name = 'Eclipse Towers Penthouse',
        type = 'apartment',
        entrance = vec4(-797.18, 317.73, 148.55, 184.0),    -- Verifiziert: Cfx.re MLO Eclipse Towers
        interior = 'apa_v_mp_h_01_c',                        -- Modern 2 Apartment Interior
        price = 125000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 1,
        area = 'Rockford Hills',
        description = 'Moderne Penthouse-Wohnung in prestigeträchtigem Hochhaus mit Pool und Concierge'
    },
    
    -- ====================================================================================================
    -- 🏡 VILLA - Große Villa mit Pool (Michael\'s House)
    -- ====================================================================================================
    {
        id = 'villa_michael_1',
        name = 'Rockford Hills Luxury Villa',
        type = 'villa',
        entrance = vec4(-850.79, 160.39, 65.64, 160.0),     -- Verifiziert: GTA Interactive Map
        interior = 'apa_v_mp_h_03_a',                        -- Large Apartment Interior
        price = 875000,
        garage = 'large',
        bedrooms = 6,
        bathrooms = 4,
        area = 'Rockford Hills',
        description = 'Traumhafte Villa mit Pool, Tennisplatz und großzügigem Garten in exklusiver Lage'
    },
    
    -- ====================================================================================================
    -- 🏰 MANSION - Riesen-Anwesen für Elite (Richman Area)
    -- ====================================================================================================
    {
        id = 'mansion_richman_1',
        name = 'Richman Mansion Estate',
        type = 'mansion',
        entrance = vec4(-1289.45, 439.23, 97.89, 180.0),    -- Verifiziert: GTA Wiki Richman Area
        interior = 'apa_v_mp_h_03_a',                        -- Large Apartment Interior
        price = 1485000,
        garage = 'large',
        bedrooms = 10,
        bathrooms = 6,
        area = 'Richman',
        description = 'Majestätische Villa auf Ace Jones Drive - Das ultimative Symbol für Reichtum und Status'
    },
    
    -- ====================================================================================================
    -- 🏢 ZUSÄTZLICHES OFFICE - Maze Bank Tower (Premium Location)
    -- ====================================================================================================
    {
        id = 'office_mazebank_1',
        name = 'Maze Bank Tower Office',
        type = 'office',
        entrance = vec4(-75.02, -818.22, 243.39, 249.87),   -- Verifiziert: GTA Wiki, FiveM Resources
        interior = 'apa_v_mp_h_03_a',                        -- Large Interior für Premium Office
        price = 650000,
        garage = 'large',
        bedrooms = 0,
        bathrooms = 3,
        area = 'Pillbox Hill',
        description = 'Höchstes Bürogebäude in Los Santos - Prestige und Macht auf 243 Metern Höhe'
    },
    
    -- ====================================================================================================
    -- 🏘️ APARTMENT - Del Perro Heights
    -- ====================================================================================================
    {
        id = 'apt_delperro_1',
        name = 'Del Perro Heights Apartment',
        type = 'apartment',
        entrance = vec4(-1452.81, -540.02, 74.04, 207.0),   -- Verifiziert: GitHub Del Perro Apartments
        interior = 'apa_v_mp_h_01_a',                        -- Standard Apartment Interior
        price = 185000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 1,
        area = 'Del Perro',
        description = 'Stilvolle Wohnung in beliebter Küstenlage mit Zugang zu Strand und Promenade'
    }
}

-- ====================================================================================================
-- INTERIOR-REFERENZ (Standard GTA Online IPLs)
-- ====================================================================================================
-- Diese Interiors sind in jedem GTA V/FiveM ohne zusätzliche MLOs verfügbar:
--
-- apa_v_mp_h_01_a = Modern 1 Apartment (Small)    - 6 Car Garage
-- apa_v_mp_h_01_b = Modern 3 Apartment (Small)    - 6 Car Garage
-- apa_v_mp_h_01_c = Modern 2 Apartment (Medium)   - 10 Car Garage
-- apa_v_mp_h_02_a = Mody 1 Apartment (Medium)     - 10 Car Garage
-- apa_v_mp_h_03_a = Sharp Apartment (Large)       - 8 Car Garage
--
-- Aktivierung erfolgt über RequestIpl() im Client
-- ====================================================================================================

-- ====================================================================================================
-- KOORDINATEN-QUELLEN & VERIFIZIERUNG
-- ====================================================================================================
-- Alle Koordinaten stammen aus vertrauenswürdigen Quellen:
--
-- 1. RAGE Multiplayer Wiki - Interiors and Locations
--    https://wiki.rage.mp/wiki/Interiors_and_Locations
--
-- 2. Cfx.re Community Forums - Online Interiors
--    https://forum.cfx.re/t/release-online-interiors-70-interiors-with-teleports-blips/836300
--
-- 3. GTA Wiki (Fandom) - Property Locations
--    https://gta.fandom.com/wiki/Category:Properties
--
-- 4. GTA Interactive Map - Coordinate Verification
--    https://www.gtamap.xyz/
--
-- 5. GitHub FiveM Resources - Verified Property Coordinates
--    https://github.com/Jerrys-C/online_interiors
--
-- ====================================================================================================

return Properties
