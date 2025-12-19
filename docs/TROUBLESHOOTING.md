# 🔧 Troubleshooting Guide

Lösungen für häufige Probleme.

## 🚫 HÄUFIGE PROBLEME

### Resource startet nicht

**Symptom:** Resource erscheint nicht in `/resources` oder startet nicht

**Lösungen:**

1. **Überprüfe Dependencies:**
   ```bash
   ensure oxmysql
   ensure es_extended  # oder qb-core
   ensure Home_Manger
   ```

2. **Überprüfe fxmanifest.lua:**
   - Datei vorhanden?
   - Syntax korrekt?
   - Alle Pfade korrekt?

3. **Überprüfe Lua-Fehler:**
   - Server-Console auf Fehler prüfen
   - Häufige Fehler: Fehlende Kommas, falsche Syntax

4. **Permissions:**
   ```bash
   chmod -R 755 Home_Manger
   ```

---

### Keine Blips auf der Map

**Symptom:** Makler-Büros oder Immobilien zeigen keine Blips

**Lösungen:**

1. **Config überprüfen:**
   ```lua
   Config.Market.openMarket.showBlips = true
   ```

2. **ShortRange deaktivieren:**
   ```lua
   Config.Properties.blips.available.shortRange = false
   ```

3. **Client neu starten:**
   - Disconnect + Reconnect
   - Oder: `/refresh` + `/ensure Home_Manger`

---

### Datenbank-Fehler

**Symptom:** "Database error", "Table doesn't exist"

**Lösungen:**

1. **SQL-Import überprüfen:**
   ```bash
   mysql -u root -p < sql/database.sql
   ```

2. **Tabellen überprüfen:**
   ```sql
   USE es_extended;
   SHOW TABLES LIKE 'property%';
   ```
   
   Sollte 13 Tabellen zeigen!

3. **OXMySQL prüfen:**
   - Ist oxmysql gestartet?
   - Connection-String korrekt?

4. **Benutzerrechte:**
   ```sql
   GRANT ALL PRIVILEGES ON es_extended.* TO 'user'@'localhost';
   FLUSH PRIVILEGES;
   ```

---

### NUI öffnet nicht

**Symptom:** Katalog/UI öffnet nicht, schwarzer Screen

**Lösungen:**

1. **JavaScript-Fehler:**
   - F8-Console öffnen
   - Auf Fehler prüfen
   - Häufig: Pfade falsch

2. **Browser-Cache:**
   - F5 während NUI offen
   - Oder Client neu starten

3. **Dateien überprüfen:**
   ```
   html/index.html
   html/css/style.css
   html/js/script.js
   ```
   Alle vorhanden?

4. **SetNuiFocus Test:**
   ```lua
   -- In F8 Console
   SetNuiFocus(true, true)
   ```

---

### Marker nicht sichtbar

**Symptom:** Keine Marker an Immobilien/Büros

**Lösungen:**

1. **Config:**
   ```lua
   Config.Market.openMarket.showMarkers = true
   ```

2. **Distanz erhöhen:**
   ```lua
   Config.Properties.markers.drawDistance = 50.0
   ```

3. **Client-Performance:**
   - Grafik-Einstellungen reduzieren
   - Andere Scripts deaktivieren

---

### Keys funktionieren nicht

**Symptom:** Spieler kann Tür nicht öffnen trotz Schlüssel

**Lösungen:**

1. **Keys-System aktiviert:**
   ```lua
   Config.Keys.enabled = true
   ```

2. **Datenbank prüfen:**
   ```sql
   SELECT * FROM property_keys WHERE holder = 'identifier';
   ```

3. **Permissions prüfen:**
   ```lua
   Config.Keys.permissions.owner.canEnter = true
   ```

4. **Distanz:**
   - Muss nah an der Tür stehen
   - `Config.Properties.markers.interactionDistance` erhöhen

---

### Garage funktioniert nicht

**Symptom:** Fahrzeuge können nicht gespeichert werden

**Lösungen:**

1. **Garagen-System aktiviert:**
   ```lua
   Config.Garages.enabled = true
   Config.Garages.autoAssign = true
   ```

2. **Garage vorhanden:**
   ```sql
   SELECT * FROM property_garages WHERE property_id = 'XXX';
   ```

3. **Interior laden:**
   - Manuell mit: `RequestIpl('apa_v_mp_h_01_a')`

4. **Fahrzeug in Reichweite:**
   - Muss direkt vor Fahrzeug stehen
   - `GetVehicleInDirection()` Test

---

### Zahlungen funktionieren nicht

**Symptom:** Hypotheken/Mieten werden nicht abgebucht

**Lösungen:**

1. **Payment Checker läuft:**
   - Server-Console: "Processing payments..."
   - Läuft alle 5 Minuten

