-- Reviewed additive migration for MySQL 5.7+/8 or MariaDB 10.2+.
-- SELECT the existing database first. Back up it and test on an authorized copy.
-- This script does not import the supplied dump, seed records, or delete data.
-- MySQL DDL auto-commits: a backup, not a transaction, is the recovery mechanism.
-- Stop if preflight fails; do not bypass checks or change unrelated schema.
DELIMITER $$
DROP PROCEDURE IF EXISTS pbcs_admin_features_v1$$
CREATE PROCEDURE pbcs_admin_features_v1()
BEGIN
    DECLARE n INT DEFAULT 0;
    DECLARE existing_table INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DO RELEASE_LOCK(CONCAT('pbcs_admin_features:',DATABASE()));
        RESIGNAL;
    END;
    IF DATABASE() IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Select the existing application database first.';
    END IF;
    IF COALESCE(GET_LOCK(CONCAT('pbcs_admin_features:',DATABASE()),10),0) <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Another AdminFeatures migration is running.';
    END IF;
    SELECT COUNT(*) INTO n FROM information_schema.TABLES
        WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN ('applications','users','account_audit_logs')
        AND ENGINE='InnoDB';
    IF n <> 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Required existing InnoDB tables are unavailable.';
    END IF;
    SELECT COUNT(*) INTO n FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND ((TABLE_NAME='applications' AND COLUMN_NAME='ApplicationID')
          OR (TABLE_NAME='users' AND COLUMN_NAME='UserID'))
        AND DATA_TYPE='int' AND COLUMN_TYPE NOT LIKE '%unsigned%' AND IS_NULLABLE='NO';
    IF n <> 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Expected signed INT applications.ApplicationID and users.UserID.';
    END IF;
    SELECT COUNT(DISTINCT CONCAT(s.TABLE_NAME,'.',s.COLUMN_NAME)) INTO n
        FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE()
        AND s.NON_UNIQUE=0 AND s.SEQ_IN_INDEX=1
        AND ((s.TABLE_NAME='applications' AND s.COLUMN_NAME='ApplicationID')
          OR (s.TABLE_NAME='users' AND s.COLUMN_NAME='UserID'))
        AND NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s2 WHERE s2.TABLE_SCHEMA=s.TABLE_SCHEMA
          AND s2.TABLE_NAME=s.TABLE_NAME AND s2.INDEX_NAME=s.INDEX_NAME AND s2.SEQ_IN_INDEX>1);
    IF n <> 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='The application and user relationship keys must be individually unique.';
    END IF;
    SELECT COUNT(*) INTO n FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
      AND TABLE_NAME='users' AND COLUMN_NAME IN
        ('FirstName','LastName','Email','Phone','Role','IsActive','LastLoginAt');
    IF n <> 7 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='The existing users table does not match the inspected source.';
    END IF;
    SELECT COUNT(*) INTO n FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='applications' AND COLUMN_NAME IN ('application_id','Status');
    IF n <> 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Expected application reference and status columns are unavailable.';
    END IF;
    -- Existing similarly named fields must be compatible, not silently replaced.
    SELECT COUNT(*) INTO n FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND (
        (TABLE_NAME='users' AND COLUMN_NAME='StaffNumber' AND (DATA_TYPE<>'varchar' OR CHARACTER_MAXIMUM_LENGTH<50))
        OR (TABLE_NAME='users' AND COLUMN_NAME IN ('Department','Station') AND (DATA_TYPE<>'varchar' OR CHARACTER_MAXIMUM_LENGTH<150))
        OR (TABLE_NAME='users' AND COLUMN_NAME='Rank' AND (DATA_TYPE<>'varchar' OR CHARACTER_MAXIMUM_LENGTH<100))
        OR (TABLE_NAME='users' AND COLUMN_NAME='CreatedAt' AND DATA_TYPE NOT IN ('datetime','timestamp'))
        OR (TABLE_NAME='applications' AND COLUMN_NAME='Priority' AND
          (DATA_TYPE<>'varchar' OR CHARACTER_MAXIMUM_LENGTH<20)));
    IF n <> 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='A pre-existing extension column is incompatible; manual schema review required.';
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='users' AND COLUMN_NAME='StaffNumber') THEN
        SET @pbcs_sql='SELECT COUNT(*) INTO @pbcs_duplicates FROM (SELECT StaffNumber FROM users WHERE StaffNumber IS NOT NULL GROUP BY StaffNumber HAVING COUNT(*)>1) d';
        PREPARE pbcs_check FROM @pbcs_sql;
        EXECUTE pbcs_check;
        DEALLOCATE PREPARE pbcs_check;
        IF @pbcs_duplicates > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing duplicate staff numbers need authorized review before migration.';
        END IF;
    END IF;
    -- Existing feature tables must have the complete contract. Do not remodel them automatically.
    SELECT COUNT(*) INTO existing_table FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='application_assignments';
    IF existing_table > 0 THEN
        SELECT COUNT(*) INTO n FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
            AND TABLE_NAME='application_assignments' AND COLUMN_NAME IN
              ('AssignmentID','ApplicationID','OfficerUserID','AssignedByUserID','AssignedAt','UnassignedAt',
               'UnassignedByUserID','Status','ActiveApplicationID');
        IF n <> 9 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing assignment table needs manual compatibility review.';
        END IF;
        SELECT COUNT(*) INTO n FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE()
            AND TABLE_NAME='application_assignments' AND COLUMN_NAME='ActiveApplicationID' AND NON_UNIQUE=0;
        IF n <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='The assignment table must enforce one active assignment.';
        END IF;
    END IF;
    SELECT COUNT(*) INTO existing_table FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='application_workflow_history';
    IF existing_table > 0 THEN
        SELECT COUNT(*) INTO n FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
            AND TABLE_NAME='application_workflow_history' AND COLUMN_NAME IN
              ('WorkflowID','ApplicationID','ActionType','FromStatus','ToStatus','ActionByUserID','Notes','ActionAt');
        IF n <> 8 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing workflow table needs manual compatibility review.';
        END IF;
    END IF;
    SELECT COUNT(*) INTO existing_table FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='sms_delivery_logs';
    IF existing_table > 0 THEN
        SELECT COUNT(*) INTO n FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
            AND TABLE_NAME='sms_delivery_logs' AND COLUMN_NAME IN
              ('SmsLogID','UserID','ApplicationID','PhoneNumber','MessageType','MessageReference','Provider',
               'ProviderMessageID','Status','ProviderResponse','ErrorMessage','CreatedAt','SentAt','DeliveredAt');
        IF n <> 14 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing SMS table needs manual compatibility review.';
        END IF;
    END IF;
    -- No modifications above this line except the temporary migration procedure.
    SELECT COUNT(*) INTO n FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME IN ('application_assignments','application_workflow_history','sms_delivery_logs')
        AND (ENGINE <> 'InnoDB' OR TABLE_TYPE <> 'BASE TABLE');
    IF n <> 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing feature tables must use InnoDB for atomic changes.';
    END IF;
    SELECT COUNT(*) INTO n FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE()
        AND c.TABLE_NAME IN ('application_assignments','application_workflow_history','sms_delivery_logs')
        AND c.COLUMN_NAME IN ('ApplicationID','OfficerUserID','AssignedByUserID','UnassignedByUserID','ActionByUserID','UserID')
        AND (c.DATA_TYPE <> 'int' OR c.COLUMN_TYPE LIKE '%unsigned%');
    IF n <> 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing relationship columns must match the signed INT parent keys.';
    END IF;
    SELECT COUNT(*) INTO n FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE()
        AND c.TABLE_NAME IN ('application_assignments','application_workflow_history','sms_delivery_logs')
        AND c.COLUMN_NAME IN ('ApplicationID','OfficerUserID','AssignedByUserID','UnassignedByUserID','ActionByUserID','UserID')
        AND NOT EXISTS (
            SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=c.TABLE_SCHEMA
                AND k.TABLE_NAME=c.TABLE_NAME AND k.COLUMN_NAME=c.COLUMN_NAME
                AND k.REFERENCED_TABLE_SCHEMA=DATABASE()
                AND ((c.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_NAME='applications'
                      AND k.REFERENCED_COLUMN_NAME='ApplicationID')
                  OR (c.COLUMN_NAME<>'ApplicationID' AND k.REFERENCED_TABLE_NAME='users'
                      AND k.REFERENCED_COLUMN_NAME='UserID')));
    IF n <> 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Existing feature foreign keys need manual compatibility review.';
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='application_assignments' AND COLUMN_NAME='ActiveApplicationID'
        AND EXTRA NOT LIKE '%STORED GENERATED%') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='ActiveApplicationID must be a stored generated column.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='applications' AND COLUMN_NAME='Priority') THEN
        ALTER TABLE applications ADD COLUMN Priority VARCHAR(20) NOT NULL DEFAULT 'Normal';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='applications' AND COLUMN_NAME='Priority' AND SEQ_IN_INDEX=1) THEN
        ALTER TABLE applications ADD INDEX idx_pbcs_application_priority (Priority);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='users' AND COLUMN_NAME='StaffNumber') THEN
        ALTER TABLE users ADD COLUMN StaffNumber VARCHAR(50) NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='users' AND COLUMN_NAME='Department') THEN
        ALTER TABLE users ADD COLUMN Department VARCHAR(150) NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='users' AND COLUMN_NAME='Station') THEN
        ALTER TABLE users ADD COLUMN Station VARCHAR(150) NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='users' AND COLUMN_NAME='Rank') THEN
        ALTER TABLE users ADD COLUMN `Rank` VARCHAR(100) NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE()
        AND TABLE_NAME='users' AND COLUMN_NAME='CreatedAt') THEN
        -- Keep existing account dates unknown. Set a default only after adding the nullable field.
        ALTER TABLE users ADD COLUMN CreatedAt DATETIME NULL DEFAULT NULL;
        ALTER TABLE users ALTER COLUMN CreatedAt SET DEFAULT CURRENT_TIMESTAMP;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE()
        AND s.TABLE_NAME='users' AND s.COLUMN_NAME='StaffNumber' AND s.NON_UNIQUE=0 AND s.SEQ_IN_INDEX=1
        AND NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s2 WHERE s2.TABLE_SCHEMA=s.TABLE_SCHEMA
          AND s2.TABLE_NAME=s.TABLE_NAME AND s2.INDEX_NAME=s.INDEX_NAME AND s2.SEQ_IN_INDEX>1)) THEN
        ALTER TABLE users ADD UNIQUE INDEX ux_pbcs_staff_number (StaffNumber);
    END IF;
    CREATE TABLE IF NOT EXISTS application_assignments (
        AssignmentID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        ApplicationID INT NOT NULL,
        OfficerUserID INT NOT NULL,
        AssignedByUserID INT NOT NULL,
        AssignedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        UnassignedAt DATETIME(6) NULL,
        UnassignedByUserID INT NULL,
        Status ENUM('Active','Ended') NOT NULL DEFAULT 'Active',
        ActiveApplicationID INT GENERATED ALWAYS AS
            (CASE WHEN UnassignedAt IS NULL THEN ApplicationID ELSE NULL END) STORED,
        UNIQUE KEY ux_pbcs_active_assignment (ActiveApplicationID),
        KEY idx_pbcs_assignment_officer (OfficerUserID,UnassignedAt),
        KEY idx_pbcs_assignment_application (ApplicationID,AssignedAt),
        CONSTRAINT fk_pbcs_assignment_application FOREIGN KEY (ApplicationID) REFERENCES applications(ApplicationID),
        CONSTRAINT fk_pbcs_assignment_officer FOREIGN KEY (OfficerUserID) REFERENCES users(UserID),
        CONSTRAINT fk_pbcs_assignment_admin FOREIGN KEY (AssignedByUserID) REFERENCES users(UserID),
        CONSTRAINT fk_pbcs_assignment_ended_by FOREIGN KEY (UnassignedByUserID) REFERENCES users(UserID)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    CREATE TABLE IF NOT EXISTS application_workflow_history (
        WorkflowID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        ApplicationID INT NOT NULL,
        ActionType VARCHAR(100) NOT NULL,
        FromStatus VARCHAR(50) NULL,
        ToStatus VARCHAR(50) NULL,
        ActionByUserID INT NOT NULL,
        Notes TEXT NULL,
        ActionAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        KEY idx_pbcs_workflow_application (ApplicationID,ActionAt,WorkflowID),
        KEY idx_pbcs_workflow_actor (ActionByUserID,ActionAt),
        KEY idx_pbcs_workflow_date (ActionAt),
        CONSTRAINT fk_pbcs_workflow_application FOREIGN KEY (ApplicationID) REFERENCES applications(ApplicationID),
        CONSTRAINT fk_pbcs_workflow_actor FOREIGN KEY (ActionByUserID) REFERENCES users(UserID)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    CREATE TABLE IF NOT EXISTS sms_delivery_logs (
        SmsLogID BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        UserID INT NULL,
        ApplicationID INT NULL,
        PhoneNumber VARCHAR(30) NOT NULL,
        MessageType VARCHAR(50) NOT NULL,
        MessageReference VARCHAR(150) NOT NULL,
        Provider VARCHAR(50) NOT NULL DEFAULT 'Hubtel',
        ProviderMessageID VARCHAR(150) NULL,
        Status ENUM('Pending','Submitted','Delivered','Failed','Unknown') NOT NULL DEFAULT 'Pending',
        ProviderResponse TEXT NULL,
        ErrorMessage TEXT NULL,
        CreatedAt DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        SentAt DATETIME(6) NULL,
        DeliveredAt DATETIME(6) NULL,
        UNIQUE KEY ux_pbcs_sms_reference (MessageReference),
        UNIQUE KEY ux_pbcs_sms_provider_id (ProviderMessageID),
        KEY idx_pbcs_sms_status_date (Status,CreatedAt),
        KEY idx_pbcs_sms_application (ApplicationID),
        CONSTRAINT fk_pbcs_sms_user FOREIGN KEY (UserID) REFERENCES users(UserID),
        CONSTRAINT fk_pbcs_sms_application FOREIGN KEY (ApplicationID) REFERENCES applications(ApplicationID)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    DO RELEASE_LOCK(CONCAT('pbcs_admin_features:',DATABASE()));
END$$
CALL pbcs_admin_features_v1()$$
DROP PROCEDURE pbcs_admin_features_v1$$
DELIMITER ;
