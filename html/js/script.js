// ====================================================================================================
// 🏠 PROPERTY MANAGER - COMPLETE UI SYSTEM
// New implementation with category navigation and full action support
// ====================================================================================================

let allProperties = [];
let currentCategory = null;
let currentProperty = null;
let filteredProperties = [];

// Image mapping for property types
const propertyImages = {
    'office': 'images/office.png',
    'house': 'images/house.png',
    'hotel': 'images/hotel.png',
    'apartment': 'images/apartment.png',
    'villa': 'images/villa.png',
    'mansion': 'images/mansion.png'
};

// ====================================================================================================
// 🚀 INITIALIZATION
// ====================================================================================================

document.addEventListener('DOMContentLoaded', () => {
    console.log('[Property Manager] UI System Loaded');
    
    // ESC key handler
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            console.log('[Property Manager] ===== ESC KEY PRESSED =====');
            console.log('[Property Manager] Calling closeUI() from ESC handler');
            closeUI();
            console.log('[Property Manager] closeUI() returned from ESC handler');
        }
    });
});

// Listen for messages from game
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (!data || !data.action) return;
    
    console.log('[Property Manager] Received action:', data.action);
    
    switch (data.action) {
        case 'openCatalog':
            openCatalog(data.properties || []);
            break;
        case 'closeCatalog':
        case 'close':
            console.log('[Property Manager] Received close action - calling closeUI()');
            closeUI();
            break;
        case 'forceClose':
        case 'forceCloseAll':
            // EMERGENCY FORCE CLOSE - Most aggressive
            console.log('[Property Manager] ========== EMERGENCY FORCE CLOSE ==========');
            console.log('[Property Manager] Hiding EVERYTHING immediately');
            document.body.style.display = 'none';
            const allElements = document.querySelectorAll('*');
            console.log('[Property Manager] Hiding', allElements.length, 'elements');
            allElements.forEach(el => el.style.display = 'none');
            currentCategory = null;
            currentProperty = null;
            filteredProperties = [];
            allProperties = [];
            console.log('[Property Manager] Emergency: All state cleared');
            setTimeout(() => {
                console.log('[Property Manager] Emergency: Restoring container');
                document.body.style.display = 'block';
                document.querySelectorAll('.page').forEach(el => el.style.display = 'none');
                console.log('[Property Manager] Emergency: Container restored');
            }, 50);
            console.log('[Property Manager] ========== EMERGENCY COMPLETE ==========');
            break;
        case 'showNotification':
            showNotification(data.type, data.title, data.message);
            break;
        case 'updateProperties':
            allProperties = data.properties || [];
            if (currentCategory) {
                showCategory(currentCategory);
            }
            break;
        default:
            console.warn('[Property Manager] Unknown action:', data.action);
    }
});

// ====================================================================================================
// 📄 PAGE NAVIGATION
// ====================================================================================================

function showPage(pageId) {
    // Hide all pages
    document.querySelectorAll('.page').forEach(page => {
        page.classList.add('hidden');
    });
    
    // Show requested page
    const page = document.getElementById(pageId);
    if (page) {
        page.classList.remove('hidden');
    }
}

function openCatalog(properties) {
    console.log('[Property Manager] Opening catalog with', properties.length, 'properties');
    allProperties = properties;
    showPage('category-page');
}

function closeUI() {
    console.log('[Property Manager] ========== JS CLOSE UI START ==========');
    
    // STEP 1: Hide entire UI container IMMEDIATELY
    console.log('[Property Manager] JS Step 1: Hiding body...');
    const container = document.body;
    if (container) {
        const wasVisible = container.style.display !== 'none';
        console.log('[Property Manager] Body was visible:', wasVisible);
        container.style.display = 'none';
        console.log('[Property Manager] Body display now:', container.style.display);
    }
    console.log('[Property Manager] JS Step 1: Body hidden ✓');
    
    // STEP 2: Hide all pages and dialogs
    console.log('[Property Manager] JS Step 2: Hiding all elements...');
    const elements = document.querySelectorAll('.page, .dialog');
    console.log('[Property Manager] Found', elements.length, 'elements to hide');
    elements.forEach(el => {
        el.style.display = 'none';
        el.classList.add('hidden');
    });
    console.log('[Property Manager] JS Step 2: All elements hidden ✓');
    
    // STEP 3: Reset all state
    console.log('[Property Manager] JS Step 3: Resetting state...');
    console.log('[Property Manager] Current category:', currentCategory);
    console.log('[Property Manager] Current property:', currentProperty);
    console.log('[Property Manager] Properties count:', allProperties.length);
    currentCategory = null;
    currentProperty = null;
    filteredProperties = [];
    allProperties = [];
    console.log('[Property Manager] State reset - all null/empty');
    console.log('[Property Manager] JS Step 3: State reset ✓');
    
    // STEP 4: DO NOT SEND MESSAGE BACK
    console.log('[Property Manager] JS Step 4: NOT sending callback to game (prevents loop)');
    console.log('[Property Manager] JS Step 4: Callback skipped ✓');
    
    // STEP 5: Re-show container after brief delay (for next open)
    console.log('[Property Manager] JS Step 5: Scheduling container restore in 100ms...');
    setTimeout(() => {
        if (container) {
            console.log('[Property Manager] Restoring container display...');
            container.style.display = 'block';
            console.log('[Property Manager] Container restored for next use');
        }
    }, 100);
    console.log('[Property Manager] JS Step 5: Restore scheduled ✓');
    
    console.log('[Property Manager] ========== JS CLOSE UI COMPLETE ==========');
}

