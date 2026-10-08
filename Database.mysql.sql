/*
POLICE BACKGROUND SYSTEM CHECK — NATIVE MYSQL / MARIADB
One consolidated schema file. MySQL 5.7+/8.x; MariaDB 10.4+; InnoDB.
LOCAL: create/select pbcswa_db in phpMyAdmin or MySQL Workbench, then import this file.
ONLINE: create the database/user in the hosting panel, select the assigned database
(which may have a hosting prefix), then import this SAME file using phpMyAdmin.
The host must provide MySQL/MariaDB; this cannot run on SQL Server-only hosting.
Import with phpMyAdmin, MySQL Workbench or mysql CLI, NOT SSMS.
MySQL command line: mysql -u YOUR_USER -p YOUR_DATABASE < Database.mysql.sql
The -p option prompts privately. Never put a password in this file or command.
Use your actual hosting MySQL endpoint in the application's private configuration;
do not use a developer PC's localhost/127.0.0.1 for a remote database.

BACK UP FIRST and test on a copy. Pause application writes during import.
This file creates missing project tables and safely adds the original extensions.
It does not create/drop databases, import accounts/records, update/delete records,
or include unrelated project tables. No SQL Server syntax remains.
No routines, triggers, DEFINER, DELIMITER, or CREATE ROUTINE permission are needed.
Required account privileges: SELECT, CREATE, ALTER, INDEX, REFERENCES on this
database; the server must permit PREPARE/EXECUTE and GET_LOCK.
This works on a new empty database selected in the client, or on a compatible
existing project database. Incompatible columns/keys/data fail the preflight.
Do not select mysql/information_schema/performance_schema/sys.

IMPORTANT: MySQL/MariaDB DDL auto-commits. It cannot be rolled back as a single
transaction. STOP on the first SQL error; never use mysql --force. A hosting client
must stop on import errors. The guard skips writes after a failed preflight even
if the client continues; permission/server failures after preflight may leave some
schema additions committed. Restore the backup or review before retrying.
Original BIGINT UNSIGNED/AUTO_INCREMENT, ENUM, stored generated assignment key,
nullable UNIQUE semantics, DATETIME precision and UTF-8 text are restored.
Existing valid FK actions/defaults are kept. Only the known payments reference to
applications.ID is corrected to ApplicationID; missing payment FK uses DELETE CASCADE.
No application code is changed. This does not import a SQL Server database's data.
*/
SET @pbcs_old_sql_mode=@@SESSION.sql_mode;
SET SESSION sql_mode=REPLACE(REPLACE(@@SESSION.sql_mode,'NO_BACKSLASH_ESCAPES',''),',,',',');
SET NAMES utf8mb4;
SET @pbcs_ok=1;
SET @pbcs_error=NULL;
SET @pbcs_lock_name=CONCAT('pbcs_mysql_schema:',DATABASE());
SET @pbcs_lock_acquired=0;

