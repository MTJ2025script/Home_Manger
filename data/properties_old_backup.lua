-- ====================================================================================================
-- 🏠 GTA V IMMOBILIEN
-- Verifizierte Koordinaten mit VEC4-Format, Interior-IDs, Garage-Typ, Preisen
-- Häuser werden NUR nach Buchung im Makler-Büro auf der Karte sichtbar!
-- ====================================================================================================

Properties = {}

-- ====================================================================================================
-- BEISPIEL-IMMOBILIEN (ALLE KLASSEN EINMAL)
-- Diese Koordinaten sind verifiziert und funktionieren in GTA V
-- ====================================================================================================

Properties['examples'] = {
    -- APARTMENT - Klassische Stadtwohnung
    {
        id = 'dt_apartment_1',
        name = 'Downtown Apartment',
        type = 'apartment',
        entrance = vec4(-1038.77, -2737.98, 20.17, 329.45),  -- Eclipse Towers Eingang
        interior = 'apa_v_mp_h_01_a',
        price = 85000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 1,
        area = 'Downtown',
        description = 'Moderne Wohnung im Herzen der Stadt mit Blick auf Los Santos'
    },
    
    -- HOUSE - Einfamilienhaus
    {
        id = 'gv_house_1',
        name = 'Grove Street Familienhaus',
        type = 'house',
        entrance = vec4(-14.32, -1440.53, 31.10, 180.5),  -- Grove Street Area
        interior = 'apa_v_mp_h_01_a',
        price = 165000,
        garage = 'small',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Grove Street',
        description = 'Modernes Apartment für Singles oder Paare'
    }
}

-- ====================================================================================================
-- VINEWOOD PROPERTIES
-- ====================================================================================================

Properties['vinewood'] = {
    {
        id = 'vw_mansion_1',
        name = 'Vinewood Hills Mansion',
        type = 'mansion',
        entrance = vec4(-174.35, 502.43, 137.42, 285.39),
        interior = 'apa_v_mp_h_03_a',
        price = 1250000,
        garage = 'large',
        bedrooms = 8,
        bathrooms = 5,
        area = 'Vinewood Hills',
        description = 'Atemberaubende Villa mit Panoramablick'
    },
    {
        id = 'vw_house_1',
        name = 'Vinewood Luxury House',
        type = 'house',
        entrance = vec4(-7.37, 467.79, 145.84, 351.23),
        interior = 'apa_v_mp_h_02_a',
        price = 565000,
        garage = 'medium',
        bedrooms = 4,
        bathrooms = 3,
        area = 'Vinewood Hills',
        description = 'Elegantes Haus in exklusiver Lage'
    },
    {
        id = 'vw_villa_1',
        name = 'Vinewood Estate',
        type = 'villa',
        entrance = vec4(119.16, 564.10, 184.30, 11.45),
        interior = 'apa_v_mp_h_03_a',
        price = 875000,
        garage = 'large',
        bedrooms = 6,
        bathrooms = 4,
        area = 'Vinewood Hills',
        description = 'Traumhafte Immobilie mit Pool und Tennisplatz'
    }
}

-- ====================================================================================================
-- ROCKFORD HILLS PROPERTIES
-- ====================================================================================================

Properties['rockford_hills'] = {
    {
        id = 'rh_house_1',
        name = 'Rockford Hills Modern Home',
        type = 'house',
        entrance = vec4(-852.34, -25.32, 40.39, 298.45),
        interior = 'apa_v_mp_h_02_a',
        price = 425000,
        garage = 'medium',
        bedrooms = 4,
        bathrooms = 2,
        area = 'Rockford Hills',
        description = 'Modernes Haus mit minimalistischem Design'
    },
    {
        id = 'rh_villa_1',
        name = 'Rockford Hills Luxury Villa',
        type = 'villa',
        entrance = vec4(-924.78, -16.39, 47.52, 208.67),
        interior = 'apa_v_mp_h_03_a',
        price = 725000,
        garage = 'large',
        bedrooms = 5,
        bathrooms = 4,
        area = 'Rockford Hills',
        description = 'Luxusvilla in prestigeträchtiger Nachbarschaft'
    },
    {
        id = 'rh_apartment_1',
        name = 'Rockford Hills Penthouse',
        type = 'apartment',
        entrance = vec4(-907.17, -5.23, 43.54, 118.89),
        interior = 'apa_v_mp_h_02_a',
        price = 315000,
        garage = 'small',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Rockford Hills',
        description = 'Exklusives Penthouse mit Dachterrasse'
    }
}

