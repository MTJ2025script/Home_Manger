// ====================================================================================================
// 🛠️ JAVASCRIPT UTILITY FUNCTIONS
// Helper functions for UI operations
// ====================================================================================================

// Format number with commas
function formatNumber(num) {
    if (!num) return '0';
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

// Format money
function formatMoney(amount, currency = '$') {
    return currency + formatNumber(amount);
}

// Format date
function formatDate(timestamp) {
    const date = new Date(timestamp);
    return date.toLocaleDateString('de-DE') + ' ' + date.toLocaleTimeString('de-DE');
}

// Format time duration
function formatDuration(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    if (hours > 0) {
        return `${hours}h ${minutes}m ${secs}s`;
    } else if (minutes > 0) {
        return `${minutes}m ${secs}s`;
    } else {
        return `${secs}s`;
    }
}

// Debounce function
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Throttle function
function throttle(func, limit) {
    let inThrottle;
    return function() {
        const args = arguments;
        const context = this;
        if (!inThrottle) {
            func.apply(context, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// Random ID generator
function generateId() {
    return Math.random().toString(36).substr(2, 9);
}

// Deep clone object
function deepClone(obj) {
    return JSON.parse(JSON.stringify(obj));
}

// Check if object is empty
function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}

// Array shuffle
function shuffle(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
}

// Array unique
function unique(array) {
    return [...new Set(array)];
}

// Sort by property
function sortBy(array, property, ascending = true) {
    return array.sort((a, b) => {
        if (ascending) {
            return a[property] > b[property] ? 1 : -1;
        } else {
            return a[property] < b[property] ? 1 : -1;
        }
    });
}

// Filter array by property value
function filterBy(array, property, value) {
    return array.filter(item => item[property] === value);
}

// Get property value by path
function getPropertyByPath(obj, path) {
    return path.split('.').reduce((current, prop) => current?.[prop], obj);
}

// Set property value by path
function setPropertyByPath(obj, path, value) {
    const props = path.split('.');
    const lastProp = props.pop();
    const target = props.reduce((current, prop) => {
        if (!current[prop]) current[prop] = {};
        return current[prop];
    }, obj);
    target[lastProp] = value;
}

// Validate email
function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// Validate phone
function isValidPhone(phone) {
    return /^\+?[\d\s\-()]+$/.test(phone);
}

// Clamp number between min and max
function clamp(num, min, max) {
    return Math.min(Math.max(num, min), max);
}

// Linear interpolation
function lerp(start, end, t) {
    return start + (end - start) * t;
}

// Map range
function mapRange(value, inMin, inMax, outMin, outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

// Export functions
window.utils = {
    formatNumber,
    formatMoney,
    formatDate,
    formatDuration,
    debounce,
    throttle,
    generateId,
    deepClone,
    isEmpty,
    shuffle,
    unique,
    sortBy,
    filterBy,
    getPropertyByPath,
    setPropertyByPath,
    isValidEmail,
    isValidPhone,
    clamp,
    lerp,
    mapRange
};
