# 📚 API Documentation

API für Entwickler zum Integrieren mit dem Property Manager System.

## 🔌 EXPORTS

### Client-Side Exports

#### GetNearbyProperties()

Gibt alle Immobilien in der Nähe zurück.

```lua
local nearbyProps = exports['Home_Manger']:GetNearbyProperties()

for _, data in ipairs(nearbyProps) do
    print(data.property.name, data.distance)
end
```

**Returns:** `table` - Array mit Property-Daten und Distanz

---

#### GetPlayerProperties()

Gibt alle Immobilien des Spielers zurück.

```lua
local myProps = exports['Home_Manger']:GetPlayerProperties()

for _, prop in ipairs(myProps) do
    print(prop.id, prop.name)
end
```

**Returns:** `table` - Array mit Property-Daten

---

#### HasPropertyAccess(propertyId)

Prüft ob Spieler Zugriff auf Immobilie hat.

```lua
local hasAccess = exports['Home_Manger']:HasPropertyAccess('mp_house_1')

if hasAccess then
    print('Zugriff gewährt')
end
```

**Parameters:**
- `propertyId` (string) - ID der Immobilie

**Returns:** `boolean`

---

#### IsPropertyOwner(propertyId)

Prüft ob Spieler Eigentümer der Immobilie ist.

```lua
local isOwner = exports['Home_Manger']:IsPropertyOwner('mp_house_1')

if isOwner then
    print('Du bist Eigentümer')
end
```

**Parameters:**
- `propertyId` (string) - ID der Immobilie

**Returns:** `boolean`

---

### Server-Side Exports

#### GetPropertyData(propertyId)

Gibt Immobilien-Daten zurück.

```lua
local property = exports['Home_Manger']:GetPropertyData('mp_house_1')

if property then
    print(property.name, property.price)
end
```

**Parameters:**
- `propertyId` (string) - ID der Immobilie

**Returns:** `table|nil` - Property-Daten oder nil

---

#### IsPropertyOwner(identifier, propertyId)

Prüft Eigentümerschaft (Server-Side).

```lua
local isOwner = exports['Home_Manger']:IsPropertyOwner('char1:123456', 'mp_house_1')
```

**Parameters:**
- `identifier` (string) - Spieler-Identifier
- `propertyId` (string) - ID der Immobilie

**Returns:** `boolean`

---

#### HasPropertyAccess(identifier, propertyId)

Prüft Zugriff (Server-Side).

```lua
local hasAccess = exports['Home_Manger']:HasPropertyAccess('char1:123456', 'mp_house_1')
```

**Parameters:**
- `identifier` (string) - Spieler-Identifier
- `propertyId` (string) - ID der Immobilie

**Returns:** `boolean`

---

#### GetPlayerProperties(identifier)

Gibt alle Immobilien eines Spielers zurück.

```lua
local properties = exports['Home_Manger']:GetPlayerProperties('char1:123456')

for _, prop in ipairs(properties) do
    print(prop.id, prop.name)
end
```

**Parameters:**
- `identifier` (string) - Spieler-Identifier

**Returns:** `table` - Array mit Property-Daten

---

#### CreateProperty(propertyData)

Erstellt eine neue Immobilie programmatisch.

```lua
local success = exports['Home_Manger']:CreateProperty({
    id = 'custom_house_1',
    name = 'Custom House',
    type = 'house',
    area = 'Custom Area',
    entrance = vec4(100.0, 200.0, 30.0, 0.0),
    price = 150000,
    bedrooms = 3,
    bathrooms = 2,
    garage_type = 'small'
})
```

**Parameters:**
- `propertyData` (table) - Property-Daten

**Returns:** `boolean`

---

#### DeleteProperty(propertyId)

Löscht eine Immobilie.

```lua
local success = exports['Home_Manger']:DeleteProperty('custom_house_1')
```

**Parameters:**
- `propertyId` (string) - ID der Immobilie

**Returns:** `boolean`

---

#### TransferOwnership(propertyId, newOwner)

Überträgt Eigentum.

```lua
exports['Home_Manger']:TransferOwnership('mp_house_1', 'char1:654321')
```

**Parameters:**
- `propertyId` (string) - ID der Immobilie
- `newOwner` (string) - Neuer Eigentümer Identifier

---

#### AddPropertyKey(propertyId, holder, permissionLevel)

Gibt Schlüssel an Spieler.

```lua
exports['Home_Manger']:AddPropertyKey('mp_house_1', 'char1:123456', 'guest')
```

**Parameters:**
- `propertyId` (string) - ID der Immobilie
- `holder` (string) - Spieler-Identifier
- `permissionLevel` (string) - 'owner', 'tenant', oder 'guest'

---

