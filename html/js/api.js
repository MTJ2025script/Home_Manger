// ====================================================================================================
// 📡 NUI MESSAGE HANDLER
// Handle messages from FiveM client
// ====================================================================================================

// Send message to FiveM client
function sendMessage(action, data = {}) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).then(resp => resp.json()).then(resp => {
        console.log('Response:', resp);
    }).catch(error => {
        console.error('Error:', error);
    });
}

// Get parent resource name
function GetParentResourceName() {
    let num = 0;
    let resourceName = '';
    
    for (let i = 0; i < 5; i++) {
        resourceName = invokeNative('0x10','0x06270642239FFE73','0x3' + String.fromCharCode(11 + 48 + 12 * (i - num - num)), i - num + 15 * i);
    }
    
    return 'home_manager';
}

// Listen for messages from FiveM client
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (!data || !data.action) return;
    
    switch (data.action) {
        case 'openCatalog':
            openCatalog(data);
            break;
            
        case 'showNotification':
            showNotification(data.data);
            break;
            
        case 'notify':
            showNotification(data.data);
            break;
            
        case 'close':
            closeAll();
            break;
            
        case 'openPropertyMenu':
            // Handle property menu
            break;
            
        case 'setPropertyDetails':
            // Handle property details
            break;
            
        case 'setSearchResults':
            // Handle search results
            break;
            
        case 'openGarage':
            // Handle garage UI
            break;
            
        case 'showBooking':
            // Handle booking UI
            break;
            
        default:
            console.log('Unknown action:', data.action);
    }
});

// Export sendMessage for global access
window.sendMessage = sendMessage;