function showCategory(category) {
    console.log('[Property Manager] Showing category:', category);
    currentCategory = category;
    
    // Filter properties by category
    filteredProperties = allProperties.filter(p => p.type === category);
    
    // Update title
    const categoryNames = {
        'office': '🏢 Büros',
        'house': '🏠 Häuser',
        'hotel': '🏨 Hotels',
        'apartment': '🏘️ Apartments',
        'villa': '🏡 Villen',
        'mansion': '🏰 Herrenhäuser'
    };
    document.getElementById('category-title').textContent = categoryNames[category] || 'Immobilien';
    
    // Render properties
    renderPropertyList();
    
    // Show property list page
    showPage('property-list-page');
}

function backToCategories() {
    currentCategory = null;
    filteredProperties = [];
    showPage('category-page');
}

function backToPropertyList() {
    currentProperty = null;
    showCategory(currentCategory);
}

// ====================================================================================================
// 🏘️ PROPERTY LIST RENDERING
// ====================================================================================================

function renderPropertyList() {
    const grid = document.getElementById('property-grid');
    grid.innerHTML = '';
    
    if (filteredProperties.length === 0) {
        grid.innerHTML = '<div class="no-properties"><p>Keine Immobilien in dieser Kategorie verfügbar.</p></div>';
        return;
    }
    
    filteredProperties.forEach(property => {
        const card = createPropertyCard(property);
        grid.appendChild(card);
    });
}

function createPropertyCard(property) {
    const card = document.createElement('div');
    card.className = 'property-card';
    card.onclick = () => showPropertyDetails(property);
    
    // Get image for property type
    const imgSrc = propertyImages[property.type] || propertyImages['house'];
    
    // Status badge
    const statusText = {
        'available': 'Verfügbar',
        'owned': 'Verkauft',
        'rented': 'Vermietet',
        'viewing': 'In Besichtigung'
    };
    const statusClass = property.status || 'available';
    
    card.innerHTML = `
        <div class="property-card-image">
            <img src="${imgSrc}" alt="${property.name}">
            <span class="property-status status-${statusClass}">${statusText[statusClass] || 'Verfügbar'}</span>
        </div>
        <div class="property-card-content">
            <h3>${property.name}</h3>
            <p class="property-card-area">📍 ${property.area}</p>
            <div class="property-card-specs">
                <span>🛏️ ${property.bedrooms || 0}</span>
                <span>🚿 ${property.bathrooms || 0}</span>
                <span>🚗 ${property.garage_type || 'Keine'}</span>
            </div>
            <p class="property-card-price">💰 $${formatPrice(property.price)}</p>
        </div>
    `;
    
    return card;
}

// ====================================================================================================
// 📋 PROPERTY DETAILS
// ====================================================================================================

function showPropertyDetails(property) {
    console.log('[Property Manager] Showing details for:', property.id);
    currentProperty = property;
    
    // Get image
    const imgSrc = propertyImages[property.type] || propertyImages['house'];
    document.getElementById('detail-property-img').src = imgSrc;
    
    // Set basic info
    document.getElementById('detail-property-name').textContent = property.name;
    document.getElementById('detail-property-title').textContent = property.name;
    document.getElementById('detail-property-price').textContent = `$${formatPrice(property.price)}`;
    document.getElementById('detail-property-type').textContent = property.type.toUpperCase();
    document.getElementById('detail-property-area').textContent = property.area;
    document.getElementById('detail-property-bedrooms').textContent = property.bedrooms || 0;
    document.getElementById('detail-property-bathrooms').textContent = property.bathrooms || 0;
    document.getElementById('detail-property-garage').textContent = property.garage_type || 'Keine';
    document.getElementById('detail-property-description').textContent = property.description || 'Keine Beschreibung verfügbar.';
    
    // Status badge
    const statusText = {
        'available': 'Verfügbar',
        'owned': 'Verkauft',
        'rented': 'Vermietet',
        'viewing': 'In Besichtigung'
    };
    const statusEl = document.getElementById('detail-property-status');
    statusEl.textContent = statusText[property.status] || 'Verfügbar';
    statusEl.className = `status-badge status-${property.status || 'available'}`;
    
    // Render action buttons
    renderPropertyActions(property);
    
    // Show details page
    showPage('property-details-page');
}

