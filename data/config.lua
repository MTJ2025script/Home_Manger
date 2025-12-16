Config = {}

-- ====================================================================================================
-- 🏠 ALLGEMEINE EINSTELLUNGEN
-- ====================================================================================================

Config.Framework = 'ESX'                                    -- Framework: 'ESX' oder 'QBCore'
Config.Locale = 'de'                                        -- Sprache: 'de', 'en', 'fr'
Config.Debug = false                                        -- Debug-Modus aktivieren (mehr Logs)
Config.UseOxTarget = false                                  -- Ox Target statt Marker verwenden
Config.UseQBTarget = false                                  -- QB Target statt Marker verwenden

-- ====================================================================================================
-- 🏢 MAKLER-BÜROS (3 LOCATIONS - MULTI-BROKER SYSTEM)
-- ====================================================================================================

Config.RealtorOffices = {
    {
        name = 'Downtown Realty',                           -- Name des Büros
        blip = vec4(1124.5, 226.5, 69.0, 0.0),             -- Blip-Position mit Heading
        marker = vec4(1124.5, 226.5, 69.0, 0.0),           -- Marker-Position mit Heading
        sprite = 375,                                       -- Blip-Icon (375 = Realty)
        color = 3,                                          -- Blip-Farbe (3 = Grün)
        scale = 0.8,                                        -- Blip-Größe
        label = 'Downtown Realty',                          -- Blip-Label
        jobRestriction = nil                                -- Job-Einschränkung (nil = alle)
    },
    {
        name = 'Vinewood Luxury Realty',
        blip = vec4(1302.8, -528.5, 71.4, 90.0),
        marker = vec4(1302.8, -528.5, 71.4, 90.0),
        sprite = 375,
        color = 5,                                          -- Gold für Premium
        scale = 0.8,
        label = 'Vinewood Luxury Realty',
        jobRestriction = nil
    },
    {
        name = 'Del Perro Beach Properties',
        blip = vec4(150.2, -1044.3, 29.4, 180.0),
        marker = vec4(150.2, -1044.3, 29.4, 180.0),
        sprite = 375,
        color = 38,                                         -- Hellblau für Beach
        scale = 0.8,
        label = 'Del Perro Beach Properties',
        jobRestriction = nil
    }
}

-- ====================================================================================================
-- 💰 ZAHLUNGS-SYSTEM & HYPOTHEKEN
-- ====================================================================================================

Config.Payment = {
    useCash = true,                                         -- Bargeld-Zahlungen erlauben
    useBank = true,                                         -- Bank-Zahlungen erlauben
    currency = '$',                                         -- Währungssymbol
    
    mortgage = {
        enabled = true,                                     -- Hypotheken aktivieren
        minDownPayment = 20,                                -- Min. Anzahlung in Prozent
        maxDownPayment = 80,                                -- Max. Anzahlung in Prozent
        interestRate = 5.5,                                 -- Zinssatz pro Jahr in Prozent
        minDuration = 12,                                   -- Min. Laufzeit in Monaten
        maxDuration = 360,                                  -- Max. Laufzeit in Monaten (30 Jahre)
        paymentInterval = 7,                                -- Zahlungsintervall in Tagen (wöchentlich)
        gracePeriod = 3,                                    -- Kulanzzeit in Zahlungsintervallen
        repossessAfterMissed = 3                            -- Räumung nach X verpassten Zahlungen
    },
    
    rent = {
        enabled = true,                                     -- Vermietung aktivieren
        dailyRate = 0.05,                                   -- Tagesmiete (5% vom Kaufpreis)
        weeklyRate = 0.30,                                  -- Wochenmiete (30% vom Kaufpreis)
        monthlyRate = 1.0,                                  -- Monatsmiete (100% vom Kaufpreis)
        paymentInterval = 7,                                -- Zahlungsintervall in Tagen
        gracePeriod = 2,                                    -- Kulanzzeit in Zahlungsintervallen
        evictAfterMissed = 2                                -- Räumung nach X verpassten Zahlungen
    }
}

