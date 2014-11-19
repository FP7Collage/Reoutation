-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.32 - MySQL Community Server (GPL)
-- Server OS:                    Win32
-- HeidiSQL Version:             8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping database structure for reputation
CREATE DATABASE IF NOT EXISTS `reputation` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `reputation`;


-- Dumping structure for table reputation.actionmap
DROP TABLE IF EXISTS `actionmap`;
CREATE TABLE IF NOT EXISTS `actionmap` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Action` int(11) unsigned NOT NULL,
  `Name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`),
  KEY `FK__actions_map` (`Action`),
  CONSTRAINT `FK__actions_map` FOREIGN KEY (`Action`) REFERENCES `actions` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actionmap: ~7 rows (approximately)
DELETE FROM `actionmap`;
/*!40000 ALTER TABLE `actionmap` DISABLE KEYS */;
INSERT INTO `actionmap` (`ID`, `Action`, `Name`) VALUES
	(1, 5, 'text'),
	(2, 6, 'image'),
	(3, 8, 'video'),
	(5, 7, 'audio'),
	(6, 14, 'link'),
	(7, 9, 'approve'),
	(8, 10, 'comment');
/*!40000 ALTER TABLE `actionmap` ENABLE KEYS */;


-- Dumping structure for table reputation.actions
DROP TABLE IF EXISTS `actions`;
CREATE TABLE IF NOT EXISTS `actions` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ActionType` int(11) unsigned NOT NULL DEFAULT '0',
  `Name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`),
  KEY `Action Category` (`ActionType`),
  CONSTRAINT `Action?Category` FOREIGN KEY (`ActionType`) REFERENCES `actiontypes` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actions: ~18 rows (approximately)
DELETE FROM `actions`;
/*!40000 ALTER TABLE `actions` DISABLE KEYS */;
INSERT INTO `actions` (`ID`, `ActionType`, `Name`) VALUES
	(1, 1, 'Listen'),
	(2, 1, 'Read'),
	(3, 1, 'Watch'),
	(4, 2, 'Tag'),
	(5, 3, 'Write'),
	(6, 3, 'Draw'),
	(7, 3, 'Record Audio'),
	(8, 3, 'Record Video'),
	(9, 4, 'Rate'),
	(10, 4, 'Comment'),
	(11, 4, 'Review'),
	(12, 5, 'Gift'),
	(13, 5, 'Assign'),
	(14, 5, 'Broadcast'),
	(15, 5, 'Private Share'),
	(16, 6, 'goal_complete'),
	(17, 6, 'comment_goal_complete'),
	(18, 6, 'team_goal_complete');
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;


-- Dumping structure for table reputation.actiontypes
DROP TABLE IF EXISTS `actiontypes`;
CREATE TABLE IF NOT EXISTS `actiontypes` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actiontypes: ~7 rows (approximately)
DELETE FROM `actiontypes`;
/*!40000 ALTER TABLE `actiontypes` DISABLE KEYS */;
INSERT INTO `actiontypes` (`ID`, `Name`) VALUES
	(1, 'Collect'),
	(2, 'Relate'),
	(3, 'Create - Generative'),
	(4, 'Create - Evaluative'),
	(5, 'Donate'),
	(6, 'Reflect'),
	(7, 'Observe');
/*!40000 ALTER TABLE `actiontypes` ENABLE KEYS */;


-- Dumping structure for table reputation.activities
DROP TABLE IF EXISTS `activities`;
CREATE TABLE IF NOT EXISTS `activities` (
  `Key` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Project` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `User` int(11) unsigned NOT NULL,
  `Action` int(11) unsigned NOT NULL,
  `Skill` int(11) unsigned NOT NULL,
  `Reference` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Key`),
  KEY `Actions` (`Action`),
  KEY `User` (`User`),
  KEY `Tags` (`Skill`),
  CONSTRAINT `Actions to activities` FOREIGN KEY (`Action`) REFERENCES `actions` (`ID`),
  CONSTRAINT `Skills to activities` FOREIGN KEY (`Skill`) REFERENCES `skills` (`ID`),
  CONSTRAINT `Users to activities` FOREIGN KEY (`User`) REFERENCES `users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.activities: ~0 rows (approximately)
DELETE FROM `activities`;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;


-- Dumping structure for table reputation.allactivities
DROP TABLE IF EXISTS `allactivities`;
CREATE TABLE IF NOT EXISTS `allactivities` (
  `Key` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Project` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `User` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Action` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Skill` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Reference` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Blob` text COLLATE utf8_unicode_ci,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.allactivities: ~0 rows (approximately)
DELETE FROM `allactivities`;
/*!40000 ALTER TABLE `allactivities` DISABLE KEYS */;
/*!40000 ALTER TABLE `allactivities` ENABLE KEYS */;


-- Dumping structure for table reputation.projectskills
DROP TABLE IF EXISTS `projectskills`;
CREATE TABLE IF NOT EXISTS `projectskills` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Project` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Skill` int(11) unsigned NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Project_Skill` (`Project`,`Skill`),
  KEY `Skill` (`Skill`),
  CONSTRAINT `FK_projectSkills_skills` FOREIGN KEY (`Skill`) REFERENCES `skills` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.projectskills: ~0 rows (approximately)
DELETE FROM `projectskills`;
/*!40000 ALTER TABLE `projectskills` DISABLE KEYS */;
/*!40000 ALTER TABLE `projectskills` ENABLE KEYS */;


-- Dumping structure for table reputation.skills
DROP TABLE IF EXISTS `skills`;
CREATE TABLE IF NOT EXISTS `skills` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.skills: ~0 rows (approximately)
DELETE FROM `skills`;
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;


-- Dumping structure for table reputation.users
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `UUID` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UUID` (`UUID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.users: ~0 rows (approximately)
DELETE FROM `users`;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