function renderPropertyActions(property) {
    const actionsContainer = document.getElementById('property-actions');
    actionsContainer.innerHTML = '';
    
    // Only show actions for available properties
    if (property.status === 'available') {
        // Viewing button
        const viewingBtn = document.createElement('button');
        viewingBtn.className = 'btn btn-viewing';
        viewingBtn.innerHTML = '👁️ Besichtigung Buchen ($500)';
        viewingBtn.onclick = () => openViewingDialog(property);
        actionsContainer.appendChild(viewingBtn);
        
        // Rent button
        const rentBtn = document.createElement('button');
        rentBtn.className = 'btn btn-rent';
        const monthlyRent = Math.floor(property.price * 0.1);
        rentBtn.innerHTML = `🔑 Mieten ($${formatPrice(monthlyRent)}/Monat)`;
        rentBtn.onclick = () => openRentDialog(property);
        actionsContainer.appendChild(rentBtn);
        
        // Purchase button
        const purchaseBtn = document.createElement('button');
        purchaseBtn.className = 'btn btn-purchase';
        purchaseBtn.innerHTML = `💰 Kaufen ($${formatPrice(property.price)})`;
        purchaseBtn.onclick = () => openPurchaseDialog(property);
        actionsContainer.appendChild(purchaseBtn);
    } else {
        // Property not available
        const notAvailableMsg = document.createElement('p');
        notAvailableMsg.className = 'not-available-message';
        notAvailableMsg.textContent = 'Diese Immobilie ist derzeit nicht verfügbar.';
        actionsContainer.appendChild(notAvailableMsg);
    }
}

// ====================================================================================================
// 💬 DIALOGS - VIEWING
// ====================================================================================================

function openViewingDialog(property) {
    currentProperty = property;
    document.getElementById('viewing-price').textContent = '$500';
    document.getElementById('viewing-dialog').classList.remove('hidden');
}

function closeViewingDialog() {
    document.getElementById('viewing-dialog').classList.add('hidden');
}

function confirmViewing() {
    if (!currentProperty) return;
    
    console.log('[Property Manager] Confirming viewing for:', currentProperty.id);
    closeViewingDialog();
    
    // Send to game
    sendMessage('propertyAction', {
        action: 'viewing',
        propertyId: currentProperty.id,
        property: currentProperty
    });
    
    showNotification('info', 'Besichtigung', 'Anfrage wird bearbeitet...');
}

// ====================================================================================================
// 💬 DIALOGS - RENT
// ====================================================================================================

function openRentDialog(property) {
    currentProperty = property;
    const monthlyRent = Math.floor(property.price * 0.1);
    const deposit = monthlyRent * 2;
    
    document.getElementById('rent-monthly').textContent = `$${formatPrice(monthlyRent)}`;
    document.getElementById('rent-deposit').textContent = `$${formatPrice(deposit)}`;
    document.getElementById('rent-dialog').classList.remove('hidden');
}

function closeRentDialog() {
    document.getElementById('rent-dialog').classList.add('hidden');
}

function confirmRent() {
    if (!currentProperty) return;
    
    console.log('[Property Manager] Confirming rent for:', currentProperty.id);
    closeRentDialog();
    
    // Send to game
    sendMessage('propertyAction', {
        action: 'rent',
        propertyId: currentProperty.id,
        property: currentProperty
    });
    
    showNotification('info', 'Miete', 'Mietvertrag wird erstellt...');
}

// ====================================================================================================
// 💬 DIALOGS - PURCHASE
// ====================================================================================================

function openPurchaseDialog(property) {
    currentProperty = property;
    document.getElementById('purchase-price').textContent = `$${formatPrice(property.price)}`;
    document.getElementById('purchase-dialog').classList.remove('hidden');
}

function closePurchaseDialog() {
    document.getElementById('purchase-dialog').classList.add('hidden');
}

function confirmPurchase() {
    if (!currentProperty) return;
    
    const paymentMethod = document.querySelector('input[name="payment"]:checked').value;
    
    console.log('[Property Manager] Confirming purchase for:', currentProperty.id, 'with payment:', paymentMethod);
    closePurchaseDialog();
    
    // Send to game
    sendMessage('propertyAction', {
        action: 'purchase',
        propertyId: currentProperty.id,
        property: currentProperty,
        paymentMethod: paymentMethod
    });
    
    showNotification('info', 'Kauf', 'Kaufvertrag wird bearbeitet...');
}

// ====================================================================================================
// 🔔 NOTIFICATIONS
// ====================================================================================================

function showNotification(type, title, message) {
    const container = document.getElementById('notifications');
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <strong>${title}</strong>
        <p>${message}</p>
    `;
    
    container.appendChild(notification);
    
    // Animate in
    setTimeout(() => notification.classList.add('show'), 10);
    
    // Remove after 4 seconds
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => notification.remove(), 300);
    }, 4000);
}

// ====================================================================================================
// 🛠️ UTILITY FUNCTIONS
// ====================================================================================================

function formatPrice(price) {
    return price.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

function sendMessage(action, data = {}) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    }).catch(err => {
        console.error('[Property Manager] Failed to send message:', err);
    });
}

function GetParentResourceName() {
    if (window.location.protocol === 'file:') {
        return 'Home_Manger'; // For testing in browser
    }
    
    const match = window.location.hostname.match(/^([^\.]+)/);
    return match ? match[1] : 'Home_Manger';
}