-- ====================================================================================================
-- 🚗 GARAGEN-SYSTEM (NUR STANDARD GTA ONLINE INTERIORS)
-- ====================================================================================================

Config.Garages = {
    enabled = true,                                         -- Garagen-System aktivieren
    autoAssign = true,                                      -- Automatisch Garage bei Hauskauf zuweisen
    
    types = {
        small = {
            name = 'Kleine Garage',                         -- Name
            interior = 'apa_v_mp_h_01_a',                   -- Interior-IPL
            slots = 6,                                      -- Fahrzeug-Slots
            spawn = vec4(-796.86, 331.62, 85.70, 0.0),     -- Spawn-Position im Interior
            entry = vec4(-809.06, 328.67, 85.70, 0.0)      -- Entry-Position im Interior
        },
        medium = {
            name = 'Mittlere Garage',
            interior = 'apa_v_mp_h_02_a',
            slots = 10,
            spawn = vec4(-796.86, 331.62, 85.70, 0.0),
            entry = vec4(-809.06, 328.67, 85.70, 0.0)
        },
        large = {
            name = 'Große Garage',
            interior = 'apa_v_mp_h_03_a',
            slots = 8,
            spawn = vec4(-796.86, 331.62, 85.70, 0.0),
            entry = vec4(-809.06, 328.67, 85.70, 0.0)
        }
    },
    
    blipSprite = 50,                                        -- Blip-Icon (50 = Garage)
    blipColor = 5,                                          -- Blip-Farbe (5 = Gold)
    blipScale = 0.7,                                        -- Blip-Größe
    
    saveVehicleState = true,                                -- Fahrzeug-Zustand speichern (Farbe, Mods, etc.)
    repairOnStore = false,                                  -- Fahrzeug beim Einlagern reparieren
    fuelOnRetrieve = false,                                 -- Fahrzeug beim Abholen volltanken
    
    markerType = 36,                                        -- Marker-Typ (36 = Kreis mit Pfeil)
    markerSize = vec3(1.5, 1.5, 1.0),                      -- Marker-Größe
    markerColor = {r = 0, g = 255, b = 0, a = 100},        -- Marker-Farbe (Grün)
    markerDistance = 10.0                                   -- Marker-Sichtweite
}

-- ====================================================================================================
-- 🔑 SCHLÜSSEL-SYSTEM
-- ====================================================================================================

Config.Keys = {
    enabled = true,                                         -- Schlüssel-System aktivieren
    usePhysicalKeys = true,                                 -- Physische Schlüssel als Items
    keyItem = 'property_key',                               -- Item-Name für Schlüssel
    
    permissions = {
        owner = {                                           -- Eigentümer-Rechte
            canEnter = true,                                -- Betreten
            canLock = true,                                 -- Abschließen
            canInvite = true,                               -- Gäste einladen
            canManageKeys = true,                           -- Schlüssel verwalten
            canAccessStorage = true,                        -- Storage zugriff
            canAccessGarage = true,                         -- Garagen-Zugriff
            canSell = true,                                 -- Verkaufen
            canRent = true                                  -- Vermieten
        },
        tenant = {                                          -- Mieter-Rechte
            canEnter = true,
            canLock = true,
            canInvite = false,
            canManageKeys = false,
            canAccessStorage = true,
            canAccessGarage = true,
            canSell = false,
            canRent = false
        },
        guest = {                                           -- Gast-Rechte
            canEnter = true,
            canLock = false,
            canInvite = false,
            canManageKeys = false,
            canAccessStorage = false,
            canAccessGarage = false,
            canSell = false,
            canRent = false
        }
    },
    
    shortTermKeys = {
        enabled = true,                                     -- Kurzzeitschlüssel aktivieren
        viewingDuration = 30,                               -- Besichtigungs-Dauer (Minuten)
        rentalDuration = 10080,                             -- Miet-Dauer (Minuten = 7 Tage)
        codeLength = 4,                                     -- Code-Länge (4-stellig)
        autoCleanup = true                                  -- Abgelaufene Codes automatisch löschen
    },
    
    duplication = {
        enabled = true,                                     -- Schlüssel-Duplikation erlauben
        cost = 500,                                         -- Kosten pro Duplikat
        requireItem = 'lockpick',                           -- Benötigtes Item (optional)
        requireSkill = false                                -- Skill-Check erforderlich
    },
    
    logging = {
        enabled = true,                                     -- Audit-Log aktivieren
        logDuration = 90                                    -- Log-Speicherdauer (Tage)
    }
}