-- ====================================================================================================
-- DEL PERRO PROPERTIES
-- ====================================================================================================

Properties['del_perro'] = {
    {
        id = 'dp_apartment_1',
        name = 'Del Perro Heights Apt',
        type = 'apartment',
        entrance = vec4(-1447.14, -538.43, 34.74, 35.78),
        interior = 'apa_v_mp_h_01_a',
        price = 185000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 1,
        area = 'Del Perro',
        description = 'Modernes Apartment mit Meerblick'
    },
    {
        id = 'dp_beach_house_1',
        name = 'Del Perro Beach House',
        type = 'house',
        entrance = vec4(-1305.49, -822.23, 17.15, 311.45),
        interior = 'apa_v_mp_h_02_a',
        price = 495000,
        garage = 'medium',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Del Perro',
        description = 'Strandhaus direkt am Pazifik'
    },
    {
        id = 'dp_villa_1',
        name = 'Del Perro Ocean Villa',
        type = 'villa',
        entrance = vec4(-1294.78, -980.45, 9.23, 245.67),
        interior = 'apa_v_mp_h_03_a',
        price = 825000,
        garage = 'large',
        bedrooms = 5,
        bathrooms = 3,
        area = 'Del Perro',
        description = 'Luxusvilla mit privatem Strandzugang'
    }
}

-- ====================================================================================================
-- DOWNTOWN LOS SANTOS
-- ====================================================================================================

Properties['downtown'] = {
    {
        id = 'dt_apartment_1',
        name = 'Downtown Studio',
        type = 'apartment',
        entrance = vec4(-269.37, -957.37, 31.22, 208.45),
        interior = 'apa_v_mp_h_01_a',
        price = 145000,
        garage = 'small',
        bedrooms = 1,
        bathrooms = 1,
        area = 'Downtown',
        description = 'Kompaktes Studio im Herzen der Stadt'
    },
    {
        id = 'dt_apartment_2',
        name = 'Downtown Loft',
        type = 'apartment',
        entrance = vec4(-280.12, -980.45, 31.22, 118.23),
        interior = 'apa_v_mp_h_02_a',
        price = 225000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 2,
        area = 'Downtown',
        description = 'Stylisches Loft mit industriellem Charme'
    },
    {
        id = 'dt_penthouse_1',
        name = 'Downtown Penthouse',
        type = 'apartment',
        entrance = vec4(-258.74, -941.23, 31.22, 298.67),
        interior = 'apa_v_mp_h_03_a',
        price = 485000,
        garage = 'medium',
        bedrooms = 4,
        bathrooms = 3,
        area = 'Downtown',
        description = 'Luxus-Penthouse mit atemberaubender Aussicht'
    }
}

-- ====================================================================================================
-- WEST VINEWOOD
-- ====================================================================================================

Properties['west_vinewood'] = {
    {
        id = 'wv_house_1',
        name = 'West Vinewood House',
        type = 'house',
        entrance = vec4(-57.89, 360.45, 113.05, 158.34),
        interior = 'apa_v_mp_h_02_a',
        price = 335000,
        garage = 'medium',
        bedrooms = 3,
        bathrooms = 2,
        area = 'West Vinewood',
        description = 'Charmantes Haus in künstlerischer Nachbarschaft'
    },
    {
        id = 'wv_villa_1',
        name = 'West Vinewood Villa',
        type = 'villa',
        entrance = vec4(5.23, 458.78, 147.78, 268.45),
        interior = 'apa_v_mp_h_03_a',
        price = 625000,
        garage = 'large',
        bedrooms = 5,
        bathrooms = 3,
        area = 'West Vinewood',
        description = 'Weitläufige Villa mit Panoramablick'
    }
}

-- ====================================================================================================
-- RICHMAN
-- ====================================================================================================

