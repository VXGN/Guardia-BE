-- CreateTable
CREATE TABLE `users` (
    `id` CHAR(36) NOT NULL,
    `full_name` VARCHAR(100) NULL,
    `email` VARCHAR(150) NULL,
    `phone_number` VARCHAR(20) NULL,
    `password_hash` TEXT NULL,
    `role` ENUM('user', 'admin', 'partner') NOT NULL DEFAULT 'user',
    `is_anonymous_mode` BOOLEAN NOT NULL DEFAULT true,
    `is_verified` BOOLEAN NOT NULL DEFAULT false,
    `fcm_token` TEXT NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL,
    `deleted_at` DATETIME(6) NULL,

    UNIQUE INDEX `users_email_key`(`email`),
    UNIQUE INDEX `users_phone_number_key`(`phone_number`),
    INDEX `users_role_idx`(`role`),
    INDEX `users_deleted_at_idx`(`deleted_at`),
    INDEX `users_verified_idx`(`is_verified`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `trusted_contacts` (
    `id` CHAR(36) NOT NULL,
    `user_id` CHAR(36) NOT NULL,
    `contact_name` VARCHAR(100) NOT NULL,
    `contact_phone` VARCHAR(20) NOT NULL,
    `contact_email` VARCHAR(150) NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL,

    INDEX `trusted_contacts_user_id_idx`(`user_id`),
    INDEX `trusted_contacts_active_idx`(`user_id`, `is_active`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `incident_reports` (
    `id` CHAR(36) NOT NULL,
    `user_id` CHAR(36) NULL,
    `incident_type` ENUM('verbal_harassment', 'physical_harassment', 'stalking', 'theft', 'intimidation', 'other') NOT NULL,
    `description` TEXT NULL,
    `incident_at` DATETIME(6) NOT NULL,
    `latitude` DECIMAL(10, 8) NOT NULL,
    `longitude` DECIMAL(11, 8) NOT NULL,
    `latitude_blurred` DECIMAL(7, 5) NOT NULL,
    `longitude_blurred` DECIMAL(7, 5) NOT NULL,
    `location_label` VARCHAR(255) NULL,
    `is_anonymous` BOOLEAN NOT NULL DEFAULT true,
    `status` ENUM('received', 'verified', 'in_progress', 'resolved', 'rejected') NOT NULL DEFAULT 'received',
    `severity_score` SMALLINT NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL,
    `deleted_at` DATETIME(6) NULL,

    INDEX `incident_reports_user_id_idx`(`user_id`),
    INDEX `incident_reports_status_idx`(`status`),
    INDEX `incident_reports_incident_at_idx`(`incident_at`),
    INDEX `incident_reports_type_idx`(`incident_type`),
    INDEX `incident_reports_blurred_loc_idx`(`latitude_blurred`, `longitude_blurred`),
    INDEX `incident_reports_deleted_at_idx`(`deleted_at`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `report_media` (
    `id` CHAR(36) NOT NULL,
    `report_id` CHAR(36) NOT NULL,
    `media_type` ENUM('photo', 'audio', 'video') NOT NULL,
    `storage_url` TEXT NOT NULL,
    `file_size_kb` INTEGER NULL,
    `is_encrypted` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    INDEX `report_media_report_id_idx`(`report_id`),
    INDEX `report_media_type_idx`(`report_id`, `media_type`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `report_status_logs` (
    `id` CHAR(36) NOT NULL,
    `report_id` CHAR(36) NOT NULL,
    `changed_by` CHAR(36) NULL,
    `old_status` ENUM('received', 'verified', 'in_progress', 'resolved', 'rejected') NOT NULL,
    `new_status` ENUM('received', 'verified', 'in_progress', 'resolved', 'rejected') NOT NULL,
    `notes` TEXT NULL,
    `changed_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    INDEX `rsl_report_id_idx`(`report_id`),
    INDEX `rsl_changed_by_idx`(`changed_by`),
    INDEX `rsl_changed_at_idx`(`changed_at`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `journeys` (
    `id` CHAR(36) NOT NULL,
    `user_id` CHAR(36) NOT NULL,
    `status` ENUM('active', 'completed', 'alert_triggered', 'cancelled') NOT NULL DEFAULT 'active',
    `started_at` DATETIME(6) NOT NULL,
    `ended_at` DATETIME(6) NULL,
    `origin_lat` DECIMAL(10, 8) NULL,
    `origin_lng` DECIMAL(11, 8) NULL,
    `destination_lat` DECIMAL(10, 8) NULL,
    `destination_lng` DECIMAL(11, 8) NULL,
    `safe_arrival_confirmed` BOOLEAN NOT NULL DEFAULT false,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL,

    INDEX `journeys_user_id_idx`(`user_id`),
    INDEX `journeys_status_idx`(`status`),
    INDEX `journeys_started_at_idx`(`started_at`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `journey_location_logs` (
    `id` CHAR(36) NOT NULL,
    `journey_id` CHAR(36) NOT NULL,
    `latitude` DECIMAL(10, 8) NOT NULL,
    `longitude` DECIMAL(11, 8) NOT NULL,
    `recorded_at` DATETIME(6) NOT NULL,
    `is_anomaly_flagged` BOOLEAN NOT NULL DEFAULT false,

    INDEX `jll_journey_id_idx`(`journey_id`),
    INDEX `jll_recorded_at_idx`(`journey_id`, `recorded_at`),
    INDEX `jll_anomaly_idx`(`is_anomaly_flagged`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `journey_contacts` (
    `id` CHAR(36) NOT NULL,
    `journey_id` CHAR(36) NOT NULL,
    `trusted_contact_id` CHAR(36) NOT NULL,
    `notified_at` DATETIME(6) NULL,
    `alert_sent_at` DATETIME(6) NULL,

    INDEX `jc_journey_id_idx`(`journey_id`),
    INDEX `jc_trusted_contact_id_idx`(`trusted_contact_id`),
    UNIQUE INDEX `journey_contacts_journey_id_trusted_contact_id_key`(`journey_id`, `trusted_contact_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `road_segments` (
    `id` CHAR(36) NOT NULL,
    `segment_name` VARCHAR(255) NULL,
    `start_lat` DECIMAL(10, 8) NOT NULL,
    `start_lng` DECIMAL(11, 8) NOT NULL,
    `end_lat` DECIMAL(10, 8) NOT NULL,
    `end_lng` DECIMAL(11, 8) NOT NULL,
    `length_meters` INTEGER NULL,
    `has_street_light` BOOLEAN NOT NULL DEFAULT false,
    `is_main_road` BOOLEAN NOT NULL DEFAULT false,
    `near_security_post` BOOLEAN NOT NULL DEFAULT false,
    `osm_way_id` BIGINT NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL,

    UNIQUE INDEX `road_segments_osm_way_id_key`(`osm_way_id`),
    INDEX `rs_osm_way_id_idx`(`osm_way_id`),
    INDEX `rs_start_coords_idx`(`start_lat`, `start_lng`),
    INDEX `rs_end_coords_idx`(`end_lat`, `end_lng`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `risk_scores` (
    `id` CHAR(36) NOT NULL,
    `segment_id` CHAR(36) NOT NULL,
    `time_slot` ENUM('morning', 'afternoon', 'evening', 'night') NOT NULL,
    `risk_score` DECIMAL(5, 2) NOT NULL,
    `incident_count` INTEGER NOT NULL DEFAULT 0,
    `dominant_incident_type` ENUM('verbal_harassment', 'physical_harassment', 'stalking', 'theft', 'intimidation', 'other') NULL,
    `calculated_at` DATETIME(6) NOT NULL,
    `valid_until` DATETIME(6) NULL,

    INDEX `risk_scores_segment_id_idx`(`segment_id`),
    INDEX `risk_scores_time_slot_idx`(`time_slot`),
    INDEX `risk_scores_score_idx`(`risk_score`),
    INDEX `risk_scores_valid_until_idx`(`valid_until`),
    UNIQUE INDEX `risk_scores_segment_id_time_slot_key`(`segment_id`, `time_slot`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `heatmap_clusters` (
    `id` CHAR(36) NOT NULL,
    `center_lat_blurred` DECIMAL(7, 5) NOT NULL,
    `center_lng_blurred` DECIMAL(7, 5) NOT NULL,
    `radius_meters` INTEGER NOT NULL,
    `intensity` ENUM('low', 'medium', 'high', 'critical') NOT NULL,
    `incident_count` INTEGER NOT NULL,
    `dominant_type` ENUM('verbal_harassment', 'physical_harassment', 'stalking', 'theft', 'intimidation', 'other') NULL,
    `time_slot` ENUM('morning', 'afternoon', 'evening', 'night') NULL,
    `valid_from` DATETIME(6) NOT NULL,
    `valid_until` DATETIME(6) NOT NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    INDEX `heatmap_intensity_idx`(`intensity`),
    INDEX `heatmap_valid_until_idx`(`valid_until`),
    INDEX `heatmap_time_slot_idx`(`time_slot`),
    INDEX `heatmap_center_idx`(`center_lat_blurred`, `center_lng_blurred`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `notifications` (
    `id` CHAR(36) NOT NULL,
    `recipient_user_id` CHAR(36) NULL,
    `recipient_phone` VARCHAR(20) NULL,
    `notification_type` ENUM('journey_start', 'journey_safe_arrival', 'journey_alert', 'report_status_update', 'panic_alert', 'system') NOT NULL,
    `title` VARCHAR(150) NOT NULL,
    `body` TEXT NOT NULL,
    `related_journey_id` CHAR(36) NULL,
    `related_report_id` CHAR(36) NULL,
    `is_sent` BOOLEAN NOT NULL DEFAULT false,
    `sent_at` DATETIME(6) NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    INDEX `notif_recipient_user_id_idx`(`recipient_user_id`),
    INDEX `notif_type_idx`(`notification_type`),
    INDEX `notif_is_sent_idx`(`is_sent`),
    INDEX `notif_created_at_idx`(`created_at`),
    INDEX `notif_journey_id_idx`(`related_journey_id`),
    INDEX `notif_report_id_idx`(`related_report_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `trusted_contacts` ADD CONSTRAINT `trusted_contacts_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `incident_reports` ADD CONSTRAINT `incident_reports_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `report_media` ADD CONSTRAINT `report_media_report_id_fkey` FOREIGN KEY (`report_id`) REFERENCES `incident_reports`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `report_status_logs` ADD CONSTRAINT `report_status_logs_report_id_fkey` FOREIGN KEY (`report_id`) REFERENCES `incident_reports`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `report_status_logs` ADD CONSTRAINT `report_status_logs_changed_by_fkey` FOREIGN KEY (`changed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `journeys` ADD CONSTRAINT `journeys_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `journey_location_logs` ADD CONSTRAINT `journey_location_logs_journey_id_fkey` FOREIGN KEY (`journey_id`) REFERENCES `journeys`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `journey_contacts` ADD CONSTRAINT `journey_contacts_journey_id_fkey` FOREIGN KEY (`journey_id`) REFERENCES `journeys`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `journey_contacts` ADD CONSTRAINT `journey_contacts_trusted_contact_id_fkey` FOREIGN KEY (`trusted_contact_id`) REFERENCES `trusted_contacts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `risk_scores` ADD CONSTRAINT `risk_scores_segment_id_fkey` FOREIGN KEY (`segment_id`) REFERENCES `road_segments`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `notifications` ADD CONSTRAINT `notifications_recipient_user_id_fkey` FOREIGN KEY (`recipient_user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `notifications` ADD CONSTRAINT `notifications_related_journey_id_fkey` FOREIGN KEY (`related_journey_id`) REFERENCES `journeys`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `notifications` ADD CONSTRAINT `notifications_related_report_id_fkey` FOREIGN KEY (`related_report_id`) REFERENCES `incident_reports`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;