-- ====================================================================================================
-- 📦 STORAGE & SAFES
-- ====================================================================================================

Config.Storage = {
    enabled = true,                                         -- Storage-System aktivieren
    
    safes = {
        small = {
            name = 'Kleiner Safe',                          -- Name
            slots = 30,                                     -- Inventar-Slots
            weight = 1000000,                               -- Max. Gewicht (1M = 1000kg)
            pinLength = 4,                                  -- PIN-Länge
            requirePin = true                               -- PIN erforderlich
        },
        medium = {
            name = 'Mittlerer Safe',
            slots = 40,
            weight = 2000000,
            pinLength = 6,
            requirePin = true
        },
        large = {
            name = 'Großer Safe',
            slots = 50,
            weight = 4000000,
            pinLength = 8,
            requirePin = true
        }
    },
    
    wardrobe = {
        enabled = true,                                     -- Kleiderschrank aktivieren
        slots = 20,                                         -- Outfit-Slots
        saveOutfits = true                                  -- Outfits speichern
    },
    
    stash = {
        enabled = true,                                     -- Stash aktivieren
        slots = 50,                                         -- Standard-Slots
        weight = 500000                                     -- Standard-Gewicht
    }
}

-- ====================================================================================================
-- 📅 BOOKING-SYSTEM (AIRBNB-STYLE)
-- ====================================================================================================

Config.Booking = {
    enabled = true,                                         -- Booking-System aktivieren
    
    viewing = {
        enabled = true,                                     -- Besichtigungen aktivieren
        duration = 30,                                      -- Dauer in Minuten
        cost = 0,                                           -- Kosten (0 = kostenlos)
        requireDeposit = false,                             -- Kaution erforderlich
        depositAmount = 1000,                               -- Kautions-Betrag
        autoRefund = true,                                  -- Kaution auto. zurück
        codeLength = 4                                      -- Code-Länge
    },
    
    shortTermRental = {
        enabled = true,                                     -- Kurzzeitmiete aktivieren
        minDuration = 1,                                    -- Min. Dauer in Tagen
        maxDuration = 7,                                    -- Max. Dauer in Tagen
        discountRate = 0.8,                                 -- Rabatt (80% vom Tagespreis)
        requireDeposit = true,
        depositAmount = 5000,
        autoRefund = true,
        codeLength = 4
    },
    
    purchase = {
        enabled = true,                                     -- Direktkauf aktivieren
        requireViewing = false,                             -- Besichtigung vorher nötig
        allowMortgage = true,                               -- Hypothek erlauben
        showGPS = true                                      -- GPS zum Haus anzeigen
    },
    
    notifications = {
        enabled = true,                                     -- Benachrichtigungen aktivieren
        showOnBooking = true,                               -- Bei Buchung benachrichtigen
        showOnExpiry = true,                                -- Bei Ablauf benachrichtigen
        showOnPayment = true                                -- Bei Zahlung benachrichtigen
    }
}

-- ====================================================================================================
-- 🏪 MARKT-MODI
-- ====================================================================================================

Config.MarketMode = 'HYBRID'                                -- Markt-Modus: 'OPEN', 'REALTOR_ONLY', 'HYBRID'

