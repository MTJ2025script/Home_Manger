Locales = {}

-- ====================================================================================================
-- 🇩🇪 GERMAN (DEUTSCH)
-- ====================================================================================================

Locales['de'] = {
    -- Allgemein
    ['property_manager'] = 'Immobilien-Verwaltung',
    ['press_to_open'] = 'Drücke ~INPUT_CONTEXT~ um zu öffnen',
    ['press_to_interact'] = 'Drücke ~INPUT_CONTEXT~ um zu interagieren',
    ['loading'] = 'Lädt...',
    ['please_wait'] = 'Bitte warten...',
    ['success'] = 'Erfolg!',
    ['error'] = 'Fehler!',
    ['warning'] = 'Warnung!',
    ['info'] = 'Info',
    
    -- Makler-Büros
    ['realtor_office'] = 'Makler-Büro',
    ['open_catalog'] = 'Katalog öffnen',
    ['downtown_realty'] = 'Downtown Realty',
    ['vinewood_luxury'] = 'Vinewood Luxury Realty',
    ['delperro_beach'] = 'Del Perro Beach Properties',
    
    -- Immobilien
    ['property'] = 'Immobilie',
    ['properties'] = 'Immobilien',
    ['for_sale'] = 'Zu Verkaufen',
    ['for_rent'] = 'Zu Vermieten',
    ['owned'] = 'Gekauft',
    ['rented'] = 'Gemietet',
    ['available'] = 'Verfügbar',
    ['not_available'] = 'Nicht verfügbar',
    ['viewing'] = 'Besichtigung',
    
    -- Property Types
    ['apartment'] = 'Apartment',
    ['house'] = 'Haus',
    ['villa'] = 'Villa',
    ['mansion'] = 'Villa',
    ['hotel'] = 'Hotel',
    ['office'] = 'Büro',
    ['warehouse'] = 'Lager',
    ['garage'] = 'Garage',
    
    -- Booking
    ['book_viewing'] = 'Besichtigung buchen',
    ['book_rental'] = 'Mieten',
    ['purchase_property'] = 'Kaufen',
    ['viewing_booked'] = 'Besichtigung gebucht!',
    ['rental_booked'] = 'Miete gebucht!',
    ['property_purchased'] = 'Immobilie gekauft!',
    ['access_code'] = 'Zugangscode',
    ['enter_code'] = 'Code eingeben',
    ['code_expires'] = 'Code läuft ab in: %s Minuten',
    ['code_expired'] = 'Code abgelaufen!',
    ['invalid_code'] = 'Ungültiger Code!',
    ['valid_code'] = 'Code gültig! Zugang gewährt.',
    
    -- Zahlungen
    ['payment'] = 'Zahlung',
    ['price'] = 'Preis',
    ['deposit'] = 'Kaution',
    ['monthly_payment'] = 'Monatliche Zahlung',
    ['down_payment'] = 'Anzahlung',
    ['interest_rate'] = 'Zinssatz',
    ['duration'] = 'Laufzeit',
    ['mortgage'] = 'Hypothek',
    ['pay_with_cash'] = 'Bar bezahlen',
    ['pay_with_bank'] = 'Mit Bank bezahlen',
    ['payment_successful'] = 'Zahlung erfolgreich!',
    ['payment_failed'] = 'Zahlung fehlgeschlagen!',
    ['insufficient_funds'] = 'Nicht genug Geld!',
    ['mortgage_payment_due'] = 'Hypotheken-Zahlung fällig!',
    ['rent_payment_due'] = 'Mietzahlung fällig!',
    ['payment_overdue'] = 'Zahlung überfällig!',
    ['eviction_warning'] = 'Räumungswarnung! Zahle sofort!',
    
    -- Schlüssel
    ['keys'] = 'Schlüssel',
    ['give_keys'] = 'Schlüssel geben',
    ['remove_keys'] = 'Schlüssel entziehen',
    ['duplicate_keys'] = 'Schlüssel duplizieren',
    ['key_received'] = 'Schlüssel erhalten!',
    ['key_removed'] = 'Schlüssel entzogen!',
    ['no_keys'] = 'Du hast keine Schlüssel!',
    ['owner_keys'] = 'Eigentümer-Schlüssel',
    ['tenant_keys'] = 'Mieter-Schlüssel',
    ['guest_keys'] = 'Gast-Schlüssel',
    ['temporary_keys'] = 'Temporäre Schlüssel',
    
    -- Garage
    ['garage_menu'] = 'Garagen-Menü',
    ['store_vehicle'] = 'Fahrzeug einlagern',
    ['retrieve_vehicle'] = 'Fahrzeug holen',
    ['vehicle_stored'] = 'Fahrzeug eingelagert!',
    ['vehicle_retrieved'] = 'Fahrzeug geholt!',
    ['garage_full'] = 'Garage voll!',
    ['no_vehicle'] = 'Kein Fahrzeug in der Nähe!',
    ['not_your_vehicle'] = 'Das ist nicht dein Fahrzeug!',
    ['vehicle_already_stored'] = 'Fahrzeug bereits eingelagert!',
    ['no_vehicles_stored'] = 'Keine Fahrzeuge eingelagert!',
    
    -- Storage
    ['storage'] = 'Lager',
    ['safe'] = 'Safe',
    ['wardrobe'] = 'Kleiderschrank',
    ['stash'] = 'Stash',
    ['open_storage'] = 'Lager öffnen',
    ['enter_pin'] = 'PIN eingeben',
    ['pin_correct'] = 'PIN korrekt!',
    ['pin_incorrect'] = 'PIN falsch!',
    ['change_pin'] = 'PIN ändern',
    ['pin_changed'] = 'PIN geändert!',
    
    -- Admin
    ['admin_panel'] = 'Admin-Panel',
    ['create_property'] = 'Immobilie erstellen',
    ['edit_property'] = 'Immobilie bearbeiten',
    ['delete_property'] = 'Immobilie löschen',
    ['transfer_ownership'] = 'Eigentümer übertragen',
    ['evict_tenant'] = 'Mieter räumen',
    ['property_created'] = 'Immobilie erstellt!',
    ['property_updated'] = 'Immobilie aktualisiert!',
    ['property_deleted'] = 'Immobilie gelöscht!',
    ['ownership_transferred'] = 'Eigentümer übertragen!',
    ['tenant_evicted'] = 'Mieter geräumt!',
    
    -- Notifications
    ['new_property_available'] = 'Neue Immobilie verfügbar!',
    ['property_sold'] = 'Immobilie verkauft!',
    ['viewing_started'] = 'Besichtigung gestartet!',
    ['viewing_ended'] = 'Besichtigung beendet!',
    ['rental_started'] = 'Mietvertrag begonnen!',
    ['rental_ended'] = 'Mietvertrag beendet!',
    ['payment_reminder'] = 'Zahlungserinnerung!',
    ['gps_set'] = 'GPS gesetzt!',
    ['gps_removed'] = 'GPS entfernt!',
    
    -- Errors
    ['no_permission'] = 'Keine Berechtigung!',
    ['too_far'] = 'Zu weit entfernt!',
    ['property_not_found'] = 'Immobilie nicht gefunden!',
    ['already_owner'] = 'Du bist bereits Eigentümer!',
    ['max_properties_reached'] = 'Maximale Anzahl Immobilien erreicht!',
    ['property_occupied'] = 'Immobilie besetzt!',
    ['not_owner'] = 'Du bist nicht der Eigentümer!',
    ['player_not_found'] = 'Spieler nicht gefunden!',
    ['invalid_amount'] = 'Ungültiger Betrag!',
    ['action_cancelled'] = 'Aktion abgebrochen!',
    
    -- UI
    ['filter_by'] = 'Filtern nach',
    ['sort_by'] = 'Sortieren nach',
    ['search'] = 'Suchen',
    ['all'] = 'Alle',
    ['type'] = 'Typ',
    ['area'] = 'Gebiet',
    ['status'] = 'Status',
    ['price_low_high'] = 'Preis: Niedrig bis Hoch',
    ['price_high_low'] = 'Preis: Hoch bis Niedrig',
    ['close'] = 'Schließen',
    ['confirm'] = 'Bestätigen',
    ['cancel'] = 'Abbrechen',
    ['back'] = 'Zurück',
    ['next'] = 'Weiter',
    ['details'] = 'Details',
    ['gallery'] = 'Galerie',
    ['location'] = 'Standort',
    ['features'] = 'Ausstattung',
    ['description'] = 'Beschreibung'
}

