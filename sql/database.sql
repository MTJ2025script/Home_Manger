-- ====================================================================================================
-- 🗄️ PROPERTY MANAGER DATABASE SCHEMA
-- 13 Tabellen für komplettes Immobilien-Verwaltungssystem
-- ====================================================================================================
--
-- WICHTIG: Führe dieses SQL-Skript in deiner ESX/QBCore Datenbank aus!
-- Das Skript erstellt alle benötigten Tabellen in der aktuell ausgewählten Datenbank.
--
-- Beispiel für ESX Legacy:
--   USE esxlegacy;
--   SOURCE path/to/database.sql;
--
-- Oder in MySQL/phpMyAdmin:
--   1. Wähle deine ESX-Datenbank aus
--   2. Importiere diese SQL-Datei
-- ====================================================================================================

-- ====================================================================================================
-- 1️⃣ PROPERTIES - Alle Immobilien mit Details
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `properties` (
    `id` VARCHAR(50) PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `type` ENUM('apartment', 'house', 'villa', 'mansion', 'hotel', 'office', 'warehouse', 'garage') NOT NULL,
    `area` VARCHAR(100) NOT NULL,
    `entrance_x` FLOAT NOT NULL,
    `entrance_y` FLOAT NOT NULL,
    `entrance_z` FLOAT NOT NULL,
    `entrance_h` FLOAT NOT NULL DEFAULT 0.0,
    `interior` VARCHAR(100) DEFAULT NULL,
    `price` INT NOT NULL DEFAULT 0,
    `rent_price` INT DEFAULT NULL,
    `garage_type` ENUM('small', 'medium', 'large') DEFAULT 'small',
    `bedrooms` INT DEFAULT 1,
    `bathrooms` INT DEFAULT 1,
    `description` TEXT,
    `owner` VARCHAR(60) DEFAULT NULL,
    `tenant` VARCHAR(60) DEFAULT NULL,
    `status` ENUM('available', 'owned', 'rented', 'viewing') DEFAULT 'available',
    `for_sale` TINYINT(1) DEFAULT 1,
    `for_rent` TINYINT(1) DEFAULT 1,
    `locked` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_owner` (`owner`),
    INDEX `idx_tenant` (`tenant`),
    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`type`),
    INDEX `idx_area` (`area`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 2️⃣ PROPERTY_KEYS - Schlüsselsystem mit Permissions
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `property_keys` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` VARCHAR(50) NOT NULL,
    `holder` VARCHAR(60) NOT NULL,
    `permission_level` ENUM('owner', 'tenant', 'guest') NOT NULL DEFAULT 'guest',
    `can_enter` TINYINT(1) DEFAULT 1,
    `can_lock` TINYINT(1) DEFAULT 0,
    `can_invite` TINYINT(1) DEFAULT 0,
    `can_manage_keys` TINYINT(1) DEFAULT 0,
    `can_access_storage` TINYINT(1) DEFAULT 0,
    `can_access_garage` TINYINT(1) DEFAULT 0,
    `can_sell` TINYINT(1) DEFAULT 0,
    `can_rent` TINYINT(1) DEFAULT 0,
    `given_by` VARCHAR(60) DEFAULT NULL,
    `expires_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    INDEX `idx_property_holder` (`property_id`, `holder`),
    INDEX `idx_holder` (`holder`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 3️⃣ PROPERTY_STORAGE - Stash/Safes Inventar
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `property_storage` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` VARCHAR(50) NOT NULL,
    `storage_type` ENUM('safe', 'stash', 'wardrobe') NOT NULL,
    `storage_name` VARCHAR(100) NOT NULL,
    `slots` INT DEFAULT 30,
    `max_weight` INT DEFAULT 1000000,
    `pin_code` VARCHAR(8) DEFAULT NULL,
    `items` LONGTEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_storage` (`property_id`, `storage_type`),
    INDEX `idx_property` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 4️⃣ PROPERTY_GARAGES - Garage pro Haus
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `property_garages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` VARCHAR(50) NOT NULL,
    `garage_type` ENUM('small', 'medium', 'large') NOT NULL DEFAULT 'small',
    `max_vehicles` INT NOT NULL DEFAULT 6,
    `interior` VARCHAR(100) NOT NULL,
    `spawn_x` FLOAT NOT NULL,
    `spawn_y` FLOAT NOT NULL,
    `spawn_z` FLOAT NOT NULL,
    `spawn_h` FLOAT NOT NULL DEFAULT 0.0,
    `entry_x` FLOAT NOT NULL,
    `entry_y` FLOAT NOT NULL,
    `entry_z` FLOAT NOT NULL,
    `entry_h` FLOAT NOT NULL DEFAULT 0.0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_garage` (`property_id`),
    INDEX `idx_property` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 5️⃣ GARAGE_VEHICLES - Autos in Garage (mit State)
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `garage_vehicles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `garage_id` INT NOT NULL,
    `property_id` VARCHAR(50) NOT NULL,
    `owner` VARCHAR(60) NOT NULL,
    `vehicle_plate` VARCHAR(20) NOT NULL,
    `vehicle_model` VARCHAR(50) NOT NULL,
    `vehicle_data` LONGTEXT NOT NULL,
    `stored` TINYINT(1) DEFAULT 1,
    `stored_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `retrieved_at` TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (`garage_id`) REFERENCES `property_garages`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    INDEX `idx_garage` (`garage_id`),
    INDEX `idx_property` (`property_id`),
    INDEX `idx_owner` (`owner`),
    INDEX `idx_plate` (`vehicle_plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 6️⃣ PROPERTY_BOOKINGS - Buchungen (Viewing/Miete/Purchase)
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `property_bookings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` VARCHAR(50) NOT NULL,
    `player_id` VARCHAR(60) NOT NULL,
    `booking_type` ENUM('viewing', 'rental', 'purchase') NOT NULL,
    `access_code` VARCHAR(10) DEFAULT NULL,
    `start_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `end_time` TIMESTAMP NULL DEFAULT NULL,
    `duration_minutes` INT DEFAULT 30,
    `amount_paid` INT DEFAULT 0,
    `status` ENUM('active', 'completed', 'cancelled', 'expired') DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    INDEX `idx_property` (`property_id`),
    INDEX `idx_player` (`player_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_code` (`access_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 7️⃣ SHORTTERM_KEYS - Kurzzeitschlüssel (Ablaufdatum)
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `shortterm_keys` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` VARCHAR(50) NOT NULL,
    `booking_id` INT DEFAULT NULL,
    `holder` VARCHAR(60) NOT NULL,
    `access_code` VARCHAR(10) NOT NULL,
    `key_type` ENUM('viewing', 'rental', 'temporary') NOT NULL,
    `expires_at` TIMESTAMP NOT NULL,
    `used` TINYINT(1) DEFAULT 0,
    `used_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`booking_id`) REFERENCES `property_bookings`(`id`) ON DELETE SET NULL,
    INDEX `idx_property` (`property_id`),
    INDEX `idx_holder` (`holder`),
    INDEX `idx_code` (`access_code`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 8️⃣ PROPERTY_TRANSACTIONS - Alle Zahlungen (History)
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `property_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` VARCHAR(50) NOT NULL,
    `player_id` VARCHAR(60) NOT NULL,
    `transaction_type` ENUM('purchase', 'rent', 'mortgage_payment', 'deposit', 'refund', 'sale', 'eviction_fee') NOT NULL,
    `amount` INT NOT NULL,
    `payment_method` ENUM('cash', 'bank') DEFAULT 'bank',
    `description` TEXT,
    `status` ENUM('pending', 'completed', 'failed', 'cancelled') DEFAULT 'completed',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    INDEX `idx_property` (`property_id`),
    INDEX `idx_player` (`player_id`),
    INDEX `idx_type` (`transaction_type`),
    INDEX `idx_date` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 9️⃣ PROPERTY_TENANTS - Mieter mit Details
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `property_tenants` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` VARCHAR(50) NOT NULL,
    `tenant_id` VARCHAR(60) NOT NULL,
    `rent_amount` INT NOT NULL,
    `payment_interval` INT DEFAULT 7,
    `last_payment` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `next_payment` TIMESTAMP NOT NULL,
    `missed_payments` INT DEFAULT 0,
    `grace_period_remaining` INT DEFAULT 2,
    `status` ENUM('active', 'overdue', 'evicted', 'ended') DEFAULT 'active',
    `lease_start` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `lease_end` TIMESTAMP NULL DEFAULT NULL,
    `deposit_paid` INT DEFAULT 0,
    `deposit_refunded` TINYINT(1) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    INDEX `idx_property` (`property_id`),
    INDEX `idx_tenant` (`tenant_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_next_payment` (`next_payment`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 🔟 PROPERTY_MORTGAGES - Hypotheken (Zahlungsplan)
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `property_mortgages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` VARCHAR(50) NOT NULL,
    `owner_id` VARCHAR(60) NOT NULL,
    `total_amount` INT NOT NULL,
    `down_payment` INT NOT NULL,
    `remaining_amount` INT NOT NULL,
    `interest_rate` FLOAT NOT NULL DEFAULT 5.5,
    `payment_amount` INT NOT NULL,
    `payment_interval` INT DEFAULT 7,
    `duration_months` INT NOT NULL,
    `payments_made` INT DEFAULT 0,
    `total_payments` INT NOT NULL,
    `last_payment` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `next_payment` TIMESTAMP NOT NULL,
    `missed_payments` INT DEFAULT 0,
    `grace_period_remaining` INT DEFAULT 3,
    `status` ENUM('active', 'overdue', 'completed', 'defaulted') DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE CASCADE,
    INDEX `idx_property` (`property_id`),
    INDEX `idx_owner` (`owner_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_next_payment` (`next_payment`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 1️⃣1️⃣ REALTOR_BRANCHES - 3x Büro-Locations
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `realtor_branches` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `location_x` FLOAT NOT NULL,
    `location_y` FLOAT NOT NULL,
    `location_z` FLOAT NOT NULL,
    `location_h` FLOAT NOT NULL DEFAULT 0.0,
    `blip_sprite` INT DEFAULT 375,
    `blip_color` INT DEFAULT 3,
    `blip_scale` FLOAT DEFAULT 0.8,
    `job_restriction` VARCHAR(50) DEFAULT NULL,
    `commission_rate` FLOAT DEFAULT 5.0,
    `active` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 1️⃣2️⃣ PROPERTY_LOGS - Audit-Trail (wer, wann, was)
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `property_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `property_id` VARCHAR(50) DEFAULT NULL,
    `player_id` VARCHAR(60) DEFAULT NULL,
    `action` VARCHAR(100) NOT NULL,
    `details` TEXT,
    `ip_address` VARCHAR(45) DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE SET NULL,
    INDEX `idx_property` (`property_id`),
    INDEX `idx_player` (`player_id`),
    INDEX `idx_action` (`action`),
    INDEX `idx_date` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 1️⃣3️⃣ PROPERTY_NOTIFICATIONS - Alle Meldungen (zentral DB)
-- ====================================================================================================

CREATE TABLE IF NOT EXISTS `property_notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` VARCHAR(60) NOT NULL,
    `property_id` VARCHAR(50) DEFAULT NULL,
    `notification_type` ENUM('success', 'error', 'warning', 'info') NOT NULL DEFAULT 'info',
    `title` VARCHAR(255) NOT NULL,
    `message` TEXT NOT NULL,
    `read` TINYINT(1) DEFAULT 0,
    `read_at` TIMESTAMP NULL DEFAULT NULL,
    `expires_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`property_id`) REFERENCES `properties`(`id`) ON DELETE SET NULL,
    INDEX `idx_player` (`player_id`),
    INDEX `idx_property` (`property_id`),
    INDEX `idx_read` (`read`),
    INDEX `idx_date` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================================================
-- 📝 INSERT SAMPLE REALTOR BRANCHES
-- ====================================================================================================

INSERT INTO `realtor_branches` (`name`, `description`, `location_x`, `location_y`, `location_z`, `location_h`, `blip_sprite`, `blip_color`, `commission_rate`, `active`) VALUES
('Downtown Realty', 'Ihr vertrauenswürdiger Partner für Immobilien im Geschäftsviertel', 1124.5, 226.5, 69.0, 0.0, 375, 3, 5.0, 1),
('Vinewood Luxury Realty', 'Exklusive Immobilien für anspruchsvolle Kunden', 1302.8, -528.5, 71.4, 90.0, 375, 5, 7.5, 1),
('Del Perro Beach Properties', 'Traumhafte Strandimmobilien und mehr', 150.2, -1044.3, 29.4, 180.0, 375, 38, 5.0, 1);

-- ====================================================================================================
-- ✅ SCHEMA CREATION COMPLETE
-- ====================================================================================================

-- Hinweis: Die properties Tabelle wird zur Laufzeit mit den Daten aus data/properties.lua gefüllt
-- Dies ermöglicht einfachere Wartung und Updates der Immobilien-Daten
