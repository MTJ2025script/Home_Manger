// ====================================================================================================
// 📜 MAIN JAVASCRIPT
// Main client-side logic for Property Manager UI
// ====================================================================================================

let properties = [];
let currentProperty = null;

// ====================================================================================================
// 🚀 INITIALIZATION
// ====================================================================================================

document.addEventListener('DOMContentLoaded', () => {
    console.log('Property Manager UI Loaded');
    
    // Hide UI on ESC key
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            closeAll();
        }
    });
});

// Listen for messages from game
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (!data || !data.action) return;
    
    switch (data.action) {
        case 'openCatalog':
            openCatalog(data);
            break;
        case 'closeCatalog':
            closeCatalog();
            break;
        case 'showNotification':
            showNotification(data);
            break;
        case 'openPropertyMenu':
            openPropertyMenu(data);
            break;
        case 'openAccessCodeDialog':
            openAccessCodeDialog(data);
            break;
        case 'closeAccessCodeDialog':
            closeAccessCodeDialog();
            break;
        case 'openKeyManagement':
            openKeyManagement(data);
            break;
        default:
            console.warn('Unknown action:', data.action);
    }
});

// ====================================================================================================
// 📋 CATALOG FUNCTIONS
// ====================================================================================================

function openCatalog(data) {
    properties = data.properties || [];
    document.getElementById('catalog').classList.remove('hidden');
    populateFilters();
    renderProperties();
}

function closeCatalog() {
    document.getElementById('catalog').classList.add('hidden');
    sendMessage('close');
}

function populateFilters() {
    const areas = [...new Set(properties.map(p => p.area))];
    const areaSelect = document.getElementById('filter-area');
    
    areaSelect.innerHTML = '<option value="all">Alle Gebiete</option>';
    areas.forEach(area => {
        const option = document.createElement('option');
        option.value = area;
        option.textContent = area;
        areaSelect.appendChild(option);
    });
}

function renderProperties(filtered = null) {
    const propertyList = document.getElementById('property-list');
    const propsToRender = filtered || properties;
    
    propertyList.innerHTML = '';
    
    propsToRender.forEach(property => {
        const card = createPropertyCard(property);
        propertyList.appendChild(card);
    });
}

function createPropertyCard(property) {
    const card = document.createElement('div');
    card.className = 'property-card animate-scaleIn';
    card.onclick = () => showPropertyDetails(property);
    
    const statusClass = property.status || 'available';
    const statusText = {
        'available': 'Verfügbar',
        'owned': 'Gekauft',
        'rented': 'Vermietet',
        'viewing': 'Besichtigung'
    }[statusClass] || 'Unbekannt';
    
    // Get property type image
    const imageMap = {
        'office': 'office.png',
        'house': 'house.png',
        'hotel': 'hotel.png',
        'apartment': 'apartment.png',
        'villa': 'villa.png',
        'mansion': 'mansion.png'
    };
    const imagePath = `images/${imageMap[property.type] || 'house.png'}`;
    
    card.innerHTML = `
        <img src="${imagePath}" alt="${property.type}" class="property-card-image">
        <div class="property-card-content">
            <div class="property-card-header">
                <div class="property-card-title">${property.name}</div>
                <div class="property-card-status ${statusClass}">${statusText}</div>
            </div>
            <div class="property-card-info">
                <p><span>📍 Gebiet:</span> <span>${property.area}</span></p>
                <p><span>🏠 Typ:</span> <span>${property.type.toUpperCase()}</span></p>
                <p><span>🛏️ Schlafzimmer:</span> <span>${property.bedrooms}</span></p>
                <p><span>🚿 Badezimmer:</span> <span>${property.bathrooms}</span></p>
            </div>
            <div class="property-card-price">$${formatNumber(property.price)}</div>
        </div>
    `;
    
    return card;
}

function applyFilters() {
    const type = document.getElementById('filter-type').value;
    const area = document.getElementById('filter-area').value;
    const status = document.getElementById('filter-status').value;
    
    let filtered = properties;
    
    if (type !== 'all') {
        filtered = filtered.filter(p => p.type === type);
    }
    
    if (area !== 'all') {
        filtered = filtered.filter(p => p.area === area);
    }
    
    if (status !== 'all') {
        filtered = filtered.filter(p => p.status === status);
    }
    
    renderProperties(filtered);
}

// ====================================================================================================
// 📱 PROPERTY DETAILS
// ====================================================================================================

