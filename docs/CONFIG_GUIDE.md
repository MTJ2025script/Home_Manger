# ⚙️ Konfigurations-Guide

Detaillierte Erklärung aller Konfigurations-Optionen.

## 📂 Datei: data/config.lua

### 🏠 Allgemeine Einstellungen

```lua
Config.Framework = 'ESX'        -- Framework: 'ESX' oder 'QBCore'
Config.Locale = 'de'             -- Sprache: 'de', 'en', 'fr'
Config.Debug = false             -- Debug-Modus (mehr Logs)
```

**Framework:** Wähle dein verwendetes Framework.
**Locale:** Hauptsprache für das System.
**Debug:** Aktiviere für detaillierte Logs (nur für Entwicklung).

### 🏢 Makler-Büros

Die 3 Makler-Büros sind bereits vorkonfiguriert:

```lua
Config.RealtorOffices = {
    {
        name = 'Downtown Realty',
        blip = vec4(1124.5, 226.5, 69.0, 0.0),
        marker = vec4(1124.5, 226.5, 69.0, 0.0),
        sprite = 375,
        color = 3,
        -- ...
    }
    -- ...
}
```

**Anpassungen:**
- `name`: Name des Büros
- `blip`: Position mit Heading (vec4)
- `sprite`: Blip-Icon ID
- `color`: Blip-Farbe
- `jobRestriction`: Job erforderlich (nil = alle)
- `commission`: Provisions-Prozentsatz

### 💰 Zahlungs-System

#### Hypotheken

```lua
Config.Payment.mortgage = {
    enabled = true,              -- Hypotheken aktivieren
    minDownPayment = 20,         -- Min. Anzahlung (20%)
    maxDownPayment = 80,         -- Max. Anzahlung (80%)
    interestRate = 5.5,          -- Zinssatz pro Jahr (5.5%)
    minDuration = 12,            -- Min. Laufzeit (12 Monate)
    maxDuration = 360,           -- Max. Laufzeit (30 Jahre)
    paymentInterval = 7,         -- Zahlungsintervall (7 Tage)
    gracePeriod = 3,             -- Kulanzzeit (3 Zahlungen)
    repossessAfterMissed = 3     -- Räumung nach X Zahlungen
}
```

**Empfehlung:**
- Zinssatz: 3-7% (realistisch)
- Payment Interval: 7 Tage (wöchentlich)
- Grace Period: 2-3 (fair für Spieler)

#### Mieten

```lua
Config.Payment.rent = {
    enabled = true,              -- Vermietung aktivieren
    dailyRate = 0.05,            -- 5% vom Kaufpreis pro Tag
    weeklyRate = 0.30,           -- 30% vom Kaufpreis pro Woche
    monthlyRate = 1.0,           -- 100% vom Kaufpreis pro Monat
    paymentInterval = 7,         -- Wöchentliche Zahlung
    gracePeriod = 2,             -- Kulanzzeit
    evictAfterMissed = 2         -- Räumung nach X Zahlungen
}
```

**Tipps:**
- Daily Rate: 0.03-0.08 (3-8%)
- Payment Interval: 7 Tage empfohlen
- Grace Period: 1-2 ausreichend

### 🚗 Garagen-System

```lua
Config.Garages = {
    enabled = true,              -- Garagen aktivieren
    autoAssign = true,           -- Auto. Garage bei Kauf
    
    types = {
        small = {
            slots = 6,           -- 6 Fahrzeug-Slots
            interior = 'apa_v_mp_h_01_a'
        },
        medium = {
            slots = 10,
            interior = 'apa_v_mp_h_02_a'
        },
        large = {
            slots = 8,
            interior = 'apa_v_mp_h_03_a'
        }
    },
    
    saveVehicleState = true,     -- Zustand speichern
    repairOnStore = false,       -- Beim Einlagern reparieren
    fuelOnRetrieve = false       -- Beim Abholen volltanken
}
```

**Wichtig:**
- Nur Standard GTA Online Interiors verwenden!
- `autoAssign`: Sollte true sein
- `saveVehicleState`: Empfohlen true
- `repairOnStore`: false für Realismus

### 🔑 Schlüssel-System

```lua
Config.Keys = {
    enabled = true,
    usePhysicalKeys = true,      -- Items im Inventory
    keyItem = 'property_key',
    
    permissions = {
        owner = {
            canEnter = true,
            canLock = true,
            canInvite = true,
            canManageKeys = true,
            canAccessStorage = true,
            canAccessGarage = true,
            canSell = true,
            canRent = true
        },
        tenant = {
            canEnter = true,
            canLock = true,
            canInvite = false,
            canManageKeys = false,
            canAccessStorage = true,
            canAccessGarage = true,
            canSell = false,
            canRent = false
        },
        guest = {
            canEnter = true,
            canLock = false,
            -- ... minimal permissions
        }
    }
}
```

**Anpassungen:**
- `usePhysicalKeys`: Nur wenn Inventory-Integration gewünscht
- Permissions können pro Level angepasst werden