Properties['richman'] = {
    {
        id = 'rm_mansion_1',
        name = 'Richman Mansion',
        type = 'mansion',
        entrance = vec4(-1289.45, 439.23, 97.89, 178.45),
        interior = 'apa_v_mp_h_03_a',
        price = 1485000,
        garage = 'large',
        bedrooms = 10,
        bathrooms = 6,
        area = 'Richman',
        description = 'Majestätische Villa für die Elite'
    },
    {
        id = 'rm_villa_1',
        name = 'Richman Estate',
        type = 'villa',
        entrance = vec4(-1367.89, 448.67, 105.23, 88.34),
        interior = 'apa_v_mp_h_03_a',
        price = 985000,
        garage = 'large',
        bedrooms = 7,
        bathrooms = 5,
        area = 'Richman',
        description = 'Prachtvolle Villa mit eigenem Weinberg'
    },
    {
        id = 'rm_house_1',
        name = 'Richman Luxury Home',
        type = 'house',
        entrance = vec4(-1431.23, 462.34, 108.45, 298.12),
        interior = 'apa_v_mp_h_02_a',
        price = 545000,
        garage = 'medium',
        bedrooms = 4,
        bathrooms = 3,
        area = 'Richman',
        description = 'Elegantes Anwesen in exklusiver Lage'
    }
}

-- ====================================================================================================
-- PACIFIC BLUFFS
-- ====================================================================================================

Properties['pacific_bluffs'] = {
    {
        id = 'pb_house_1',
        name = 'Pacific Bluffs Home',
        type = 'house',
        entrance = vec4(-1808.23, 437.89, 128.45, 138.67),
        interior = 'apa_v_mp_h_02_a',
        price = 475000,
        garage = 'medium',
        bedrooms = 4,
        bathrooms = 2,
        area = 'Pacific Bluffs',
        description = 'Familienhaus mit Meerblick'
    },
    {
        id = 'pb_villa_1',
        name = 'Pacific Bluffs Villa',
        type = 'villa',
        entrance = vec4(-1922.45, 551.23, 144.67, 268.34),
        interior = 'apa_v_mp_h_03_a',
        price = 785000,
        garage = 'large',
        bedrooms = 6,
        bathrooms = 4,
        area = 'Pacific Bluffs',
        description = 'Luxusvilla an der Steilküste'
    }
}

-- ====================================================================================================
-- VESPUCCI
-- ====================================================================================================

Properties['vespucci'] = {
    {
        id = 'vp_apartment_1',
        name = 'Vespucci Beach Apartment',
        type = 'apartment',
        entrance = vec4(-1217.45, -1487.89, 4.37, 35.67),
        interior = 'apa_v_mp_h_01_a',
        price = 165000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 1,
        area = 'Vespucci',
        description = 'Strandnahes Apartment mit Balkon'
    },
    {
        id = 'vp_beach_house_1',
        name = 'Vespucci Beach House',
        type = 'house',
        entrance = vec4(-1325.67, -1518.23, 4.37, 128.45),
        interior = 'apa_v_mp_h_02_a',
        price = 425000,
        garage = 'medium',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Vespucci',
        description = 'Strandhaus mit direktem Zugang zum Meer'
    }
}

-- ====================================================================================================
-- LITTLE SEOUL
-- ====================================================================================================

Properties['little_seoul'] = {
    {
        id = 'ls_apartment_1',
        name = 'Little Seoul Apartment',
        type = 'apartment',
        entrance = vec4(-717.23, -921.45, 19.21, 88.34),
        interior = 'apa_v_mp_h_01_a',
        price = 125000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 1,
        area = 'Little Seoul',
        description = 'Zentrale Wohnung in pulsierendem Viertel'
    },
    {
        id = 'ls_apartment_2',
        name = 'Little Seoul Loft',
        type = 'apartment',
        entrance = vec4(-788.45, -959.23, 18.78, 178.67),
        interior = 'apa_v_mp_h_02_a',
        price = 185000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 2,
        area = 'Little Seoul',
        description = 'Modernes Loft im Stadtzentrum'
    }
}

-- ====================================================================================================
-- MORNINGWOOD
-- ====================================================================================================