function showPropertyDetails(property) {
    currentProperty = property;
    
    document.getElementById('property-name').textContent = property.name;
    document.getElementById('property-price').textContent = '$' + formatNumber(property.price);
    document.getElementById('property-area').textContent = property.area;
    document.getElementById('property-type').textContent = property.type;
    document.getElementById('property-bedrooms').textContent = property.bedrooms;
    document.getElementById('property-bathrooms').textContent = property.bathrooms;
    document.getElementById('property-status').textContent = property.status || 'available';
    document.getElementById('property-desc').textContent = property.description || 'Keine Beschreibung verfügbar';
    
    // Render actions
    renderPropertyActions(property);
    
    document.getElementById('property-details').classList.remove('hidden');
}

function closeDetails() {
    document.getElementById('property-details').classList.add('hidden');
    currentProperty = null;
}

function renderPropertyActions(property) {
    const actionsContainer = document.querySelector('.property-actions');
    actionsContainer.innerHTML = '';
    
    if (property.status === 'available') {
        if (property.for_sale === 1) {
            const purchaseBtn = document.createElement('button');
            purchaseBtn.className = 'btn-success';
            purchaseBtn.textContent = '✓ Kaufen';
            purchaseBtn.onclick = () => purchaseProperty(property.id);
            actionsContainer.appendChild(purchaseBtn);
        }
        
        if (property.for_rent === 1) {
            const rentBtn = document.createElement('button');
            rentBtn.className = 'btn-primary';
            rentBtn.textContent = '🏠 Mieten';
            rentBtn.onclick = () => rentProperty(property.id);
            actionsContainer.appendChild(rentBtn);
        }
        
        const viewingBtn = document.createElement('button');
        viewingBtn.className = 'btn-warning';
        viewingBtn.textContent = '👁️ Besichtigen';
        viewingBtn.onclick = () => bookViewing(property.id);
        actionsContainer.appendChild(viewingBtn);
    }
}

// ====================================================================================================
// 🎯 ACTIONS
// ====================================================================================================

function purchaseProperty(propertyId) {
    sendMessage('propertyAction', {
        action: 'purchase',
        propertyId: propertyId
    });
    closeDetails();
    closeCatalog();
}

function rentProperty(propertyId) {
    sendMessage('propertyAction', {
        action: 'rent',
        propertyId: propertyId
    });
    closeDetails();
    closeCatalog();
}

function bookViewing(propertyId) {
    sendMessage('propertyAction', {
        action: 'viewing',
        propertyId: propertyId
    });
    closeDetails();
    closeCatalog();
}

// ====================================================================================================
// 🔔 NOTIFICATIONS
// ====================================================================================================

function showNotification(data) {
    const notification = document.createElement('div');
    notification.className = `notification ${data.type} animate-slideIn`;
    notification.id = `notif-${data.id || Date.now()}`;
    
    const icons = {
        success: '✓',
        error: '✗',
        warning: '⚠',
        info: 'ℹ'
    };
    
    notification.innerHTML = `
        <div class="notification-icon">${icons[data.type] || 'ℹ'}</div>
        <div class="notification-content">
            <div class="notification-title">${data.title}</div>
            <div class="notification-message">${data.message}</div>
        </div>
    `;
    
    document.getElementById('notifications').appendChild(notification);
    
    // Auto-remove after duration
    setTimeout(() => {
        removeNotification(notification.id);
    }, data.duration || 5000);
}

function removeNotification(id) {
    const notification = document.getElementById(id);
    if (notification) {
        notification.classList.add('animate-slideOut');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }
}

// ====================================================================================================
// 🏠 PROPERTY INTERACTION MENU
// ====================================================================================================

