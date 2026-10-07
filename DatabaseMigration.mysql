-- Run after importing the supplied MariaDB/MySQL schema and taking a backup.
-- The supplied schema already defines users.IsActive, FailedLoginAttempts,
-- LockedUntil, and MustChangePassword. It also defines account_audit_logs.
-- This idempotent statement creates the audit table only if it is absent.
-- It does not modify or delete existing user/application rows.
-- Ensure users and account_audit_logs use InnoDB for transactional changes.

CREATE TABLE IF NOT EXISTS account_audit_logs (
    AuditID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ActorUserID INT NULL,
    TargetUserID INT NULL,
    ActionType VARCHAR(60) NOT NULL,
    Details TEXT NULL,
    IPAddress VARCHAR(45) NULL,
    UserAgent VARCHAR(255) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (AuditID),
    KEY IX_account_audit_logs_created (CreatedAt),
    KEY IX_account_audit_logs_target (TargetUserID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_reset_requests (
    ResetRequestID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    UserID INT NOT NULL,
    RequestedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    RequestSource VARCHAR(30) NOT NULL DEFAULT 'HUBTEL_SMS',
    ResetTokenHash CHAR(64) NULL,
    TokenExpiresAt DATETIME NULL,
    ProcessedBy INT NULL,
    ProcessedAt DATETIME NULL,
    AdminNotes VARCHAR(500) NULL,
    PRIMARY KEY (ResetRequestID),
    KEY IX_password_reset_requests_user_time (UserID, RequestedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add the request throttle index when the supplied database already has the
-- table but not this index. This syntax works on supported MySQL/MariaDB.
SET @password_reset_index_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'password_reset_requests'
      AND INDEX_NAME = 'IX_password_reset_requests_user_time'
);
SET @password_reset_index_sql = IF(
    @password_reset_index_exists = 0,
    'CREATE INDEX IX_password_reset_requests_user_time ON password_reset_requests (UserID, RequestedAt)',
    'SELECT 1'
);
PREPARE password_reset_index_statement FROM @password_reset_index_sql;
EXECUTE password_reset_index_statement;
DEALLOCATE PREPARE password_reset_index_statement;

-- Manual document-review decisions are append-only. This is separate from
-- identity_verifications, which stores non-authoritative local record comparisons.
CREATE TABLE IF NOT EXISTS identity_document_reviews (
    ReviewID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ApplicationReference VARCHAR(50) NOT NULL,
    DocumentType VARCHAR(32) NOT NULL,
    Decision VARCHAR(24) NOT NULL,
    ReviewReason VARCHAR(1000) NOT NULL,
    ReviewerUserID INT NULL,
    ReviewerName VARCHAR(150) NOT NULL,
    ReviewedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ReviewID),
    KEY IX_identity_document_reviews_latest
        (ApplicationReference, DocumentType, ReviewID),
    KEY IX_identity_document_reviews_decision
        (Decision, ReviewedAt),
    KEY IX_identity_document_reviews_reviewer
        (ReviewerUserID, ReviewedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Repair the two known foreign keys without replacing or deleting application
-- data. Correct constraints are kept; incorrect references to applications.ID
-- are removed and recreated against applications.ApplicationID.
DROP PROCEDURE IF EXISTS repair_police_application_foreign_keys;
DELIMITER $$
CREATE PROCEDURE repair_police_application_foreign_keys()
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_constraint VARCHAR(64);

    SELECT COUNT(*) INTO v_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'applications'
      AND COLUMN_NAME = 'ApplicationID';

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'applications.ApplicationID is required before repairing application foreign keys.';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'applications'
      AND COLUMN_NAME = 'ApplicationID'
      AND INDEX_NAME = 'PRIMARY';

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'applications.ApplicationID must be a primary key before repairing application foreign keys.';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'payments'
      AND COLUMN_NAME = 'ApplicationID';

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'payments.ApplicationID is required before repairing its foreign key.';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'vehicle_reports'
      AND COLUMN_NAME = 'ApplicationID';

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'vehicle_reports.ApplicationID is required before repairing its foreign key.';
    END IF;

    SET v_constraint = NULL;
    SELECT CONSTRAINT_NAME INTO v_constraint
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'payments'
      AND COLUMN_NAME = 'ApplicationID'
      AND REFERENCED_TABLE_NAME = 'applications'
      AND COALESCE(REFERENCED_COLUMN_NAME, '') <> 'ApplicationID'
    LIMIT 1;

    IF v_constraint IS NOT NULL THEN
        SET @repair_sql = CONCAT(
            'ALTER TABLE `payments` DROP FOREIGN KEY `',
            REPLACE(v_constraint, '`', '``'),
            '`'
        );
        PREPARE repair_statement FROM @repair_sql;
        EXECUTE repair_statement;
        DEALLOCATE PREPARE repair_statement;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'payments'
      AND COLUMN_NAME = 'ApplicationID'
      AND REFERENCED_TABLE_NAME = 'applications'
      AND REFERENCED_COLUMN_NAME = 'ApplicationID';

    IF v_count = 0 THEN
        ALTER TABLE `payments`
            ADD CONSTRAINT `fk_payments_applications_ApplicationID`
            FOREIGN KEY (`ApplicationID`)
            REFERENCES `applications` (`ApplicationID`)
            ON DELETE CASCADE;
    END IF;

    SET v_constraint = NULL;
    SELECT CONSTRAINT_NAME INTO v_constraint
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'vehicle_reports'
      AND COLUMN_NAME = 'ApplicationID'
      AND REFERENCED_TABLE_NAME = 'applications'
      AND COALESCE(REFERENCED_COLUMN_NAME, '') <> 'ApplicationID'
    LIMIT 1;

    IF v_constraint IS NOT NULL THEN
        SET @repair_sql = CONCAT(
            'ALTER TABLE `vehicle_reports` DROP FOREIGN KEY `',
            REPLACE(v_constraint, '`', '``'),
            '`'
        );
        PREPARE repair_statement FROM @repair_sql;
        EXECUTE repair_statement;
        DEALLOCATE PREPARE repair_statement;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'vehicle_reports'
      AND COLUMN_NAME = 'ApplicationID'
      AND REFERENCED_TABLE_NAME = 'applications'
      AND REFERENCED_COLUMN_NAME = 'ApplicationID';

    IF v_count = 0 THEN
        ALTER TABLE `vehicle_reports`
            ADD CONSTRAINT `fk_vehicle_reports_applications_ApplicationID`
            FOREIGN KEY (`ApplicationID`)
            REFERENCES `applications` (`ApplicationID`)
            ON DELETE CASCADE;
    END IF;
END$$
DELIMITER ;

CALL repair_police_application_foreign_keys();
DROP PROCEDURE IF EXISTS repair_police_application_foreign_keys;