#### Kurzzeitschlüssel

```lua
Config.Keys.shortTermKeys = {
    enabled = true,
    viewingDuration = 30,        -- 30 Minuten
    rentalDuration = 10080,      -- 7 Tage
    codeLength = 4,              -- 4-stellig
    autoCleanup = true           -- Auto. löschen
}
```

### 📦 Storage & Safes

```lua
Config.Storage = {
    enabled = true,
    
    safes = {
        small = {
            slots = 30,
            weight = 1000000,    -- 1000kg
            pinLength = 4
        },
        medium = {
            slots = 40,
            weight = 2000000,
            pinLength = 6
        },
        large = {
            slots = 50,
            weight = 4000000,
            pinLength = 8
        }
    }
}
```

**Empfehlung:**
- Small: Apartments
- Medium: Häuser
- Large: Villen/Mansions

### 📅 Booking-System

```lua
Config.Booking = {
    enabled = true,
    
    viewing = {
        enabled = true,
        duration = 30,           -- Minuten
        cost = 0,                -- Kostenlos
        requireDeposit = false,
        codeLength = 4
    },
    
    shortTermRental = {
        enabled = true,
        minDuration = 1,         -- Min. 1 Tag
        maxDuration = 7,         -- Max. 7 Tage
        discountRate = 0.8,      -- 20% Rabatt
        requireDeposit = true,
        depositAmount = 5000
    }
}
```

### 🏪 Markt-Modi

```lua
Config.MarketMode = 'HYBRID'     -- 'OPEN', 'REALTOR_ONLY', 'HYBRID'

Config.Market = {
    openMarket = {
        enabled = true,
        showBlips = true,
        showMarkers = true
    },
    
    realtorOnly = {
        enabled = true,
        requiredJob = 'realtor',
        commission = 5,          -- 5% Provision
        payCommissionTo = 'society'
    },
    
    hybrid = {
        allowPlayerSales = true,
        realtorBonus = 2,        -- +2% für Makler
        realtorExclusiveListings = false
    }
}
```

**Modi-Erklärung:**
- **OPEN**: Jeder kann kaufen/verkaufen
- **REALTOR_ONLY**: Nur Makler-Job
- **HYBRID**: Beides möglich (empfohlen)

### 🏠 Immobilien-Einstellungen

```lua
Config.Properties = {
    maxPropertiesPerPlayer = 3,  -- Max. Häuser pro Spieler
    allowMultipleOwners = false, -- Mehrere Eigentümer
    
    blips = {
        available = {
            sprite = 40,
            color = 0,           -- Weiß
            scale = 0.7
        },
        owned = {
            color = 2            -- Grün
        },
        rented = {
            color = 3            -- Blau
        }
    }
}
```

### 🔔 Notifications

```lua
Config.Notifications = {
    position = 'bottom-center',
    duration = 5000,             -- 5 Sekunden
    maxStack = 5,
    
    types = {
        success = {
            color = '#10b981',
            icon = '✓',
            sound = true
        },
        -- ...
    }
}
```

### 🎨 UI-Farben

```lua
Config.UI = {
    theme = 'dark',
    
    colors = {
        primary = '#8b5cf6',     -- Lila
        secondary = '#3b82f6',   -- Blau
        accent = '#f59e0b',      -- Gold
        success = '#10b981',     -- Grün
        danger = '#ef4444',      -- Rot
        -- ...
    }
}
```

**Anpassungen:**
- Farben können als HEX-Codes angepasst werden
- Theme: 'dark' oder 'light'

### 🛡️ Sicherheit

```lua
Config.Security = {
    antiCheat = {
        enabled = true,
        checkInterval = 60000,   -- 1 Minute
        maxDistance = 100.0,
        validateServer = true
    },
    
    rateLimit = {
        enabled = true,
        maxRequests = 10,
        timeWindow = 60000
    }
}
```

**Empfehlung:** Alle Sicherheits-Features aktiviert lassen!

### 📊 Logging

```lua
Config.Logging = {
    enabled = true,
    level = 'info',              -- 'debug', 'info', 'warn', 'error'
    
    events = {
        propertyPurchase = true,
        propertyRent = true,
        keysGiven = true,
        payment = true,
        eviction = true,
        adminActions = true
    },
    
    database = {
        enabled = true,
        retention = 90           -- 90 Tage
    },
    
    discord = {
        enabled = false,
        webhook = '',
        color = 3447003
    }
}
```

## 🔄 Config Neu Laden

Nach Änderungen:

```
restart Home_Manger
```

Oder ohne Neustart (nur einige Einstellungen):

```
refresh
ensure Home_Manger
```

## 💡 Tipps

1. **Backup:** Sichere immer die Config vor Änderungen
2. **Test-Server:** Teste Änderungen zuerst auf Test-Server
3. **Kommentare:** Nutze `--` für eigene Notizen
4. **Vec4:** IMMER vec4(x, y, z, heading) verwenden!

## 🆘 Hilfe

Bei Problemen siehe [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