function openPropertyMenu(data) {
    const property = data.property;
    const hasAccess = data.hasAccess;
    const keyData = data.keyData;
    
    let menuHTML = `
        <div class="property-menu-overlay" id="propertyMenuOverlay">
            <div class="property-menu-container">
                <div class="property-menu-header">
                    <h2>${property.name}</h2>
                    <p>${property.area} • ${property.type}</p>
                    <button class="close-btn" onclick="closePropertyMenu()">×</button>
                </div>
                <div class="property-menu-content">
    `;
    
    if (hasAccess && keyData) {
        // Player has keys - show full menu
        menuHTML += `
            <div class="menu-section">
                <h3>🔑 Zugriff</h3>
                <p class="access-level">Berechtigung: <strong>${keyData.permission_level}</strong></p>
            </div>
            <div class="menu-actions">
        `;
        
        if (keyData.can_enter == 1) {
            menuHTML += `<button class="menu-btn primary" onclick="propertyMenuAction('enter', '${property.id}')">🚪 Betreten</button>`;
        }
        
        if (keyData.can_lock == 1) {
            menuHTML += `<button class="menu-btn" onclick="propertyMenuAction('lock', '${property.id}')">🔒 Abschließen/Aufschließen</button>`;
        }
        
        if (keyData.can_manage_keys == 1) {
            menuHTML += `<button class="menu-btn" onclick="propertyMenuAction('manageKeys', '${property.id}')">🔑 Schlüsselverwaltung</button>`;
        }
        
        if (keyData.can_access_garage == 1) {
            menuHTML += `<button class="menu-btn" onclick="propertyMenuAction('garage', '${property.id}')">🚗 Garage</button>`;
        }
        
        if (keyData.can_sell == 1) {
            menuHTML += `<button class="menu-btn danger" onclick="propertyMenuAction('sell', '${property.id}')">💰 Verkaufen</button>`;
        }
        
        menuHTML += `</div>`;
    } else {
        // Player has NO keys - show access code input
        menuHTML += `
            <div class="menu-section">
                <h3>🔐 Zugangscode erforderlich</h3>
                <p>Sie benötigen einen 4-stelligen Zugangscode oder Schlüssel für diese Immobilie.</p>
            </div>
            <div class="menu-actions">
                <button class="menu-btn primary" onclick="propertyMenuAction('enterCode', '${property.id}')">🔢 Code eingeben</button>
                <button class="menu-btn" onclick="closePropertyMenu()">❌ Abbrechen</button>
            </div>
        `;
    }
    
    menuHTML += `
                </div>
            </div>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', menuHTML);
}

function closePropertyMenu() {
    const overlay = document.getElementById('propertyMenuOverlay');
    if (overlay) {
        overlay.remove();
    }
    sendMessage('propertyMenuAction', { action: 'close' });
}

function propertyMenuAction(action, propertyId) {
    sendMessage('propertyMenuAction', { action, propertyId });
    if (action !== 'manageKeys' && action !== 'garage' && action !== 'enterCode') {
        closePropertyMenu();
    }
}

// ====================================================================================================
// 🔢 ACCESS CODE INPUT DIALOG
// ====================================================================================================

function openAccessCodeDialog(data) {
    const propertyId = data.propertyId;
    
    const dialogHTML = `
        <div class="access-code-overlay" id="accessCodeOverlay">
            <div class="access-code-dialog">
                <div class="dialog-header">
                    <h2>🔐 Zugangscode eingeben</h2>
                    <button class="close-btn" onclick="closeAccessCodeDialog()">×</button>
                </div>
                <div class="dialog-content">
                    <p>Geben Sie den 4-stelligen Zugangscode ein:</p>
                    <div class="code-input-group">
                        <input type="text" id="codeDigit1" class="code-digit" maxlength="1" autofocus>
                        <input type="text" id="codeDigit2" class="code-digit" maxlength="1">
                        <input type="text" id="codeDigit3" class="code-digit" maxlength="1">
                        <input type="text" id="codeDigit4" class="code-digit" maxlength="1">
                    </div>
                    <p class="code-hint">Hinweis: Sie erhalten diesen Code bei einer Buchung oder Besichtigung.</p>
                </div>
                <div class="dialog-actions">
                    <button class="btn-primary" onclick="submitAccessCode('${propertyId}')">✓ Bestätigen</button>
                    <button class="btn-secondary" onclick="closeAccessCodeDialog()">✗ Abbrechen</button>
                </div>
            </div>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', dialogHTML);
    
    // Setup auto-focus and auto-advance for code inputs
    setupCodeInputs();
}

function setupCodeInputs() {
    const inputs = document.querySelectorAll('.code-digit');
    inputs.forEach((input, index) => {
        input.addEventListener('input', (e) => {
            if (e.target.value.length === 1 && index < inputs.length - 1) {
                inputs[index + 1].focus();
            }
        });
        
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Backspace' && e.target.value === '' && index > 0) {
                inputs[index - 1].focus();
            }
        });
        
        // Only allow numbers
        input.addEventListener('keypress', (e) => {
            if (!/[0-9]/.test(e.key)) {
                e.preventDefault();
            }
        });
    });
}

function submitAccessCode(propertyId) {
    const digit1 = document.getElementById('codeDigit1').value;
    const digit2 = document.getElementById('codeDigit2').value;
    const digit3 = document.getElementById('codeDigit3').value;
    const digit4 = document.getElementById('codeDigit4').value;
    
    const accessCode = digit1 + digit2 + digit3 + digit4;
    
    if (accessCode.length !== 4) {
        showNotification({
            type: 'error',
            title: 'Fehler',
            message: 'Bitte geben Sie einen vollständigen 4-stelligen Code ein.'
        });
        return;
    }
    
    sendMessage('submitAccessCode', { propertyId, accessCode });
}

