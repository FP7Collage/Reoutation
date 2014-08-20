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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actionmap: ~6 rows (approximately)
/*!40000 ALTER TABLE `actionmap` DISABLE KEYS */;
INSERT INTO `actionmap` (`ID`, `Action`, `Name`) VALUES
	(1, 5, 'Text'),
	(2, 6, 'Image'),
	(3, 8, 'Video'),
	(5, 7, 'Audio'),
	(6, 14, 'Link'),
  (7, 9, 'approve');
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actions: ~16 rows (approximately)
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
  (17, 6, 'comment_goal_complete');
  (18, 6, 'team_goal_complete'),
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;


-- Dumping structure for table reputation.actiontypes
DROP TABLE IF EXISTS `actiontypes`;
CREATE TABLE IF NOT EXISTS `actiontypes` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actiontypes: ~7 rows (approximately)
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
/*!40000 ALTER TABLE `allactivities` DISABLE KEYS */;
/*!40000 ALTER TABLE `allactivities` ENABLE KEYS */;


-- Dumping structure for table reputation.goalupdates
DROP TABLE IF EXISTS `goalupdates`;
CREATE TABLE IF NOT EXISTS `goalupdates` (
  `Key` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `User` int(10) unsigned NOT NULL DEFAULT '0',
  `Status` enum('ACCEPT','DECLINE','VIEW INFO','PROGRESS','COMPLETE','TIME OUT','GIVE UP') COLLATE utf8_unicode_ci NOT NULL COMMENT 'The thing what they do',
  `QuestID` int(10) unsigned NOT NULL,
  `Reference` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Key`),
  KEY `goalUpdate to user` (`User`),
  CONSTRAINT `goalUpdate to user` FOREIGN KEY (`User`) REFERENCES `users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='When the user does a thing';

-- Dumping data for table reputation.goalupdates: ~0 rows (approximately)
/*!40000 ALTER TABLE `goalupdates` DISABLE KEYS */;
/*!40000 ALTER TABLE `goalupdates` ENABLE KEYS */;


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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.projectskills: ~3 rows (approximately)
/*!40000 ALTER TABLE `projectskills` DISABLE KEYS */;
INSERT INTO `projectskills` (`ID`, `Project`, `Skill`) VALUES
	(1, NULL, 1),
	(2, NULL, 2),
	(3, NULL, 3);
/*!40000 ALTER TABLE `projectskills` ENABLE KEYS */;


-- Dumping structure for table reputation.skills
DROP TABLE IF EXISTS `skills`;
CREATE TABLE IF NOT EXISTS `skills` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.skills: ~3 rows (approximately)
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
INSERT INTO `skills` (`ID`, `Name`) VALUES
	(1, 'explorative workshops'),
	(3, 'open materials'),
	(2, 'sustainable resources');
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;


-- Dumping structure for table reputation.userpreferences
DROP TABLE IF EXISTS `userpreferences`;
CREATE TABLE IF NOT EXISTS `userpreferences` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `User` int(10) unsigned NOT NULL,
  `Action` int(10) unsigned NOT NULL,
  `Skill` int(10) unsigned NOT NULL,
  `Feedback` enum('Y','N') COLLATE utf8_unicode_ci NOT NULL,
  `Level` enum('goal','action') COLLATE utf8_unicode_ci NOT NULL,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `Preferences - User` (`User`),
  KEY `Preferences - Action` (`Action`),
  KEY `Preferences - Skill` (`Skill`),
  CONSTRAINT `Preferences - Action` FOREIGN KEY (`Action`) REFERENCES `actions` (`ID`),
  CONSTRAINT `Preferences - Skill` FOREIGN KEY (`Skill`) REFERENCES `skills` (`ID`),
  CONSTRAINT `Preferences - User` FOREIGN KEY (`User`) REFERENCES `users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.userpreferences: ~0 rows (approximately)
/*!40000 ALTER TABLE `userpreferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `userpreferences` ENABLE KEYS */;


-- Dumping structure for table reputation.users
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `UUID` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UUID` (`UUID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.users: ~0 rows (approximately)
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;


-- Dumping structure for table reputation.userskills
DROP TABLE IF EXISTS `userskills`;
CREATE TABLE IF NOT EXISTS `userskills` (
  `Key` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `User` int(10) unsigned NOT NULL,
  `Skill` int(10) unsigned NOT NULL,
  `Action` int(10) unsigned NOT NULL,
  `Time` int(10) unsigned NOT NULL DEFAULT '0',
  `Count` int(10) unsigned NOT NULL DEFAULT '0',
  `Rating` int(10) unsigned NOT NULL DEFAULT '0',
  `PDV` float unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`Key`),
  UNIQUE KEY `Combined index` (`User`,`Skill`,`Action`),
  KEY ` Skills to userSkills` (`Skill`),
  KEY `Actions to userSkills` (`Action`),
  CONSTRAINT ` Skills to userSkills` FOREIGN KEY (`Skill`) REFERENCES `skills` (`ID`),
  CONSTRAINT `Actions to userSkills` FOREIGN KEY (`Action`) REFERENCES `actions` (`ID`),
  CONSTRAINT `Users to userSkills` FOREIGN KEY (`User`) REFERENCES `users` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.userskills: ~0 rows (approximately)
/*!40000 ALTER TABLE `userskills` DISABLE KEYS */;
/*!40000 ALTER TABLE `userskills` ENABLE KEYS */;


-- Dumping structure for table reputation.userstats
DROP TABLE IF EXISTS `userstats`;
CREATE TABLE IF NOT EXISTS `userstats` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `User` int(11) NOT NULL,
  `Count` int(11) NOT NULL,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `User_Date` (`User`,`Date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.userstats: ~0 rows (approximately)
/*!40000 ALTER TABLE `userstats` DISABLE KEYS */;
/*!40000 ALTER TABLE `userstats` ENABLE KEYS */;