2. **Zahlungs-System aktiviert:**
   ```lua
   Config.Payment.mortgage.enabled = true
   Config.Payment.rent.enabled = true
   ```

3. **Datenbank prüfen:**
   ```sql
   SELECT * FROM property_mortgages WHERE status = 'active';
   SELECT * FROM property_tenants WHERE status = 'active';
   ```

4. **Grace Period:**
   - Vielleicht noch in Kulanzzeit
   - `gracePeriod` in Config prüfen

---

### Notifications zeigen nicht

**Symptom:** Keine Benachrichtigungen sichtbar

**Lösungen:**

1. **Config:**
   ```lua
   Config.Notifications.enabled = true
   ```

2. **NUI prüfen:**
   - F8-Console auf Fehler
   - `#notifications` Element vorhanden?

3. **CSS prüfen:**
   ```css
   #notifications {
       z-index: 10000;
   }
   ```

---

### Spieler kann nicht kaufen

**Symptom:** "Insufficient funds" obwohl genug Geld

**Lösungen:**

1. **Framework-Integration:**
   - ESX/QBCore korrekt?
   - `GetPlayerMoney()` Test

2. **Account-Typ:**
   ```lua
   -- ESX
   xPlayer.getAccount('bank').money
   
   -- QBCore
   Player.PlayerData.money.bank
   ```

3. **Betrag prüfen:**
   - Hypothek: Nur Anzahlung nötig
   - Config: `minDownPayment` prüfen

---

### Admin-Commands funktionieren nicht

**Symptom:** "No permission" bei Admin-Befehlen

**Lösungen:**

1. **Admin-Gruppe:**
   - ESX: `admin` oder `superadmin`
   - QBCore: `admin` oder `god` Permission

2. **Funktion anpassen:**
   ```lua
   -- In server/server.lua
   function HasPermission(source, permission)
       -- Eigene Logik
       return true -- Für Tests
   end
   ```

3. **ACE Permissions:**
   ```cfg
   add_ace group.admin command.adminprop allow
   ```

---

## 🐛 DEBUG-MODUS

Aktiviere Debug für detaillierte Logs:

```lua
Config.Debug = true
```

Dann in Console:

```
Server: [Property Manager] DEBUG: ...
Client: [Property Manager] DEBUG: ...
```

---

## 📊 PERFORMANCE-PROBLEME

### Hohe CPU-Auslastung

**Lösungen:**

1. **Marker-Distanz reduzieren:**
   ```lua
   Config.Properties.markers.drawDistance = 10.0
   ```

2. **Blips optimieren:**
   ```lua
   Config.Properties.blips.available.shortRange = true
   ```

3. **Property-Anzahl:**
   - Weniger Properties in `data/properties.lua`
   - Oder in Phasen laden

### Hoher RAM-Verbrauch

**Lösungen:**

1. **Logs begrenzen:**
   ```lua
   Config.Logging.database.retention = 30  -- Statt 90 Tage
   ```

2. **Auto-Cleanup:**
   ```lua
   Config.Keys.shortTermKeys.autoCleanup = true
   ```

---

## 🔍 LOGS ÜBERPRÜFEN

### Server-Logs

```bash
# Linux
tail -f server.log | grep "Property Manager"

# Windows
Get-Content server.log -Tail 50 -Wait | Select-String "Property Manager"
```

### Datenbank-Logs

```sql
SELECT * FROM property_logs 
ORDER BY created_at DESC 
LIMIT 50;
```

### Player-Logs

```sql
SELECT * FROM property_logs 
WHERE player_id = 'identifier'
ORDER BY created_at DESC;
```

---

## 🆘 WEITERE HILFE

### 1. GitHub Issues

Erstelle ein Issue mit:
- Genauer Fehlerbeschreibung
- Server-/Client-Logs
- Config-Auszug
- FiveM Version
- Framework Version

### 2. Discord Support

- Tritt unserem Discord bei
- #support Channel
- Logs und Screenshots bereithalten

### 3. FAQ

Überprüfe häufig gestellte Fragen im Wiki.

---

## ✅ CHECKLISTE FÜR SUPPORT-ANFRAGE

Bevor du Support anfragst:

- [ ] Alle Lösungen hier ausprobiert?
- [ ] Server-Logs überprüft?
- [ ] Client-Logs (F8) überprüft?
- [ ] Datenbank-Verbindung OK?
- [ ] Dependencies alle gestartet?
- [ ] Config korrekt?
- [ ] Resource neugestartet?
- [ ] FiveM Client neugestartet?
- [ ] Andere Scripts deaktiviert zum Testen?

---

## 📚 WEITERFÜHRENDE DOCS

- [INSTALLATION.md](INSTALLATION.md) - Installation
- [CONFIG_GUIDE.md](CONFIG_GUIDE.md) - Konfiguration
- [COMMANDS.md](COMMANDS.md) - Befehle
- [API.md](API.md) - API-Dokumentation