Config.Market = {
    openMarket = {
        enabled = true,                                     -- Offener Markt (Marker an Häusern)
        showBlips = true,                                   -- Blips anzeigen
        showMarkers = true,                                 -- Marker anzeigen
        markerType = 27,                                    -- Marker-Typ
        markerSize = vec3(1.0, 1.0, 1.0),
        markerColor = {r = 255, g = 255, b = 255, a = 100},
        interactionDistance = 2.5                           -- Interaktions-Distanz
    },
    
    realtorOnly = {
        enabled = true,                                     -- Nur Makler können verkaufen
        requiredJob = 'realtor',                            -- Job-Name
        commission = 5,                                     -- Provision in Prozent
        showCommission = true,                              -- Provision anzeigen
        payCommissionTo = 'society'                         -- 'player' oder 'society'
    },
    
    hybrid = {
        allowPlayerSales = true,                            -- Spieler-Verkäufe erlauben
        realtorBonus = 2,                                   -- Makler-Bonus in Prozent
        realtorExclusiveListings = false                    -- Exklusive Makler-Angebote
    }
}

-- ====================================================================================================
-- 🏠 IMMOBILIEN-EINSTELLUNGEN
-- ====================================================================================================

Config.Properties = {
    maxPropertiesPerPlayer = 3,                             -- Max. Häuser pro Spieler
    allowMultipleOwners = false,                            -- Mehrere Eigentümer erlauben
    
    blips = {
        available = {                                       -- Verfügbare Häuser
            sprite = 40,                                    -- Blip-Icon (40 = Haus)
            color = 0,                                      -- Farbe (0 = Weiß)
            scale = 0.7,
            alpha = 255,
            shortRange = true
        },
        owned = {                                           -- Gekaufte Häuser
            sprite = 40,
            color = 2,                                      -- Farbe (2 = Grün)
            scale = 0.7,
            alpha = 255,
            shortRange = true
        },
        rented = {                                          -- Vermietete Häuser
            sprite = 40,
            color = 3,                                      -- Farbe (3 = Blau)
            scale = 0.7,
            alpha = 255,
            shortRange = true
        },
        viewing = {                                         -- Bei Besichtigung
            sprite = 40,
            color = 5,                                      -- Farbe (5 = Gold)
            scale = 0.9,
            alpha = 255,
            shortRange = false
        }
    },
    
    markers = {
        type = 27,                                          -- Marker-Typ (27 = Zylinder)
        size = vec3(1.5, 1.5, 0.5),
        color = {r = 0, g = 255, b = 0, a = 100},
        bobUpAndDown = false,
        rotate = false,
        drawDistance = 25.0,
        interactionDistance = 2.0
    },
    
    doors = {
        lockSystem = 'internal',                            -- 'internal', 'nui_doorlock', 'qb-doorlock'
        autoLock = true,                                    -- Auto. abschließen beim Verlassen
        lockSound = true,                                   -- Sound beim Abschließen
        unlockSound = true                                  -- Sound beim Aufschließen
    }
}

-- ====================================================================================================
-- 🔔 NOTIFICATIONS
-- ====================================================================================================

Config.Notifications = {
    position = 'bottom-center',                             -- Position: 'top', 'bottom', 'center'
    duration = 5000,                                        -- Dauer in Millisekunden
    maxStack = 5,                                           -- Max. gleichzeitige Notifications
    
    types = {
        success = {
            color = '#10b981',                              -- Grün
            icon = '✓',
            sound = true,
            soundFile = 'success.ogg'
        },
        error = {
            color = '#ef4444',                              -- Rot
            icon = '✗',
            sound = true,
            soundFile = 'error.ogg'
        },
        warning = {
            color = '#f59e0b',                              -- Orange
            icon = '⚠',
            sound = true,
            soundFile = 'warning.ogg'
        },
        info = {
            color = '#3b82f6',                              -- Blau
            icon = 'ℹ',
            sound = false,
            soundFile = 'info.ogg'
        }
    },
    
    animations = {
        slideIn = true,                                     -- Slide-In Animation
        slideOut = true,                                    -- Slide-Out Animation
        fade = true,                                        -- Fade Animation
        duration = 300                                      -- Animations-Dauer (ms)
    }
}

-- ====================================================================================================
-- 🎨 UI-FARBEN & THEMES
-- ====================================================================================================