SET @pbcs_test=IFNULL((DATABASE() IS NOT NULL AND DATABASE() NOT IN ('mysql','information_schema','performance_schema','sys')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'Select your local or hosting-assigned application database before importing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_lock_acquired=IF(@pbcs_ok=1,GET_LOCK(@pbcs_lock_name,10),0);
SET @pbcs_test=IFNULL((@pbcs_lock_acquired=1),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'Another project schema import is running, or GET_LOCK is unavailable.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);


-- 1. Preflight every existing project table/column before changing schema.

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='users' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'users: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='applications' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'applications: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='account_audit_logs') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='account_audit_logs' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'account_audit_logs: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='password_reset_requests') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='password_reset_requests' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'password_reset_requests: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='identity_document_reviews') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='identity_document_reviews' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_document_reviews: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='application_assignments' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_workflow_history') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='application_workflow_history' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='certificates') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='certificates' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'certificates: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='ghana_card_registry') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='ghana_card_registry' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'ghana_card_registry: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='identity_verifications') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='identity_verifications' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_verifications: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='payments') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='payments' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='sms_delivery_logs') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='sms_delivery_logs' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='verification_log') OR EXISTS (SELECT 1 FROM information_schema.TABLES t WHERE t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME='verification_log' AND t.TABLE_TYPE='BASE TABLE' AND t.ENGINE='InnoDB')),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'verification_log: existing object must be an InnoDB base table.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL(((SELECT COUNT(*) FROM (SELECT 'users' AS `t`,'UserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'FirstName' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'Email' AS `c`,'varchar' AS `dtype`,100 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'Phone' AS `c`,'varchar' AS `dtype`,20 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'PhoneVerified' AS `c`,'tinyint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'LastName' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'Password' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'Role' AS `c`,'varchar' AS `dtype`,20 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'IsActive' AS `c`,'tinyint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'FailedLoginAttempts' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,1 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'LockedUntil' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'LastLoginAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'PasswordChangedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'MustChangePassword' AS `c`,'tinyint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'StaffNumber' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,1 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'Department' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,1 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'Station' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,1 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'Rank' AS `c`,'varchar' AS `dtype`,100 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,1 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'users' AS `t`,'CreatedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,1 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'application_id' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'ApplicationID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'FullName' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'Gender' AS `c`,'varchar' AS `dtype`,20 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'DateOfBirth' AS `c`,'date' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'MaritalStatus' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'PlaceOfBirth' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'GPSAddress' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'Email' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'Phone' AS `c`,'varchar' AS `dtype`,30 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'Profession' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'NextOfKinName' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'NextOfKinPhone' AS `c`,'varchar' AS `dtype`,30 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'NationalIDType' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'IDIssueDate' AS `c`,'date' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'IDIssueLocation' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'EmployerName' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'EmploymentPosition' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'EmployerAddress' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'InstitutionName' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'ProgrammeName' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'StudentID' AS `c`,'varchar' AS `dtype`,100 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'DestinationCountry' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'VisaType' AS `c`,'varchar' AS `dtype`,100 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'TravelDate' AS `c`,'date' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'OtherPurpose' AS `c`,'varchar' AS `dtype`,500 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'GhanaCard' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'Purpose' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'Status' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'DateSubmitted' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'ReviewedBy' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'ReviewedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'ReviewNotes' AS `c`,'text' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'RejectionReason' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'applications' AS `t`,'Priority' AS `c`,'varchar' AS `dtype`,20 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,1 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'account_audit_logs' AS `t`,'AuditID' AS `c`,'bigint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,1 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'account_audit_logs' AS `t`,'ActorUserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'account_audit_logs' AS `t`,'TargetUserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'account_audit_logs' AS `t`,'ActionType' AS `c`,'varchar' AS `dtype`,60 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'account_audit_logs' AS `t`,'Details' AS `c`,'text' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'account_audit_logs' AS `t`,'IPAddress' AS `c`,'varchar' AS `dtype`,45 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'account_audit_logs' AS `t`,'UserAgent' AS `c`,'varchar' AS `dtype`,255 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'account_audit_logs' AS `t`,'CreatedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'ResetRequestID' AS `c`,'bigint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,1 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'UserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'RequestedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'Status' AS `c`,'varchar' AS `dtype`,20 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'RequestSource' AS `c`,'varchar' AS `dtype`,30 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'ResetTokenHash' AS `c`,'char' AS `dtype`,64 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'TokenExpiresAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'ProcessedBy' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'ProcessedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'password_reset_requests' AS `t`,'AdminNotes' AS `c`,'varchar' AS `dtype`,500 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_document_reviews' AS `t`,'ReviewID' AS `c`,'bigint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,1 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_document_reviews' AS `t`,'ApplicationReference' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_document_reviews' AS `t`,'DocumentType' AS `c`,'varchar' AS `dtype`,32 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_document_reviews' AS `t`,'Decision' AS `c`,'varchar' AS `dtype`,24 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_document_reviews' AS `t`,'ReviewReason' AS `c`,'varchar' AS `dtype`,1000 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_document_reviews' AS `t`,'ReviewerUserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_document_reviews' AS `t`,'ReviewerName' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_document_reviews' AS `t`,'ReviewedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_assignments' AS `t`,'AssignmentID' AS `c`,'bigint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,1 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_assignments' AS `t`,'ApplicationID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_assignments' AS `t`,'OfficerUserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_assignments' AS `t`,'AssignedByUserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_assignments' AS `t`,'AssignedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,6 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_assignments' AS `t`,'UnassignedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,6 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_assignments' AS `t`,'UnassignedByUserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_assignments' AS `t`,'Status' AS `c`,'enum' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'enum(''Active'',''Ended'')' AS `enum_type`
UNION ALL
SELECT 'application_assignments' AS `t`,'ActiveApplicationID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,1 AS `generated`,1 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_workflow_history' AS `t`,'WorkflowID' AS `c`,'bigint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,1 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_workflow_history' AS `t`,'ApplicationID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_workflow_history' AS `t`,'ActionType' AS `c`,'varchar' AS `dtype`,100 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_workflow_history' AS `t`,'FromStatus' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_workflow_history' AS `t`,'ToStatus' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_workflow_history' AS `t`,'ActionByUserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_workflow_history' AS `t`,'Notes' AS `c`,'text' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'application_workflow_history' AS `t`,'ActionAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,6 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'certificates' AS `t`,'CertificateID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'certificates' AS `t`,'ApplicationReference' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'certificates' AS `t`,'CertificateReference' AS `c`,'varchar' AS `dtype`,100 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'certificates' AS `t`,'CertificateStatus' AS `c`,'varchar' AS `dtype`,30 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'certificates' AS `t`,'IssueDate' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'ghana_card_registry' AS `t`,'registry_id' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'ghana_card_registry' AS `t`,'ghana_card_number' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'ghana_card_registry' AS `t`,'full_name' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'ghana_card_registry' AS `t`,'date_of_birth' AS `c`,'date' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'ghana_card_registry' AS `t`,'gender' AS `c`,'varchar' AS `dtype`,20 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'ghana_card_registry' AS `t`,'verification_status' AS `c`,'varchar' AS `dtype`,30 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'ghana_card_registry' AS `t`,'created_at' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'VerificationID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'ApplicationReference' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'GhanaCardNumber' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'ApplicantName' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'ApplicantDateOfBirth' AS `c`,'date' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'ApplicantGender' AS `c`,'varchar' AS `dtype`,20 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'RegistryName' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'RegistryDateOfBirth' AS `c`,'date' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'RegistryGender' AS `c`,'varchar' AS `dtype`,20 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'GhanaCardMatch' AS `c`,'tinyint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'NameMatch' AS `c`,'tinyint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'DateOfBirthMatch' AS `c`,'tinyint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'GenderMatch' AS `c`,'tinyint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'OverallStatus' AS `c`,'varchar' AS `dtype`,30 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'VerifiedBy' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'identity_verifications' AS `t`,'VerifiedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'payments' AS `t`,'PaymentID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'payments' AS `t`,'ApplicationID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'payments' AS `t`,'PaymentMethod' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'payments' AS `t`,'TransactionID' AS `c`,'varchar' AS `dtype`,100 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'payments' AS `t`,'AmountPaid' AS `c`,'decimal' AS `dtype`,0 AS `minlen`,2 AS `minscale`,10 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'payments' AS `t`,'PaymentDate' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'payments' AS `t`,'PaymentVerified' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'SmsLogID' AS `c`,'bigint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,1 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'UserID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'ApplicationID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'PhoneNumber' AS `c`,'varchar' AS `dtype`,30 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'MessageType' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'MessageReference' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'Provider' AS `c`,'varchar' AS `dtype`,50 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'ProviderMessageID' AS `c`,'varchar' AS `dtype`,150 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'Status' AS `c`,'enum' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'enum(''Pending'',''Submitted'',''Delivered'',''Failed'',''Unknown'')' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'ProviderResponse' AS `c`,'text' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'ErrorMessage' AS `c`,'text' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'CreatedAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,6 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'SentAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,6 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'sms_delivery_logs' AS `t`,'DeliveredAt' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,6 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'verification_log' AS `t`,'LogID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,1 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'verification_log' AS `t`,'ApplicationID' AS `c`,'int' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,0 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'verification_log' AS `t`,'OfficerName' AS `c`,'varchar' AS `dtype`,100 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'verification_log' AS `t`,'VerificationDate' AS `c`,'datetime' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'verification_log' AS `t`,'IsVerified' AS `c`,'tinyint' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`
UNION ALL
SELECT 'verification_log' AS `t`,'Notes' AS `c`,'text' AS `dtype`,0 AS `minlen`,0 AS `minscale`,0 AS `minprecision`,1 AS `nullable`,0 AS `unsigned_type`,0 AS `auto_id`,0 AS `generated`,0 AS `can_add`,'' AS `enum_type`) e JOIN information_schema.TABLES t ON t.TABLE_SCHEMA=DATABASE() AND t.TABLE_NAME=e.t LEFT JOIN information_schema.COLUMNS c ON c.TABLE_SCHEMA=t.TABLE_SCHEMA AND c.TABLE_NAME=e.t AND c.COLUMN_NAME=e.c WHERE (c.COLUMN_NAME IS NULL AND e.can_add=0) OR (c.COLUMN_NAME IS NOT NULL AND (LOWER(c.DATA_TYPE)<>e.dtype OR (e.minlen>0 AND c.CHARACTER_MAXIMUM_LENGTH<e.minlen) OR (e.dtype IN ('varchar','char','text','enum') AND c.CHARACTER_SET_NAME<>'utf8mb4') OR (e.dtype='decimal' AND (c.NUMERIC_SCALE<e.minscale OR c.NUMERIC_PRECISION-c.NUMERIC_SCALE<e.minprecision-e.minscale)) OR (e.dtype='datetime' AND IFNULL(c.DATETIME_PRECISION,0)<e.minscale) OR ((c.IS_NULLABLE='YES')<>e.nullable) OR ((LOWER(c.COLUMN_TYPE) LIKE '%unsigned%')<>e.unsigned_type) OR ((LOWER(c.EXTRA) LIKE '%auto_increment%')<>e.auto_id) OR (e.generated=1 AND (LOWER(c.EXTRA) NOT LIKE '%stored generated%' OR LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(c.GENERATION_EXPRESSION,'`',''),' ',''),'(',''),')',''),CHAR(10),''))<>'casewhenunassignedatisnullthenapplicationidelsenullend')) OR (e.enum_type<>'' AND LOWER(c.COLUMN_TYPE)<>LOWER(e.enum_type)))))=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'An existing column is missing or incompatible (type, size, precision, NULL, unsigned, identity, ENUM or generated expression). No conversion or data cleanup is automatic.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='users' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='users' AND s.INDEX_NAME='PRIMARY')='UserID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'users: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `UserID` FROM `users` GROUP BY `UserID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'users: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='applications' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='applications' AND s.INDEX_NAME='PRIMARY')='ApplicationID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'applications: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='ApplicationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `ApplicationID` FROM `applications` GROUP BY `ApplicationID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'applications: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='account_audit_logs') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='PRIMARY')='AuditID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'account_audit_logs: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='account_audit_logs' AND c.COLUMN_NAME='AuditID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `AuditID` FROM `account_audit_logs` GROUP BY `AuditID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'account_audit_logs: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='password_reset_requests') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='PRIMARY')='ResetRequestID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'password_reset_requests: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='password_reset_requests' AND c.COLUMN_NAME='ResetRequestID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `ResetRequestID` FROM `password_reset_requests` GROUP BY `ResetRequestID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'password_reset_requests: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='identity_document_reviews') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' AND s.INDEX_NAME='PRIMARY')='ReviewID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_document_reviews: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='identity_document_reviews' AND c.COLUMN_NAME='ReviewID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `ReviewID` FROM `identity_document_reviews` GROUP BY `ReviewID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_document_reviews: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='PRIMARY')='AssignmentID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='AssignmentID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `AssignmentID` FROM `application_assignments` GROUP BY `AssignmentID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_workflow_history') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' AND s.INDEX_NAME='PRIMARY')='WorkflowID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_workflow_history' AND c.COLUMN_NAME='WorkflowID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `WorkflowID` FROM `application_workflow_history` GROUP BY `WorkflowID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='certificates') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='certificates' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='certificates' AND s.INDEX_NAME='PRIMARY')='CertificateID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'certificates: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='certificates' AND c.COLUMN_NAME='CertificateID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `CertificateID` FROM `certificates` GROUP BY `CertificateID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'certificates: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='ghana_card_registry') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='ghana_card_registry' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='ghana_card_registry' AND s.INDEX_NAME='PRIMARY')='registry_id'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'ghana_card_registry: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='ghana_card_registry' AND c.COLUMN_NAME='registry_id')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `registry_id` FROM `ghana_card_registry` GROUP BY `registry_id` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'ghana_card_registry: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='identity_verifications') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_verifications' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_verifications' AND s.INDEX_NAME='PRIMARY')='VerificationID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_verifications: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='identity_verifications' AND c.COLUMN_NAME='VerificationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `VerificationID` FROM `identity_verifications` GROUP BY `VerificationID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_verifications: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='payments') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='payments' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='payments' AND s.INDEX_NAME='PRIMARY')='PaymentID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='payments' AND c.COLUMN_NAME='PaymentID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `PaymentID` FROM `payments` GROUP BY `PaymentID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='sms_delivery_logs') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='PRIMARY')='SmsLogID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='sms_delivery_logs' AND c.COLUMN_NAME='SmsLogID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `SmsLogID` FROM `sms_delivery_logs` GROUP BY `SmsLogID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.TABLES c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='verification_log') OR NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='verification_log' AND s.INDEX_NAME='PRIMARY') OR (SELECT GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX) FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='verification_log' AND s.INDEX_NAME='PRIMARY')='LogID'),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'verification_log: existing primary key differs from the project schema.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='verification_log' AND c.COLUMN_NAME='LogID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `LogID` FROM `verification_log` GROUP BY `LogID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'verification_log: duplicate primary identifiers require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='idx_account_audit_target_date') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='idx_account_audit_target_date' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='TargetUserID,CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'account_audit_logs.idx_account_audit_target_date: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='idx_account_audit_actor_date') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='idx_account_audit_actor_date' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActorUserID,CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'account_audit_logs.idx_account_audit_actor_date: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='idx_account_audit_action_date') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='idx_account_audit_action_date' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActionType,CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'account_audit_logs.idx_account_audit_action_date: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='applications' AND s.INDEX_NAME='idx_pbcs_application_priority') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='applications' AND s.INDEX_NAME='idx_pbcs_application_priority' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='Priority' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'applications.idx_pbcs_application_priority: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='ux_pbcs_active_assignment') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='ux_pbcs_active_assignment' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActiveApplicationID' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.ux_pbcs_active_assignment: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='ApplicationID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='UnassignedAt')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT ApplicationID FROM application_assignments WHERE UnassignedAt IS NULL GROUP BY ApplicationID HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.ux_pbcs_active_assignment: duplicate unique values require authorised review; nothing is merged/deleted.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='idx_pbcs_assignment_officer') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='idx_pbcs_assignment_officer' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='OfficerUserID,UnassignedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.idx_pbcs_assignment_officer: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='idx_pbcs_assignment_application') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='idx_pbcs_assignment_application' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID,AssignedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.idx_pbcs_assignment_application: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='fk_pbcs_assignment_admin') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='fk_pbcs_assignment_admin' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='AssignedByUserID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.fk_pbcs_assignment_admin: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='fk_pbcs_assignment_ended_by') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='fk_pbcs_assignment_ended_by' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='UnassignedByUserID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.fk_pbcs_assignment_ended_by: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' AND s.INDEX_NAME='idx_pbcs_workflow_application') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' AND s.INDEX_NAME='idx_pbcs_workflow_application' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID,ActionAt,WorkflowID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.idx_pbcs_workflow_application: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' AND s.INDEX_NAME='idx_pbcs_workflow_actor') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' AND s.INDEX_NAME='idx_pbcs_workflow_actor' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActionByUserID,ActionAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.idx_pbcs_workflow_actor: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' AND s.INDEX_NAME='idx_pbcs_workflow_date') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' AND s.INDEX_NAME='idx_pbcs_workflow_date' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActionAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.idx_pbcs_workflow_date: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='certificates' AND s.INDEX_NAME='UQ_CertificateReference') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='certificates' AND s.INDEX_NAME='UQ_CertificateReference' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='CertificateReference' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'certificates.UQ_CertificateReference: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='certificates' AND c.COLUMN_NAME='CertificateReference')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `CertificateReference` FROM `certificates` WHERE `CertificateReference` IS NOT NULL GROUP BY `CertificateReference` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'certificates.UQ_CertificateReference: duplicate unique values require authorised review; nothing is merged/deleted.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='certificates' AND s.INDEX_NAME='UQ_CertificateApplication') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='certificates' AND s.INDEX_NAME='UQ_CertificateApplication' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationReference' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'certificates.UQ_CertificateApplication: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='certificates' AND c.COLUMN_NAME='ApplicationReference')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `ApplicationReference` FROM `certificates` WHERE `ApplicationReference` IS NOT NULL GROUP BY `ApplicationReference` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'certificates.UQ_CertificateApplication: duplicate unique values require authorised review; nothing is merged/deleted.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='ghana_card_registry' AND s.INDEX_NAME='uq_ghana_card_number') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='ghana_card_registry' AND s.INDEX_NAME='uq_ghana_card_number' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ghana_card_number' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'ghana_card_registry.uq_ghana_card_number: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='ghana_card_registry' AND c.COLUMN_NAME='ghana_card_number')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `ghana_card_number` FROM `ghana_card_registry` WHERE `ghana_card_number` IS NOT NULL GROUP BY `ghana_card_number` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'ghana_card_registry.uq_ghana_card_number: duplicate unique values require authorised review; nothing is merged/deleted.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' AND s.INDEX_NAME='IX_identity_document_reviews_latest') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' AND s.INDEX_NAME='IX_identity_document_reviews_latest' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationReference,DocumentType,ReviewID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_document_reviews.IX_identity_document_reviews_latest: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' AND s.INDEX_NAME='IX_identity_document_reviews_decision') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' AND s.INDEX_NAME='IX_identity_document_reviews_decision' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='Decision,ReviewedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_document_reviews.IX_identity_document_reviews_decision: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' AND s.INDEX_NAME='IX_identity_document_reviews_reviewer') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' AND s.INDEX_NAME='IX_identity_document_reviews_reviewer' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ReviewerUserID,ReviewedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_document_reviews.IX_identity_document_reviews_reviewer: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_verifications' AND s.INDEX_NAME='IX_ApplicationReference') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_verifications' AND s.INDEX_NAME='IX_ApplicationReference' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationReference' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'identity_verifications.IX_ApplicationReference: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='idx_reset_user_status') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='idx_reset_user_status' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='UserID,Status' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'password_reset_requests.idx_reset_user_status: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='idx_reset_status_requested') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='idx_reset_status_requested' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='Status,RequestedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'password_reset_requests.idx_reset_status_requested: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='idx_reset_token_hash') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='idx_reset_token_hash' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ResetTokenHash' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'password_reset_requests.idx_reset_token_hash: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='idx_reset_processed_by') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='idx_reset_processed_by' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ProcessedBy' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'password_reset_requests.idx_reset_processed_by: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='IX_password_reset_requests_user_time') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='IX_password_reset_requests_user_time' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='UserID,RequestedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'password_reset_requests.IX_password_reset_requests_user_time: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='payments' AND s.INDEX_NAME='TransactionID') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='payments' AND s.INDEX_NAME='TransactionID' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='TransactionID' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments.TransactionID: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='payments' AND c.COLUMN_NAME='TransactionID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `TransactionID` FROM `payments` WHERE `TransactionID` IS NOT NULL GROUP BY `TransactionID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments.TransactionID: duplicate unique values require authorised review; nothing is merged/deleted.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='payments' AND s.INDEX_NAME='ApplicationID') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='payments' AND s.INDEX_NAME='ApplicationID' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments.ApplicationID: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='ux_pbcs_sms_reference') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='ux_pbcs_sms_reference' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='MessageReference' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.ux_pbcs_sms_reference: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='sms_delivery_logs' AND c.COLUMN_NAME='MessageReference')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `MessageReference` FROM `sms_delivery_logs` WHERE `MessageReference` IS NOT NULL GROUP BY `MessageReference` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.ux_pbcs_sms_reference: duplicate unique values require authorised review; nothing is merged/deleted.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='ux_pbcs_sms_provider_id') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='ux_pbcs_sms_provider_id' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ProviderMessageID' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.ux_pbcs_sms_provider_id: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='sms_delivery_logs' AND c.COLUMN_NAME='ProviderMessageID')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `ProviderMessageID` FROM `sms_delivery_logs` WHERE `ProviderMessageID` IS NOT NULL GROUP BY `ProviderMessageID` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.ux_pbcs_sms_provider_id: duplicate unique values require authorised review; nothing is merged/deleted.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='idx_pbcs_sms_status_date') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='idx_pbcs_sms_status_date' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='Status,CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.idx_pbcs_sms_status_date: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='idx_pbcs_sms_application') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='idx_pbcs_sms_application' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.idx_pbcs_sms_application: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='fk_pbcs_sms_user') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='fk_pbcs_sms_user' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='UserID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.fk_pbcs_sms_user: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='users' AND s.INDEX_NAME='ux_pbcs_staff_number') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='users' AND s.INDEX_NAME='ux_pbcs_staff_number' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='StaffNumber' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'users.ux_pbcs_staff_number: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='StaffNumber')), 'SELECT COUNT(*) INTO @pbcs_count FROM (SELECT `StaffNumber` FROM `users` WHERE `StaffNumber` IS NOT NULL GROUP BY `StaffNumber` HAVING COUNT(*)>1) d', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'users.ux_pbcs_staff_number: duplicate unique values require authorised review; nothing is merged/deleted.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='users' AND s.INDEX_NAME='idx_users_active_locked') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='users' AND s.INDEX_NAME='idx_users_active_locked' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='IsActive,LockedUntil' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'users.idx_users_active_locked: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='verification_log' AND s.INDEX_NAME='idx_application') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='verification_log' AND s.INDEX_NAME='idx_application' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'verification_log.idx_application: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='IX_account_audit_logs_created') OR EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='IX_account_audit_logs_created' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'account_audit_logs.IX_account_audit_logs_created: existing index name has an incompatible definition.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='AssignedByUserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND NOT ((k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID') OR (k.TABLE_NAME='payments' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID')))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.AssignedByUserID: unknown conflicting foreign key; review it before import.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='AssignedByUserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE x WHERE x.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND x.TABLE_NAME=k.TABLE_NAME AND x.CONSTRAINT_NAME=k.CONSTRAINT_NAME)>1)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.AssignedByUserID: an unexpected composite foreign key needs manual review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r WHERE r.CONSTRAINT_SCHEMA=DATABASE() AND r.CONSTRAINT_NAME='fk_pbcs_assignment_admin' AND (r.TABLE_NAME<>'application_assignments' OR r.REFERENCED_TABLE_NAME<>'users'))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'fk_pbcs_assignment_admin: foreign-key name belongs to a different relationship.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='AssignedByUserID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_assignments` c LEFT JOIN `users` p ON p.`UserID`=c.`AssignedByUserID` WHERE c.`AssignedByUserID` IS NOT NULL AND p.`UserID` IS NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.AssignedByUserID: orphaned relationship records require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='AssignedByUserID') AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_assignments` WHERE `AssignedByUserID` IS NOT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.AssignedByUserID: related records exist but their parent table/key is missing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND NOT ((k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ApplicationID') OR (k.TABLE_NAME='payments' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID')))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.ApplicationID: unknown conflicting foreign key; review it before import.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE x WHERE x.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND x.TABLE_NAME=k.TABLE_NAME AND x.CONSTRAINT_NAME=k.CONSTRAINT_NAME)>1)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.ApplicationID: an unexpected composite foreign key needs manual review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r WHERE r.CONSTRAINT_SCHEMA=DATABASE() AND r.CONSTRAINT_NAME='fk_pbcs_assignment_application' AND (r.TABLE_NAME<>'application_assignments' OR r.REFERENCED_TABLE_NAME<>'applications'))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'fk_pbcs_assignment_application: foreign-key name belongs to a different relationship.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='ApplicationID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='ApplicationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_assignments` c LEFT JOIN `applications` p ON p.`ApplicationID`=c.`ApplicationID` WHERE c.`ApplicationID` IS NOT NULL AND p.`ApplicationID` IS NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.ApplicationID: orphaned relationship records require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='ApplicationID') AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='ApplicationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_assignments` WHERE `ApplicationID` IS NOT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.ApplicationID: related records exist but their parent table/key is missing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='UnassignedByUserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND NOT ((k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID') OR (k.TABLE_NAME='payments' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID')))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.UnassignedByUserID: unknown conflicting foreign key; review it before import.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='UnassignedByUserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE x WHERE x.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND x.TABLE_NAME=k.TABLE_NAME AND x.CONSTRAINT_NAME=k.CONSTRAINT_NAME)>1)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.UnassignedByUserID: an unexpected composite foreign key needs manual review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r WHERE r.CONSTRAINT_SCHEMA=DATABASE() AND r.CONSTRAINT_NAME='fk_pbcs_assignment_ended_by' AND (r.TABLE_NAME<>'application_assignments' OR r.REFERENCED_TABLE_NAME<>'users'))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'fk_pbcs_assignment_ended_by: foreign-key name belongs to a different relationship.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='UnassignedByUserID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_assignments` c LEFT JOIN `users` p ON p.`UserID`=c.`UnassignedByUserID` WHERE c.`UnassignedByUserID` IS NOT NULL AND p.`UserID` IS NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.UnassignedByUserID: orphaned relationship records require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='UnassignedByUserID') AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_assignments` WHERE `UnassignedByUserID` IS NOT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.UnassignedByUserID: related records exist but their parent table/key is missing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='OfficerUserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND NOT ((k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID') OR (k.TABLE_NAME='payments' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID')))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.OfficerUserID: unknown conflicting foreign key; review it before import.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='OfficerUserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE x WHERE x.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND x.TABLE_NAME=k.TABLE_NAME AND x.CONSTRAINT_NAME=k.CONSTRAINT_NAME)>1)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.OfficerUserID: an unexpected composite foreign key needs manual review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r WHERE r.CONSTRAINT_SCHEMA=DATABASE() AND r.CONSTRAINT_NAME='fk_pbcs_assignment_officer' AND (r.TABLE_NAME<>'application_assignments' OR r.REFERENCED_TABLE_NAME<>'users'))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'fk_pbcs_assignment_officer: foreign-key name belongs to a different relationship.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='OfficerUserID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_assignments` c LEFT JOIN `users` p ON p.`UserID`=c.`OfficerUserID` WHERE c.`OfficerUserID` IS NOT NULL AND p.`UserID` IS NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.OfficerUserID: orphaned relationship records require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='OfficerUserID') AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_assignments` WHERE `OfficerUserID` IS NOT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_assignments.OfficerUserID: related records exist but their parent table/key is missing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_workflow_history' AND k.COLUMN_NAME='ActionByUserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND NOT ((k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID') OR (k.TABLE_NAME='payments' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID')))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.ActionByUserID: unknown conflicting foreign key; review it before import.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_workflow_history' AND k.COLUMN_NAME='ActionByUserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE x WHERE x.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND x.TABLE_NAME=k.TABLE_NAME AND x.CONSTRAINT_NAME=k.CONSTRAINT_NAME)>1)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.ActionByUserID: an unexpected composite foreign key needs manual review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r WHERE r.CONSTRAINT_SCHEMA=DATABASE() AND r.CONSTRAINT_NAME='fk_pbcs_workflow_actor' AND (r.TABLE_NAME<>'application_workflow_history' OR r.REFERENCED_TABLE_NAME<>'users'))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'fk_pbcs_workflow_actor: foreign-key name belongs to a different relationship.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_workflow_history' AND c.COLUMN_NAME='ActionByUserID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_workflow_history` c LEFT JOIN `users` p ON p.`UserID`=c.`ActionByUserID` WHERE c.`ActionByUserID` IS NOT NULL AND p.`UserID` IS NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.ActionByUserID: orphaned relationship records require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_workflow_history' AND c.COLUMN_NAME='ActionByUserID') AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_workflow_history` WHERE `ActionByUserID` IS NOT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.ActionByUserID: related records exist but their parent table/key is missing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_workflow_history' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND NOT ((k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ApplicationID') OR (k.TABLE_NAME='payments' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID')))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.ApplicationID: unknown conflicting foreign key; review it before import.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_workflow_history' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE x WHERE x.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND x.TABLE_NAME=k.TABLE_NAME AND x.CONSTRAINT_NAME=k.CONSTRAINT_NAME)>1)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.ApplicationID: an unexpected composite foreign key needs manual review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r WHERE r.CONSTRAINT_SCHEMA=DATABASE() AND r.CONSTRAINT_NAME='fk_pbcs_workflow_application' AND (r.TABLE_NAME<>'application_workflow_history' OR r.REFERENCED_TABLE_NAME<>'applications'))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'fk_pbcs_workflow_application: foreign-key name belongs to a different relationship.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_workflow_history' AND c.COLUMN_NAME='ApplicationID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='ApplicationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_workflow_history` c LEFT JOIN `applications` p ON p.`ApplicationID`=c.`ApplicationID` WHERE c.`ApplicationID` IS NOT NULL AND p.`ApplicationID` IS NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.ApplicationID: orphaned relationship records require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_workflow_history' AND c.COLUMN_NAME='ApplicationID') AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='ApplicationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `application_workflow_history` WHERE `ApplicationID` IS NOT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'application_workflow_history.ApplicationID: related records exist but their parent table/key is missing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='payments' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND NOT ((k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ApplicationID') OR (k.TABLE_NAME='payments' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID')))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments.ApplicationID: unknown conflicting foreign key; review it before import.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='payments' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE x WHERE x.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND x.TABLE_NAME=k.TABLE_NAME AND x.CONSTRAINT_NAME=k.CONSTRAINT_NAME)>1)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments.ApplicationID: an unexpected composite foreign key needs manual review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r WHERE r.CONSTRAINT_SCHEMA=DATABASE() AND r.CONSTRAINT_NAME='fk_pbcs_payments_application_corrected' AND (r.TABLE_NAME<>'payments' OR r.REFERENCED_TABLE_NAME<>'applications'))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'fk_pbcs_payments_application_corrected: foreign-key name belongs to a different relationship.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='payments' AND c.COLUMN_NAME='ApplicationID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='ApplicationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `payments` c LEFT JOIN `applications` p ON p.`ApplicationID`=c.`ApplicationID` WHERE c.`ApplicationID` IS NOT NULL AND p.`ApplicationID` IS NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments.ApplicationID: orphaned relationship records require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='payments' AND c.COLUMN_NAME='ApplicationID') AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='ApplicationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `payments` WHERE `ApplicationID` IS NOT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'payments.ApplicationID: related records exist but their parent table/key is missing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='sms_delivery_logs' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND NOT ((k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ApplicationID') OR (k.TABLE_NAME='payments' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID')))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.ApplicationID: unknown conflicting foreign key; review it before import.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='sms_delivery_logs' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE x WHERE x.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND x.TABLE_NAME=k.TABLE_NAME AND x.CONSTRAINT_NAME=k.CONSTRAINT_NAME)>1)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.ApplicationID: an unexpected composite foreign key needs manual review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r WHERE r.CONSTRAINT_SCHEMA=DATABASE() AND r.CONSTRAINT_NAME='fk_pbcs_sms_application' AND (r.TABLE_NAME<>'sms_delivery_logs' OR r.REFERENCED_TABLE_NAME<>'applications'))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'fk_pbcs_sms_application: foreign-key name belongs to a different relationship.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='sms_delivery_logs' AND c.COLUMN_NAME='ApplicationID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='ApplicationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `sms_delivery_logs` c LEFT JOIN `applications` p ON p.`ApplicationID`=c.`ApplicationID` WHERE c.`ApplicationID` IS NOT NULL AND p.`ApplicationID` IS NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.ApplicationID: orphaned relationship records require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='sms_delivery_logs' AND c.COLUMN_NAME='ApplicationID') AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='ApplicationID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `sms_delivery_logs` WHERE `ApplicationID` IS NOT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.ApplicationID: related records exist but their parent table/key is missing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='sms_delivery_logs' AND k.COLUMN_NAME='UserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND NOT ((k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID') OR (k.TABLE_NAME='payments' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID')))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.UserID: unknown conflicting foreign key; review it before import.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='sms_delivery_logs' AND k.COLUMN_NAME='UserID' AND k.REFERENCED_TABLE_NAME IS NOT NULL AND (SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE x WHERE x.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA AND x.TABLE_NAME=k.TABLE_NAME AND x.CONSTRAINT_NAME=k.CONSTRAINT_NAME)>1)),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.UserID: an unexpected composite foreign key needs manual review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_test=IFNULL((NOT EXISTS (SELECT 1 FROM information_schema.REFERENTIAL_CONSTRAINTS r WHERE r.CONSTRAINT_SCHEMA=DATABASE() AND r.CONSTRAINT_NAME='fk_pbcs_sms_user' AND (r.TABLE_NAME<>'sms_delivery_logs' OR r.REFERENCED_TABLE_NAME<>'users'))),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'fk_pbcs_sms_user: foreign-key name belongs to a different relationship.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='sms_delivery_logs' AND c.COLUMN_NAME='UserID') AND EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `sms_delivery_logs` c LEFT JOIN `users` p ON p.`UserID`=c.`UserID` WHERE c.`UserID` IS NOT NULL AND p.`UserID` IS NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.UserID: orphaned relationship records require authorised review.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);

