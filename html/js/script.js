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