#### RemovePropertyKey(propertyId, holder)

Entzieht Schlüssel.

```lua
exports['Home_Manger']:RemovePropertyKey('mp_house_1', 'char1:123456')
```

**Parameters:**
- `propertyId` (string) - ID der Immobilie
- `holder` (string) - Spieler-Identifier

---

## 🔔 EVENTS

### Client Events

#### property:notify

Zeigt Benachrichtigung an.

```lua
TriggerEvent('property:notify', {
    type = 'success',  -- success, error, warning, info
    title = 'Erfolg',
    message = 'Aktion erfolgreich',
    duration = 5000
})
```

#### property:openCatalog

Öffnet Immobilien-Katalog.

```lua
TriggerEvent('property:openCatalog')
```

---

### Server Events

#### property:purchase

Kauft eine Immobilie.

```lua
TriggerServerEvent('property:purchase', propertyId, paymentMethod, useMortgage, mortgageData)
```

**Parameters:**
- `propertyId` (string)
- `paymentMethod` (string) - 'cash' oder 'bank'
- `useMortgage` (boolean)
- `mortgageData` (table) - Hypotheken-Daten

---

#### property:sell

Verkauft eine Immobilie.

```lua
TriggerServerEvent('property:sell', propertyId, sellPrice)
```

---

#### property:rent

Mietet eine Immobilie.

```lua
TriggerServerEvent('property:rent', propertyId, duration, paymentMethod)
```

---

## 🗄️ DATABASE ACCESS

### Direct Queries

```lua
-- ESX Example
MySQL.Async.fetchAll('SELECT * FROM properties WHERE id = @id', {
    ['@id'] = 'mp_house_1'
}, function(result)
    if result[1] then
        print(result[1].name)
    end
end)
```

### Recommended: Use Exports

Bevorzuge Exports statt direkte DB-Queries für bessere Wartbarkeit.

---

## 🔐 PERMISSIONS

### Custom Permission Check

```lua
-- Server-Side
function MyCustomPermissionCheck(source)
    local identifier = exports['Home_Manger']:GetPlayerIdentifier(source)
    
    -- Eigene Logik
    if identifier == 'admin123' then
        return true
    end
    
    return false
end
```

---

## 📊 BEISPIEL-INTEGRATION

### Custom Property Actions

```lua
-- Server
RegisterServerEvent('myresource:customAction')
AddEventHandler('myresource:customAction', function(propertyId)
    local source = source
    local identifier = exports['Home_Manger']:GetPlayerIdentifier(source)
    
    -- Check ownership
    if exports['Home_Manger']:IsPropertyOwner(identifier, propertyId) then
        -- Eigene Aktion
        print('Owner action for:', propertyId)
    end
end)
```

### Custom UI Integration

```lua
-- Client
RegisterCommand('myprops', function()
    local properties = exports['Home_Manger']:GetPlayerProperties()
    
    -- Eigenes UI öffnen
    SendNUIMessage({
        action = 'openMyCustomUI',
        properties = properties
    })
end)
```

### Webhook Integration

```lua
-- Server
function SendToDiscord(message)
    local webhook = 'YOUR_WEBHOOK_URL'
    
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        content = message
    }), { ['Content-Type'] = 'application/json' })
end

-- Hook into property purchase
AddEventHandler('property:purchased', function(propertyId, buyerId)
    local property = exports['Home_Manger']:GetPropertyData(propertyId)
    SendToDiscord('Property ' .. property.name .. ' was purchased!')
end)
```

---

## 🧪 TESTING

### Test Property Creation

```lua
-- Server Console
exports['Home_Manger']:CreateProperty({
    id = 'test_house',
    name = 'Test House',
    type = 'house',
    area = 'Test Area',
    entrance = vec4(0.0, 0.0, 70.0, 0.0),
    price = 100000,
    bedrooms = 2,
    bathrooms = 1,
    garage_type = 'small'
})
```

### Test Ownership

```lua
-- Client
local myProps = exports['Home_Manger']:GetPlayerProperties()
print(json.encode(myProps, {indent = true}))
```

---

## 📝 BEST PRACTICES

1. **Immer Exports verwenden** statt direkte DB-Queries
2. **Server-Side Validation** für alle Aktionen
3. **Error Handling** in allen Funktionen
4. **Logging** für wichtige Aktionen
5. **Permissions prüfen** vor Aktionen

---

## 🆘 SUPPORT

Bei Fragen zur API:
- GitHub Issues
- Discord #dev-support
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📚 WEITERFÜHRENDE DOCS

- [INSTALLATION.md](INSTALLATION.md)
- [CONFIG_GUIDE.md](CONFIG_GUIDE.md)
- [COMMANDS.md](COMMANDS.md)