-- ====================================================================================================
-- 🇬🇧 ENGLISH
-- ====================================================================================================

Locales['en'] = {
    -- General
    ['property_manager'] = 'Property Manager',
    ['press_to_open'] = 'Press ~INPUT_CONTEXT~ to open',
    ['press_to_interact'] = 'Press ~INPUT_CONTEXT~ to interact',
    ['loading'] = 'Loading...',
    ['please_wait'] = 'Please wait...',
    ['success'] = 'Success!',
    ['error'] = 'Error!',
    ['warning'] = 'Warning!',
    ['info'] = 'Info',
    
    -- Realtor Offices
    ['realtor_office'] = 'Realtor Office',
    ['open_catalog'] = 'Open Catalog',
    ['downtown_realty'] = 'Downtown Realty',
    ['vinewood_luxury'] = 'Vinewood Luxury Realty',
    ['delperro_beach'] = 'Del Perro Beach Properties',
    
    -- Properties
    ['property'] = 'Property',
    ['properties'] = 'Properties',
    ['for_sale'] = 'For Sale',
    ['for_rent'] = 'For Rent',
    ['owned'] = 'Owned',
    ['rented'] = 'Rented',
    ['available'] = 'Available',
    ['not_available'] = 'Not Available',
    ['viewing'] = 'Viewing',
    
    -- Property Types
    ['apartment'] = 'Apartment',
    ['house'] = 'House',
    ['villa'] = 'Villa',
    ['mansion'] = 'Mansion',
    ['hotel'] = 'Hotel',
    ['office'] = 'Office',
    ['warehouse'] = 'Warehouse',
    ['garage'] = 'Garage',
    
    -- Booking
    ['book_viewing'] = 'Book Viewing',
    ['book_rental'] = 'Rent',
    ['purchase_property'] = 'Purchase',
    ['viewing_booked'] = 'Viewing booked!',
    ['rental_booked'] = 'Rental booked!',
    ['property_purchased'] = 'Property purchased!',
    ['access_code'] = 'Access Code',
    ['enter_code'] = 'Enter Code',
    ['code_expires'] = 'Code expires in: %s minutes',
    ['code_expired'] = 'Code expired!',
    ['invalid_code'] = 'Invalid code!',
    ['valid_code'] = 'Valid code! Access granted.',
    
    -- Payments
    ['payment'] = 'Payment',
    ['price'] = 'Price',
    ['deposit'] = 'Deposit',
    ['monthly_payment'] = 'Monthly Payment',
    ['down_payment'] = 'Down Payment',
    ['interest_rate'] = 'Interest Rate',
    ['duration'] = 'Duration',
    ['mortgage'] = 'Mortgage',
    ['pay_with_cash'] = 'Pay with Cash',
    ['pay_with_bank'] = 'Pay with Bank',
    ['payment_successful'] = 'Payment successful!',
    ['payment_failed'] = 'Payment failed!',
    ['insufficient_funds'] = 'Insufficient funds!',
    ['mortgage_payment_due'] = 'Mortgage payment due!',
    ['rent_payment_due'] = 'Rent payment due!',
    ['payment_overdue'] = 'Payment overdue!',
    ['eviction_warning'] = 'Eviction warning! Pay now!',
    
    -- Keys
    ['keys'] = 'Keys',
    ['give_keys'] = 'Give Keys',
    ['remove_keys'] = 'Remove Keys',
    ['duplicate_keys'] = 'Duplicate Keys',
    ['key_received'] = 'Key received!',
    ['key_removed'] = 'Key removed!',
    ['no_keys'] = 'You have no keys!',
    ['owner_keys'] = 'Owner Keys',
    ['tenant_keys'] = 'Tenant Keys',
    ['guest_keys'] = 'Guest Keys',
    ['temporary_keys'] = 'Temporary Keys',
    
    -- Garage
    ['garage_menu'] = 'Garage Menu',
    ['store_vehicle'] = 'Store Vehicle',
    ['retrieve_vehicle'] = 'Retrieve Vehicle',
    ['vehicle_stored'] = 'Vehicle stored!',
    ['vehicle_retrieved'] = 'Vehicle retrieved!',
    ['garage_full'] = 'Garage full!',
    ['no_vehicle'] = 'No vehicle nearby!',
    ['not_your_vehicle'] = 'Not your vehicle!',
    ['vehicle_already_stored'] = 'Vehicle already stored!',
    ['no_vehicles_stored'] = 'No vehicles stored!',
    
    -- Storage
    ['storage'] = 'Storage',
    ['safe'] = 'Safe',
    ['wardrobe'] = 'Wardrobe',
    ['stash'] = 'Stash',
    ['open_storage'] = 'Open Storage',
    ['enter_pin'] = 'Enter PIN',
    ['pin_correct'] = 'PIN correct!',
    ['pin_incorrect'] = 'PIN incorrect!',
    ['change_pin'] = 'Change PIN',
    ['pin_changed'] = 'PIN changed!',
    
    -- Admin
    ['admin_panel'] = 'Admin Panel',
    ['create_property'] = 'Create Property',
    ['edit_property'] = 'Edit Property',
    ['delete_property'] = 'Delete Property',
    ['transfer_ownership'] = 'Transfer Ownership',
    ['evict_tenant'] = 'Evict Tenant',
    ['property_created'] = 'Property created!',
    ['property_updated'] = 'Property updated!',
    ['property_deleted'] = 'Property deleted!',
    ['ownership_transferred'] = 'Ownership transferred!',
    ['tenant_evicted'] = 'Tenant evicted!',
    
    -- Notifications
    ['new_property_available'] = 'New property available!',
    ['property_sold'] = 'Property sold!',
    ['viewing_started'] = 'Viewing started!',
    ['viewing_ended'] = 'Viewing ended!',
    ['rental_started'] = 'Rental started!',
    ['rental_ended'] = 'Rental ended!',
    ['payment_reminder'] = 'Payment reminder!',
    ['gps_set'] = 'GPS set!',
    ['gps_removed'] = 'GPS removed!',
    
    -- Errors
    ['no_permission'] = 'No permission!',
    ['too_far'] = 'Too far away!',
    ['property_not_found'] = 'Property not found!',
    ['already_owner'] = 'Already owner!',
    ['max_properties_reached'] = 'Maximum properties reached!',
    ['property_occupied'] = 'Property occupied!',
    ['not_owner'] = 'Not the owner!',
    ['player_not_found'] = 'Player not found!',
    ['invalid_amount'] = 'Invalid amount!',
    ['action_cancelled'] = 'Action cancelled!',
    
    -- UI
    ['filter_by'] = 'Filter by',
    ['sort_by'] = 'Sort by',
    ['search'] = 'Search',
    ['all'] = 'All',
    ['type'] = 'Type',
    ['area'] = 'Area',
    ['status'] = 'Status',
    ['price_low_high'] = 'Price: Low to High',
    ['price_high_low'] = 'Price: High to Low',
    ['close'] = 'Close',
    ['confirm'] = 'Confirm',
    ['cancel'] = 'Cancel',
    ['back'] = 'Back',
    ['next'] = 'Next',
    ['details'] = 'Details',
    ['gallery'] = 'Gallery',
    ['location'] = 'Location',
    ['features'] = 'Features',
    ['description'] = 'Description'
}