function closeAccessCodeDialog() {
    const overlay = document.getElementById('accessCodeOverlay');
    if (overlay) {
        overlay.remove();
    }
}

// ====================================================================================================
// 🔑 KEY MANAGEMENT UI
// ====================================================================================================

function openKeyManagement(data) {
    const propertyId = data.propertyId;
    const keyHolders = data.keyHolders;
    
    let keyHoldersHTML = '';
    keyHolders.forEach(key => {
        keyHoldersHTML += `
            <div class="key-holder-card">
                <div class="key-holder-info">
                    <strong>${key.holder}</strong>
                    <span class="permission-badge ${key.permission_level}">${key.permission_level}</span>
                </div>
                <div class="key-permissions">
                    ${key.can_enter == 1 ? '🚪 Betreten' : ''}
                    ${key.can_lock == 1 ? '🔒 Abschließen' : ''}
                    ${key.can_invite == 1 ? '👥 Einladen' : ''}
                    ${key.can_manage_keys == 1 ? '🔑 Verwalten' : ''}
                </div>
                <button class="btn-danger-sm" onclick="removeKey('${propertyId}', '${key.holder}')">Entfernen</button>
            </div>
        `;
    });
    
    const managementHTML = `
        <div class="key-management-overlay" id="keyManagementOverlay">
            <div class="key-management-dialog">
                <div class="dialog-header">
                    <h2>🔑 Schlüsselverwaltung</h2>
                    <button class="close-btn" onclick="closeKeyManagement()">×</button>
                </div>
                <div class="dialog-content">
                    <div class="key-holders-list">
                        <h3>Schlüsselinhaber (${keyHolders.length})</h3>
                        ${keyHoldersHTML || '<p class="no-data">Keine Schlüsselinhaber</p>'}
                    </div>
                    <div class="key-actions">
                        <h3>Aktionen</h3>
                        <button class="btn-primary" onclick="showGiveKeyDialog('${propertyId}')">➕ Schlüssel vergeben</button>
                        <button class="btn-secondary" onclick="duplicateKey('${propertyId}')">📋 Schlüssel duplizieren</button>
                    </div>
                </div>
                <div class="dialog-actions">
                    <button class="btn-secondary" onclick="closeKeyManagement()">Schließen</button>
                </div>
            </div>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', managementHTML);
}

function closeKeyManagement() {
    const overlay = document.getElementById('keyManagementOverlay');
    if (overlay) {
        overlay.remove();
    }
    sendMessage('keyManagementAction', { action: 'close' });
}

function removeKey(propertyId, targetPlayerId) {
    if (confirm('Möchten Sie wirklich den Schlüssel von diesem Spieler entfernen?')) {
        sendMessage('keyManagementAction', {
            action: 'removeKey',
            propertyId,
            targetPlayerId
        });
        closeKeyManagement();
    }
}

function showGiveKeyDialog(propertyId) {
    const playerId = prompt('Spieler-ID eingeben:');
    if (playerId) {
        const permissions = ['owner', 'tenant', 'guest'];
        const permissionLevel = prompt('Berechtigungsstufe (owner/tenant/guest):', 'guest');
        
        if (permissions.includes(permissionLevel)) {
            sendMessage('keyManagementAction', {
                action: 'giveKey',
                propertyId,
                targetPlayerId: parseInt(playerId),
                permissionLevel
            });
            closeKeyManagement();
        }
    }
}

function duplicateKey(propertyId) {
    if (confirm('Schlüssel duplizieren für $500?')) {
        sendMessage('keyManagementAction', {
            action: 'duplicateKey',
            propertyId,
            paymentMethod: 'cash'
        });
        closeKeyManagement();
    }
}

// ====================================================================================================
// 🛠️ UTILITY FUNCTIONS
// ====================================================================================================

function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function sendMessage(action, data = {}) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    }).catch(err => console.error('Error sending message:', err));
}

function GetParentResourceName() {
    return window.location.hostname === '' ? 'Home_Manger' : window.location.hostname;
}

function closeAll() {
    closeCatalog();
    closeDetails();
    sendMessage('close');
}

// Export functions for global access
window.closeCatalog = closeCatalog;
window.closeDetails = closeDetails;
window.applyFilters = applyFilters;
