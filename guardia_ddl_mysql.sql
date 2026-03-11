-- =============================================================================
-- GUARDIA – Smart, Safe, and Inclusive Public Spaces
-- SQL DDL – MySQL 8.0+ Compatible
-- Generated: 2026-03-11
-- Standards: snake_case, UUID PK, TIMESTAMPTZ via DATETIME(6), Soft Delete
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';

-- =============================================================================
-- EXTENSIONS / UTILITIES (MySQL does not need explicit UUID extension)
-- UUID generation handled via UUID() or application-level UUIDs (CHAR(36))
-- =============================================================================

-- =============================================================================
-- TABLE: users
-- =============================================================================
CREATE TABLE IF NOT EXISTS `users` (
    `id`                CHAR(36)        NOT NULL DEFAULT (UUID()),
    `full_name`         VARCHAR(100)    NULL,
    `email`             VARCHAR(150)    NULL,
    `phone_number`      VARCHAR(20)     NULL,
    `password_hash`     TEXT            NULL,
    `role`              ENUM('user','admin','partner') NOT NULL DEFAULT 'user',
    `is_anonymous_mode` TINYINT(1)      NOT NULL DEFAULT 1,
    `is_verified`       TINYINT(1)      NOT NULL DEFAULT 0,
    `fcm_token`         TEXT            NULL     COMMENT 'Firebase Cloud Messaging token for push notification',
    `created_at`        DATETIME(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at`        DATETIME(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `deleted_at`        DATETIME(6)     NULL     COMMENT 'Soft delete timestamp',

    CONSTRAINT `pk_users` PRIMARY KEY (`id`),
    CONSTRAINT `uq_users_email` UNIQUE (`email`),
    CONSTRAINT `uq_users_phone` UNIQUE (`phone_number`),
    CONSTRAINT `chk_users_email_or_phone` CHECK (
        `email` IS NOT NULL OR `phone_number` IS NOT NULL OR `is_anonymous_mode` = 1
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Akun pengguna Guardia, mendukung mode anonim';

CREATE INDEX `users_role_idx`       ON `users` (`role`);
CREATE INDEX `users_deleted_at_idx` ON `users` (`deleted_at`);
CREATE INDEX `users_verified_idx`   ON `users` (`is_verified`);

-- =============================================================================
-- TABLE: trusted_contacts
-- =============================================================================
CREATE TABLE IF NOT EXISTS `trusted_contacts` (
    `id`            CHAR(36)    NOT NULL DEFAULT (UUID()),
    `user_id`       CHAR(36)    NOT NULL,
    `contact_name`  VARCHAR(100) NOT NULL,
    `contact_phone` VARCHAR(20) NOT NULL,
    `contact_email` VARCHAR(150) NULL,
    `is_active`     TINYINT(1)  NOT NULL DEFAULT 1,
    `created_at`    DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at`    DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT `pk_trusted_contacts` PRIMARY KEY (`id`),
    CONSTRAINT `fk_trusted_contacts_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Kontak kepercayaan pengguna untuk fitur Temani Perjalanan';

CREATE INDEX `trusted_contacts_user_id_idx`  ON `trusted_contacts` (`user_id`);
CREATE INDEX `trusted_contacts_active_idx`   ON `trusted_contacts` (`user_id`, `is_active`);

-- =============================================================================
-- TABLE: incident_reports
-- =============================================================================
CREATE TABLE IF NOT EXISTS `incident_reports` (
    `id`                CHAR(36)    NOT NULL DEFAULT (UUID()),
    `user_id`           CHAR(36)    NULL     COMMENT 'NULL jika laporan sepenuhnya anonim (guest)',
    `incident_type`     ENUM('verbal_harassment','physical_harassment','stalking','theft','intimidation','other') NOT NULL,
    `description`       TEXT        NULL,
    `incident_at`       DATETIME(6) NOT NULL COMMENT 'Waktu kejadian, bisa berbeda dari created_at',
    `latitude`          DECIMAL(10,8) NOT NULL COMMENT 'Koordinat presisi, hanya untuk internal/analitik',
    `longitude`         DECIMAL(11,8) NOT NULL,
    `longitude_blurred` DECIMAL(8,5)  NOT NULL COMMENT 'Koordinat dibulatkan untuk heatmap publik (~100-200m)',
    `longitude_blurred` DECIMAL(7,5)  NOT NULL,
    `location_label`    VARCHAR(255) NULL,
    `is_anonymous`      TINYINT(1)  NOT NULL DEFAULT 1,
    `status`            ENUM('received','verified','in_progress','resolved','rejected') NOT NULL DEFAULT 'received',
    `severity_score`    SMALLINT    NULL     COMMENT 'Skor keparahan 1-5, diisi admin atau AI',
    `created_at`        DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at`        DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `deleted_at`        DATETIME(6) NULL     COMMENT 'Soft delete',

    CONSTRAINT `pk_incident_reports` PRIMARY KEY (`id`),
    CONSTRAINT `fk_incident_reports_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `chk_incident_severity`
        CHECK (`severity_score` IS NULL OR (`severity_score` BETWEEN 1 AND 5)),
    CONSTRAINT `chk_incident_lat`
        CHECK (`latitude` BETWEEN -90 AND 90),
    CONSTRAINT `chk_incident_lng`
        CHECK (`longitude` BETWEEN -180 AND 180)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Laporan insiden warga, mendukung mode anonim';

CREATE INDEX `incident_reports_user_id_idx`     ON `incident_reports` (`user_id`);
CREATE INDEX `incident_reports_status_idx`      ON `incident_reports` (`status`);
CREATE INDEX `incident_reports_incident_at_idx` ON `incident_reports` (`incident_at`);
CREATE INDEX `incident_reports_type_idx`        ON `incident_reports` (`incident_type`);
CREATE INDEX `incident_reports_blurred_loc_idx` ON `incident_reports` (`latitude_blurred`, `longitude_blurred`);
CREATE INDEX `incident_reports_deleted_at_idx`  ON `incident_reports` (`deleted_at`);

-- =============================================================================
-- TABLE: report_media
-- =============================================================================
CREATE TABLE IF NOT EXISTS `report_media` (
    `id`           CHAR(36)    NOT NULL DEFAULT (UUID()),
    `report_id`    CHAR(36)    NOT NULL,
    `media_type`   ENUM('photo','audio','video') NOT NULL,
    `storage_url`  TEXT        NOT NULL COMMENT 'URL terenkripsi di cloud storage (S3/Firebase)',
    `file_size_kb` INTEGER     NULL,
    `is_encrypted` TINYINT(1)  NOT NULL DEFAULT 1,
    `created_at`   DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT `pk_report_media` PRIMARY KEY (`id`),
    CONSTRAINT `fk_report_media_report_id`
        FOREIGN KEY (`report_id`) REFERENCES `incident_reports`(`id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_report_media_size`
        CHECK (`file_size_kb` IS NULL OR `file_size_kb` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='File media (foto/audio/video) terenkripsi untuk laporan';

CREATE INDEX `report_media_report_id_idx`  ON `report_media` (`report_id`);
CREATE INDEX `report_media_type_idx`       ON `report_media` (`report_id`, `media_type`);

-- =============================================================================
-- TABLE: report_status_logs
-- =============================================================================
CREATE TABLE IF NOT EXISTS `report_status_logs` (
    `id`         CHAR(36)    NOT NULL DEFAULT (UUID()),
    `report_id`  CHAR(36)    NOT NULL,
    `changed_by` CHAR(36)    NULL     COMMENT 'Admin/partner yang mengubah status',
    `old_status` ENUM('received','verified','in_progress','resolved','rejected') NOT NULL,
    `new_status` ENUM('received','verified','in_progress','resolved','rejected') NOT NULL,
    `notes`      TEXT        NULL     COMMENT 'Catatan tindak lanjut yang ditampilkan ke pelapor',
    `changed_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT `pk_report_status_logs` PRIMARY KEY (`id`),
    CONSTRAINT `fk_rsl_report_id`
        FOREIGN KEY (`report_id`) REFERENCES `incident_reports`(`id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_rsl_changed_by`
        FOREIGN KEY (`changed_by`) REFERENCES `users`(`id`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `chk_rsl_status_changed`
        CHECK (`old_status` <> `new_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Riwayat perubahan status laporan (audit trail)';

CREATE INDEX `rsl_report_id_idx`   ON `report_status_logs` (`report_id`);
CREATE INDEX `rsl_changed_by_idx`  ON `report_status_logs` (`changed_by`);
CREATE INDEX `rsl_changed_at_idx`  ON `report_status_logs` (`changed_at`);

-- =============================================================================
-- TABLE: journeys
-- =============================================================================
CREATE TABLE IF NOT EXISTS `journeys` (
    `id`                     CHAR(36)      NOT NULL DEFAULT (UUID()),
    `user_id`                CHAR(36)      NOT NULL,
    `status`                 ENUM('active','completed','alert_triggered','cancelled') NOT NULL DEFAULT 'active',
    `started_at`             DATETIME(6)   NOT NULL,
    `ended_at`               DATETIME(6)   NULL,
    `origin_lat`             DECIMAL(10,8) NULL,
    `origin_lng`             DECIMAL(11,8) NULL,
    `destination_lat`        DECIMAL(10,8) NULL,
    `destination_lng`        DECIMAL(11,8) NULL,
    `safe_arrival_confirmed` TINYINT(1)    NOT NULL DEFAULT 0,
    `created_at`             DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at`             DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT `pk_journeys` PRIMARY KEY (`id`),
    CONSTRAINT `fk_journeys_user_id`
        FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_journeys_ended_after_started`
        CHECK (`ended_at` IS NULL OR `ended_at` >= `started_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Sesi Temani Perjalanan yang diaktifkan pengguna';

CREATE INDEX `journeys_user_id_idx`   ON `journeys` (`user_id`);
CREATE INDEX `journeys_status_idx`    ON `journeys` (`status`);
CREATE INDEX `journeys_started_at_idx` ON `journeys` (`started_at`);

-- =============================================================================
-- TABLE: journey_location_logs
-- =============================================================================
CREATE TABLE IF NOT EXISTS `journey_location_logs` (
    `id`                CHAR(36)      NOT NULL DEFAULT (UUID()),
    `journey_id`        CHAR(36)      NOT NULL,
    `latitude`          DECIMAL(10,8) NOT NULL,
    `longitude`         DECIMAL(11,8) NOT NULL,
    `recorded_at`       DATETIME(6)   NOT NULL,
    `is_anomaly_flagged` TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'True jika sistem deteksi pengguna tidak bergerak di area berisiko',

    CONSTRAINT `pk_journey_location_logs` PRIMARY KEY (`id`),
    CONSTRAINT `fk_jll_journey_id`
        FOREIGN KEY (`journey_id`) REFERENCES `journeys`(`id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_jll_lat` CHECK (`latitude` BETWEEN -90 AND 90),
    CONSTRAINT `chk_jll_lng` CHECK (`longitude` BETWEEN -180 AND 180)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Log titik lokasi real-time selama sesi perjalanan aktif';

CREATE INDEX `jll_journey_id_idx`     ON `journey_location_logs` (`journey_id`);
CREATE INDEX `jll_recorded_at_idx`    ON `journey_location_logs` (`journey_id`, `recorded_at`);
CREATE INDEX `jll_anomaly_idx`        ON `journey_location_logs` (`is_anomaly_flagged`);

-- =============================================================================
-- TABLE: journey_contacts
-- =============================================================================
CREATE TABLE IF NOT EXISTS `journey_contacts` (
    `id`                 CHAR(36)    NOT NULL DEFAULT (UUID()),
    `journey_id`         CHAR(36)    NOT NULL,
    `trusted_contact_id` CHAR(36)    NOT NULL,
    `notified_at`        DATETIME(6) NULL,
    `alert_sent_at`      DATETIME(6) NULL COMMENT 'Waktu notifikasi peringatan anomali dikirim',

    CONSTRAINT `pk_journey_contacts` PRIMARY KEY (`id`),
    CONSTRAINT `uq_journey_contact` UNIQUE (`journey_id`, `trusted_contact_id`),
    CONSTRAINT `fk_jc_journey_id`
        FOREIGN KEY (`journey_id`) REFERENCES `journeys`(`id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_jc_trusted_contact_id`
        FOREIGN KEY (`trusted_contact_id`) REFERENCES `trusted_contacts`(`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Pivot: kontak kepercayaan yang diikutsertakan dalam sesi perjalanan';

CREATE INDEX `jc_journey_id_idx`         ON `journey_contacts` (`journey_id`);
CREATE INDEX `jc_trusted_contact_id_idx` ON `journey_contacts` (`trusted_contact_id`);

-- =============================================================================
-- TABLE: road_segments
-- =============================================================================
CREATE TABLE IF NOT EXISTS `road_segments` (
    `id`                 CHAR(36)      NOT NULL DEFAULT (UUID()),
    `segment_name`       VARCHAR(255)  NULL,
    `start_lat`          DECIMAL(10,8) NOT NULL,
    `start_lng`          DECIMAL(11,8) NOT NULL,
    `end_lat`            DECIMAL(10,8) NOT NULL,
    `end_lng`            DECIMAL(11,8) NOT NULL,
    `length_meters`      INTEGER       NULL,
    `has_street_light`   TINYINT(1)    NOT NULL DEFAULT 0,
    `is_main_road`       TINYINT(1)    NOT NULL DEFAULT 0,
    `near_security_post` TINYINT(1)    NOT NULL DEFAULT 0,
    `osm_way_id`         BIGINT        NULL     COMMENT 'OpenStreetMap Way ID referensi',
    `created_at`         DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at`         DATETIME(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

    CONSTRAINT `pk_road_segments` PRIMARY KEY (`id`),
    CONSTRAINT `uq_road_segments_osm` UNIQUE (`osm_way_id`),
    CONSTRAINT `chk_rs_length` CHECK (`length_meters` IS NULL OR `length_meters` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Segmen jalan untuk graf rute aman (OpenStreetMap / manual)';

CREATE INDEX `rs_osm_way_id_idx`     ON `road_segments` (`osm_way_id`);
CREATE INDEX `rs_start_coords_idx`   ON `road_segments` (`start_lat`, `start_lng`);
CREATE INDEX `rs_end_coords_idx`     ON `road_segments` (`end_lat`, `end_lng`);
CREATE INDEX `rs_street_light_idx`   ON `road_segments` (`has_street_light`);

-- =============================================================================
-- TABLE: risk_scores
-- =============================================================================
CREATE TABLE IF NOT EXISTS `risk_scores` (
    `id`                    CHAR(36)    NOT NULL DEFAULT (UUID()),
    `segment_id`            CHAR(36)    NOT NULL,
    `time_slot`             ENUM('morning','afternoon','evening','night') NOT NULL,
    `risk_score`            DECIMAL(5,2) NOT NULL COMMENT 'Skor 0.00–100.00, semakin tinggi semakin berisiko',
    `incident_count`        INTEGER     NOT NULL DEFAULT 0,
    `dominant_incident_type` ENUM('verbal_harassment','physical_harassment','stalking','theft','intimidation','other') NULL,
    `calculated_at`         DATETIME(6) NOT NULL,
    `valid_until`           DATETIME(6) NULL COMMENT 'Cache/expiry management',

    CONSTRAINT `pk_risk_scores` PRIMARY KEY (`id`),
    CONSTRAINT `uq_risk_scores_segment_slot` UNIQUE (`segment_id`, `time_slot`),
    CONSTRAINT `fk_risk_scores_segment_id`
        FOREIGN KEY (`segment_id`) REFERENCES `road_segments`(`id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_risk_score_range`
        CHECK (`risk_score` BETWEEN 0.00 AND 100.00),
    CONSTRAINT `chk_risk_incident_count`
        CHECK (`incident_count` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Skor risiko per segmen jalan per time-slot dari AI microservice';

CREATE INDEX `risk_scores_segment_id_idx`   ON `risk_scores` (`segment_id`);
CREATE INDEX `risk_scores_time_slot_idx`    ON `risk_scores` (`time_slot`);
CREATE INDEX `risk_scores_score_idx`        ON `risk_scores` (`risk_score`);
CREATE INDEX `risk_scores_valid_until_idx`  ON `risk_scores` (`valid_until`);

-- =============================================================================
-- TABLE: heatmap_clusters
-- =============================================================================
CREATE TABLE IF NOT EXISTS `heatmap_clusters` (
    `id`                  CHAR(36)    NOT NULL DEFAULT (UUID()),
    `center_lat_blurred`  DECIMAL(7,5) NOT NULL COMMENT 'Koordinat dibulatkan untuk privasi',
    `center_lng_blurred`  DECIMAL(8,5) NOT NULL,
    `radius_meters`       INTEGER     NOT NULL,
    `intensity`           ENUM('low','medium','high','critical') NOT NULL,
    `incident_count`      INTEGER     NOT NULL,
    `dominant_type`       ENUM('verbal_harassment','physical_harassment','stalking','theft','intimidation','other') NULL,
    `time_slot`           ENUM('morning','afternoon','evening','night') NULL,
    `valid_from`          DATETIME(6) NOT NULL,
    `valid_until`         DATETIME(6) NOT NULL,
    `created_at`          DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT `pk_heatmap_clusters` PRIMARY KEY (`id`),
    CONSTRAINT `chk_heatmap_radius`    CHECK (`radius_meters` > 0),
    CONSTRAINT `chk_heatmap_incidents` CHECK (`incident_count` >= 0),
    CONSTRAINT `chk_heatmap_validity`  CHECK (`valid_until` > `valid_from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Hasil clustering spatio-temporal untuk heatmap di aplikasi';

CREATE INDEX `heatmap_intensity_idx`    ON `heatmap_clusters` (`intensity`);
CREATE INDEX `heatmap_valid_until_idx`  ON `heatmap_clusters` (`valid_until`);
CREATE INDEX `heatmap_time_slot_idx`    ON `heatmap_clusters` (`time_slot`);
CREATE INDEX `heatmap_center_idx`       ON `heatmap_clusters` (`center_lat_blurred`, `center_lng_blurred`);

-- =============================================================================
-- TABLE: notifications
-- =============================================================================
CREATE TABLE IF NOT EXISTS `notifications` (
    `id`                  CHAR(36)    NOT NULL DEFAULT (UUID()),
    `recipient_user_id`   CHAR(36)    NULL,
    `recipient_phone`     VARCHAR(20) NULL     COMMENT 'Untuk kontak kepercayaan non-user',
    `notification_type`   ENUM('journey_start','journey_safe_arrival','journey_alert','report_status_update','panic_alert','system') NOT NULL,
    `title`               VARCHAR(150) NOT NULL,
    `body`                TEXT        NOT NULL,
    `related_journey_id`  CHAR(36)    NULL,
    `related_report_id`   CHAR(36)    NULL,
    `is_sent`             TINYINT(1)  NOT NULL DEFAULT 0,
    `sent_at`             DATETIME(6) NULL,
    `created_at`          DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),

    CONSTRAINT `pk_notifications` PRIMARY KEY (`id`),
    CONSTRAINT `fk_notif_recipient_user_id`
        FOREIGN KEY (`recipient_user_id`) REFERENCES `users`(`id`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_notif_related_journey_id`
        FOREIGN KEY (`related_journey_id`) REFERENCES `journeys`(`id`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_notif_related_report_id`
        FOREIGN KEY (`related_report_id`) REFERENCES `incident_reports`(`id`)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `chk_notif_recipient`
        CHECK (`recipient_user_id` IS NOT NULL OR `recipient_phone` IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Log semua notifikasi sistem ke pengguna atau kontak kepercayaan';

CREATE INDEX `notif_recipient_user_id_idx` ON `notifications` (`recipient_user_id`);
CREATE INDEX `notif_type_idx`              ON `notifications` (`notification_type`);
CREATE INDEX `notif_is_sent_idx`           ON `notifications` (`is_sent`);
CREATE INDEX `notif_created_at_idx`        ON `notifications` (`created_at`);
CREATE INDEX `notif_journey_id_idx`        ON `notifications` (`related_journey_id`);
CREATE INDEX `notif_report_id_idx`         ON `notifications` (`related_report_id`);

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- END OF DDL
-- =============================================================================