-- ====================================================================================================
-- 🇫🇷 FRENCH (FRANÇAIS)
-- ====================================================================================================

Locales['fr'] = {
    -- Général
    ['property_manager'] = 'Gestionnaire Immobilier',
    ['press_to_open'] = 'Appuyez sur ~INPUT_CONTEXT~ pour ouvrir',
    ['press_to_interact'] = 'Appuyez sur ~INPUT_CONTEXT~ pour interagir',
    ['loading'] = 'Chargement...',
    ['please_wait'] = 'Veuillez patienter...',
    ['success'] = 'Succès!',
    ['error'] = 'Erreur!',
    ['warning'] = 'Attention!',
    ['info'] = 'Info',
    
    -- Bureaux Immobilier
    ['realtor_office'] = 'Bureau Immobilier',
    ['open_catalog'] = 'Ouvrir le Catalogue',
    ['downtown_realty'] = 'Downtown Realty',
    ['vinewood_luxury'] = 'Vinewood Luxury Realty',
    ['delperro_beach'] = 'Del Perro Beach Properties',
    
    -- Propriétés
    ['property'] = 'Propriété',
    ['properties'] = 'Propriétés',
    ['for_sale'] = 'À Vendre',
    ['for_rent'] = 'À Louer',
    ['owned'] = 'Possédé',
    ['rented'] = 'Loué',
    ['available'] = 'Disponible',
    ['not_available'] = 'Non Disponible',
    ['viewing'] = 'Visite',
    
    -- Types de Propriétés
    ['apartment'] = 'Appartement',
    ['house'] = 'Maison',
    ['villa'] = 'Villa',
    ['mansion'] = 'Manoir',
    ['hotel'] = 'Hôtel',
    ['office'] = 'Bureau',
    ['warehouse'] = 'Entrepôt',
    ['garage'] = 'Garage',
    
    -- Réservation
    ['book_viewing'] = 'Réserver une Visite',
    ['book_rental'] = 'Louer',
    ['purchase_property'] = 'Acheter',
    ['viewing_booked'] = 'Visite réservée!',
    ['rental_booked'] = 'Location réservée!',
    ['property_purchased'] = 'Propriété achetée!',
    ['access_code'] = 'Code d\'Accès',
    ['enter_code'] = 'Entrer le Code',
    ['code_expires'] = 'Code expire dans: %s minutes',
    ['code_expired'] = 'Code expiré!',
    ['invalid_code'] = 'Code invalide!',
    ['valid_code'] = 'Code valide! Accès accordé.',
    
    -- Paiements
    ['payment'] = 'Paiement',
    ['price'] = 'Prix',
    ['deposit'] = 'Dépôt',
    ['monthly_payment'] = 'Paiement Mensuel',
    ['down_payment'] = 'Acompte',
    ['interest_rate'] = 'Taux d\'Intérêt',
    ['duration'] = 'Durée',
    ['mortgage'] = 'Hypothèque',
    ['pay_with_cash'] = 'Payer en Espèces',
    ['pay_with_bank'] = 'Payer par Banque',
    ['payment_successful'] = 'Paiement réussi!',
    ['payment_failed'] = 'Paiement échoué!',
    ['insufficient_funds'] = 'Fonds insuffisants!',
    ['mortgage_payment_due'] = 'Paiement d\'hypothèque dû!',
    ['rent_payment_due'] = 'Loyer dû!',
    ['payment_overdue'] = 'Paiement en retard!',
    ['eviction_warning'] = 'Avertissement d\'expulsion! Payez maintenant!',
    
    -- Clés
    ['keys'] = 'Clés',
    ['give_keys'] = 'Donner les Clés',
    ['remove_keys'] = 'Retirer les Clés',
    ['duplicate_keys'] = 'Dupliquer les Clés',
    ['key_received'] = 'Clé reçue!',
    ['key_removed'] = 'Clé retirée!',
    ['no_keys'] = 'Vous n\'avez pas de clés!',
    ['owner_keys'] = 'Clés Propriétaire',
    ['tenant_keys'] = 'Clés Locataire',
    ['guest_keys'] = 'Clés Invité',
    ['temporary_keys'] = 'Clés Temporaires',
    
    -- Garage
    ['garage_menu'] = 'Menu Garage',
    ['store_vehicle'] = 'Ranger Véhicule',
    ['retrieve_vehicle'] = 'Récupérer Véhicule',
    ['vehicle_stored'] = 'Véhicule rangé!',
    ['vehicle_retrieved'] = 'Véhicule récupéré!',
    ['garage_full'] = 'Garage plein!',
    ['no_vehicle'] = 'Aucun véhicule à proximité!',
    ['not_your_vehicle'] = 'Pas votre véhicule!',
    ['vehicle_already_stored'] = 'Véhicule déjà rangé!',
    ['no_vehicles_stored'] = 'Aucun véhicule rangé!',
    
    -- Stockage
    ['storage'] = 'Stockage',
    ['safe'] = 'Coffre-fort',
    ['wardrobe'] = 'Garde-robe',
    ['stash'] = 'Cachette',
    ['open_storage'] = 'Ouvrir le Stockage',
    ['enter_pin'] = 'Entrer le PIN',
    ['pin_correct'] = 'PIN correct!',
    ['pin_incorrect'] = 'PIN incorrect!',
    ['change_pin'] = 'Changer le PIN',
    ['pin_changed'] = 'PIN changé!',
    
    -- Admin
    ['admin_panel'] = 'Panneau Admin',
    ['create_property'] = 'Créer Propriété',
    ['edit_property'] = 'Modifier Propriété',
    ['delete_property'] = 'Supprimer Propriété',
    ['transfer_ownership'] = 'Transférer Propriété',
    ['evict_tenant'] = 'Expulser Locataire',
    ['property_created'] = 'Propriété créée!',
    ['property_updated'] = 'Propriété mise à jour!',
    ['property_deleted'] = 'Propriété supprimée!',
    ['ownership_transferred'] = 'Propriété transférée!',
    ['tenant_evicted'] = 'Locataire expulsé!',
    
    -- Notifications
    ['new_property_available'] = 'Nouvelle propriété disponible!',
    ['property_sold'] = 'Propriété vendue!',
    ['viewing_started'] = 'Visite commencée!',
    ['viewing_ended'] = 'Visite terminée!',
    ['rental_started'] = 'Location commencée!',
    ['rental_ended'] = 'Location terminée!',
    ['payment_reminder'] = 'Rappel de paiement!',
    ['gps_set'] = 'GPS défini!',
    ['gps_removed'] = 'GPS retiré!',
    
    -- Erreurs
    ['no_permission'] = 'Pas de permission!',
    ['too_far'] = 'Trop loin!',
    ['property_not_found'] = 'Propriété non trouvée!',
    ['already_owner'] = 'Déjà propriétaire!',
    ['max_properties_reached'] = 'Maximum de propriétés atteint!',
    ['property_occupied'] = 'Propriété occupée!',
    ['not_owner'] = 'Pas le propriétaire!',
    ['player_not_found'] = 'Joueur non trouvé!',
    ['invalid_amount'] = 'Montant invalide!',
    ['action_cancelled'] = 'Action annulée!',
    
    -- UI
    ['filter_by'] = 'Filtrer par',
    ['sort_by'] = 'Trier par',
    ['search'] = 'Rechercher',
    ['all'] = 'Tous',
    ['type'] = 'Type',
    ['area'] = 'Zone',
    ['status'] = 'Statut',
    ['price_low_high'] = 'Prix: Bas à Élevé',
    ['price_high_low'] = 'Prix: Élevé à Bas',
    ['close'] = 'Fermer',
    ['confirm'] = 'Confirmer',
    ['cancel'] = 'Annuler',
    ['back'] = 'Retour',
    ['next'] = 'Suivant',
    ['details'] = 'Détails',
    ['gallery'] = 'Galerie',
    ['location'] = 'Emplacement',
    ['features'] = 'Caractéristiques',
    ['description'] = 'Description'
}

-- Helper function to get localized text
function _(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    end
    return 'Translation [' .. str .. '] not found'
end