Config.UI = {
    theme = 'dark',                                         -- Theme: 'dark', 'light'
    
    colors = {
        primary = '#8b5cf6',                                -- Lila/Purple
        secondary = '#3b82f6',                              -- Blau
        accent = '#f59e0b',                                 -- Gold/Orange
        success = '#10b981',                                -- Grün
        danger = '#ef4444',                                 -- Rot
        warning = '#f59e0b',                                -- Orange
        info = '#3b82f6',                                   -- Blau
        
        background = '#1a1a2e',                             -- Dunkler Hintergrund
        surface = '#16213e',                                -- Surface
        card = '#0f3460',                                   -- Card-Hintergrund
        
        text = {
            primary = '#ffffff',                            -- Primärer Text (Weiß)
            secondary = '#94a3b8',                          -- Sekundärer Text (Grau)
            muted = '#64748b'                               -- Gedämpfter Text
        },
        
        neon = {
            blue = '#00f0ff',                               -- Neon Blau
            purple = '#bf00ff',                             -- Neon Lila
            pink = '#ff00e6',                               -- Neon Pink
            green = '#00ff88',                              -- Neon Grün
            gold = '#ffd700'                                -- Gold
        }
    },
    
    glassmorphism = {
        enabled = true,                                     -- Glassmorphism-Effekt
        blur = 10,                                          -- Blur-Stärke
        opacity = 0.1,                                      -- Transparenz
        borderOpacity = 0.2                                 -- Border-Transparenz
    },
    
    animations = {
        enabled = true,                                     -- Animationen aktivieren
        duration = 300,                                     -- Animations-Dauer (ms)
        easing = 'ease-in-out'                             -- Easing-Funktion
    }
}

-- ====================================================================================================
-- 🛡️ SICHERHEIT & ANTI-CHEAT
-- ====================================================================================================

Config.Security = {
    antiCheat = {
        enabled = true,                                     -- Anti-Cheat aktivieren
        checkInterval = 60000,                              -- Check-Intervall (ms)
        maxDistance = 100.0,                                -- Max. Distanz für Interaktionen
        validateServer = true,                              -- Server-Side Validation
        logSuspicious = true                                -- Verdächtige Aktionen loggen
    },
    
    rateLimit = {
        enabled = true,                                     -- Rate-Limiting aktivieren
        maxRequests = 10,                                   -- Max. Requests pro Zeitfenster
        timeWindow = 60000,                                 -- Zeitfenster (ms)
        banOnExceed = false,                                -- Bei Überschreitung bannen
        cooldown = 5000                                     -- Cooldown nach Limit (ms)
    }
}

-- ====================================================================================================
-- 📊 LOGGING & DEBUG
-- ====================================================================================================

Config.Logging = {
    enabled = true,                                         -- Logging aktivieren
    level = 'info',                                         -- Log-Level: 'debug', 'info', 'warn', 'error'
    
    events = {
        propertyPurchase = true,                            -- Hauskauf loggen
        propertyRent = true,                                -- Vermietung loggen
        keysGiven = true,                                   -- Schlüssel-Ausgabe loggen
        payment = true,                                     -- Zahlungen loggen
        eviction = true,                                    -- Räumungen loggen
        adminActions = true                                 -- Admin-Aktionen loggen
    },
    
    database = {
        enabled = true,                                     -- In DB speichern
        retention = 90                                      -- Speicherdauer (Tage)
    },
    
    discord = {
        enabled = false,                                    -- Discord-Webhook
        webhook = '',                                       -- Webhook-URL
        color = 3447003,                                    -- Embed-Farbe
        username = 'Property Manager',                      -- Bot-Name
        avatar = ''                                         -- Bot-Avatar URL
    }
}

-- ====================================================================================================
-- 🔄 VERSION CHECK
-- ====================================================================================================

Config.VersionCheck = {
    enabled = true,                                         -- Versions-Check aktivieren
    url = 'https://api.github.com/repos/MTJ2025script/Home_Manger/releases/latest'
}

return Config