SET @pbcs_count=0;
SET @pbcs_sql=IF(@pbcs_ok=1 AND (EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='sms_delivery_logs' AND c.COLUMN_NAME='UserID') AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='UserID')), 'SELECT COUNT(*) INTO @pbcs_count FROM `sms_delivery_logs` WHERE `UserID` IS NOT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_test=IFNULL((@pbcs_count=0),0);
SET @pbcs_error=IF(@pbcs_ok=1 AND @pbcs_test=0,'sms_delivery_logs.UserID: related records exist but their parent table/key is missing.',@pbcs_error);
SET @pbcs_ok=IF(@pbcs_ok=1 AND @pbcs_test=1,1,0);


SELECT IF(@pbcs_ok=1,'PREFLIGHT PASSED',CONCAT('IMPORT STOPPED: ',@pbcs_error)) AS ImportPreflight;
-- Deliberately fail in reserved information_schema if the preflight failed.
-- The guard remains zero, preventing later schema writes in continuing clients.
SET @pbcs_sql=IF(@pbcs_ok=1,'DO 0','SELECT * FROM information_schema.PBCS_IMPORT_ABORT_READ_IMPORTPREFLIGHT');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;


-- 2. Create missing project tables in parent-before-child order.

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `users` (
    `UserID` int NOT NULL AUTO_INCREMENT,
    `FirstName` varchar(50) NOT NULL,
    `Email` varchar(100) NOT NULL,
    `Phone` varchar(20) DEFAULT NULL,
    `PhoneVerified` tinyint(1) NOT NULL DEFAULT 0,
    `LastName` varchar(50) NOT NULL,
    `Password` varchar(255) NOT NULL,
    `Role` varchar(20) NOT NULL,
    `IsActive` tinyint(1) NOT NULL DEFAULT 1 COMMENT ''1=active, 0=inactive'',
    `FailedLoginAttempts` int UNSIGNED NOT NULL DEFAULT 0,
    `LockedUntil` datetime DEFAULT NULL,
    `LastLoginAt` datetime DEFAULT NULL,
    `PasswordChangedAt` datetime DEFAULT NULL,
    `MustChangePassword` tinyint(1) NOT NULL DEFAULT 0 COMMENT ''1=force password change at next login'',
    `StaffNumber` varchar(50) DEFAULT NULL,
    `Department` varchar(150) DEFAULT NULL,
    `Station` varchar(150) DEFAULT NULL,
    `Rank` varchar(100) DEFAULT NULL,
    `CreatedAt` datetime DEFAULT current_timestamp(),
    PRIMARY KEY (`UserID`),
    UNIQUE KEY `ux_pbcs_staff_number` (`StaffNumber`),
    KEY `idx_users_active_locked` (`IsActive`,`LockedUntil`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `applications` (
    `application_id` varchar(50) NOT NULL,
    `ApplicationID` int NOT NULL AUTO_INCREMENT,
    `FullName` varchar(150) NOT NULL,
    `Gender` varchar(20) DEFAULT NULL,
    `DateOfBirth` date DEFAULT NULL,
    `MaritalStatus` varchar(50) DEFAULT NULL,
    `PlaceOfBirth` varchar(255) DEFAULT NULL,
    `GPSAddress` varchar(255) DEFAULT NULL,
    `Email` varchar(255) DEFAULT NULL,
    `Phone` varchar(30) DEFAULT NULL,
    `Profession` varchar(255) DEFAULT NULL,
    `NextOfKinName` varchar(255) DEFAULT NULL,
    `NextOfKinPhone` varchar(30) DEFAULT NULL,
    `NationalIDType` varchar(50) DEFAULT NULL,
    `IDIssueDate` date DEFAULT NULL,
    `IDIssueLocation` varchar(255) DEFAULT NULL,
    `EmployerName` varchar(255) DEFAULT NULL,
    `EmploymentPosition` varchar(255) DEFAULT NULL,
    `EmployerAddress` varchar(255) DEFAULT NULL,
    `InstitutionName` varchar(255) DEFAULT NULL,
    `ProgrammeName` varchar(255) DEFAULT NULL,
    `StudentID` varchar(100) DEFAULT NULL,
    `DestinationCountry` varchar(255) DEFAULT NULL,
    `VisaType` varchar(100) DEFAULT NULL,
    `TravelDate` date DEFAULT NULL,
    `OtherPurpose` varchar(500) DEFAULT NULL,
    `GhanaCard` varchar(50) DEFAULT NULL,
    `Purpose` varchar(255) DEFAULT NULL,
    `Status` varchar(50) DEFAULT ''Pending'',
    `DateSubmitted` datetime DEFAULT current_timestamp(),
    `ReviewedBy` varchar(150) DEFAULT NULL,
    `ReviewedAt` datetime DEFAULT NULL,
    `ReviewNotes` text DEFAULT NULL,
    `RejectionReason` varchar(255) DEFAULT NULL,
    `Priority` varchar(20) NOT NULL DEFAULT ''Normal'',
    PRIMARY KEY (`ApplicationID`),
    KEY `idx_pbcs_application_priority` (`Priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `account_audit_logs` (
    `AuditID` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    `ActorUserID` int DEFAULT NULL,
    `TargetUserID` int DEFAULT NULL,
    `ActionType` varchar(60) NOT NULL,
    `Details` text DEFAULT NULL,
    `IPAddress` varchar(45) DEFAULT NULL,
    `UserAgent` varchar(255) DEFAULT NULL,
    `CreatedAt` datetime NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`AuditID`),
    KEY `idx_account_audit_target_date` (`TargetUserID`,`CreatedAt`),
    KEY `idx_account_audit_actor_date` (`ActorUserID`,`CreatedAt`),
    KEY `idx_account_audit_action_date` (`ActionType`,`CreatedAt`),
    KEY `IX_account_audit_logs_created` (`CreatedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `password_reset_requests` (
    `ResetRequestID` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    `UserID` int NOT NULL,
    `RequestedAt` datetime NOT NULL DEFAULT current_timestamp(),
    `Status` varchar(20) NOT NULL DEFAULT ''Pending'',
    `RequestSource` varchar(30) NOT NULL DEFAULT ''SelfService'',
    `ResetTokenHash` char(64) DEFAULT NULL,
    `TokenExpiresAt` datetime DEFAULT NULL,
    `ProcessedBy` int DEFAULT NULL,
    `ProcessedAt` datetime DEFAULT NULL,
    `AdminNotes` varchar(500) DEFAULT NULL,
    PRIMARY KEY (`ResetRequestID`),
    KEY `idx_reset_user_status` (`UserID`,`Status`),
    KEY `idx_reset_status_requested` (`Status`,`RequestedAt`),
    KEY `idx_reset_token_hash` (`ResetTokenHash`),
    KEY `idx_reset_processed_by` (`ProcessedBy`),
    KEY `IX_password_reset_requests_user_time` (`UserID`,`RequestedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `identity_document_reviews` (
    `ReviewID` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    `ApplicationReference` varchar(50) NOT NULL,
    `DocumentType` varchar(32) NOT NULL,
    `Decision` varchar(24) NOT NULL,
    `ReviewReason` varchar(1000) NOT NULL,
    `ReviewerUserID` int DEFAULT NULL,
    `ReviewerName` varchar(150) NOT NULL,
    `ReviewedAt` datetime NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`ReviewID`),
    KEY `IX_identity_document_reviews_latest` (`ApplicationReference`,`DocumentType`,`ReviewID`),
    KEY `IX_identity_document_reviews_decision` (`Decision`,`ReviewedAt`),
    KEY `IX_identity_document_reviews_reviewer` (`ReviewerUserID`,`ReviewedAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `application_assignments` (
    `AssignmentID` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    `ApplicationID` int NOT NULL,
    `OfficerUserID` int NOT NULL,
    `AssignedByUserID` int NOT NULL,
    `AssignedAt` datetime(6) NOT NULL DEFAULT current_timestamp(6),
    `UnassignedAt` datetime(6) DEFAULT NULL,
    `UnassignedByUserID` int DEFAULT NULL,
    `Status` enum(''Active'',''Ended'') NOT NULL DEFAULT ''Active'',
    `ActiveApplicationID` int GENERATED ALWAYS AS (case when `UnassignedAt` is null then `ApplicationID` else NULL end) STORED,
    PRIMARY KEY (`AssignmentID`),
    UNIQUE KEY `ux_pbcs_active_assignment` (`ActiveApplicationID`),
    KEY `idx_pbcs_assignment_officer` (`OfficerUserID`,`UnassignedAt`),
    KEY `idx_pbcs_assignment_application` (`ApplicationID`,`AssignedAt`),
    KEY `fk_pbcs_assignment_admin` (`AssignedByUserID`),
    KEY `fk_pbcs_assignment_ended_by` (`UnassignedByUserID`),
    CONSTRAINT `fk_pbcs_assignment_admin` FOREIGN KEY (`AssignedByUserID`) REFERENCES `users` (`UserID`),
    CONSTRAINT `fk_pbcs_assignment_application` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`),
    CONSTRAINT `fk_pbcs_assignment_ended_by` FOREIGN KEY (`UnassignedByUserID`) REFERENCES `users` (`UserID`),
    CONSTRAINT `fk_pbcs_assignment_officer` FOREIGN KEY (`OfficerUserID`) REFERENCES `users` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `application_workflow_history` (
    `WorkflowID` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    `ApplicationID` int NOT NULL,
    `ActionType` varchar(100) NOT NULL,
    `FromStatus` varchar(50) DEFAULT NULL,
    `ToStatus` varchar(50) DEFAULT NULL,
    `ActionByUserID` int NOT NULL,
    `Notes` text DEFAULT NULL,
    `ActionAt` datetime(6) NOT NULL DEFAULT current_timestamp(6),
    PRIMARY KEY (`WorkflowID`),
    KEY `idx_pbcs_workflow_application` (`ApplicationID`,`ActionAt`,`WorkflowID`),
    KEY `idx_pbcs_workflow_actor` (`ActionByUserID`,`ActionAt`),
    KEY `idx_pbcs_workflow_date` (`ActionAt`),
    CONSTRAINT `fk_pbcs_workflow_actor` FOREIGN KEY (`ActionByUserID`) REFERENCES `users` (`UserID`),
    CONSTRAINT `fk_pbcs_workflow_application` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `certificates` (
    `CertificateID` int NOT NULL AUTO_INCREMENT,
    `ApplicationReference` varchar(50) NOT NULL,
    `CertificateReference` varchar(100) NOT NULL,
    `CertificateStatus` varchar(30) NOT NULL DEFAULT ''Issued'',
    `IssueDate` datetime NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`CertificateID`),
    UNIQUE KEY `UQ_CertificateReference` (`CertificateReference`),
    UNIQUE KEY `UQ_CertificateApplication` (`ApplicationReference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `ghana_card_registry` (
    `registry_id` int NOT NULL AUTO_INCREMENT,
    `ghana_card_number` varchar(50) NOT NULL,
    `full_name` varchar(150) NOT NULL,
    `date_of_birth` date DEFAULT NULL,
    `gender` varchar(20) DEFAULT NULL,
    `verification_status` varchar(30) NOT NULL DEFAULT ''ACTIVE'',
    `created_at` datetime NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`registry_id`),
    UNIQUE KEY `uq_ghana_card_number` (`ghana_card_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `identity_verifications` (
    `VerificationID` int NOT NULL AUTO_INCREMENT,
    `ApplicationReference` varchar(50) NOT NULL,
    `GhanaCardNumber` varchar(50) DEFAULT NULL,
    `ApplicantName` varchar(150) DEFAULT NULL,
    `ApplicantDateOfBirth` date DEFAULT NULL,
    `ApplicantGender` varchar(20) DEFAULT NULL,
    `RegistryName` varchar(150) DEFAULT NULL,
    `RegistryDateOfBirth` date DEFAULT NULL,
    `RegistryGender` varchar(20) DEFAULT NULL,
    `GhanaCardMatch` tinyint(1) NOT NULL DEFAULT 0,
    `NameMatch` tinyint(1) NOT NULL DEFAULT 0,
    `DateOfBirthMatch` tinyint(1) NOT NULL DEFAULT 0,
    `GenderMatch` tinyint(1) NOT NULL DEFAULT 0,
    `OverallStatus` varchar(30) NOT NULL DEFAULT ''Not Verified'',
    `VerifiedBy` varchar(150) DEFAULT NULL,
    `VerifiedAt` datetime DEFAULT NULL,
    PRIMARY KEY (`VerificationID`),
    KEY `IX_ApplicationReference` (`ApplicationReference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `payments` (
    `PaymentID` int NOT NULL AUTO_INCREMENT,
    `ApplicationID` int NOT NULL,
    `PaymentMethod` varchar(50) DEFAULT ''MoMo'',
    `TransactionID` varchar(100) NOT NULL,
    `AmountPaid` decimal(10,2) NOT NULL,
    `PaymentDate` datetime DEFAULT current_timestamp(),
    `PaymentVerified` int DEFAULT 0,
    PRIMARY KEY (`PaymentID`),
    UNIQUE KEY `TransactionID` (`TransactionID`),
    KEY `ApplicationID` (`ApplicationID`),
    CONSTRAINT `fk_pbcs_payments_application_corrected` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `sms_delivery_logs` (
    `SmsLogID` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    `UserID` int DEFAULT NULL,
    `ApplicationID` int DEFAULT NULL,
    `PhoneNumber` varchar(30) NOT NULL,
    `MessageType` varchar(50) NOT NULL,
    `MessageReference` varchar(150) NOT NULL,
    `Provider` varchar(50) NOT NULL DEFAULT ''Hubtel'',
    `ProviderMessageID` varchar(150) DEFAULT NULL,
    `Status` enum(''Pending'',''Submitted'',''Delivered'',''Failed'',''Unknown'') NOT NULL DEFAULT ''Pending'',
    `ProviderResponse` text DEFAULT NULL,
    `ErrorMessage` text DEFAULT NULL,
    `CreatedAt` datetime(6) NOT NULL DEFAULT current_timestamp(6),
    `SentAt` datetime(6) DEFAULT NULL,
    `DeliveredAt` datetime(6) DEFAULT NULL,
    PRIMARY KEY (`SmsLogID`),
    UNIQUE KEY `ux_pbcs_sms_reference` (`MessageReference`),
    UNIQUE KEY `ux_pbcs_sms_provider_id` (`ProviderMessageID`),
    KEY `idx_pbcs_sms_status_date` (`Status`,`CreatedAt`),
    KEY `idx_pbcs_sms_application` (`ApplicationID`),
    KEY `fk_pbcs_sms_user` (`UserID`),
    CONSTRAINT `fk_pbcs_sms_application` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`),
    CONSTRAINT `fk_pbcs_sms_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (1), 'CREATE TABLE IF NOT EXISTS `verification_log` (
    `LogID` int NOT NULL AUTO_INCREMENT,
    `ApplicationID` int NOT NULL,
    `OfficerName` varchar(100) DEFAULT NULL,
    `VerificationDate` datetime DEFAULT current_timestamp(),
    `IsVerified` tinyint(1) DEFAULT NULL,
    `Notes` text DEFAULT NULL,
    PRIMARY KEY (`LogID`),
    KEY `idx_application` (`ApplicationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;


-- 3. Add only the original feature extensions; preserve old account dates.

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='applications' AND c.COLUMN_NAME='Priority')), 'ALTER TABLE `applications` ADD COLUMN `Priority` varchar(20) NOT NULL DEFAULT ''Normal''', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_add_created_at=IF(@pbcs_ok=1 AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='CreatedAt'),1,0);
SET @pbcs_sql=IF(@pbcs_ok=1 AND (@pbcs_add_created_at=1), 'ALTER TABLE `users` ADD COLUMN `CreatedAt` DATETIME NULL DEFAULT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (@pbcs_add_created_at=1), 'ALTER TABLE `users` ALTER COLUMN `CreatedAt` SET DEFAULT CURRENT_TIMESTAMP', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='Department')), 'ALTER TABLE `users` ADD COLUMN `Department` varchar(150) DEFAULT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='Rank')), 'ALTER TABLE `users` ADD COLUMN `Rank` varchar(100) DEFAULT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='StaffNumber')), 'ALTER TABLE `users` ADD COLUMN `StaffNumber` varchar(50) DEFAULT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='users' AND c.COLUMN_NAME='Station')), 'ALTER TABLE `users` ADD COLUMN `Station` varchar(150) DEFAULT NULL', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS c WHERE c.TABLE_SCHEMA=DATABASE() AND c.TABLE_NAME='application_assignments' AND c.COLUMN_NAME='ActiveApplicationID')), 'ALTER TABLE `application_assignments` ADD COLUMN `ActiveApplicationID` int GENERATED ALWAYS AS (case when `UnassignedAt` is null then `ApplicationID` else NULL end) STORED', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;


-- 4. Add absent primary keys and semantic (deduplicated) indexes.

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='users' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `users` ADD PRIMARY KEY (`UserID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='applications' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `applications` ADD PRIMARY KEY (`ApplicationID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `account_audit_logs` ADD PRIMARY KEY (`AuditID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `password_reset_requests` ADD PRIMARY KEY (`ResetRequestID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `identity_document_reviews` ADD PRIMARY KEY (`ReviewID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `application_assignments` ADD PRIMARY KEY (`AssignmentID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `application_workflow_history` ADD PRIMARY KEY (`WorkflowID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='certificates' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `certificates` ADD PRIMARY KEY (`CertificateID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='ghana_card_registry' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `ghana_card_registry` ADD PRIMARY KEY (`registry_id`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_verifications' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `identity_verifications` ADD PRIMARY KEY (`VerificationID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='payments' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `payments` ADD PRIMARY KEY (`PaymentID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `sms_delivery_logs` ADD PRIMARY KEY (`SmsLogID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='verification_log' AND s.INDEX_NAME='PRIMARY')), 'ALTER TABLE `verification_log` ADD PRIMARY KEY (`LogID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='TargetUserID,CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `account_audit_logs` ADD INDEX `idx_account_audit_target_date` (`TargetUserID`,`CreatedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActorUserID,CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `account_audit_logs` ADD INDEX `idx_account_audit_actor_date` (`ActorUserID`,`CreatedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActionType,CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `account_audit_logs` ADD INDEX `idx_account_audit_action_date` (`ActionType`,`CreatedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='applications' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='Priority' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `applications` ADD INDEX `idx_pbcs_application_priority` (`Priority`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActiveApplicationID' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `application_assignments` ADD UNIQUE INDEX `ux_pbcs_active_assignment` (`ActiveApplicationID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='OfficerUserID,UnassignedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `application_assignments` ADD INDEX `idx_pbcs_assignment_officer` (`OfficerUserID`,`UnassignedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID,AssignedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `application_assignments` ADD INDEX `idx_pbcs_assignment_application` (`ApplicationID`,`AssignedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='AssignedByUserID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `application_assignments` ADD INDEX `fk_pbcs_assignment_admin` (`AssignedByUserID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_assignments' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='UnassignedByUserID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `application_assignments` ADD INDEX `fk_pbcs_assignment_ended_by` (`UnassignedByUserID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID,ActionAt,WorkflowID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `application_workflow_history` ADD INDEX `idx_pbcs_workflow_application` (`ApplicationID`,`ActionAt`,`WorkflowID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActionByUserID,ActionAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `application_workflow_history` ADD INDEX `idx_pbcs_workflow_actor` (`ActionByUserID`,`ActionAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='application_workflow_history' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ActionAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `application_workflow_history` ADD INDEX `idx_pbcs_workflow_date` (`ActionAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='certificates' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='CertificateReference' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `certificates` ADD UNIQUE INDEX `UQ_CertificateReference` (`CertificateReference`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='certificates' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationReference' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `certificates` ADD UNIQUE INDEX `UQ_CertificateApplication` (`ApplicationReference`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='ghana_card_registry' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ghana_card_number' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `ghana_card_registry` ADD UNIQUE INDEX `uq_ghana_card_number` (`ghana_card_number`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationReference,DocumentType,ReviewID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `identity_document_reviews` ADD INDEX `IX_identity_document_reviews_latest` (`ApplicationReference`,`DocumentType`,`ReviewID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='Decision,ReviewedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `identity_document_reviews` ADD INDEX `IX_identity_document_reviews_decision` (`Decision`,`ReviewedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_document_reviews' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ReviewerUserID,ReviewedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `identity_document_reviews` ADD INDEX `IX_identity_document_reviews_reviewer` (`ReviewerUserID`,`ReviewedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='identity_verifications' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationReference' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `identity_verifications` ADD INDEX `IX_ApplicationReference` (`ApplicationReference`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='UserID,Status' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `password_reset_requests` ADD INDEX `idx_reset_user_status` (`UserID`,`Status`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='Status,RequestedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `password_reset_requests` ADD INDEX `idx_reset_status_requested` (`Status`,`RequestedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ResetTokenHash' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `password_reset_requests` ADD INDEX `idx_reset_token_hash` (`ResetTokenHash`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ProcessedBy' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `password_reset_requests` ADD INDEX `idx_reset_processed_by` (`ProcessedBy`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='password_reset_requests' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='UserID,RequestedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `password_reset_requests` ADD INDEX `IX_password_reset_requests_user_time` (`UserID`,`RequestedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='payments' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='TransactionID' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `payments` ADD UNIQUE INDEX `TransactionID` (`TransactionID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='payments' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `payments` ADD INDEX `ApplicationID` (`ApplicationID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='MessageReference' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `sms_delivery_logs` ADD UNIQUE INDEX `ux_pbcs_sms_reference` (`MessageReference`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ProviderMessageID' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `sms_delivery_logs` ADD UNIQUE INDEX `ux_pbcs_sms_provider_id` (`ProviderMessageID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='Status,CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `sms_delivery_logs` ADD INDEX `idx_pbcs_sms_status_date` (`Status`,`CreatedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `sms_delivery_logs` ADD INDEX `idx_pbcs_sms_application` (`ApplicationID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='sms_delivery_logs' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='UserID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `sms_delivery_logs` ADD INDEX `fk_pbcs_sms_user` (`UserID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='users' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='StaffNumber' AND MIN(s.NON_UNIQUE)=0 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `users` ADD UNIQUE INDEX `ux_pbcs_staff_number` (`StaffNumber`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='users' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='IsActive,LockedUntil' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `users` ADD INDEX `idx_users_active_locked` (`IsActive`,`LockedUntil`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='verification_log' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='ApplicationID' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `verification_log` ADD INDEX `idx_application` (`ApplicationID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS s WHERE s.TABLE_SCHEMA=DATABASE() AND s.TABLE_NAME='account_audit_logs' GROUP BY s.INDEX_NAME HAVING GROUP_CONCAT(s.COLUMN_NAME ORDER BY s.SEQ_IN_INDEX)='CreatedAt' AND MIN(s.NON_UNIQUE)=1 AND SUM(s.SUB_PART IS NOT NULL)=0)), 'ALTER TABLE `account_audit_logs` ADD INDEX `IX_account_audit_logs_created` (`CreatedAt`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;


-- 5. Correct the one known bad payment FK using a distinct replacement name.

SET @pbcs_bad_fk=NULL;
SELECT k.CONSTRAINT_NAME INTO @pbcs_bad_fk FROM information_schema.KEY_COLUMN_USAGE k
WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='payments' AND k.COLUMN_NAME='ApplicationID'
AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ID'
LIMIT 1;
SET @pbcs_sql=IF(@pbcs_ok=1 AND @pbcs_bad_fk IS NOT NULL,
CONCAT('ALTER TABLE `payments` DROP FOREIGN KEY `',REPLACE(@pbcs_bad_fk,'`','``'),'`'),'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='AssignedByUserID' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID')), 'ALTER TABLE `application_assignments` ADD CONSTRAINT `fk_pbcs_assignment_admin` FOREIGN KEY (`AssignedByUserID`) REFERENCES `users` (`UserID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ApplicationID')), 'ALTER TABLE `application_assignments` ADD CONSTRAINT `fk_pbcs_assignment_application` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='UnassignedByUserID' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID')), 'ALTER TABLE `application_assignments` ADD CONSTRAINT `fk_pbcs_assignment_ended_by` FOREIGN KEY (`UnassignedByUserID`) REFERENCES `users` (`UserID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_assignments' AND k.COLUMN_NAME='OfficerUserID' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID')), 'ALTER TABLE `application_assignments` ADD CONSTRAINT `fk_pbcs_assignment_officer` FOREIGN KEY (`OfficerUserID`) REFERENCES `users` (`UserID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_workflow_history' AND k.COLUMN_NAME='ActionByUserID' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID')), 'ALTER TABLE `application_workflow_history` ADD CONSTRAINT `fk_pbcs_workflow_actor` FOREIGN KEY (`ActionByUserID`) REFERENCES `users` (`UserID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='application_workflow_history' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ApplicationID')), 'ALTER TABLE `application_workflow_history` ADD CONSTRAINT `fk_pbcs_workflow_application` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='payments' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ApplicationID')), 'ALTER TABLE `payments` ADD CONSTRAINT `fk_pbcs_payments_application_corrected` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`) ON DELETE CASCADE', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='sms_delivery_logs' AND k.COLUMN_NAME='ApplicationID' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='applications' AND k.REFERENCED_COLUMN_NAME='ApplicationID')), 'ALTER TABLE `sms_delivery_logs` ADD CONSTRAINT `fk_pbcs_sms_application` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;

SET @pbcs_sql=IF(@pbcs_ok=1 AND (NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE k WHERE k.TABLE_SCHEMA=DATABASE() AND k.TABLE_NAME='sms_delivery_logs' AND k.COLUMN_NAME='UserID' AND k.REFERENCED_TABLE_SCHEMA=DATABASE() AND k.REFERENCED_TABLE_NAME='users' AND k.REFERENCED_COLUMN_NAME='UserID')), 'ALTER TABLE `sms_delivery_logs` ADD CONSTRAINT `fk_pbcs_sms_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`)', 'DO 0');
PREPARE pbcs_statement FROM @pbcs_sql;
EXECUTE pbcs_statement;
DEALLOCATE PREPARE pbcs_statement;


-- Finish: no FOREIGN_KEY_CHECKS disabling, data import, or fake seed accounts.
SELECT IF(@pbcs_ok=1,'SCHEMA IMPORT FINISHED - confirm there were no earlier SQL errors',
CONCAT('IMPORT BLOCKED: ',@pbcs_error)) AS ImportResult;
DO IF(@pbcs_lock_acquired=1,RELEASE_LOCK(@pbcs_lock_name),0);
SET SESSION sql_mode=@pbcs_old_sql_mode;

