-- MySQL dump 10.13  Distrib 8.0.26, for Win64 (x86_64)
--
-- Host: us-cdbr-east-05.cleardb.net    Database: heroku_6e385326a5583be
-- ------------------------------------------------------
-- Server version	8.0.26

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `book`
--

DROP TABLE IF EXISTS `book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book` (
  `isbn` varchar(17) NOT NULL,
  `title` varchar(200) NOT NULL,
  `author` varchar(100) NOT NULL,
  `publisher` varchar(100) DEFAULT NULL,
  `is_audio_book` tinyint(1) NOT NULL,
  `num_pages` int DEFAULT NULL,
  `book_dewey` float NOT NULL,
  PRIMARY KEY (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book`
--

LOCK TABLES `book` WRITE;
/*!40000 ALTER TABLE `book` DISABLE KEYS */;
INSERT INTO `book` VALUES ('385545681','Empire of Pain: The Secret History of the Sackler Dynasty','Patrick Radden Keefe','Random House Audio',1,535,338.7),('978-0-13-294326-0','Database Systems - A Practical Approach to Design, Implementation, and Management','Thomas Connolly and Carolyn Begg','Pearson',0,1442,5.74),('9780140481341','Death of a Salesman','Arthur Miller','Penguin Plays',0,139,812.52),('9780316013550','Little Red Riding Hood','	Brothers Grimm','Little, Brown and Company',0,34,398.2),('9780425120231','Moby Dick','Herman Melville','Berkley Pub Group',0,704,812.54),('9780486808352','A Modern Utopia','H. G. Wells','Chapman and Hall',0,393,321.07),('9780593298145','China Room','Sunjeev Sahota','Penguin Audio',1,243,823.92),('9780841993583','The Man Who Died Twice: A Thursday Murder Club Mystery','Richard Osman','Penguin Audio',1,365,823.92),('9780977716173','Alice\'s Adventures in Wonderland','Lewis Carroll','Macmillan',0,176,823.8),('9781324005797','American Republics: A Continental History of the United States, 1783-1850','Alan Taylor','W. W. Norton & Company ',1,544,973.3),('9781432870126','The Institute','Stephen King','Scribner',0,576,813.54),('9781435171589','Pride and Prejudice','Jane Austen','Barnes & Noble Signature Classics Series',0,384,823.7),('9781612197500','How to do nothing : resisting the attention economy','Jenny Odell','Melville House',0,256,303.48),('9781662065965','Exit','Belinda Bauer','Dreamscape Media, LLC',1,336,823.92),('9781705286647','The Death of the Heart','Elizabeth Bowen','Knopf',1,445,823.912),('9781984830227','Majesty','Katharine McGee','Random House',0,448,813.6),('9783962190019','American Gods','Neil Gaiman','William Morrow, Headline',0,465,813.54);
/*!40000 ALTER TABLE `book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book_inventory`
--

DROP TABLE IF EXISTS `book_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book_inventory` (
  `book_id` int NOT NULL AUTO_INCREMENT,
  `isbn` varchar(17) NOT NULL,
  `loaned_by` int DEFAULT NULL,
  `bookshelf_id` int DEFAULT NULL,
  `checkout_length_days` int DEFAULT NULL,
  `late_fee_per_day` float NOT NULL DEFAULT '0.5',
  PRIMARY KEY (`book_id`),
  KEY `fk_book_isbn` (`isbn`),
  KEY `FK_book_employee` (`loaned_by`),
  KEY `FK_book_bookshelf` (`bookshelf_id`),
  CONSTRAINT `FK_book_bookshelf` FOREIGN KEY (`bookshelf_id`) REFERENCES `bookshelf` (`bookshelf_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_book_employee` FOREIGN KEY (`loaned_by`) REFERENCES `employee` (`employee_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_book_isbn` FOREIGN KEY (`isbn`) REFERENCES `book` (`isbn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book_inventory`
--

LOCK TABLES `book_inventory` WRITE;
/*!40000 ALTER TABLE `book_inventory` DISABLE KEYS */;
INSERT INTO `book_inventory` VALUES (1,'978-0-13-294326-0',NULL,1,2,10),(2,'9780425120231',NULL,2,10,0.3),(3,'9780425120231',NULL,2,21,0.3),(4,'9780425120231',NULL,7,9,0.3),(5,'9780425120231',NULL,20,14,0.3),(6,'9781432870126',NULL,7,14,0.5),(7,'9781612197500',NULL,9,20,0.05),(8,'9781984830227',NULL,13,7,0.2),(9,'9781435171589',NULL,15,16,0.12),(10,'9780316013550',NULL,14,8,0.1),(11,'9780486808352',NULL,17,14,0.1),(12,'9781324005797',NULL,2,12,0.15),(13,'9780593298145',NULL,7,7,0.2),(14,'9781705286647',NULL,11,15,0.05),(15,'385545681',NULL,12,14,0.03),(16,'9781662065965',NULL,15,11,0.2),(17,'9780841993583',NULL,20,14,0.06),(18,'9780977716173',NULL,11,14,0.03),(19,'9783962190019',NULL,11,14,0.09),(20,'9780140481341',NULL,13,21,0.06);
/*!40000 ALTER TABLE `book_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookcase`
--

DROP TABLE IF EXISTS `bookcase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookcase` (
  `bookcase_id` int NOT NULL AUTO_INCREMENT,
  `bookcase_local_num` int NOT NULL,
  `dewey_max` float NOT NULL,
  `dewey_min` float NOT NULL,
  `library_id` int DEFAULT NULL,
  PRIMARY KEY (`bookcase_id`),
  KEY `FK_bookcase_lib` (`library_id`),
  CONSTRAINT `FK_bookcase_lib` FOREIGN KEY (`library_id`) REFERENCES `library` (`library_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookcase`
--

LOCK TABLES `bookcase` WRITE;
/*!40000 ALTER TABLE `bookcase` DISABLE KEYS */;
INSERT INTO `bookcase` VALUES (1,1,999,0,1),(2,1,499,0,2),(3,2,999,500,2),(4,1,999,0,3),(5,1,999,0,4),(6,1,999,0,5),(7,1,499,0,6),(8,2,999,500,6);
/*!40000 ALTER TABLE `bookcase` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookshelf`
--

DROP TABLE IF EXISTS `bookshelf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookshelf` (
  `bookshelf_id` int NOT NULL AUTO_INCREMENT,
  `dewey_max` float NOT NULL,
  `dewey_min` float NOT NULL,
  `bookshelf_local_num` int DEFAULT NULL,
  `bookcase_id` int DEFAULT NULL,
  PRIMARY KEY (`bookshelf_id`),
  KEY `FK_bookshelf_bookcase` (`bookcase_id`),
  CONSTRAINT `FK_bookshelf_bookcase` FOREIGN KEY (`bookcase_id`) REFERENCES `bookcase` (`bookcase_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookshelf`
--

LOCK TABLES `bookshelf` WRITE;
/*!40000 ALTER TABLE `bookshelf` DISABLE KEYS */;
INSERT INTO `bookshelf` VALUES (1,499,0,1,1),(2,999,500,2,1),(3,299,0,3,2),(4,399,300,4,2),(5,499,400,5,2),(6,750,500,6,3),(7,999,751,7,3),(8,199,0,8,4),(9,399,200,9,4),(10,599,400,10,4),(11,999,600,11,4),(12,499,0,12,5),(13,999,500,13,5),(14,599,0,14,6),(15,999,600,15,6),(16,99,0,16,7),(17,399,100,17,7),(18,499,400,18,7),(19,639,500,19,8),(20,999,640,20,8);
/*!40000 ALTER TABLE `bookshelf` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `checked_out_books`
--

DROP TABLE IF EXISTS `checked_out_books`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `checked_out_books` (
  `user_id` int NOT NULL,
  `book_id` int NOT NULL,
  `checkout_date` datetime NOT NULL,
  `due_date` datetime NOT NULL,
  KEY `FK_checked_out_user` (`user_id`),
  KEY `FK_checked_out_book` (`book_id`),
  CONSTRAINT `FK_checked_out_book` FOREIGN KEY (`book_id`) REFERENCES `book_inventory` (`book_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_checked_out_user` FOREIGN KEY (`user_id`) REFERENCES `lib_user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `checked_out_books`
--

LOCK TABLES `checked_out_books` WRITE;
/*!40000 ALTER TABLE `checked_out_books` DISABLE KEYS */;
INSERT INTO `checked_out_books` VALUES (1,2,'2022-01-28 04:02:23','2022-02-07 04:02:23'),(1,4,'2022-01-28 04:02:23','2022-02-06 04:02:23'),(7,13,'2022-01-28 04:02:23','2022-02-04 04:02:23');
/*!40000 ALTER TABLE `checked_out_books` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `employee_id` int NOT NULL AUTO_INCREMENT,
  `hire_date` date DEFAULT NULL,
  `salary` float DEFAULT NULL,
  `job_role` varchar(200) DEFAULT NULL,
  `is_approved` tinyint(1) DEFAULT '0',
  `user_id` int DEFAULT NULL,
  `library_id` int DEFAULT NULL,
  PRIMARY KEY (`employee_id`),
  KEY `FK_employee_user` (`user_id`),
  KEY `FK_employee_lib` (`library_id`),
  CONSTRAINT `FK_employee_lib` FOREIGN KEY (`library_id`) REFERENCES `library` (`library_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_employee_user` FOREIGN KEY (`user_id`) REFERENCES `lib_user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (1,'2022-01-28',60000,'Manages the Charlestown library. Can add new books to the catalog.',1,1,1),(2,'2022-01-28',55000,'Manages the Plymouth Public library. Can add new books to the catalog.',1,2,4),(3,'2022-01-28',70000,'Manages the Cambridge Public library. Can add new books to the catalog.',1,3,6),(4,'2022-01-28',65300,'Manages the Central Library in Copley Square. Can add new books to the catalog.',1,4,2),(5,'2022-01-28',59870,'Manages the Jamaica Plain Library. Can add new books to the catalog.',1,5,3),(6,'2022-01-28',53240,'Manages the Kingston Plain Library. Can add new books to the catalog.',1,6,5);
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `holds`
--

DROP TABLE IF EXISTS `holds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `holds` (
  `hold_id` int NOT NULL AUTO_INCREMENT,
  `isbn` varchar(17) NOT NULL,
  `user_id` int NOT NULL,
  `lib_sys_id` int NOT NULL,
  `library_id` int NOT NULL,
  `hold_start_date` datetime NOT NULL,
  PRIMARY KEY (`hold_id`),
  KEY `FK_hold_isbn` (`isbn`),
  KEY `FK_hold_user` (`user_id`),
  KEY `FK_hold_lib_sys` (`lib_sys_id`),
  KEY `FK_hold_lib` (`library_id`),
  CONSTRAINT `FK_hold_isbn` FOREIGN KEY (`isbn`) REFERENCES `book` (`isbn`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_hold_lib` FOREIGN KEY (`library_id`) REFERENCES `library` (`library_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_hold_lib_sys` FOREIGN KEY (`lib_sys_id`) REFERENCES `library_system` (`library_sys_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_hold_user` FOREIGN KEY (`user_id`) REFERENCES `lib_user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `holds`
--

LOCK TABLES `holds` WRITE;
/*!40000 ALTER TABLE `holds` DISABLE KEYS */;
INSERT INTO `holds` VALUES (1,'9780593298145',1,1,2,'2022-01-28 04:02:23');
/*!40000 ALTER TABLE `holds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lib_cards`
--

DROP TABLE IF EXISTS `lib_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lib_cards` (
  `lib_card_id` int NOT NULL AUTO_INCREMENT,
  `lib_card_num` int NOT NULL,
  PRIMARY KEY (`lib_card_id`),
  UNIQUE KEY `lib_card_num` (`lib_card_num`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lib_cards`
--

LOCK TABLES `lib_cards` WRITE;
/*!40000 ALTER TABLE `lib_cards` DISABLE KEYS */;
INSERT INTO `lib_cards` VALUES (1,0),(2,1),(3,2),(4,3),(5,4),(6,5),(7,6);
/*!40000 ALTER TABLE `lib_cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lib_user`
--

DROP TABLE IF EXISTS `lib_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lib_user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `lib_card_id` int NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `dob` date NOT NULL,
  `num_borrowed` int DEFAULT NULL,
  `is_employee` tinyint(1) DEFAULT '0',
  `username` varchar(50) NOT NULL,
  `lib_password` varchar(50) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  KEY `lib_card_id_fk` (`lib_card_id`),
  CONSTRAINT `lib_card_id_fk` FOREIGN KEY (`lib_card_id`) REFERENCES `lib_cards` (`lib_card_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lib_user`
--

LOCK TABLES `lib_user` WRITE;
/*!40000 ALTER TABLE `lib_user` DISABLE KEYS */;
INSERT INTO `lib_user` VALUES (1,1,'nick','rizzo','2022-01-28',0,1,'nickrizzo','9003d1df22eb4d3820015070385194c8'),(2,2,'Matt','Rizzo','2022-01-28',0,1,'mattrizzo','9003d1df22eb4d3820015070385194c8'),(3,3,'Domenic','Privitera','2022-01-28',0,1,'dompriv','9003d1df22eb4d3820015070385194c8'),(4,4,'Central','Emp','2022-01-28',0,1,'central_employee','6b7d2ef8406243e2c79b44b86831e3ce'),(5,5,'Jamaica','Emp','2022-01-28',0,1,'jamaica_employee','e17b51443cb9962a72eeae11002b2ee5'),(6,6,'Kingston','Emp','2022-01-28',0,1,'kingston_employee','97540aa7e34407c6dced053e6f3516dd'),(7,7,'fname','lname','2022-01-28',0,1,'holdacct','9003d1df22eb4d3820015070385194c8');
/*!40000 ALTER TABLE `lib_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library`
--

DROP TABLE IF EXISTS `library`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library` (
  `library_id` int NOT NULL AUTO_INCREMENT,
  `library_system` int NOT NULL,
  `library_name` varchar(100) NOT NULL,
  `address` varchar(100) DEFAULT NULL,
  `start_time_of_operation` time DEFAULT NULL,
  `end_time_of_operation` time DEFAULT NULL,
  `max_concurrently_borrowed` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`library_id`),
  KEY `FK_lib_system` (`library_system`),
  CONSTRAINT `FK_lib_system` FOREIGN KEY (`library_system`) REFERENCES `library_system` (`library_sys_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library`
--

LOCK TABLES `library` WRITE;
/*!40000 ALTER TABLE `library` DISABLE KEYS */;
INSERT INTO `library` VALUES (1,1,'Charlestown','179 Main St Charlestown, MA 02129','10:00:00','18:00:00',5),(2,1,'Central Library in Copley Square','700 Boylston Street Boston, MA 02116','10:00:00','20:00:00',5),(3,1,'Jamaica Plain','30 South Street Jamaica Plain, MA 02130','10:00:00','18:00:00',5),(4,2,'Plymouth Public Library','132 South Street Plymouth, MA 02360','10:00:00','21:00:00',8),(5,2,'Kingston Public Library','6 Green Street Kingston, MA 02364','10:00:00','17:00:00',4),(6,3,'Cambridge Public Library','449 Broadway Cambridge, MA 02138','10:00:00','21:00:00',4);
/*!40000 ALTER TABLE `library` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `library_system`
--

DROP TABLE IF EXISTS `library_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `library_system` (
  `library_sys_id` int NOT NULL AUTO_INCREMENT,
  `library_sys_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`library_sys_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `library_system`
--

LOCK TABLES `library_system` WRITE;
/*!40000 ALTER TABLE `library_system` DISABLE KEYS */;
INSERT INTO `library_system` VALUES (1,'Metro Boston Library Network'),(2,'Old Colony Library Network'),(3,'Minuteman Library Network');
/*!40000 ALTER TABLE `library_system` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_hist`
--

DROP TABLE IF EXISTS `user_hist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_hist` (
  `loan_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `book_borrowed` int NOT NULL,
  `library_id` int NOT NULL,
  `date_borrowed` datetime NOT NULL,
  `date_returned` datetime DEFAULT NULL,
  PRIMARY KEY (`loan_id`),
  KEY `FK_hist_user` (`user_id`),
  KEY `FK_hist_book` (`book_borrowed`),
  KEY `FK_hist_library` (`library_id`),
  CONSTRAINT `FK_hist_book` FOREIGN KEY (`book_borrowed`) REFERENCES `book_inventory` (`book_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_hist_library` FOREIGN KEY (`library_id`) REFERENCES `library` (`library_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_hist_user` FOREIGN KEY (`user_id`) REFERENCES `lib_user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_hist`
--

LOCK TABLES `user_hist` WRITE;
/*!40000 ALTER TABLE `user_hist` DISABLE KEYS */;
INSERT INTO `user_hist` VALUES (1,1,2,1,'2022-01-28 04:02:23',NULL),(2,1,4,2,'2022-01-28 04:02:23',NULL),(3,7,13,2,'2022-01-28 04:02:23',NULL);
/*!40000 ALTER TABLE `user_hist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_register`
--

DROP TABLE IF EXISTS `user_register`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_register` (
  `user_id` int NOT NULL,
  `library_id` int NOT NULL,
  KEY `FK_register_user` (`user_id`),
  KEY `FK_register_library` (`library_id`),
  CONSTRAINT `FK_register_library` FOREIGN KEY (`library_id`) REFERENCES `library` (`library_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_register_user` FOREIGN KEY (`user_id`) REFERENCES `lib_user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_register`
--

LOCK TABLES `user_register` WRITE;
/*!40000 ALTER TABLE `user_register` DISABLE KEYS */;
INSERT INTO `user_register` VALUES (1,1),(2,4),(3,6),(4,2),(5,3),(6,5),(7,1);
/*!40000 ALTER TABLE `user_register` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'heroku_6e385326a5583be'
--

--
-- Dumping routines for database 'heroku_6e385326a5583be'
--
/*!50003 DROP FUNCTION IF EXISTS `get_bookshelf_from_dewey` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_bookshelf_from_dewey`(in_dewey_num FLOAT, in_lib_id INT) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE correct_case_id INT;
    DECLARE shelf_id_for_dewey INT;
    -- Get the bookcase in the library that fits the dewey number
    SELECT bookcase_id INTO correct_case_id
        FROM bookcase
        WHERE library_id = in_lib_id
            AND in_dewey_num >= dewey_min
            AND in_dewey_num <= dewey_max;

    -- Get the specific shelf within that case that works for the given dewey number
    SELECT bookshelf_id INTO shelf_id_for_dewey
        FROM bookshelf
        WHERE bookcase_id = correct_case_id
            AND in_dewey_num >= dewey_min
            AND in_dewey_num <= dewey_max
        -- Put it in the lowest possible shelf
        ORDER BY bookcase_id ASC
        LIMIT 1;

    return (shelf_id_for_dewey);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_card_num_by_username` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_card_num_by_username`(username_p VARCHAR(50)) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
 DECLARE lib_card_num_out INT;

  SELECT lib_cards.lib_card_num
  INTO lib_card_num_out
  FROM lib_user
  JOIN lib_cards ON lib_user.lib_card_id = lib_cards.lib_card_id
  WHERE lib_user.username = username_p
  LIMIT 1;

  RETURN(lib_card_num_out);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_card_num_by_user_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_card_num_by_user_id`(user_id_p INT) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
 DECLARE lib_card_num_out INT;

  SELECT lib_cards.lib_card_num
  INTO lib_card_num_out
  FROM lib_user
  JOIN lib_cards ON lib_user.lib_card_id = lib_cards.lib_card_id
  WHERE lib_user.user_id = user_id_p
  LIMIT 1;

  RETURN(lib_card_num_out);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_checkout_book_id_from_user_title` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_checkout_book_id_from_user_title`(user_id_in INT, book_title_in VARCHAR(200)) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
 DECLARE book_id_out INT;

  SELECT checked_out_books.book_id
  INTO book_id_out
  FROM checked_out_books
  JOIN book_inventory ON book_inventory.book_id = checked_out_books.book_id
  JOIN book ON book.isbn = book_inventory.isbn
  WHERE checked_out_books.user_id = user_id_in AND book.title = book_title_in
  LIMIT 1;

  RETURN(book_id_out);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_is_user_employee` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_is_user_employee`(user_id_p INT) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
 DECLARE is_user_employee BOOL;

  -- check that an employee exists with a user id corresponding to the given user
  SELECT COUNT(*) > 0
  INTO is_user_employee
  FROM employee
  -- an employee is a VERIFIED employee if they are approved
  WHERE employee.user_id = user_id_p
    AND employee.is_approved = true
  LIMIT 1;

  RETURN(is_user_employee);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_lib_id_from_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_lib_id_from_name`(in_lib_name VARCHAR(100), in_lib_sys_name VARCHAR(100)) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE library_id_out INT;
    -- GIVEN: a user's id, return the id of the library they belong to

  -- The backend side will have the user's id,
  -- so this procedure makes it very easy to get the library they belong to
  SELECT library_id INTO library_id_out
    FROM library
    WHERE library_name = in_lib_name /*AND in_lib_sys_name = library_system*/;

    RETURN(library_id_out);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_lib_name_from_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_lib_name_from_id`(in_lib_id INT) RETURNS varchar(100) CHARSET utf8mb3
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE ret VARCHAR(100) ;
    SELECT library_name INTO ret
        FROM library
        WHERE in_lib_id = library.library_id;

    RETURN(ret);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_lib_sys_id_from_sys_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_lib_sys_id_from_sys_name`(in_lib_sys_name VARCHAR(100)) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE lib_sys_id INT;
    -- GIVEN a user's id, returns the id of the library system
    SELECT library_system INTO lib_sys_id
        FROM library
        WHERE library_id = (
            SELECT library_sys_id
            FROM library_system
            WHERE library_sys_name = in_lib_sys_name
            LIMIT 1
        );

    RETURN(lib_sys_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_lib_sys_id_from_user_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_lib_sys_id_from_user_id`(in_user_id INT) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE lib_sys_id INT;
    -- GIVEN a user's id, returns the id of the library system
    SELECT library_system INTO lib_sys_id
        FROM library
        WHERE library_id = (
            SELECT library_id
            FROM user_register
            WHERE user_id = in_user_id
            LIMIT 1
        );

    RETURN(lib_sys_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_lib_sys_name_from_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_lib_sys_name_from_id`(in_lib_sys_id INT) RETURNS varchar(100) CHARSET utf8mb3
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE ret VARCHAR(100) ;
    SELECT library_sys_name INTO ret
        FROM library_system
        WHERE in_lib_sys_id = library_system.library_sys_id;

    RETURN(ret);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_lib_sys_name_from_user_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_lib_sys_name_from_user_id`(in_user_id INT) RETURNS varchar(100) CHARSET utf8mb3
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE user_lib_id INT;
    DECLARE found_lib_sys_id INT;
    DECLARE lib_sys_name VARCHAR(100);
    -- GIVEN a user's id, returns the id of the library system
    -- SELECT library_system_name INTO lib_sys_name
    SET user_lib_id  = (SELECT library_id FROM user_register WHERE in_user_id = user_id);
    SET found_lib_sys_id = (SELECT library_system FROM library WHERE library_id = user_lib_id);

    SELECT library_sys_name INTO lib_sys_name
        FROM library_system
        WHERE found_lib_sys_id = library_sys_id;

    RETURN(lib_sys_name);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_users_lib_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_users_lib_id`(in_user_id INT) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE library_id_out INT;
    -- GIVEN: a user's id, return the id of the library they belong to

  -- The backend side will have the user's id,
  -- so this procedure makes it very easy to get the library they belong to
  SELECT library_id INTO library_id_out
    FROM user_register
    WHERE in_user_id = user_id;

    RETURN(library_id_out);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_user_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `get_user_id`(username_p VARCHAR(50)) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE found_user_id INT;
    SELECT user_id INTO found_user_id FROM lib_user WHERE (username = username_p) LIMIT 1;
    RETURN (found_user_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `is_a_lib_sys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `is_a_lib_sys`(in_lib_sys_id INT) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE ret BOOL;
    -- GIVEN a library system name, return 1 if it exists
    -- If a match is found, the count is 1 and ret = 1
    SELECT COUNT(*)>0 INTO ret
        FROM library_system
        WHERE in_lib_sys_id = library_system.library_sys_id;

    RETURN(ret);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `is_book_avail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `is_book_avail`(
  book_title_p VARCHAR(200),
  lib_sys_id_p INT,
  lib_id_p INT,
  user_id_p INT
) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
  -- returns a book_id of a copy of the book
  -- titled 'book_title_p' in the library system
  -- -1 if no book exists
  -- -2 if user already checked out book
  DECLARE book_copy_avail INT;
  SET book_copy_avail = (
    WITH rel_book_in_sys AS (
      SELECT book.title, book_inventory.book_id as rel_book_id, library.*  FROM book
      JOIN book_inventory ON book_inventory.isbn = book.isbn
      JOIN bookshelf ON bookshelf.bookshelf_id = book_inventory.bookshelf_id
      JOIN bookcase ON bookcase.bookcase_id = bookshelf.bookcase_id
      JOIN library ON library.library_id = bookcase.library_id
    ),
    avail_book_in_sys AS (
      SELECT * FROM rel_book_in_sys
      WHERE
        title = book_title_p AND
        library_system = lib_sys_id_p AND
        library_id = lib_id_p AND
        rel_book_id NOT IN (SELECT book_id FROM checked_out_books)
      LIMIT 1
    ),
    already_checked_out AS (
      SELECT * FROM rel_book_in_sys
      -- join means all rows are of "checked out" books
      JOIN checked_out_books ON checked_out_books.book_id = rel_book_id
      WHERE
        checked_out_books.user_id = user_id_p AND
        title = book_title_p AND
        library_system = lib_sys_id_p AND
        library_id = lib_id_p
    )
    SELECT (CASE
      -- if user already checked out book, count > 0 (if not select valid book_id)
      WHEN COUNT(*) > 0 THEN -2 ELSE (
        SELECT (CASE WHEN COUNT(*) > 0 THEN avail_book_in_sys.rel_book_id ELSE -1 END)
        FROM avail_book_in_sys
      ) END
    )
    FROM already_checked_out -- should be empty if none checked out already

  );

  RETURN(book_copy_avail);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `is_book_checked_out` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `is_book_checked_out`(book_id_p INT) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
  -- must be > 0 copies available (and book_id cant be already checked out)
  DECLARE book_already_out BOOLEAN;
  SET book_already_out = (
    SELECT COUNT(*) > 0
    FROM checked_out_books
    WHERE book_id = book_id_p
    GROUP BY book_id
  );
  RETURN(book_already_out);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `is_employee_pending_by_user_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `is_employee_pending_by_user_id`(in_user_id INT) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
 DECLARE is_still_pending BOOL;
  -- return true if the user is still pending as an employee
  -- If the user is not registered as an employee AT ALL - returns false as well

  SELECT COUNT(*)
  INTO is_still_pending
  FROM employee
  WHERE
    -- first make sure the user exists as an employee
    user_id = in_user_id
    AND
    -- must be pending approval
    is_approved = false
  LIMIT 1;

  RETURN(is_still_pending);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `is_lib_in_sys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `is_lib_in_sys`(in_lib_id INT, in_lib_sys_id INT) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE ret BOOL;
    -- GIVEN a library name and system, return 1 if the library is in the system
    -- If a match is found, the count is 1 and ret = 1
    SELECT COUNT(*)>0 INTO ret
        FROM library
        WHERE
            in_lib_id = library_id
            AND
            in_lib_sys_id = library_system;

    RETURN(ret);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `library_id_from_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `library_id_from_book`(book_id_p INT) RETURNS int
    READS SQL DATA
    DETERMINISTIC
BEGIN
 DECLARE library_id_out INT;
 WITH desired_book AS(
    SELECT book_inventory.*, book.title FROM book_inventory
    JOIN book ON book.isbn = book_inventory.isbn
    WHERE book_inventory.book_id = book_id_p
  ),
 -- joining the desired_book and bookcase_id from bookshelf table
  desired_book_bs AS (
    SELECT title, bookcase.library_id, desired_book.bookshelf_id, bookshelf.bookcase_id
    FROM desired_book
    JOIN bookshelf USING (bookshelf_id)
    JOIN bookcase USING (bookcase_id)
  )

  SELECT library_id INTO library_id_out FROM desired_book_bs;

 RETURN(library_id_out);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_bookcase` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `add_bookcase`(IN in_library_id INT,
    IN in_dewey_min FLOAT,
    IN in_dewey_max FLOAT)
BEGIN
    -- Get the current highest bookcase number for the library - use the next value
    DECLARE next_bookcase_local_num INT;

     SET next_bookcase_local_num  = (
        -- If a library doesnt have any bookshelves, max is null. this will have the result be a 0 instead of NULL.
        SELECT COALESCE(MAX(bookcase_local_num) + 1, 1)
        FROM bookcase
        WHERE library_id = in_library_id
        );

    -- insert the new book case
    INSERT INTO bookcase (bookcase_local_num, dewey_max, dewey_min, library_id)
        VALUES (next_bookcase_local_num, in_dewey_max, in_dewey_min, in_library_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_bookshelf` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `add_bookshelf`(IN in_library_id INT,
    IN in_dewey_min FLOAT,
    IN in_dewey_max FLOAT)
BEGIN
    -- Get the current highest bookshelf number for the library - use the next value
    DECLARE next_bookshelf_local_num INT;
    DECLARE referenced_bookcase_id INT;

    SET next_bookshelf_local_num = (
        -- If a library doesnt have any bookshelves, max is null.
        -- This will have the result be a 0 instead of NULL.
        SELECT COALESCE(MAX(get_shelfs_in_lib.bookshelf_local_num) + 1, 1)
        -- Get the shelfs in the library
        FROM (
            SELECT bookshelf.* FROM
            -- Get the bookcase(s) this shelf could belong to
            (
                SELECT bookcase_id FROM bookcase WHERE library_id = in_library_id
            ) getBookcases
            -- Get all of the id's for EVERY shelf in this library (based on all of its cases)
            RIGHT JOIN bookshelf
            ON bookshelf.bookcase_id = getBookcases.bookcase_id
        ) get_shelfs_in_lib
    );

    -- pick the proper bookcase based on if the shelf's dewey range fits inside it.
    -- Can assume only 1 bookcase fits the criteria. limit to 1 just in case though.
    -- Whenever possible, put the book in the lower order book case
    SET referenced_bookcase_id = (
        SELECT getBookcasesID.bookcase_id
        FROM (
        -- Get the bookcase(s) this shelf could belong to in the library
            SELECT bookcase_id, dewey_min, dewey_max
            FROM bookcase
            WHERE library_id = in_library_id
                AND in_dewey_min >= dewey_min
                AND in_dewey_max <= dewey_max
        ORDER BY bookcase.bookcase_id DESC
        LIMIT 1
        ) getBookcasesID
    );

    -- insert the new bookshelf
    INSERT INTO bookshelf (dewey_max, dewey_min, bookshelf_local_num, bookcase_id)
        VALUES (in_dewey_max, in_dewey_min, next_bookshelf_local_num, referenced_bookcase_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_library` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `add_library`(IN in_library_system_name VARCHAR(100),
    IN in_library_name VARCHAR(100),
    IN in_address VARCHAR(100),
    IN in_start_time_of_operation time,
    IN in_end_time_of_operation time,
    IN in_max_concurrently_borrowed INT)
BEGIN
    -- Get the id of the library system that this new library belongs to
    DECLARE var_library_sys_id INT;
    SET var_library_sys_id = (
         SELECT library_sys_id
            FROM library_system
            WHERE library_sys_name = in_library_system_name
            LIMIT 1
        );

    -- Insert the given values into the table
     INSERT INTO library (library_system,
            library_name,
            address,
            start_time_of_operation,
            end_time_of_operation,
            max_concurrently_borrowed)
     VALUES (var_library_sys_id, in_library_name, in_address, in_start_time_of_operation,
        in_end_time_of_operation, in_max_concurrently_borrowed);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_new_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `add_new_book`(IN in_title VARCHAR(200),
    -- PRECONDITION: backend code uses get_users_lib_id to get their library_id BEFORE this procedure
    IN in_lib_id INT,
    IN in_isbn VARCHAR(17),
    IN in_author VARCHAR(100),
    IN in_publisher VARCHAR(100),
    IN in_is_audio_book BOOL,
    IN in_num_pages INT,
    IN in_checkout_length_days INT,
    IN in_book_dewey FLOAT,
    IN in_late_fee_per_day FLOAT)
BEGIN

  DECLARE placement_bookshelf_id INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;
  START TRANSACTION;
  -- Using the dewey number of the book, puts it in the right bookshelf + bookshelf
  -- NOTE: in a lot of cases the Dewey Number is an estimate.
  -- Real data domain experts would be needed to provide the exact dewey numbers
  -- Reference: https://www.britannica.com/science/Dewey-Decimal-Classification
  -- Reference (through searching each book): https://catalog.loc.gov/vwebv/ui/en_US/htdocs/help/numbers.html
  SET placement_bookshelf_id = (SELECT get_bookshelf_from_dewey(in_book_dewey, in_lib_id) );

  -- check if book is already in master list, if not then have to add
  IF NOT EXISTS (SELECT 1 FROM book WHERE in_isbn = book.isbn) THEN
    INSERT INTO book (isbn, title, author, publisher, is_audio_book, num_pages, book_dewey)
    VALUES(in_isbn, in_title, in_author, in_publisher, in_is_audio_book, in_num_pages, in_book_dewey);
  END IF;

  INSERT INTO book_inventory (book_id, isbn, bookshelf_id, checkout_length_days, late_fee_per_day)
  VALUES(DEFAULT, in_isbn, placement_bookshelf_id, in_checkout_length_days, in_late_fee_per_day);

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `approve_employee` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `approve_employee`(IN in_employee_id INT)
BEGIN
    -- GIVEN: an employee's employee_id, update their status to be approved
    UPDATE employee
        SET is_approved = true
        WHERE employee_id = in_employee_id;
    commit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cancel_hold` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `cancel_hold`(IN user_id_in INT, IN hold_id_in INT)
BEGIN
  -- if hold doesnt exist, return 0
  -- if exists and canceled, return 1
  DECLARE rtncode INT;

  IF EXISTS (SELECT * FROM holds WHERE user_id = user_id_in AND hold_id = hold_id_in) THEN
    DELETE FROM holds WHERE user_id = user_id_in AND hold_id = hold_id_in;
    SET rtncode = 1;
  ELSE
    SET rtncode = 0;
  END IF;


  COMMIT;
  SELECT rtncode;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `checkout_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `checkout_book`(
  IN user_id_p INT,
  IN book_title VARCHAR(200),
  IN lib_sys_id_p INT,
  IN lib_id_p INT
)
checkout_label:BEGIN
  -- given user_id, book_title, lib_sys_id, & lib_id -> checkout book
  -- RETURN: {rtncode: <code>, due_datetime(if success): <datetime> }
  -- code 1:  Success
  -- code -1: no copies available
  -- code -2: user already has book checked out
  -- code 0: other failure
  -- modify checked_out_books & user_hist tables
  DECLARE checkout_length_days INT;
  DECLARE checkout_datetime DATETIME;
  DECLARE due_datetime DATETIME;
  DECLARE avail_book_id INT;

  -- use transaction bc multiple inserts and should rollback on error
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SHOW ERRORS;
    ROLLBACK;
    SELECT 0 as "rtncode", null as "due_date";
  END;
  START TRANSACTION; -- may need to rollback bc multiple inserts

  -- function return -1 if no coopies of the book can be checked out
  SET avail_book_id = is_book_avail(book_title, lib_sys_id_p, lib_id_p, user_id_p);
  IF avail_book_id < 0 THEN
    SELECT avail_book_id as "rtncode", null as "due_date";
    ROLLBACK;
    LEAVE checkout_label;
  END IF;

  SET checkout_length_days = (
    SELECT book_inventory.checkout_length_days FROM book_inventory
    WHERE book_id = avail_book_id
  );

  SET checkout_datetime = NOW();
  SET due_datetime = (SELECT DATE_ADD(checkout_datetime, INTERVAL checkout_length_days DAY));

  -- Adds the book to the check_out_books table
  INSERT INTO checked_out_books (user_id,   book_id,       checkout_date,     due_date)
  VALUES                        (user_id_p, avail_book_id, checkout_datetime, due_datetime);

  -- Adding the checkout into the user_hist table
  INSERT INTO user_hist (loan_id, user_id,   book_borrowed, library_id, date_borrowed)
  VALUES                (DEFAULT, user_id_p, avail_book_id, lib_id_p,   checkout_datetime);

  -- TODO: in checkout return this info: bookcase_local_num & bookshelf_local_num
  SELECT 1 as "rtncode", due_datetime as "due_date";
  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_lib_card` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `check_lib_card`(IN username_to_test VARCHAR(50), IN card_num INT)
BEGIN
  DECLARE does_user_card_match BOOLEAN;
  SET does_user_card_match = (
    SELECT COUNT(*) > 0
    FROM (
      SELECT
          lib_user.lib_card_id
      FROM lib_user
      JOIN lib_cards on lib_cards.lib_card_id = lib_user.lib_card_id
      WHERE (username = username_to_test and card_num = lib_cards.lib_card_num)
    ) X
  );

  SELECT does_user_card_match;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `check_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `check_password`(IN username_to_test VARCHAR(50), IN pwd VARCHAR(50))
BEGIN
  -- insert into @hash_pwd exec get_user_pass username;
  -- SELECT lib_password FROM lib_user WHERE (username = username_p);
  DECLARE is_pwd_match BOOLEAN;
  DECLARE hashed_pwd VARCHAR(50);

  SET hashed_pwd = (
    SELECT lib_password FROM lib_user WHERE (username = username_to_test)
  );

  SET is_pwd_match = hashed_pwd = MD5(pwd);
  SELECT is_pwd_match;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `current_hold_and_checked_out` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `current_hold_and_checked_out`(IN user_id_p INT)
BEGIN
   WITH current_holds AS(
    SELECT isbn FROM holds WHERE (user_id_p = user_id)
   ),
   current_checked_out_id AS (
    SELECT book_id FROM checked_out_books WHERE (user_id_p = user_id)
   ),
   current_checked_out_isbn AS (
    SELECT isbn FROM book_inventory
     WHERE (book_id IN (SELECT * FROM current_checked_out_ID))
   )

   -- the table of ISBNs representing the books a specific user
   -- has checked out or has placed a hold on
   SELECT * FROM current_holds
    UNION ALL
   SELECT * FROM current_checked_out_isbn;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `deny_employee_approval` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `deny_employee_approval`(IN in_employee_id INT)
BEGIN
    -- GIVEN: an employee's employee_id, dont approve them by removing them from the employee table
    DELETE FROM employee
        WHERE employee_id = in_employee_id;
    commit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `does_username_exist` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `does_username_exist`(IN username_p VARCHAR(50))
BEGIN
   SELECT EXISTS(SELECT username FROM lib_user WHERE (username = username_p)) AS username_exists;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_all_libraries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `get_all_libraries`()
BEGIN
  -- Needed for validation of register. Can't be function because multiple rows returned
  SELECT library_id, library_name FROM library ORDER BY library_name ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_all_library_systems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `get_all_library_systems`()
BEGIN
  -- Needed for validation of register. Can't be function because multiple rows returned
  SELECT library_sys_id, library_sys_name FROM library_system ORDER BY library_sys_name ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_all_libs_in_system` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `get_all_libs_in_system`(IN in_lib_sys_id INT)
BEGIN

  -- Needed for validation of register. Can't be function because multiple rows returned
  SELECT library_id, library_name
    FROM library
    WHERE library_system = in_lib_sys_id
    ORDER BY library_name ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_pending_employees` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `get_pending_employees`(IN in_user_id INT)
BEGIN
    -- PRECONDITION: the in_user_id is the user_id of an employee
    -- given the user id (of an employee), get ALL pending employees belonging to this employee's library
    -- return their first_name, last_name, job_role, and hire_date

    DECLARE user_lib_id INT;
    -- Only care about employees that are part of the same library
    SELECT library_id INTO user_lib_id
        FROM employee
        WHERE in_user_id = employee.user_id;

    WITH pending_employees AS(
        SELECT hire_date, job_role, user_id, employee_id
        FROM employee
        WHERE is_approved = false AND user_lib_id = employee.library_id
    )

    -- Get all needed information
    SELECT lib_user.first_name,
           lib_user.last_name,
           pending_employees.job_role,
           pending_employees.hire_date,
           pending_employees.employee_id
        FROM pending_employees
        JOIN lib_user
        ON pending_employees.user_id = lib_user.user_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_user_checkouts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `get_user_checkouts`(IN user_id_p INT)
BEGIN
  -- GIVEN: user_id
  -- RETURNS: user_id, book_title, book_id, author, library_name, checkout_date, due_date

  SELECT
    user_id_p AS "user_id",
    book.title AS book_title,
    checked_out_books.book_id,
    book.author,
    library.library_name,
    checked_out_books.checkout_date,
    checked_out_books.due_date
  FROM checked_out_books
  JOIN book_inventory ON book_inventory.book_id = checked_out_books.book_id
  JOIN book ON book_inventory.isbn = book.isbn
  JOIN bookshelf ON bookshelf.bookshelf_id = book_inventory.bookshelf_id
  JOIN bookcase ON bookcase.bookcase_id = bookshelf.bookcase_id
  JOIN library ON library.library_id = bookcase.library_id
  WHERE checked_out_books.user_id = user_id_p;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_user_hist_from_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `get_user_hist_from_id`(IN in_user_id INT)
BEGIN
    -- Given a user id, return their history of checkout
    -- Return:
    -- book title checked out, date checked out, return date (null or the day), overdue fee ( have to calculate it), library name
    -- preferably in sorted order of checked out date

    WITH get_loan_hist AS (
        SELECT loan_id, book_borrowed AS borrowed_book_id, library_id, date_borrowed, date_returned
        FROM user_hist
        WHERE user_id = in_user_id
    ),
    -- use the borrowed_book_id (FK to inventory) to get its isbn and from there, its title in book
    get_book_name AS (
        SELECT get_loan_hist.*, book.title,
            -- If the book has yet to be returned, assume it will be today when calculating costs
            DATEDIFF(coalesce(get_loan_hist.date_returned, CURDATE()), date_borrowed) AS days_checked_out,
            book_inventory.checkout_length_days AS max_checkout_len_days,
            book_inventory.late_fee_per_day
        FROM get_loan_hist
        LEFT OUTER JOIN book_inventory ON get_loan_hist.borrowed_book_id = book_inventory.book_id
        LEFT OUTER JOIN book ON book_inventory.isbn = book.isbn
    ),
    -- Get the library name from the id
    get_lib_name AS (
        SELECT get_book_name.*, library.library_name
        FROM get_book_name
        LEFT JOIN library ON get_book_name.library_id = library.library_id
    ),
    calc_overdue_costs AS (
        SELECT get_lib_name.library_name, get_lib_name.date_borrowed,
            get_lib_name.date_returned, days_checked_out, get_lib_name.title,
            -- if the days checked out is less than the allowed checkout length, cost is 0
            CASE
                WHEN days_checked_out < max_checkout_len_days THEN 0
                ELSE (days_checked_out - max_checkout_len_days) * late_fee_per_day
            END AS overdue_fee_dollars,
            max_checkout_len_days, late_fee_per_day
        FROM get_lib_name
    )


    SELECT *
    FROM calc_overdue_costs
    ORDER BY calc_overdue_costs.date_borrowed ASC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_user_holds` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `get_user_holds`(IN user_id_p INT)
BEGIN
  -- GIVEN: user_id
  -- RETURNS: hold_id, book_title, author, library_name, hold_start_date

  SELECT
    holds.hold_id,
    book.title AS book_title,
    book.author,
    library.library_name,
    holds.hold_start_date
  FROM holds
  JOIN book ON holds.isbn = book.isbn
  JOIN library ON library.library_id = holds.library_id
  WHERE holds.user_id = user_id_p;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_user_pass` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `get_user_pass`(IN username_p VARCHAR(50))
BEGIN
    SELECT lib_password FROM lib_user WHERE (username = username_p);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_employee` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `insert_employee`(
-- Inserts a new employee into the DB
  IN in_hire_date DATE,
  IN in_salary FLOAT,
  IN in_job_role varchar(200),
  -- REQUIRES INSERT USER IS CALLED FIRST AND THE USER'S NEW id IS OBTAINED
  IN in_user_id INT,
  IN in_library_id INT,
  IN in_is_approved BOOL
)
BEGIN
  -- in case insert into lib_user fails, start a transaction that can rollback other insertions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
      ROLLBACK;
  END;
  START TRANSACTION;

  -- insert into lib_user
  INSERT INTO employee (employee_id, hire_date, salary, job_role, user_id, library_id, is_approved)
  -- employee_id is auto increment, so specify default behavior
  VALUES(DEFAULT, in_hire_date, in_salary, in_job_role, in_user_id, in_library_id, in_is_approved);

  COMMIT;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `insert_user`(
-- Inserts a new user into the DB
  IN fname VARCHAR(50),
  IN lname VARCHAR(50),
  -- In python, call a procedure to get the library id given its name
  IN in_library_id INT,
  IN dob DATE,
  IN is_employee BOOLEAN,
  IN username VARCHAR(50),
  IN pwd VARCHAR(50)
)
BEGIN
  DECLARE new_user_id INT;
  DECLARE new_lib_card_num INT;
  DECLARE new_lib_card_id INT;
  -- in case insert into lib_user fails, start a transaction that can rollback other insertions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
      ROLLBACK;
  END;
  START TRANSACTION;

  -- create new library card number based on existing
  SET new_lib_card_num = (
    -- coalesce handles if no entries in table yet and max is null
    SELECT coalesce(MAX(lib_card_num)+1, 0)
    FROM lib_cards
  );

  -- insert into library card (and get its id)
  INSERT INTO lib_cards (lib_card_id, lib_card_num) VALUES (DEFAULT, new_lib_card_num);
  SET new_lib_card_id = LAST_INSERT_ID(); -- get id of last inserted row into a table

  -- insert into lib_user
  INSERT INTO lib_user (user_id, lib_card_id, first_name, last_name, dob, num_borrowed, is_employee, username, lib_password)
  -- user_id is auto increment, so specify default behavior
  -- hash the password with MD5 & only ever do checks on the hash (no plaintext passwords)
  VALUES(DEFAULT, new_lib_card_id, fname, lname, dob, 0, is_employee, username, MD5(pwd));
  SET new_user_id = LAST_INSERT_ID();

  -- insert into user_register
  INSERT INTO user_register (user_id, library_id) VALUES(new_user_id, in_library_id);
  COMMIT;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `place_hold` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `place_hold`(
  IN user_id_p INT,
  IN title_p VARCHAR(200),
  IN lib_sys_id_p INT,
  IN lib_id_p INT
)
place_hold_label:BEGIN
  -- returns {rtncode: <code>}
  -- code = 0: user already placed a hold on that book at that library
  -- code = 1: success
  -- code = 2: user already has the book checked out

  -- get isbn from title
  DECLARE book_isbn VARCHAR(17);

  SET book_isbn = (
    SELECT isbn FROM book WHERE book.title = title_p
  );

  -- make sure user doesnt have a hold on this book already
  IF EXISTS (
    SELECT * FROM holds
    JOIN book ON book.isbn = holds.isbn
    WHERE (lib_sys_id_p = holds.lib_sys_id AND user_id = user_id_p AND holds.isbn = book_isbn)
  ) THEN
    SELECT 0 as rtncode;
    LEAVE place_hold_label;
  END IF;

  -- make sure user doesnt have this book checked out already
  IF EXISTS (
    SELECT * FROM checked_out_books
    JOIN book_inventory ON book_inventory.book_id = checked_out_books.book_id
    JOIN book ON book.isbn = book_inventory.isbn
    JOIN bookshelf ON bookshelf.bookshelf_id = book_inventory.bookshelf_id
    JOIN bookcase ON bookcase.bookcase_id = bookshelf.bookcase_id
    JOIN library ON library.library_id = bookcase.library_id
    WHERE (
      lib_sys_id_p = library.library_system AND
      checked_out_books.user_id = user_id_p AND
      book_inventory.isbn = book_isbn
    )
  ) THEN
    SELECT 2 as rtncode;
    LEAVE place_hold_label;
  END IF;

  -- make a hold with that book and user date
  INSERT INTO holds (hold_id, isbn,      user_id,   lib_sys_id,   library_id,  hold_start_date)
  VALUES            (DEFAULT, book_isbn, user_id_p, lib_sys_id_p, lib_id_p,    NOW());

  COMMIT;

  SELECT 1 as rtncode;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `return_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `return_book`(IN book_id_p INT, IN user_id_p INT)
BEGIN
  DECLARE book_library_id INT;
  DECLARE new_checkout_user_id INT;
  DECLARE checkout_length_days INT;
  DECLARE due_datetime DATE;
  DECLARE isbn_from_p VARCHAR(17);
  -- id of user who's had the longest hold on isbn and will check it out
  DECLARE user_id_checkout_hold INT;

  -- use transaction bc multiple inserts and should rollback on error
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SHOW ERRORS;
    ROLLBACK;
    SELECT "Failed to return book, rolling back";
    CALL raise_error;
  END;

  -- Grabs the ISBN of the book being returned
  SELECT isbn FROM book_inventory WHERE (book_inventory.book_id = book_id_p)
    INTO isbn_from_p;

  -- A function to get the library_id for a specific book
  SELECT library_id_from_book(book_id_p) INTO book_library_id;

 -- Adds the return date to the user_Hist
  UPDATE user_hist
  SET date_returned = now()
  WHERE ((user_id_p = user_id) AND
          (book_id_p = book_borrowed));

  -- Delete row from checked_out_Books
  DELETE FROM checked_out_books
  WHERE ((user_id_p = checked_out_books.user_id) AND
          (book_id_p = checked_out_books.book_id));

  -- Checks out the book for the next person on hold, if one exists
  -- Otherwise, the book is return and ready to be checked out by whomever else wants it
  -- We will register the user to whatever copy of the book that has been checked out
  -- for the longest period of time, assuming that it will be the next copy returned
  IF EXISTS (SELECT * FROM holds WHERE (isbn_from_p = isbn)) THEN
    SET new_checkout_user_id = (
      SELECT user_id FROM holds
      WHERE (isbn_from_p = isbn)
      ORDER BY hold_start_date ASC LIMIT 1
    );
    SET checkout_length_days = (SELECT checkout_length_days FROM book_inventory WHERE book_id_p = book_inventory.book_id);
    SET due_datetime = (SELECT DATE_ADD(checkout_datetime, INTERVAL checkout_length_days DAY));

    INSERT INTO checked_out_books (user_id,              book_id,   checkout_date, due_date)
    VALUES                        (new_checkout_user_id, book_id_p, now(),         due_datetime);

    -- Updates user_hist
    SET user_id_checkout_hold = (
      SELECT user_id FROM holds
      WHERE (holds.isbn = isbn_from_p)
      ORDER BY hold_start_date ASC LIMIT 1
    );

    INSERT INTO user_hist (loan_id, user_id, book_borrowed, library_id, date_borrowed, date_returned)
    VALUES (DEFAULT, user_id_checkout_hold, book_id_p, book_library_id, now(), null);

  END IF;

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_for_book` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `search_for_book`(IN booktitle_p VARCHAR(200), IN lib_sys_id_p INT)
BEGIN
-- This cannot be a function because a table is returned
 DECLARE derived_isbn VARCHAR(17);
 SET derived_isbn = (SELECT isbn FROM book WHERE title = booktitle_p LIMIT 1);

 WITH
   -- all copies of this book in the system with their shelf_id, case_id, local shelf/case id, lib_id
  all_copies AS(
    SELECT
      book_inventory.book_id,
      book_inventory.isbn,
      library.library_name,
      library.library_id,
      bookcase.bookcase_local_num,
      bookshelf.bookshelf_local_num,
      bookcase.bookcase_id,
      bookshelf.bookshelf_id
    FROM book_inventory
    JOIN bookshelf ON book_inventory.bookshelf_id = bookshelf.bookshelf_id
    JOIN bookcase ON bookshelf.bookcase_id = bookcase.bookcase_id
    JOIN library ON bookcase.library_id = library.library_id
    WHERE (book_inventory.isbn = derived_isbn AND lib_sys_id_p = library.library_system)
  ),
  num_copies_exist AS(
    SELECT all_copies.library_id, count(*) as num_copies_at_library
    FROM all_copies
    GROUP BY all_copies.library_id
  ),
  num_copies_available AS(
    SELECT
      all_copies.library_id,
      COUNT(checked_out_books.book_id) as num_checked_out,
      (num_copies_exist.num_copies_at_library - COUNT(checked_out_books.book_id)) as num_copies_in_stock
    FROM all_copies
    LEFT JOIN num_copies_exist ON num_copies_exist.library_id = all_copies.library_id
    LEFT JOIN checked_out_books ON all_copies.book_id = checked_out_books.book_id
    GROUP BY all_copies.library_id
  ),
  -- Find how many holds there are for the book at each library
  relevant_holds AS (
    SELECT all_copies.*, holds.hold_id, holds.user_id
    FROM all_copies
    LEFT JOIN holds ON holds.library_id = all_copies.library_id -- AND holds.isbn = all_copies.isbn
    WHERE holds.isbn = derived_isbn
    -- multiple users at one library can have the "same" hold
    GROUP BY holds.library_id, holds.user_id
  ),
  num_holds AS(
    SELECT
      relevant_holds.library_id,
      COUNT(*) AS number_holds
    FROM relevant_holds
    GROUP BY relevant_holds.library_id
  ),
  combined_table AS (
    SELECT
      all_copies.library_id,
      all_copies.library_name,
      num_copies_exist.num_copies_at_library,
      num_copies_available.num_checked_out,
      num_copies_available.num_copies_in_stock,
      -- if no holds, may be null, replace with 0
      coalesce(num_holds.number_holds, 0) AS number_holds
    FROM all_copies
    LEFT OUTER JOIN num_copies_exist ON num_copies_exist.library_id = all_copies.library_id
    LEFT OUTER JOIN num_holds ON num_holds.library_id = all_copies.library_id
    LEFT OUTER JOIN num_copies_available ON all_copies.library_id = num_copies_available.library_id
    GROUP BY all_copies.library_id
  )

  SELECT * FROM combined_table;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `search_lib_sys_catalog` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `search_lib_sys_catalog`(IN lib_sys_id_p INT)
BEGIN
    -- This cannot be a function because a table is returned
    -- limit the libraries to JUST libraries in the system
    WITH libs_in_sys AS (
        SELECT library_id, library_name FROM library WHERE library_system = lib_sys_id_p
    ),
    -- Overall: lib -> bookcases -> bookshelves -> books
    lib_bookcases AS (
        SELECT libs_in_sys.*, bookcase.bookcase_id
        FROM libs_in_sys
        JOIN bookcase ON libs_in_sys.library_id = bookcase.library_id),
    lib_book_shelves AS (
        SELECT lib_bookcases.*, bookshelf.bookshelf_id
        FROM lib_bookcases
        JOIN bookshelf ON bookshelf.bookcase_id = lib_bookcases.bookcase_id
    ),
    -- Gets the number of each book owned at each library
    books_in_lib_sys AS (
        SELECT lib_book_shelves.*, book.title AS book_title, book.author, COUNT(book.title) AS num_copies_at_library
        FROM lib_book_shelves
        JOIN book_inventory ON lib_book_shelves.bookshelf_id = book_inventory.bookshelf_id
        JOIN book ON book.isbn = book_inventory.isbn
        -- Get the number of copies of EACH book at EACH library
        GROUP BY lib_book_shelves.library_name, book.title
    )

    SELECT library_name, book_title, author,  num_copies_at_library
        FROM books_in_lib_sys
        ORDER BY book_title ASC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_pwd` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `update_pwd`(IN username_p VARCHAR(50), IN pwd_p VARCHAR(50))
BEGIN
 UPDATE lib_user
 SET lib_password = MD5(pwd_p)
 WHERE username = username_p;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-01-28  4:21:31
