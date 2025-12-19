/* home_manger/html/js/script.js
   Fixes applied:
   - Re-entrancy guard (isClosing) to prevent multiple closeUI runs
   - restoreTimer with clearTimeout to avoid stacked timers
   - Single ESC handler registration that ignores key repeat
   - Temporary removal/re-registration of ESC handler while closing (optional)
   - Preserves and expands existing debug logs
*/

(function () {
  'use strict';

  // State guards
  let isClosing = false;
  let restoreTimer = null;

  // Example state variables used by the UI (adapt if your real names differ)
  let currentCategory = null;
  let currentProperty = null;
  let propertiesCount = 0;

  // Make sure we don't register the ESC handler multiple times
  function registerEscHandler() {
    if (!window.__homeManagerEscRegistered) {
      window.addEventListener('keydown', handleKeydown);
      window.__homeManagerEscRegistered = true;
      console.log('[Property Manager] ESC handler registered');
    }
  }

  function unregisterEscHandler() {
    if (window.__homeManagerEscRegistered) {
      window.removeEventListener('keydown', handleKeydown);
      window.__homeManagerEscRegistered = false;
      console.log('[Property Manager] ESC handler unregistered');
    }
  }

  function handleKeydown(e) {
    if (e.key === 'Escape') {
      // Ignore auto-repeat events from holding the key
      if (e.repeat) {
        console.log('[Property Manager] ESC key repeat ignored');
        return;
      }

      console.log('[Property Manager] ===== ESC KEY PRESSED =====');
      // Call closeUI through safe entry-point
      closeUI();
    }
  }

  // Safe, idempotent closeUI
  function closeUI() {
    // Prevent re-entrancy
    if (isClosing) {
      console.log('[Property Manager] closeUI() called but already closing - skipping');
      return;
    }
    isClosing = true;

    console.log('[Property Manager] ========== JS CLOSE UI START ==========');

    // Step 1: Hiding body
    try {
      console.log('[Property Manager] JS Step 1: Hiding body...');
      const body = document.querySelector('body');
      const bodyWasVisible = body && getComputedStyle(body).display !== 'none';
      console.log('[Property Manager] Body was visible: ' + (bodyWasVisible ? 'true' : 'false'));
      if (body) body.style.display = 'none';
      console.log('[Property Manager] Body display now: ' + (body ? body.style.display : 'none'));
      console.log('[Property Manager] JS Step 1: Body hidden ✓');
    } catch (err) {
      console.error('[Property Manager] Error in Step 1:', err);
    }

    // Step 2: Hiding all elements
    try {
      console.log('[Property Manager] JS Step 2: Hiding all elements...');
      // Adjust selector to match elements you need to hide
      const elements = Array.from(document.querySelectorAll('.property-ui, .property-overlay, .property-container, .pm-hide'));
      console.log('[Property Manager] Found ' + elements.length + ' elements to hide');
      elements.forEach(el => {
        el.dataset.__pm_orig_display = el.style.display || '';
        el.style.display = 'none';
      });
      console.log('[Property Manager] JS Step 2: All elements hidden ✓');
    } catch (err) {
      console.error('[Property Manager] Error in Step 2:', err);
    }

    // Step 3: Resetting state
    try {
      console.log('[Property Manager] JS Step 3: Resetting state...');
      console.log('[Property Manager] Current category: ' + (currentCategory === null ? 'null' : currentCategory));
      console.log('[Property Manager] Current property: ' + (currentProperty === null ? 'null' : currentProperty));
      console.log('[Property Manager] Properties count: ' + propertiesCount);

      // Reset the in-memory state used by the UI
      currentCategory = null;
      currentProperty = null;
      propertiesCount = 0;

      console.log('[Property Manager] State reset - all null/empty');
      console.log('[Property Manager] JS Step 3: State reset ✓');
    } catch (err) {
      console.error('[Property Manager] Error in Step 3:', err);
    }

    // Step 4: Optionally skip sending callback to game to prevent loops
    try {
      console.log('[Property Manager] JS Step 4: NOT sending callback to game (prevents loop)');
      // If you have a callback system, ensure we skip it here
      // e.g. gameCallbackSkip = true; // implement as needed
      console.log('[Property Manager] JS Step 4: Callback skipped ✓');
    } catch (err) {
      console.error('[Property Manager] Error in Step 4:', err);
    }

    // Before scheduling restore, clear any previous timer to avoid stacking
    if (restoreTimer) {
      clearTimeout(restoreTimer);
      restoreTimer = null;
      console.log('[Property Manager] Cleared previous restore timer');
    }

    // Optionally unregister ESC while closing to be extra-safe
    try {
      unregisterEscHandler();
      console.log('[Property Manager] JS Step 5: Scheduling container restore in 100ms...');

      restoreTimer = setTimeout(() => {
        try {
          console.log('[Property Manager] Restoring container display...');

          // Restore previously-hidden elements
          const elements = Array.from(document.querySelectorAll('[data-__pm_orig_display]'));
          elements.forEach(el => {
            const prev = el.dataset.__pm_orig_display || '';
            el.style.display = prev;
            delete el.dataset.__pm_orig_display;
          });

          const body = document.querySelector('body');
          if (body) body.style.display = '';

          console.log('[Property Manager] Container restored for next use');
        } catch (err) {
          console.error('[Property Manager] Error during restore:', err);
        } finally {
          // Re-register ESC handler so UI can be closed again later
          registerEscHandler();

          // Clear guard state so next close can run
          isClosing = false;
          restoreTimer = null;
          console.log('[Property Manager] ========== JS CLOSE UI COMPLETE ==========');
        }
      }, 100);

      console.log('[Property Manager] JS Step 5: Restore scheduled ✓');
    } catch (err) {
      console.error('[Property Manager] Error scheduling restore:', err);
      // In case of error, clear guard so we don't block future closes
      isClosing = false;
    }
  }

  // Initialization: ensure ESC handler is registered exactly once
  registerEscHandler();

  // Expose to global scope if other modules call closeUI directly
  window.homeManager = window.homeManager || {};
  window.homeManager.closeUI = closeUI;

})();
