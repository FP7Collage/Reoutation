-- --------------------------------------------------------
-- Host:                         10.0.0.2
-- Server version:               5.5.30-1.1 - (Debian)
-- Server OS:                    debian-linux-gnu
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
  `ActionType` int(11) unsigned NOT NULL DEFAULT '0',
  `Name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`),
  KEY `Action Category` (`ActionType`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actions: ~15 rows (approximately)
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
	(15, 5, 'Private Share');
/*!40000 ALTER TABLE `actions` ENABLE KEYS */;


-- Dumping structure for table reputation.actionTypes
CREATE TABLE IF NOT EXISTS `actionTypes` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actionTypes: ~7 rows (approximately)
/*!40000 ALTER TABLE `actionTypes` DISABLE KEYS */;
INSERT INTO `actionTypes` (`ID`, `Name`) VALUES
	(1, 'Collect'),
	(2, 'Relate'),
	(3, 'Create - Generative'),
	(4, 'Create - Evaluative'),
	(5, 'Donate'),
	(6, 'Reflect'),
	(7, 'Observe');
/*!40000 ALTER TABLE `actionTypes` ENABLE KEYS */;


-- Dumping structure for table reputation.actionMap
DROP TABLE IF EXISTS `actionMap`;
CREATE TABLE IF NOT EXISTS `actionMap` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Action` int(11) unsigned NOT NULL,
  `Name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`),
  KEY `FK__actions_map` (`Action`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.actionMap: ~3 rows (approximately)
/*!40000 ALTER TABLE `actionMap` DISABLE KEYS */;
INSERT INTO `actionMap` (`ID`, `Action`, `Name`) VALUES
	(1, 5, 'Text'),
	(2, 6, 'Image'),
	(3, 8, 'Video'),
	(5, 7, 'Audio'),
	(6, 14, 'Link');
/*!40000 ALTER TABLE `actionMap` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;




-- Dumping structure for table reputation.goalUpdates
CREATE TABLE IF NOT EXISTS `goalUpdates` (
  `Key` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `User` int(10) unsigned NOT NULL DEFAULT '0',
  `Status` enum('ACCEPT','DECLINE','VIEW INFO','PROGRESS','COMPLETE','TIME OUT','GIVE UP') COLLATE utf8_unicode_ci NOT NULL COMMENT 'The thing what they do',
  `QuestID` int(10) unsigned NOT NULL,
  `Reference` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Key`),
  KEY `goalUpdate to user` (`User`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='When the user does a thing';

-- Dumping data for table reputation.goalUpdates: ~0 rows (approximately)
/*!40000 ALTER TABLE `goalUpdates` DISABLE KEYS */;
/*!40000 ALTER TABLE `goalUpdates` ENABLE KEYS */;


-- Dumping structure for table reputation.skills
CREATE TABLE IF NOT EXISTS `skills` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.skills: ~5 rows (approximately)
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
INSERT INTO `skills` (`ID`, `Name`) VALUES
	(1, 'Database'),
	(4, 'Design'),
	(2, 'Elastic Cloud Computing'),
	(5, 'node.js'),
	(3, 'UX');
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;


-- Dumping structure for table reputation.userPreferences
CREATE TABLE IF NOT EXISTS `userPreferences` (
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
  KEY `Preferences - Skill` (`Skill`)


) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping data for table reputation.userPreferences: ~0 rows (approximately)
/*!40000 ALTER TABLE `userPreferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `userPreferences` ENABLE KEYS */;


-- Dumping structure for table reputation.users
CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `UUID` char(36) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UUID` (`UUID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- Dumping structure for table reputation.userSkills
CREATE TABLE IF NOT EXISTS `userSkills` (
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
  KEY `Actions to userSkills` (`Action`)


) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- Dumping structure for table reputation.activities
CREATE TABLE IF NOT EXISTS `activities` (
  `Key` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `User` int(11) unsigned NOT NULL,
  `Action` int(11) unsigned NOT NULL,
  `Skill` int(11) unsigned NOT NULL,
  `Reference` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Key`),
  KEY `Actions` (`Action`),
  KEY `User` (`User`),
  KEY `Tags` (`Skill`)


) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Dumping structure for trigger reputation.activity_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `activity_insert` AFTER INSERT ON `activities` FOR EACH ROW BEGIN
		INSERT INTO userSkills (User, Skill, Action, Count) VALUES (NEW.User, NEW.Skill, NEW.Action, 1) ON DUPLICATE KEY UPDATE Count = Count + 1;
		
		UPDATE userSkills, (
			SELECT User, Action, Skill
			FROM activities
			WHERE Reference = NEW.Reference
				AND User != NEW.User
				AND Action IN (
					SELECT ID
					FROM actions
					WHERE actions.ActionType = 3
				)
				LIMIT 1
			) as referencedRow 
		SET Rating = Rating + 1
		WHERE userSkills.User = referencedRow.User
			AND userSkills.Skill = referencedRow.Skill
			AND userSkills.Action = referencedRow.Action;
		
		UPDATE userSkills, (
			SELECT Skill, Action, AVG(Count) as avgCount, AVG(Rating) as avgRating
			FROM userSkills
			GROUP BY Skill, Action
		) as avg
		SET PDV = (Count/avgCount + IFNULL(Rating/avgRating, 1))
		WHERE userSkills.Skill = avg.Skill
			AND userSkills.Action = avg.Action;
	END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;