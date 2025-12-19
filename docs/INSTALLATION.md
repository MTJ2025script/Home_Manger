# 📦 Installations-Anleitung

Schritt-für-Schritt Anleitung zur Installation des Property Manager Systems.

## 📋 Voraussetzungen

- FiveM Server (Empfohlen: Aktuelle Version)
- MySQL/MariaDB Datenbank
- ESX Legacy ODER QBCore Framework
- OXMySQL Ressource

## 🚀 Schritt 1: Repository Klonen

Navigiere in deinen `resources` Ordner und klone das Repository:

```bash
cd resources
git clone https://github.com/MTJ2025script/Home_Manger.git
```

Oder lade die ZIP-Datei herunter und entpacke sie in den `resources` Ordner.

## 🗄️ Schritt 2: Datenbank Einrichten

**⚠️ WICHTIG:** Das SQL-Skript MUSS in deiner existierenden ESX/QBCore Datenbank ausgeführt werden!

### Option A: Manueller Import (Empfohlen)

1. Öffne deine MySQL-Datenbank (z.B. mit phpMyAdmin, HeidiSQL, DBeaver)
2. **Wähle deine ESX/QBCore Datenbank aus** (z.B. `esxlegacy`, `es_extended`, `qbcore`)
3. Importiere die Datei `sql/database.sql`

### Option B: Kommandozeile

```bash
# Für ESX Legacy
mysql -u dein_user -p esxlegacy < sql/database.sql

# Oder mit USE statement
mysql -u dein_user -p
USE esxlegacy;  # oder dein Datenbankname
SOURCE /pfad/zu/Home_Manger/sql/database.sql;
```

**Hinweis:** Ersetze `esxlegacy` mit dem tatsächlichen Namen deiner Datenbank!

### Verifizierung

Überprüfe, ob folgende Tabellen erstellt wurden:
- properties
- property_keys
- property_storage
- property_garages
- garage_vehicles
- property_bookings
- shortterm_keys
- property_transactions
- property_tenants
- property_mortgages
- realtor_branches
- property_logs
- property_notifications

## ⚙️ Schritt 3: Konfiguration Anpassen

### 3.1 Framework Einstellen

Öffne `data/config.lua` und setze dein Framework:

```lua
Config.Framework = 'ESX'  -- Oder 'QBCore'
```

### 3.2 Sprache Einstellen

```lua
Config.Locale = 'de'  -- Oder 'en', 'fr'
```

### 3.3 Weitere Einstellungen

Passe folgende Einstellungen nach Bedarf an:
- Zahlungs-Einstellungen (Hypotheken, Mieten)
- Garagen-System
- Schlüssel-System
- Markt-Modus
- UI-Farben

Details siehe [CONFIG_GUIDE.md](CONFIG_GUIDE.md)

## 📝 Schritt 4: Server Config

Füge die Resource zu deiner `server.cfg` hinzu:

```cfg
ensure oxmysql
ensure es_extended  # oder qb-core
ensure Home_Manger
```

**Wichtig:** Home_Manger MUSS nach ESX/QBCore und OXMySQL geladen werden!

## 🔄 Schritt 5: Server Neustarten

Starte deinen FiveM Server neu:

```bash
restart
```

Oder starte nur die Resource:

```bash
refresh
ensure Home_Manger
```

## ✅ Schritt 6: Testen

### Test 1: Resource Gestartet?

Überprüfe die Server-Console:

```
====================================================================================================
🏠 PROPERTY MANAGER SYSTEM v1.0.0
====================================================================================================
Framework: ESX
Properties Loaded: 50
Market Mode: HYBRID
Garages: Enabled
Booking System: Enabled
====================================================================================================
```

### Test 2: Datenbank Verbindung

Logge dich auf dem Server ein. Du solltest keine Fehler in der F8-Console sehen.

### Test 3: Makler-Büro Besuchen

Fahre zu einem der 3 Makler-Büros:
- Downtown Realty (GPS: 1124.5, 226.5, 69.0)
- Vinewood Luxury Realty (GPS: 1302.8, -528.5, 71.4)
- Del Perro Beach Properties (GPS: 150.2, -1044.3, 29.4)

Drücke E am Marker → Der Immobilien-Katalog sollte sich öffnen.

### Test 4: Immobilie Kaufen

1. Öffne den Katalog
2. Wähle eine verfügbare Immobilie
3. Klicke auf "Kaufen"
4. Die Immobilie sollte dir gehören

## 🔧 Optionale Konfiguration

### Inventory Integration

Falls du ox_inventory oder qb-inventory verwendest, aktiviere physische Schlüssel:

```lua
Config.Keys.usePhysicalKeys = true
Config.Keys.keyItem = 'property_key'
```

Füge das Item zu deinem Inventory-Config hinzu:

```lua
['property_key'] = {
    label = 'Property Key',
    weight = 10,
    stack = false,
    close = true,
    description = 'A key to a property'
}
```

### Discord Webhooks

Aktiviere Discord-Logging:

```lua
Config.Logging.discord.enabled = true
Config.Logging.discord.webhook = 'DEIN_WEBHOOK_URL'
```

## 🐛 Troubleshooting

### Problem: Resource startet nicht

**Lösung:**
1. Überprüfe Server-Console auf Fehler
2. Stelle sicher, dass oxmysql läuft
3. Überprüfe, ob ESX/QBCore geladen ist

### Problem: Keine Blips sichtbar

**Lösung:**
```lua
Config.Market.openMarket.showBlips = true
Config.Properties.blips.available.shortRange = false
```

### Problem: Datenbank-Fehler

**Lösung:**
1. Überprüfe MySQL-Verbindung
2. Stelle sicher, dass alle Tabellen korrekt erstellt wurden
3. Überprüfe Benutzerrechte in der Datenbank

### Problem: NUI öffnet nicht

**Lösung:**
1. Drücke F8 und überprüfe auf JavaScript-Fehler
2. Stelle sicher, dass alle HTML/CSS/JS Dateien vorhanden sind
3. Lösche Browser-Cache (F5 im NUI)

## 📚 Nächste Schritte

- Lies den [Konfigurations-Guide](CONFIG_GUIDE.md)
- Lerne die [Admin-Befehle](COMMANDS.md)
- Entdecke die [API](API.md) für Custom Scripts

## 🆘 Hilfe Benötigt?

Siehe [TROUBLESHOOTING.md](TROUBLESHOOTING.md) für häufige Probleme und Lösungen.
