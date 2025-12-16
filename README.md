# 🏠 Property Manager System für FiveM

Ein **komplettes, professionelles Immobilien-Verwaltungssystem** für FiveM GTA V RP Server mit umfangreichen Features.

## 🎯 WIE ES FUNKTIONIERT

**Wichtiger Workflow:**

1. **Spieler besucht Makler-Büro** → Einer der 3 Standorte (Downtown / Vinewood / Del Perro)
2. **Katalog öffnet sich** → Alle verfügbaren Häuser werden angezeigt (OHNE Blips auf Map!)
3. **Spieler wählt Immobilie** → Besichtigung / Kurzzeitmiete / Kauf buchen
4. **Nach Buchung** → Haus bekommt GRÜNEN BLIP auf Map + GPS-Route
5. **Spieler fährt zum Haus** → Code eingeben und Zugang erhalten
6. **Haus nutzen** → Garage, Safe, Wardrobe, etc. nutzen

**⚠️ WICHTIG:** Verfügbare Häuser erscheinen NICHT auf der Karte! Sie sind nur im Makler-Katalog sichtbar und bekommen erst nach Buchung einen Blip.

## 📋 KERNFEATURES

### 🏢 Multi-Makler-Büro System (3 Standorte)
- **Downtown Realty** - vec4(1124.5, 226.5, 69.0, 0.0)
- **Vinewood Luxury Realty** - vec4(1302.8, -528.5, 71.4, 90.0)
- **Del Perro Beach Properties** - vec4(150.2, -1044.3, 29.4, 180.0)
- Gemeinsamer Live-Katalog über alle Standorte (MySQL-Sync)
- GPS-Integration zu allen Büros

### 🏠 Immobilien-Portal (NUI)
- Website-ähnlicher Katalog mit moderner NUI
- Filter nach Preis, Typ, Gebiet und Status
- **Alle Immobilien-Klassen**: Office, House, Hotel, Apartment, Villa, Mansion
- Dark/Neon Theme mit Glassmorphism-Effekten
- Zentrale Benachrichtigungen mit Animationen

### 📅 Booking-System (Airbnb-Style)
- **Besichtigungen** (30 Min, kostenlos, 4-stelliger Code)
- **Kurzzeitmiete** (1-7 Tage mit reduziertem Preis)
- **Direktkauf** (Bar oder mit Hypothek)
- **Automatische GPS-Markierung** nach Buchung (GRÜNER BLIP)
- Temporäre Zugangscodes (auto-generiert, verfallen automatisch)

### 💰 Zahlungssystem
- **Hypotheken** mit konfigurierbaren Zinsen und Raten
- **Mieten** (täglich/wöchentlich/monatlich)
- Automatische Zahlungsüberwachung
- Automatische Räumung bei Zahlungsrückstand
- Vollständige Transaktionshistorie

### 🔑 Schlüsselsystem
- Physische Schlüssel als Inventory-Items
- 3 Permission-Level: Owner/Tenant/Guest
- Kurzzeitschlüssel mit Ablaufdatum
- Schlüssel verteilen/widerrufen/duplizieren
- Audit-Log für alle Aktionen

### 🚗 Private Garage-System
- **3 Größen**: Small (6), Medium (10), Large (8 Slots)
- **NUR Standard GTA Online Interiors** (kostenlos)
- Fahrzeug-Zustand wird gespeichert (Farbe, Mods, Tuning)
- Automatische Garage-Zuordnung bei Hauskauf

### 📦 Storage & Safes
- 3 Safe-Größen (30/40/50 Slots)
- PIN-Code Schutz (4-8 stellig)
- Kleiderschrank pro Haus
- Permission-basierter Zugriff

### 👑 Admin-Panel
- In-Game Admin-Panel mit Glassmorphism-Design
- Häuser erstellen/bearbeiten/löschen
- Eigentümer übertragen
- Notfall-Räumung
- Statistiken & Logs
- Zahlreiche Admin-Commands

### 📊 Markt-Modi
- **OPEN MARKET**: Marker an Häusern + Zentrale Agentur
- **REALTOR ONLY**: Nur Makler können verkaufen
- **HYBRID**: Beide Modi kombiniert

## 🗄️ DATENBANK-STRUKTUR

Das System verwendet **13 Tabellen**:

1. **properties** - Alle Immobilien mit Details
2. **property_keys** - Schlüsselsystem mit Permissions
3. **property_storage** - Stash/Safes Inventar
4. **property_garages** - Garage pro Haus
5. **garage_vehicles** - Autos in Garage mit State
6. **property_bookings** - Buchungen (Viewing/Miete/Kauf)
7. **shortterm_keys** - Kurzzeitschlüssel mit Ablauf
8. **property_transactions** - Alle Zahlungen (History)
9. **property_tenants** - Mieter mit Details
10. **property_mortgages** - Hypotheken (Zahlungsplan)
11. **realtor_branches** - 3x Büro-Locations
12. **property_logs** - Audit-Trail
13. **property_notifications** - Benachrichtigungen

## 📦 INSTALLATION

1. **Repository klonen:**
   ```bash
   cd resources
   git clone https://github.com/MTJ2025script/Home_Manger.git
   ```

2. **Datenbank importieren:**
   ```bash
   # WICHTIG: Wähle zuerst deine ESX/QBCore Datenbank!
   mysql -u root -p
   USE esxlegacy;  # Dein Datenbankname (z.B. esxlegacy, es_extended, qbcore)
   SOURCE /pfad/zu/Home_Manger/sql/database.sql;
   ```
   Oder nutze phpMyAdmin: Datenbank auswählen → SQL-Datei importieren

3. **Config anpassen:**
   - Öffne `data/config.lua`
   - Passe Framework an (ESX/QBCore)
   - Konfiguriere Zahlungen, Hypotheken, etc.

4. **Resource starten:**
   - Füge `ensure Home_Manger` zu `server.cfg` hinzu
   - Server neustarten

## ⚙️ KONFIGURATION

Die Config befindet sich in `data/config.lua` und ist **vollständig auf Deutsch kommentiert**.

### Wichtige Einstellungen:
- Framework (ESX/QBCore)
- Makler-Büros (3 Standorte)
- Zahlungssystem (Hypotheken & Mieten)
- Garagen-System
- Schlüssel-System
- Markt-Modus
- UI-Farben & Theme

### Beispiel:
```lua
Config.Framework = 'ESX'                    -- Framework
Config.MarketMode = 'HYBRID'                -- Markt-Modus
Config.Payment.mortgage.enabled = true      -- Hypotheken aktivieren
Config.Payment.mortgage.interestRate = 5.5  -- Zinssatz 5.5%
```

## 🎮 BEFEHLE

### Spieler-Befehle:
- `/entercode` - Zugangscode eingeben

### Admin-Befehle:
- `/adminprop` - Admin-Panel öffnen
- `/createproperty` - Immobilie erstellen
- `/editproperty [id]` - Immobilie bearbeiten
- `/deleteproperty [id]` - Immobilie löschen
- `/transferproperty [id] [player_id]` - Eigentümer übertragen
- `/evictproperty [id]` - Mieter räumen
- `/propertyinfo [id]` - Immobilien-Info anzeigen
- `/listproperties` - Alle Immobilien auflisten
- `/tpprop [id]` - Zu Immobilie teleportieren

## 🎨 UI/UX

Das System bietet:
- **Dark/Neon Theme** mit modernem Design
- **Glassmorphism-Effekte** für elegante Optik
- **Smooth Animations** (Slide, Fade, Scale)
- **Zentrale Notifications** unten mit Auto-Stack
- **Deutsche Sprache** (Primär) + EN/FR
- **Responsive Design** für verschiedene Auflösungen

## 🔧 TECHNISCHE DETAILS

### Framework-Unterstützung:
- ✅ ESX Legacy (primär)
- ✅ QBCore (vollständig unterstützt)
- ✅ Standalone-ready mit Fallbacks

### Datenbank:
- OXMySQL / MySQLAsync Integration
- Optimierte Queries
- Automatische Synchronisation

### Sicherheit:
- Server-Side Validation
- Anti-Cheat Checks
- Rate-Limiting
- SQL-Injection Schutz

## 📚 DOKUMENTATION

Weitere Dokumentation findest du in:
- `docs/INSTALLATION.md` - Detaillierte Installation
- `docs/CONFIG_GUIDE.md` - Konfigurations-Guide
- `docs/COMMANDS.md` - Alle Befehle
- `docs/API.md` - API für Entwickler
- `docs/TROUBLESHOOTING.md` - Problemlösungen

## 🤝 SUPPORT

Bei Fragen oder Problemen:
1. Überprüfe die [Troubleshooting-Dokumentation](docs/TROUBLESHOOTING.md)
2. Erstelle ein Issue auf GitHub
3. Kontaktiere uns im Discord

## 📄 LIZENZ

Dieses Projekt ist Open Source und steht unter der MIT-Lizenz.

## 🙏 CREDITS

Entwickelt von **MTJ2025script**

---

⭐ Gefällt dir das System? Gib uns einen Stern auf GitHub!
