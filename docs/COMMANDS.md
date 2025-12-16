# 🎮 Befehle-Übersicht

Alle verfügbaren Befehle für Property Manager System.

## 👥 SPIELER-BEFEHLE

### `/entercode`

Zugangscode für Besichtigung/Miete eingeben.

**Verwendung:**
```
/entercode
```

**Beschreibung:**
- Muss in der Nähe einer Immobilie stehen
- Code wird per Keyboard-Input eingegeben
- Bei korrektem Code wird Zugang gewährt
- Code ist zeitlich begrenzt (siehe Booking)

**Beispiel:**
```
1. Besichtigung gebucht → Code: 1234
2. Zur Immobilie fahren
3. /entercode
4. "1234" eingeben
5. Zugang erhalten
```

---

## 👑 ADMIN-BEFEHLE

### `/adminprop`

Öffnet das Admin-Panel für Property Management.

**Berechtigung:** Admin

**Features im Panel:**
- Alle Immobilien anzeigen
- Statistiken ansehen
- Logs durchsuchen
- Schnelle Aktionen

---

### `/createproperty`

Öffnet das Formular zum Erstellen einer neuen Immobilie.

**Berechtigung:** Admin

**Verwendung:**
```
/createproperty
```

**Erforderliche Angaben:**
- ID (eindeutig)
- Name
- Typ (apartment, house, villa, etc.)
- Gebiet
- Position (vec4)
- Preis
- Schlafzimmer/Badezimmer
- Garage-Typ
- Beschreibung

---

### `/editproperty [property_id]`

Bearbeitet eine existierende Immobilie.

**Berechtigung:** Admin

**Verwendung:**
```
/editproperty mp_house_1
```

**Parameter:**
- `property_id`: ID der Immobilie

**Beispiel:**
```
/editproperty vw_mansion_1
```

---

### `/deleteproperty [property_id]`

Löscht eine Immobilie permanent.

**Berechtigung:** Admin

**Verwendung:**
```
/deleteproperty [property_id]
```

**⚠️ WARNUNG:** Diese Aktion kann nicht rückgängig gemacht werden!

**Beispiel:**
```
/deleteproperty old_house_123
```

---

### `/transferproperty [property_id] [player_id]`

Überträgt Eigentum einer Immobilie an einen Spieler.

**Berechtigung:** Admin

**Verwendung:**
```
/transferproperty [property_id] [player_id]
```

**Parameter:**
- `property_id`: ID der Immobilie
- `player_id`: Server ID des Ziel-Spielers

**Beispiel:**
```
/transferproperty mp_house_1 5
```

**Hinweis:** 
- Alte Eigentümer-Keys werden entfernt
- Neue Owner-Keys werden automatisch erstellt
- Spieler erhält Benachrichtigung

---

### `/evictproperty [property_id]`

Räumt den Mieter einer Immobilie sofort.

**Berechtigung:** Admin

**Verwendung:**
```
/evictproperty [property_id]
```

**Beispiel:**
```
/evictproperty dp_apartment_1
```

**Effekte:**
- Mieter verliert Zugang
- Keys werden entfernt
- Immobilie wird verfügbar
- Mietvertrag wird beendet

---

### `/propertyinfo [property_id]`

Zeigt detaillierte Informationen über eine Immobilie.

**Berechtigung:** Admin

**Verwendung:**
```
/propertyinfo [property_id]
```

**Angezeigte Infos:**
- Grunddaten (Name, Typ, Preis)
- Eigentümer/Mieter
- Status
- Anzahl Keys
- Anzahl Fahrzeuge in Garage
- Hypotheken-Info
- Letzte Transaktionen

**Beispiel:**
```
/propertyinfo rh_villa_1
```

---

### `/listproperties`

Listet alle Immobilien im System auf.

**Berechtigung:** Admin

**Verwendung:**
```
/listproperties
```

**Ausgabe:**
- Alle Immobilien sortiert nach Gebiet
- ID, Name, Status, Eigentümer, Mieter

---

### `/tpprop [property_id]`

Teleportiert dich zur Immobilie.

**Berechtigung:** Admin

**Verwendung:**
```
/tpprop [property_id]
```

**Beispiel:**
```
/tpprop vw_mansion_1
```

**Nützlich für:**
- Schnelle Inspektion
- Support-Anfragen
- Testing

---

## 📝 COMMAND ALIASES

Einige Befehle haben Kurzformen:

| Vollständig | Kurzform |
|-------------|----------|
| `/adminprop` | `/aprop` |
| `/propertyinfo` | `/pinfo` |
| `/listproperties` | `/props` |

---

## 🔐 BERECHTIGUNGEN

### Admin-Check

Das System überprüft folgende Berechtigungen:

**ESX:**
```lua
xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin'
```

**QBCore:**
```lua
QBCore.Functions.HasPermission(source, 'admin') or 
QBCore.Functions.HasPermission(source, 'god')
```

### Eigene Berechtigungen

Du kannst in `server/server.lua` die Funktion `HasPermission()` anpassen:

```lua
function HasPermission(source, permission)
    -- Eigene Logik hier
    return true/false
end
```

---

## 💡 TIPPS

### Für Admins:

1. **Immobilien-IDs:** Verwende sprechende IDs (z.B. `vw_mansion_1` statt `prop123`)
2. **Vor Löschen:** Immer mit `/propertyinfo` prüfen, ob Eigentümer vorhanden
3. **Teleport:** Nutze `/tpprop` für schnelle Checks
4. **Logs:** Regelmäßig `/adminprop` → Logs checken

### Für Spieler:

1. **Code-Eingabe:** Muss nah an der Tür stehen
2. **Codes:** Werden automatisch abgelaufen nach Zeit
3. **Hilfe:** Bei Problemen Admin kontaktieren

---

## 🆘 TROUBLESHOOTING

### "No permission"

**Lösung:** Überprüfe Admin-Berechtigung auf dem Server

### "Property not found"

**Lösung:** 
- Überprüfe Property-ID (Case-sensitive!)
- Nutze `/listproperties` für korrekte ID

### "Player not found"

**Lösung:**
- Überprüfe Server-ID des Spielers
- Spieler muss online sein

### Befehl tut nichts

**Lösung:**
- F8-Console auf Fehler prüfen
- Server-Console auf Fehler prüfen
- Resource neu starten

---

## 📚 WEITERFÜHRENDE DOCS

- [INSTALLATION.md](INSTALLATION.md) - Installation
- [CONFIG_GUIDE.md](CONFIG_GUIDE.md) - Konfiguration
- [API.md](API.md) - Für Entwickler
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problemlösungen
