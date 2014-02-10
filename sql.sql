-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.6.11 - MySQL Community Server (GPL)
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


-- Dumping structure for table reputation.actions
CREATE TABLE IF NOT EXISTS `actions` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Category` int(11) unsigned NOT NULL DEFAULT '0',
  `Name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`),
  KEY `Action Category` (`Category`),
  CONSTRAINT `Action?Category` FOREIGN KEY (`Category`) REFERENCES `categories` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actions: ~15 rows (approximately)
/*!40000 ALTER TABLE `actions` DISABLE KEYS */;
INSERT INTO `actions` (`ID`, `Category`, `Name`) VALUES
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
	(15, 5, 'Private Share');
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;


-- Dumping structure for table reputation.activities
CREATE TABLE IF NOT EXISTS `activities` (
  `Key` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `User` int(11) unsigned NOT NULL,
  `Action` int(11) unsigned NOT NULL,
  `Tag` int(11) unsigned NOT NULL,
  `Reference` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Key`),
  KEY `Actions` (`Action`),
  KEY `User` (`User`),
  KEY `Tags` (`Tag`),
  CONSTRAINT `Actions` FOREIGN KEY (`Action`) REFERENCES `actions` (`ID`),
  CONSTRAINT `Tags` FOREIGN KEY (`Tag`) REFERENCES `tags` (`ID`),
  CONSTRAINT `Users` FOREIGN KEY (`User`) REFERENCES `users` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.activities: ~4 rows (approximately)
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
INSERT INTO `activities` (`Key`, `User`, `Action`, `Tag`, `Reference`, `Date`) VALUES
	(1, 1, 2, 1, '', '2014-02-04 11:16:52'),
	(2, 1, 5, 1, '', '2014-02-04 11:17:35'),
	(3, 1, 9, 3, '', '2014-02-07 14:56:04'),
	(4, 1, 4, 5, '', '2014-02-07 15:35:23');
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;


-- Dumping structure for table reputation.categories
CREATE TABLE IF NOT EXISTS `categories` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.categories: ~7 rows (approximately)
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` (`ID`, `Name`) VALUES
	(1, 'Collect'),
	(2, 'Relate'),
	(3, 'Create - Generative'),
	(4, 'Create - Evaluative'),
	(5, 'Donate'),
	(6, 'Reflect'),
	(7, 'Observe');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;


-- Dumping structure for table reputation.tags
CREATE TABLE IF NOT EXISTS `tags` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.tags: ~5 rows (approximately)
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` (`ID`, `Name`) VALUES
	(1, 'Database'),
	(4, 'Design'),
	(2, 'Elastic Cloud Computing'),
	(5, 'node.js'),
	(3, 'UX');
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;


-- Dumping structure for table reputation.users
CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `UUID` char(36) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UUID` (`UUID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.users: ~3 rows (approximately)
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`ID`, `UUID`) VALUES
	(2, '1C5D2E42-5C13-458B-AA5C-50A85B471F9'),
	(3, '31F2E6D0-A822-4B80-BDA6-9FFD4F09CED5'),
	(1, '4FA06769-C5C7-432B-9E37-4A3E7B4D294D');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
