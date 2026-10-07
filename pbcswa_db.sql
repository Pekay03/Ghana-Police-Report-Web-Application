-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 06, 2026 at 01:01 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pbcswa_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `repair_police_application_foreign_keys` ()   BEGIN
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

-- --------------------------------------------------------

--
-- Table structure for table `account_audit_logs`
--

CREATE TABLE `account_audit_logs` (
  `AuditID` bigint(20) UNSIGNED NOT NULL,
  `ActorUserID` int(11) DEFAULT NULL,
  `TargetUserID` int(11) DEFAULT NULL,
  `ActionType` varchar(60) NOT NULL,
  `Details` text DEFAULT NULL,
  `IPAddress` varchar(45) DEFAULT NULL,
  `UserAgent` varchar(255) DEFAULT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `account_audit_logs`
--

INSERT INTO `account_audit_logs` (`AuditID`, `ActorUserID`, `TargetUserID`, `ActionType`, `Details`, `IPAddress`, `UserAgent`, `CreatedAt`) VALUES
(1, 2, NULL, 'APPLICATION_DOCUMENT_VIEWED', 'Application GPRS-20260903-676EC7; document type PASSPORT_PHOTO.', NULL, NULL, '2026-10-05 04:59:08'),
(2, 2, NULL, 'APPLICATION_DOCUMENT_VIEWED', 'Application GPRS-20260903-676EC7; document type GHANA_CARD_FRONT.', NULL, NULL, '2026-10-05 04:59:13'),
(3, 2, NULL, 'APPLICATION_DOCUMENT_VIEWED', 'Application GPRS-20260903-676EC7; document type GHANA_CARD_BACK.', NULL, NULL, '2026-10-05 04:59:15'),
(4, 2, NULL, 'APPLICATION_DOCUMENT_VIEWED', 'Application GPRS-20260903-676EC7; document type PASSPORT_PHOTO.', NULL, NULL, '2026-10-05 05:51:39'),
(5, 2, NULL, 'APPLICATION_DOCUMENT_VIEWED', 'Application GPRS-20260903-676EC7; document type GHANA_CARD_FRONT.', NULL, NULL, '2026-10-05 05:52:05'),
(6, 2, NULL, 'APPLICATION_DOCUMENT_VIEWED', 'Application GPRS-20260903-676EC7; document type GHANA_CARD_BACK.', NULL, NULL, '2026-10-05 05:52:08'),
(7, 2, NULL, 'APPLICATION_DOCUMENT_VIEWED', 'Application GPRS-20260903-676EC7; document type GHANA_CARD_FRONT.', NULL, NULL, '2026-10-05 14:13:30'),
(8, 3, NULL, 'APPLICATION_DOCUMENT_VIEWED', 'Application GPRS-20260903-676EC7; document type PASSPORT_PHOTO.', NULL, NULL, '2026-10-05 14:22:24');

-- --------------------------------------------------------

--
-- Table structure for table `applications`
--

CREATE TABLE `applications` (
  `application_id` varchar(50) NOT NULL,
  `ApplicationID` int(11) NOT NULL,
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
  `Status` varchar(50) DEFAULT 'Pending',
  `DateSubmitted` datetime DEFAULT current_timestamp(),
  `ReviewedBy` varchar(150) DEFAULT NULL,
  `ReviewedAt` datetime DEFAULT NULL,
  `ReviewNotes` text DEFAULT NULL,
  `RejectionReason` varchar(255) DEFAULT NULL,
  `Priority` varchar(20) NOT NULL DEFAULT 'Normal'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `applications`
--

INSERT INTO `applications` (`application_id`, `ApplicationID`, `FullName`, `Gender`, `DateOfBirth`, `MaritalStatus`, `PlaceOfBirth`, `GPSAddress`, `Email`, `Phone`, `Profession`, `NextOfKinName`, `NextOfKinPhone`, `NationalIDType`, `IDIssueDate`, `IDIssueLocation`, `EmployerName`, `EmploymentPosition`, `EmployerAddress`, `InstitutionName`, `ProgrammeName`, `StudentID`, `DestinationCountry`, `VisaType`, `TravelDate`, `OtherPurpose`, `GhanaCard`, `Purpose`, `Status`, `DateSubmitted`, `ReviewedBy`, `ReviewedAt`, `ReviewNotes`, `RejectionReason`, `Priority`) VALUES
('GPRS-20260903-676EC7', 3, 'SAMUEL OSEI BOAKYE', 'Male', '2026-08-30', 'Single', 'KUMASI', 'AK-3238-933', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', 'FRED OPOKU', '0531129141', 'Ghana Card', '2026-09-01', 'KUMASI', NULL, NULL, NULL, NULL, NULL, NULL, 'CANADA', 'Student', '2026-09-16', NULL, 'GHA-004282828-2', 'Travel/Visa', 'Pending', '2026-09-03 16:28:50', NULL, NULL, NULL, NULL, 'Normal');

-- --------------------------------------------------------

--
-- Table structure for table `application_assignments`
--

CREATE TABLE `application_assignments` (
  `AssignmentID` bigint(20) UNSIGNED NOT NULL,
  `ApplicationID` int(11) NOT NULL,
  `OfficerUserID` int(11) NOT NULL,
  `AssignedByUserID` int(11) NOT NULL,
  `AssignedAt` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `UnassignedAt` datetime(6) DEFAULT NULL,
  `UnassignedByUserID` int(11) DEFAULT NULL,
  `Status` enum('Active','Ended') NOT NULL DEFAULT 'Active',
  `ActiveApplicationID` int(11) GENERATED ALWAYS AS (case when `UnassignedAt` is null then `ApplicationID` else NULL end) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `application_workflow_history`
--

CREATE TABLE `application_workflow_history` (
  `WorkflowID` bigint(20) UNSIGNED NOT NULL,
  `ApplicationID` int(11) NOT NULL,
  `ActionType` varchar(100) NOT NULL,
  `FromStatus` varchar(50) DEFAULT NULL,
  `ToStatus` varchar(50) DEFAULT NULL,
  `ActionByUserID` int(11) NOT NULL,
  `Notes` text DEFAULT NULL,
  `ActionAt` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `certificates`
--

CREATE TABLE `certificates` (
  `CertificateID` int(11) NOT NULL,
  `ApplicationReference` varchar(50) NOT NULL,
  `CertificateReference` varchar(100) NOT NULL,
  `CertificateStatus` varchar(30) NOT NULL DEFAULT 'Issued',
  `IssueDate` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ghana_card_registry`
--

CREATE TABLE `ghana_card_registry` (
  `registry_id` int(11) NOT NULL,
  `ghana_card_number` varchar(50) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `verification_status` varchar(30) NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `identity_document_reviews`
--

CREATE TABLE `identity_document_reviews` (
  `ReviewID` bigint(20) UNSIGNED NOT NULL,
  `ApplicationReference` varchar(50) NOT NULL,
  `DocumentType` varchar(32) NOT NULL,
  `Decision` varchar(24) NOT NULL,
  `ReviewReason` varchar(1000) NOT NULL,
  `ReviewerUserID` int(11) DEFAULT NULL,
  `ReviewerName` varchar(150) NOT NULL,
  `ReviewedAt` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `identity_verifications`
--

CREATE TABLE `identity_verifications` (
  `VerificationID` int(11) NOT NULL,
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
  `OverallStatus` varchar(30) NOT NULL DEFAULT 'Not Verified',
  `VerifiedBy` varchar(150) DEFAULT NULL,
  `VerifiedAt` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `identity_verifications`
--

INSERT INTO `identity_verifications` (`VerificationID`, `ApplicationReference`, `GhanaCardNumber`, `ApplicantName`, `ApplicantDateOfBirth`, `ApplicantGender`, `RegistryName`, `RegistryDateOfBirth`, `RegistryGender`, `GhanaCardMatch`, `NameMatch`, `DateOfBirthMatch`, `GenderMatch`, `OverallStatus`, `VerifiedBy`, `VerifiedAt`) VALUES
(2, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 11:27:43'),
(3, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 11:27:45'),
(4, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 11:27:52'),
(5, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 11:27:57'),
(6, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 11:27:59'),
(7, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 11:28:06'),
(8, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 11:28:08'),
(9, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 11:28:10'),
(10, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 11:28:17'),
(11, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 17:57:46'),
(12, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 17:57:49'),
(13, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 17:57:51'),
(14, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 17:57:54'),
(15, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 17:57:56'),
(16, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 17:57:58'),
(17, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 17:58:03'),
(18, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-04 17:58:06'),
(19, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 09:53:07'),
(20, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 09:53:09'),
(21, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 09:53:14'),
(22, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 09:53:17'),
(23, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 09:53:19'),
(24, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 09:53:23'),
(25, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 17:17:47'),
(26, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 17:18:06'),
(27, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 17:18:56'),
(28, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 17:35:16'),
(29, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 17:35:20'),
(30, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 17:35:49'),
(31, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 17:37:01'),
(32, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 17:45:22'),
(33, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'Failed', 'fredopoku@gmail.com', '2026-09-06 17:45:29'),
(34, 'GPRS-20260903-676EC7', 'GHA-004282828-2', 'SAMUEL OSEI BOAKYE', '2026-08-30', 'Male', 'No registry record found', NULL, 'No registry record f', 0, 0, 0, 0, 'LocalRecordMismatch', 'Fred Opoku', '2026-10-05 04:58:41');

-- --------------------------------------------------------

--
-- Table structure for table `nationalregistry`
--

CREATE TABLE `nationalregistry` (
  `RegistryID` int(11) NOT NULL,
  `GhanaCardPIN` varchar(100) NOT NULL,
  `FirstName` varchar(100) NOT NULL,
  `Surname` varchar(100) NOT NULL,
  `DateOfBirth` date NOT NULL,
  `Gender` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `nationalregistry`
--

INSERT INTO `nationalregistry` (`RegistryID`, `GhanaCardPIN`, `FirstName`, `Surname`, `DateOfBirth`, `Gender`) VALUES
(1, 'GHA-004222622-6', 'Samuel', 'Boakye', '1998-05-15', 'Male');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_requests`
--

CREATE TABLE `password_reset_requests` (
  `ResetRequestID` bigint(20) UNSIGNED NOT NULL,
  `UserID` int(11) NOT NULL,
  `RequestedAt` datetime NOT NULL DEFAULT current_timestamp(),
  `Status` varchar(20) NOT NULL DEFAULT 'Pending',
  `RequestSource` varchar(30) NOT NULL DEFAULT 'SelfService',
  `ResetTokenHash` char(64) DEFAULT NULL,
  `TokenExpiresAt` datetime DEFAULT NULL,
  `ProcessedBy` int(11) DEFAULT NULL,
  `ProcessedAt` datetime DEFAULT NULL,
  `AdminNotes` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `PaymentID` int(11) NOT NULL,
  `ApplicationID` int(11) NOT NULL,
  `PaymentMethod` varchar(50) DEFAULT 'MoMo',
  `TransactionID` varchar(100) NOT NULL,
  `AmountPaid` decimal(10,2) NOT NULL,
  `PaymentDate` datetime DEFAULT current_timestamp(),
  `PaymentVerified` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sms_delivery_logs`
--

CREATE TABLE `sms_delivery_logs` (
  `SmsLogID` bigint(20) UNSIGNED NOT NULL,
  `UserID` int(11) DEFAULT NULL,
  `ApplicationID` int(11) DEFAULT NULL,
  `PhoneNumber` varchar(30) NOT NULL,
  `MessageType` varchar(50) NOT NULL,
  `MessageReference` varchar(150) NOT NULL,
  `Provider` varchar(50) NOT NULL DEFAULT 'Hubtel',
  `ProviderMessageID` varchar(150) DEFAULT NULL,
  `Status` enum('Pending','Submitted','Delivered','Failed','Unknown') NOT NULL DEFAULT 'Pending',
  `ProviderResponse` text DEFAULT NULL,
  `ErrorMessage` text DEFAULT NULL,
  `CreatedAt` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `SentAt` datetime(6) DEFAULT NULL,
  `DeliveredAt` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_users`
--

CREATE TABLE `system_users` (
  `UserID` int(11) NOT NULL,
  `Username` varchar(100) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `FullName` varchar(150) NOT NULL,
  `UserRole` varchar(50) NOT NULL,
  `CreatedAt` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `system_users`
--

INSERT INTO `system_users` (`UserID`, `Username`, `PasswordHash`, `FullName`, `UserRole`, `CreatedAt`) VALUES
(1, 'citizen1', 'pass123', 'Frederick Opoku', 'Citizen', '2026-06-28 03:08:45'),
(2, 'officer1', 'pass123', 'Inspector Osei Boakye', 'PoliceOfficer', '2026-06-28 03:08:45'),
(6, 'ADMIN-001', 'pass123', 'Samuel Osei Boakye', 'Admin', '2026-08-09 01:44:22');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `PhoneVerified` tinyint(1) NOT NULL DEFAULT 0,
  `LastName` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Role` varchar(20) NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1=active, 0=inactive',
  `FailedLoginAttempts` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `LockedUntil` datetime DEFAULT NULL,
  `LastLoginAt` datetime DEFAULT NULL,
  `PasswordChangedAt` datetime DEFAULT NULL,
  `MustChangePassword` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=force password change at next login',
  `StaffNumber` varchar(50) DEFAULT NULL,
  `Department` varchar(150) DEFAULT NULL,
  `Station` varchar(150) DEFAULT NULL,
  `Rank` varchar(100) DEFAULT NULL,
  `CreatedAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`UserID`, `FirstName`, `Email`, `Phone`, `PhoneVerified`, `LastName`, `Password`, `Role`, `IsActive`, `FailedLoginAttempts`, `LockedUntil`, `LastLoginAt`, `PasswordChangedAt`, `MustChangePassword`, `StaffNumber`, `Department`, `Station`, `Rank`, `CreatedAt`) VALUES
(2, 'Fred', 'fredopoku@gmail.com', '0249550587', 1, 'Opoku', 'PBKDF2-SHA256$210000$108VqjaKIjQCVDAXWaO+FQ==$r7PBpfPIcw64NiR29omvsmitkbsg/Tfn/VnlyAWdbnE=', 'PoliceOfficer', 1, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(3, 'Samuel', 'samuel.fred@gmail.com', '0531129141', 1, 'Fred', 'PBKDF2-SHA256$210000$94A5EJB+neTCkMfQ9d0yVg==$A4FvdB10ITAPEaZ9QJJIEy7CJ45xihdh2d9jrZrWaWw=', 'Administrator', 1, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(4, 'Samuel', 'samuel.booakye@gmail.com', '0244943074', 0, 'Osei Boakye', 'PBKDF2-SHA256$210000$CS3UXBf8ZPEUMXGGz/K3lw==$t4OmYqpEqlO4gmChMd85PbZs7Np6MCnKZKSDhM1YHds=', 'Citizen', 1, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `verification_log`
--

CREATE TABLE `verification_log` (
  `LogID` int(11) NOT NULL,
  `ApplicationID` int(11) NOT NULL,
  `OfficerName` varchar(100) DEFAULT NULL,
  `VerificationDate` datetime DEFAULT current_timestamp(),
  `IsVerified` tinyint(1) DEFAULT NULL,
  `Notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `verification_log`
--

INSERT INTO `verification_log` (`LogID`, `ApplicationID`, `OfficerName`, `VerificationDate`, `IsVerified`, `Notes`) VALUES
(1, 15, 'Inspector Osei Boakye', '2026-08-18 03:35:11', 0, 'Ghana Card PIN was not provided');

-- --------------------------------------------------------

--
-- Table structure for table `vetting_applications`
--

CREATE TABLE `vetting_applications` (
  `ApplicationID` bigint(20) NOT NULL,
  `Username` varchar(100) NOT NULL,
  `FullName` varchar(255) DEFAULT NULL,
  `ClearancePurpose` varchar(150) NOT NULL,
  `Surname` varchar(100) NOT NULL,
  `MiddleName` varchar(100) DEFAULT NULL,
  `FirstName` varchar(100) NOT NULL,
  `Gender` varchar(20) NOT NULL,
  `DateOfBirth` date NOT NULL,
  `MaritalStatus` varchar(50) NOT NULL,
  `PlaceOfBirth` varchar(150) NOT NULL,
  `Nationality` varchar(100) NOT NULL,
  `HomeTown` varchar(150) NOT NULL,
  `TownOfResidence` varchar(150) NOT NULL,
  `DigitalAddress` varchar(100) DEFAULT NULL,
  `PostalAddress` varchar(250) DEFAULT NULL,
  `Email` varchar(150) NOT NULL,
  `ContactNo` varchar(50) NOT NULL,
  `Profession` varchar(150) DEFAULT NULL,
  `DocumentType` varchar(50) DEFAULT NULL,
  `DocumentNumber` varchar(100) NOT NULL,
  `DocumentIssueDate` date NOT NULL,
  `PlaceOfIssue` varchar(150) NOT NULL,
  `PassportNumber` varchar(100) NOT NULL,
  `PassportIssueDate` date NOT NULL,
  `PassportExpiryDate` date NOT NULL,
  `PassportPhotoPath` varchar(255) DEFAULT NULL,
  `DocumentUploadPath` varchar(255) DEFAULT NULL,
  `Status` varchar(50) DEFAULT 'Pending Approval',
  `Officer` varchar(100) DEFAULT NULL,
  `StaffNum` varchar(50) DEFAULT NULL,
  `AppliedDate` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vetting_applications`
--

INSERT INTO `vetting_applications` (`ApplicationID`, `Username`, `FullName`, `ClearancePurpose`, `Surname`, `MiddleName`, `FirstName`, `Gender`, `DateOfBirth`, `MaritalStatus`, `PlaceOfBirth`, `Nationality`, `HomeTown`, `TownOfResidence`, `DigitalAddress`, `PostalAddress`, `Email`, `ContactNo`, `Profession`, `DocumentType`, `DocumentNumber`, `DocumentIssueDate`, `PlaceOfIssue`, `PassportNumber`, `PassportIssueDate`, `PassportExpiryDate`, `PassportPhotoPath`, `DocumentUploadPath`, `Status`, `Officer`, `StaffNum`, `AppliedDate`) VALUES
(1, 'samuel99', NULL, 'Employment', 'Boakye', 'osei', 'Samuel', 'Male', '2026-07-03', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', '', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-02', 'KUMASI', 'G545368', '2026-07-02', '2026-08-21', NULL, NULL, 'Approved', NULL, NULL, '2026-07-01 00:38:49'),
(2, 'samuel99', NULL, 'Education', 'Boakye', 'osei', 'Samuel', 'Male', '0000-00-00', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', '', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-01', 'KUMASI', 'G545368', '2026-07-01', '2026-07-14', NULL, NULL, 'Rejected', NULL, NULL, '2026-07-01 01:49:13'),
(3, 'samuel99', NULL, 'Other', 'Boakye', 'osei', 'Samuel', 'Male', '2026-07-12', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', '', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-01', 'KUMASI', 'G545368', '2026-07-01', '2026-07-30', NULL, NULL, 'Approved', NULL, NULL, '2026-07-01 01:59:59'),
(4, 'samuel99', NULL, 'Visa / Immigration / Travel Application', 'Boakye', 'osei', 'Samuel', 'Male', '2026-07-12', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', '', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-01', 'KUMASI', 'G545368', '2026-07-01', '2026-07-30', NULL, NULL, 'Rejected', NULL, NULL, '2026-07-01 02:55:28'),
(5, 'samuel99', NULL, 'Visa / Immigration / Travel Application', 'Boakye', 'osei', 'Samuel', 'Male', '2026-07-29', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', '', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-01', 'KUMASI', 'G545368', '2026-07-01', '2026-07-31', NULL, NULL, 'Approved', NULL, NULL, '2026-07-01 03:06:41'),
(6, 'officer1', NULL, 'Employment', 'Boakye', 'osei', 'Samuel', 'Male', '2026-07-07', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', '', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-02', 'KUMASI', 'G545368', '2026-07-16', '2026-07-31', NULL, NULL, 'Approved', NULL, NULL, '2026-07-12 04:34:08'),
(7, 'citizen1', NULL, 'Employment', 'Boakye', 'osei', 'Samuel', 'Male', '2018-06-21', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-07', 'KUMASI', 'G545368', '2026-07-08', '2026-07-30', NULL, NULL, 'Rejected', NULL, NULL, '2026-07-21 10:46:00'),
(8, 'citizen1', NULL, 'Employment', 'Boakye', 'osei', 'Samuel', 'Male', '0000-00-00', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-08-05', 'KUMASI', 'G545368', '2026-08-05', '2026-08-29', NULL, NULL, 'Rejected', NULL, NULL, '2026-08-08 02:08:45'),
(9, 'citizen1', NULL, 'Employment', 'Boakye', 'osei', 'Samuel', 'Male', '2026-08-05', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-08-05', 'KUMASI', 'G545368', '2026-08-05', '2026-08-29', NULL, NULL, 'Approved', NULL, NULL, '2026-08-08 02:11:06'),
(10, 'citizen1', NULL, 'Visa / Immigration / Travel Application', 'Boakye', 'osei', 'Samuel', 'Male', '2026-08-11', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-28', 'KUMASI', 'G545368', '2026-08-04', '2026-08-28', NULL, NULL, 'Approved', NULL, NULL, '2026-08-08 02:19:56'),
(11, 'citizen1', NULL, 'Visa / Immigration / Travel Application', 'Boakye', 'osei', 'Samuel', 'Male', '2026-07-28', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-27', 'KUMASI', 'G545368', '2026-08-13', '2026-08-27', NULL, NULL, 'REJECTED', NULL, NULL, '2026-08-08 02:25:11'),
(12, 'citizen1', NULL, 'Education', 'Boakye', 'osei', 'Samuel', 'Male', '2026-08-03', 'Divorced', 'kumasi', 'Ghanaian', '', '', 'AK-542-365', '', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-08-05', 'KUMASI', 'G545368', '2026-08-13', '2026-09-03', NULL, NULL, 'Pending Approval', NULL, NULL, '2026-08-12 13:43:43'),
(13, 'citizen1', NULL, 'Visa / Immigration / Travel Application', 'Boakye', 'osei', 'Samuel', 'Male', '2026-07-30', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-08-13', 'KUMASI', 'G545368', '2026-08-27', '2026-08-07', NULL, NULL, 'Pending Approval', NULL, NULL, '2026-08-15 01:05:36'),
(14, 'citizen1', NULL, 'Employment', 'Boakye', 'osei', 'Samuel', 'Male', '2026-08-05', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-08-07', 'KUMASI', 'G545368', '2026-08-05', '2026-08-28', '~/Uploads/PassportPhotos/3bc50a68-783c-46ce-b91c-0bc14f5e3e4b.jpg', '~/Uploads/IDDocuments/8c2bbdee-206b-4729-8723-218411937ad8.jpg', 'Pending Approval', NULL, NULL, '2026-08-15 01:58:08'),
(15, 'citizen1', NULL, 'Education', 'Boakye', 'osei', 'Samuel', 'Male', '2026-07-26', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-29', '2026-08-07', 'G545368', '2026-08-11', '2026-09-03', '~/Uploads/PassportPhotos/4bc5c0af-76cf-4daa-89b7-85c3c4381335.jpg', '~/Uploads/IDDocuments/1411ad5c-d2ca-497f-951c-7a8b9560d061.jpg', 'Pending Approval', NULL, NULL, '2026-08-15 02:28:59'),
(16, 'citizen001', NULL, 'Employment', 'Osei', 'Boakye', 'Samuel', 'Male', '2026-07-28', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', NULL, 'GHA-004222622-6', '2026-07-30', '2026-07-29', 'G545368', '2026-08-06', '2026-08-26', '~/Uploads/PassportPhotos/10c6d219-7d9f-4415-af4a-aa6cd2d1b2e6.jpg', '~/Uploads/IDDocuments/f63e4bf2-9fb5-4ce4-8c43-1a2ab6e24808.jpg', 'Pending Approval', NULL, NULL, '2026-08-23 02:56:33'),
(17, 'citizen001', NULL, 'Employment', 'Osei', 'Boakye', 'Samuel', 'Male', '2026-07-27', 'Single', 'kumasi', 'Ghanaian', 'kumasi', 'kumasi', 'AK-542-365', 'P.O.BOX KJ122', 'samuel.booakye@gmail.com', '0249550587', 'STUDENT', 'Ghana Card', 'GHA-004222622-6', '2026-08-04', 'KUMASI', 'G545368', '2026-08-11', '2026-09-03', '~/Uploads/PassportPhotos/a38944c7-8533-4ab6-be11-6bffe5684b30.jpg', NULL, 'REJECTED', 'officer1', NULL, '2026-08-23 03:29:30');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `account_audit_logs`
--
ALTER TABLE `account_audit_logs`
  ADD PRIMARY KEY (`AuditID`),
  ADD KEY `idx_account_audit_target_date` (`TargetUserID`,`CreatedAt`),
  ADD KEY `idx_account_audit_actor_date` (`ActorUserID`,`CreatedAt`),
  ADD KEY `idx_account_audit_action_date` (`ActionType`,`CreatedAt`);

--
-- Indexes for table `applications`
--
ALTER TABLE `applications`
  ADD PRIMARY KEY (`ApplicationID`),
  ADD KEY `idx_pbcs_application_priority` (`Priority`);

--
-- Indexes for table `application_assignments`
--
ALTER TABLE `application_assignments`
  ADD PRIMARY KEY (`AssignmentID`),
  ADD UNIQUE KEY `ux_pbcs_active_assignment` (`ActiveApplicationID`),
  ADD KEY `idx_pbcs_assignment_officer` (`OfficerUserID`,`UnassignedAt`),
  ADD KEY `idx_pbcs_assignment_application` (`ApplicationID`,`AssignedAt`),
  ADD KEY `fk_pbcs_assignment_admin` (`AssignedByUserID`),
  ADD KEY `fk_pbcs_assignment_ended_by` (`UnassignedByUserID`);

--
-- Indexes for table `application_workflow_history`
--
ALTER TABLE `application_workflow_history`
  ADD PRIMARY KEY (`WorkflowID`),
  ADD KEY `idx_pbcs_workflow_application` (`ApplicationID`,`ActionAt`,`WorkflowID`),
  ADD KEY `idx_pbcs_workflow_actor` (`ActionByUserID`,`ActionAt`),
  ADD KEY `idx_pbcs_workflow_date` (`ActionAt`);

--
-- Indexes for table `certificates`
--
ALTER TABLE `certificates`
  ADD PRIMARY KEY (`CertificateID`),
  ADD UNIQUE KEY `UQ_CertificateReference` (`CertificateReference`),
  ADD UNIQUE KEY `UQ_CertificateApplication` (`ApplicationReference`);

--
-- Indexes for table `ghana_card_registry`
--
ALTER TABLE `ghana_card_registry`
  ADD PRIMARY KEY (`registry_id`),
  ADD UNIQUE KEY `uq_ghana_card_number` (`ghana_card_number`);

--
-- Indexes for table `identity_document_reviews`
--
ALTER TABLE `identity_document_reviews`
  ADD PRIMARY KEY (`ReviewID`),
  ADD KEY `IX_identity_document_reviews_latest` (`ApplicationReference`,`DocumentType`,`ReviewID`),
  ADD KEY `IX_identity_document_reviews_decision` (`Decision`,`ReviewedAt`),
  ADD KEY `IX_identity_document_reviews_reviewer` (`ReviewerUserID`,`ReviewedAt`);

--
-- Indexes for table `identity_verifications`
--
ALTER TABLE `identity_verifications`
  ADD PRIMARY KEY (`VerificationID`),
  ADD KEY `IX_ApplicationReference` (`ApplicationReference`);

--
-- Indexes for table `nationalregistry`
--
ALTER TABLE `nationalregistry`
  ADD PRIMARY KEY (`RegistryID`),
  ADD UNIQUE KEY `GhanaCardPIN` (`GhanaCardPIN`);

--
-- Indexes for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  ADD PRIMARY KEY (`ResetRequestID`),
  ADD KEY `idx_reset_user_status` (`UserID`,`Status`),
  ADD KEY `idx_reset_status_requested` (`Status`,`RequestedAt`),
  ADD KEY `idx_reset_token_hash` (`ResetTokenHash`),
  ADD KEY `idx_reset_processed_by` (`ProcessedBy`),
  ADD KEY `IX_password_reset_requests_user_time` (`UserID`,`RequestedAt`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`PaymentID`),
  ADD UNIQUE KEY `TransactionID` (`TransactionID`),
  ADD KEY `ApplicationID` (`ApplicationID`);

--
-- Indexes for table `sms_delivery_logs`
--
ALTER TABLE `sms_delivery_logs`
  ADD PRIMARY KEY (`SmsLogID`),
  ADD UNIQUE KEY `ux_pbcs_sms_reference` (`MessageReference`),
  ADD UNIQUE KEY `ux_pbcs_sms_provider_id` (`ProviderMessageID`),
  ADD KEY `idx_pbcs_sms_status_date` (`Status`,`CreatedAt`),
  ADD KEY `idx_pbcs_sms_application` (`ApplicationID`),
  ADD KEY `fk_pbcs_sms_user` (`UserID`);

--
-- Indexes for table `system_users`
--
ALTER TABLE `system_users`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `Username` (`Username`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `ux_pbcs_staff_number` (`StaffNumber`),
  ADD KEY `idx_users_active_locked` (`IsActive`,`LockedUntil`);

--
-- Indexes for table `verification_log`
--
ALTER TABLE `verification_log`
  ADD PRIMARY KEY (`LogID`),
  ADD KEY `idx_application` (`ApplicationID`);

--
-- Indexes for table `vetting_applications`
--
ALTER TABLE `vetting_applications`
  ADD PRIMARY KEY (`ApplicationID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `account_audit_logs`
--
ALTER TABLE `account_audit_logs`
  MODIFY `AuditID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `applications`
--
ALTER TABLE `applications`
  MODIFY `ApplicationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `application_assignments`
--
ALTER TABLE `application_assignments`
  MODIFY `AssignmentID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `application_workflow_history`
--
ALTER TABLE `application_workflow_history`
  MODIFY `WorkflowID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `certificates`
--
ALTER TABLE `certificates`
  MODIFY `CertificateID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ghana_card_registry`
--
ALTER TABLE `ghana_card_registry`
  MODIFY `registry_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `identity_document_reviews`
--
ALTER TABLE `identity_document_reviews`
  MODIFY `ReviewID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `identity_verifications`
--
ALTER TABLE `identity_verifications`
  MODIFY `VerificationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `nationalregistry`
--
ALTER TABLE `nationalregistry`
  MODIFY `RegistryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  MODIFY `ResetRequestID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `PaymentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `sms_delivery_logs`
--
ALTER TABLE `sms_delivery_logs`
  MODIFY `SmsLogID` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_users`
--
ALTER TABLE `system_users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `verification_log`
--
ALTER TABLE `verification_log`
  MODIFY `LogID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `vetting_applications`
--
ALTER TABLE `vetting_applications`
  MODIFY `ApplicationID` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `application_assignments`
--
ALTER TABLE `application_assignments`
  ADD CONSTRAINT `fk_pbcs_assignment_admin` FOREIGN KEY (`AssignedByUserID`) REFERENCES `users` (`UserID`),
  ADD CONSTRAINT `fk_pbcs_assignment_application` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`),
  ADD CONSTRAINT `fk_pbcs_assignment_ended_by` FOREIGN KEY (`UnassignedByUserID`) REFERENCES `users` (`UserID`),
  ADD CONSTRAINT `fk_pbcs_assignment_officer` FOREIGN KEY (`OfficerUserID`) REFERENCES `users` (`UserID`);

--
-- Constraints for table `application_workflow_history`
--
ALTER TABLE `application_workflow_history`
  ADD CONSTRAINT `fk_pbcs_workflow_actor` FOREIGN KEY (`ActionByUserID`) REFERENCES `users` (`UserID`),
  ADD CONSTRAINT `fk_pbcs_workflow_application` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ID`) ON DELETE CASCADE;

--
-- Constraints for table `sms_delivery_logs`
--
ALTER TABLE `sms_delivery_logs`
  ADD CONSTRAINT `fk_pbcs_sms_application` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`),
  ADD CONSTRAINT `fk_pbcs_sms_user` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