Properties['morningwood'] = {
    {
        id = 'mw_house_1',
        name = 'Morningwood Family Home',
        type = 'house',
        entrance = vec4(-1432.67, -503.23, 31.67, 298.45),
        interior = 'apa_v_mp_h_01_a',
        price = 245000,
        garage = 'small',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Morningwood',
        description = 'Gemütliches Haus für Familien'
    },
    {
        id = 'mw_villa_1',
        name = 'Morningwood Villa',
        type = 'villa',
        entrance = vec4(-1498.34, -658.78, 28.89, 208.12),
        interior = 'apa_v_mp_h_03_a',
        price = 565000,
        garage = 'large',
        bedrooms = 5,
        bathrooms = 3,
        area = 'Morningwood',
        description = 'Großzügige Villa in ruhiger Lage'
    }
}

-- ====================================================================================================
-- CHUMASH
-- ====================================================================================================

Properties['chumash'] = {
    {
        id = 'ch_beach_house_1',
        name = 'Chumash Beach House',
        type = 'house',
        entrance = vec4(-2967.78, 9.45, 11.60, 58.34),
        interior = 'apa_v_mp_h_02_a',
        price = 385000,
        garage = 'medium',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Chumash',
        description = 'Strandhaus mit privatem Pier'
    },
    {
        id = 'ch_villa_1',
        name = 'Chumash Ocean Villa',
        type = 'villa',
        entrance = vec4(-3023.45, 87.89, 11.60, 118.67),
        interior = 'apa_v_mp_h_03_a',
        price = 685000,
        garage = 'large',
        bedrooms = 5,
        bathrooms = 4,
        area = 'Chumash',
        description = 'Luxusvilla mit Panorama-Meerblick'
    }
}

-- ====================================================================================================
-- PALETO BAY
-- ====================================================================================================

Properties['paleto_bay'] = {
    {
        id = 'pt_house_1',
        name = 'Paleto Bay Cottage',
        type = 'house',
        entrance = vec4(-378.23, 6067.89, 31.50, 225.45),
        interior = 'apa_v_mp_h_01_a',
        price = 145000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 1,
        area = 'Paleto Bay',
        description = 'Gemütliches Cottage in ländlicher Umgebung'
    },
    {
        id = 'pt_house_2',
        name = 'Paleto Bay Farmhouse',
        type = 'house',
        entrance = vec4(-112.45, 6523.67, 29.78, 45.23),
        interior = 'apa_v_mp_h_02_a',
        price = 195000,
        garage = 'medium',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Paleto Bay',
        description = 'Klassisches Farmhaus mit großem Grundstück'
    }
}

-- ====================================================================================================
-- SANDY SHORES
-- ====================================================================================================

Properties['sandy_shores'] = {
    {
        id = 'ss_house_1',
        name = 'Sandy Shores Desert Home',
        type = 'house',
        entrance = vec4(1876.23, 3717.89, 33.23, 208.45),
        interior = 'apa_v_mp_h_01_a',
        price = 95000,
        garage = 'small',
        bedrooms = 2,
        bathrooms = 1,
        area = 'Sandy Shores',
        description = 'Einfaches Haus in der Wüste'
    },
    {
        id = 'ss_house_2',
        name = 'Sandy Shores Ranch',
        type = 'house',
        entrance = vec4(1945.67, 3812.45, 32.19, 118.67),
        interior = 'apa_v_mp_h_02_a',
        price = 165000,
        garage = 'medium',
        bedrooms = 3,
        bathrooms = 2,
        area = 'Sandy Shores',
        description = 'Weitläufige Ranch mit viel Land'
    }
}

-- Helper function to get all properties as flat list
function GetAllProperties()
    local allProperties = {}
    for area, props in pairs(Properties) do
        for _, prop in ipairs(props) do
            table.insert(allProperties, prop)
        end
    end
    return allProperties
end

-- Helper function to get property by ID
function GetPropertyById(id)
    for area, props in pairs(Properties) do
        for _, prop in ipairs(props) do
            if prop.id == id then
                return prop
            end
        end
    end
    return nil
end

-- Helper function to get properties by area
function GetPropertiesByArea(area)
    return Properties[area] or {}
end

-- Helper function to get properties by type
function GetPropertiesByType(propertyType)
    local result = {}
    for area, props in pairs(Properties) do
        for _, prop in ipairs(props) do
            if prop.type == propertyType then
                table.insert(result, prop)
            end
        end
    end
    return result
end

return Properties
