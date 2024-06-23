-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 03, 2024 at 11:11 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `flighttemp`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `admin_login` (IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `p_success` BOOLEAN, OUT `p_id` INT, OUT `p_username` VARCHAR(255))   BEGIN
    DECLARE user_count INT;
    DECLARE hashed_password VARCHAR(255);

    -- Hash the provided password using MD5
    SET hashed_password = MD5(p_password);
    
    -- Check if user exists with provided email and hashed password
    SELECT COUNT(*) INTO user_count
    FROM admin
    WHERE admin_email = p_email AND admin_pwd = hashed_password;
    
    IF user_count = 1 THEN
        -- User exists, fetch user details
        SELECT admin_id, admin_uname
        INTO p_id, p_username
        FROM admin
        WHERE admin_email = p_email;
        
        SET p_success = TRUE;
    ELSE
        -- User doesn't exist or incorrect credentials
        SET p_success = FALSE;
        SET p_id = NULL;
        SET p_username = NULL;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ApplyDiscount` ()   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE user_id_val INT;
    DECLARE ticket_count INT;
    DECLARE cur CURSOR FOR SELECT user_id, COUNT(*) FROM ticket GROUP BY user_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    START TRANSACTION;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO user_id_val, ticket_count;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        IF ticket_count > 5 THEN
            UPDATE ticket SET cost = cost * 0.9 WHERE user_id = user_id_val;
        END IF;
    END LOOP;

    CLOSE cur;

    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `user_login` (IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `p_success` BOOLEAN, OUT `p_id` INT, OUT `p_username` VARCHAR(255))   BEGIN
    DECLARE user_count INT;
    DECLARE hashed_password VARCHAR(255);

    -- Hash the provided password using MD5
    SET hashed_password = MD5(p_password);
    
    -- Check if user exists with provided email and hashed password
    SELECT COUNT(*) INTO user_count
    FROM users
    WHERE email = p_email AND password = hashed_password;
    
    IF user_count = 1 THEN
        -- User exists, fetch user details
        SELECT user_id, username
        INTO p_id, p_username
        FROM users
        WHERE email = p_email;
        
        SET p_success = TRUE;
    ELSE
        -- User doesn't exist or incorrect credentials
        SET p_success = FALSE;
        SET p_id = NULL;
        SET p_username = NULL;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `user_register` (IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_username` VARCHAR(255), OUT `p_success` BOOLEAN)   BEGIN
    DECLARE user_exists INT;

    -- Hash the password using MD5
    DECLARE hashed_password VARCHAR(255);
    SET hashed_password = MD5(p_password);
    
    -- Check if user already exists with provided email
    SELECT COUNT(*) INTO user_exists
    FROM users
    WHERE email = p_email;
    
    IF user_exists = 0 THEN
        -- User doesn't exist, proceed with registration
        INSERT INTO users (email, password, username)
        VALUES (p_email, hashed_password, p_username);
        
        SET p_success = TRUE;
    ELSE
        -- User already exists
        SET p_success = FALSE;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `admin_id` int(11) NOT NULL,
  `admin_uname` varchar(20) NOT NULL,
  `admin_email` varchar(50) NOT NULL,
  `admin_pwd` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`admin_id`, `admin_uname`, `admin_email`, `admin_pwd`) VALUES
(1, 'admin', 'admin@mail.com', 'f71459ce3167b35f10e8a18629187876');

-- --------------------------------------------------------

--
-- Table structure for table `airline`
--

CREATE TABLE `airline` (
  `airline_id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `seats` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `airline`
--

INSERT INTO `airline` (`airline_id`, `name`, `seats`) VALUES
(1, 'Core Airways', 165),
(2, 'Echo Airline', 220),
(3, 'Spark Airways', 125),
(4, 'Peak Airways', 210),
(5, 'Homelander Airways', 185),
(9, 'Blue Airlines', 200),
(10, 'GoldStar Airways', 205),
(11, 'Novar Airways', 158),
(12, 'Aero Airways', 210),
(13, 'Nep Airways', 215),
(14, 'Delta Airlines', 135),
(15, 'Jhon', 200);

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `log_id` int(11) NOT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `operation` varchar(10) DEFAULT NULL,
  `record_id` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_log`
--

INSERT INTO `audit_log` (`log_id`, `table_name`, `operation`, `record_id`, `timestamp`) VALUES
(21, 'flight', 'insert', 27, '2024-04-19 11:33:16'),
(22, 'passenger_profile', 'insert', 1, '2024-04-19 11:35:24'),
(23, 'payment', 'insert', 27, '2024-04-19 11:35:40'),
(24, 'flight', 'update', 27, '2024-04-19 11:35:40'),
(25, 'flight', 'update', 27, '2024-04-19 11:35:40'),
(26, 'payment', 'delete', 27, '2024-04-19 11:40:00'),
(27, 'payment', 'insert', 27, '2024-04-19 11:40:07'),
(28, 'flight', 'update', 27, '2024-04-19 11:40:07'),
(29, 'flight', 'update', 27, '2024-04-19 11:40:07'),
(30, 'payment', 'delete', 27, '2024-04-19 11:43:49'),
(31, 'passenger_profile', 'insert', 2, '2024-04-19 11:48:36'),
(32, 'payment', 'insert', 27, '2024-04-19 11:48:54'),
(33, 'flight', 'update', 27, '2024-04-19 11:48:54'),
(34, 'flight', 'update', 27, '2024-04-19 11:48:54'),
(35, 'payment', 'insert', 27, '2024-04-19 11:50:12'),
(36, 'flight', 'update', 27, '2024-04-19 11:50:12'),
(37, 'flight', 'update', 27, '2024-04-19 11:50:12'),
(38, 'flight', 'insert', 28, '2024-04-19 12:16:23'),
(39, 'passenger_profile', 'insert', 3, '2024-04-19 12:19:10'),
(40, 'payment', 'insert', 28, '2024-04-19 12:20:03'),
(41, 'flight', 'update', 28, '2024-04-19 12:20:03'),
(42, 'flight', 'update', 28, '2024-04-19 12:20:03'),
(43, 'flight', 'insert', 29, '2024-04-19 12:22:21'),
(44, 'flight', 'update', 29, '2024-04-19 12:23:06'),
(45, 'flight', 'update', 29, '2024-04-19 12:23:20'),
(46, 'flight', 'update', 29, '2024-04-19 12:24:06'),
(47, 'flight', 'insert', 30, '2024-04-19 12:25:29'),
(48, 'flight', 'insert', 31, '2024-04-19 12:27:28'),
(49, 'flight', 'insert', 32, '2024-04-19 12:28:18'),
(50, 'flight', 'insert', 33, '2024-04-19 12:29:15'),
(51, 'flight', 'insert', 34, '2024-04-19 12:30:33'),
(52, 'flight', 'insert', 35, '2024-04-19 12:31:25'),
(53, 'flight', 'insert', 36, '2024-04-19 12:32:14'),
(54, 'flight', 'insert', 37, '2024-04-19 12:33:03'),
(55, 'passenger_profile', 'insert', 4, '2024-04-19 12:35:10'),
(56, 'payment', 'insert', 27, '2024-04-19 12:35:33'),
(57, 'flight', 'update', 27, '2024-04-19 12:35:33'),
(58, 'flight', 'update', 27, '2024-04-19 12:35:33'),
(59, 'passenger_profile', 'delete', 1, '2024-04-19 12:36:38'),
(60, 'passenger_profile', 'insert', 5, '2024-04-19 12:41:33'),
(61, 'payment', 'insert', 30, '2024-04-19 12:42:14'),
(62, 'flight', 'update', 30, '2024-04-19 12:42:14'),
(63, 'passenger_profile', 'insert', 6, '2024-04-19 12:44:07'),
(64, 'payment', 'insert', 27, '2024-04-19 12:44:31'),
(65, 'flight', 'update', 27, '2024-04-19 12:44:31'),
(66, 'flight', 'update', 27, '2024-04-19 12:44:31'),
(67, 'passenger_profile', 'insert', 7, '2024-04-30 16:19:39'),
(68, 'payment', 'insert', 35, '2024-04-30 16:20:15'),
(69, 'flight', 'update', 35, '2024-04-30 16:20:15'),
(70, 'passenger_profile', 'insert', 8, '2024-05-01 06:27:05'),
(71, 'payment', 'insert', 35, '2024-05-01 06:27:32'),
(72, 'flight', 'update', 35, '2024-05-01 06:27:32'),
(73, 'flight', 'update', 35, '2024-05-01 06:27:32'),
(74, 'passenger_profile', 'delete', 2, '2024-05-01 06:36:44'),
(75, 'passenger_profile', 'delete', 3, '2024-05-01 06:36:44'),
(76, 'passenger_profile', 'delete', 4, '2024-05-01 06:36:44'),
(77, 'passenger_profile', 'delete', 5, '2024-05-01 06:36:44'),
(78, 'passenger_profile', 'delete', 6, '2024-05-01 06:36:44'),
(79, 'passenger_profile', 'delete', 7, '2024-05-01 06:36:44'),
(80, 'passenger_profile', 'delete', 8, '2024-05-01 06:36:44'),
(81, 'payment', 'delete', 30, '2024-05-01 06:37:09'),
(82, 'payment', 'delete', 27, '2024-05-01 06:37:09'),
(83, 'payment', 'delete', 27, '2024-05-01 06:37:09'),
(84, 'payment', 'delete', 35, '2024-05-01 06:37:09'),
(85, 'payment', 'delete', 27, '2024-05-01 06:37:09'),
(86, 'payment', 'delete', 28, '2024-05-01 06:37:09'),
(87, 'payment', 'delete', 35, '2024-05-01 06:37:09'),
(88, 'payment', 'delete', 27, '2024-05-01 06:37:09'),
(89, 'passenger_profile', 'insert', 1, '2024-05-01 06:40:02'),
(90, 'payment', 'insert', 35, '2024-05-01 06:41:47'),
(91, 'flight', 'update', 35, '2024-05-01 06:41:47'),
(92, 'flight', 'update', 35, '2024-05-01 06:41:48'),
(93, 'payment', 'insert', 35, '2024-05-01 06:47:40'),
(94, 'flight', 'update', 35, '2024-05-01 06:47:40'),
(95, 'payment', 'delete', 35, '2024-05-01 06:49:32'),
(96, 'payment', 'delete', 35, '2024-05-01 06:49:32'),
(97, 'payment', 'insert', 35, '2024-05-01 06:49:46'),
(98, 'flight', 'update', 35, '2024-05-01 06:49:46'),
(99, 'flight', 'update', 35, '2024-05-01 06:49:46'),
(100, 'passenger_profile', 'insert', 2, '2024-05-01 06:54:35'),
(101, 'payment', 'insert', 35, '2024-05-01 06:54:53'),
(102, 'flight', 'update', 35, '2024-05-01 06:54:53'),
(103, 'flight', 'update', 35, '2024-05-01 06:54:53'),
(104, 'passenger_profile', 'delete', 1, '2024-05-01 06:55:09'),
(105, 'passenger_profile', 'insert', 3, '2024-05-01 06:56:19'),
(106, 'payment', 'insert', 35, '2024-05-01 06:56:37'),
(107, 'flight', 'update', 35, '2024-05-01 06:56:37'),
(108, 'passenger_profile', 'insert', 4, '2024-05-01 07:26:33'),
(109, 'payment', 'insert', 27, '2024-05-01 07:26:50'),
(110, 'flight', 'update', 27, '2024-05-01 07:26:50'),
(111, 'flight', 'update', 27, '2024-05-01 07:26:50'),
(112, 'passenger_profile', 'insert', 5, '2024-05-01 07:30:30'),
(113, 'passenger_profile', 'insert', 6, '2024-05-01 07:30:30'),
(114, 'payment', 'insert', 27, '2024-05-01 07:30:50'),
(115, 'flight', 'update', 27, '2024-05-01 07:30:50'),
(116, 'flight', 'update', 27, '2024-05-01 07:30:50'),
(117, 'flight', 'update', 27, '2024-05-01 07:30:50'),
(118, 'passenger_profile', 'delete', 4, '2024-05-01 07:34:38'),
(119, 'passenger_profile', 'delete', 6, '2024-05-01 07:34:44'),
(120, 'passenger_profile', 'insert', 7, '2024-05-01 07:36:12'),
(121, 'payment', 'insert', 27, '2024-05-01 07:36:31'),
(122, 'flight', 'update', 27, '2024-05-01 07:36:31'),
(123, 'flight', 'update', 27, '2024-05-01 07:36:31'),
(124, 'passenger_profile', 'delete', 7, '2024-05-01 07:41:06'),
(125, 'passenger_profile', 'insert', 8, '2024-05-01 07:42:43'),
(126, 'passenger_profile', 'insert', 9, '2024-05-01 07:42:43'),
(127, 'payment', 'insert', 27, '2024-05-01 07:43:07'),
(128, 'flight', 'update', 27, '2024-05-01 07:43:07'),
(129, 'flight', 'update', 27, '2024-05-01 07:43:07'),
(130, 'flight', 'update', 27, '2024-05-01 07:43:07'),
(131, 'passenger_profile', 'delete', 9, '2024-05-01 07:46:35'),
(132, 'payment', 'insert', 27, '2024-05-01 07:47:39'),
(133, 'flight', 'update', 27, '2024-05-01 07:47:39'),
(134, 'flight', 'update', 27, '2024-05-01 07:47:39'),
(135, 'flight', 'update', 27, '2024-05-01 07:47:39'),
(136, 'passenger_profile', 'insert', 9, '2024-05-03 20:13:14'),
(137, 'payment', 'insert', 30, '2024-05-03 20:13:26'),
(138, 'flight', 'update', 30, '2024-05-03 20:13:26'),
(139, 'flight', 'update', 30, '2024-05-03 20:13:26'),
(140, 'passenger_profile', 'delete', 9, '2024-05-03 20:16:18'),
(141, 'passenger_profile', 'insert', 9, '2024-05-03 20:17:13'),
(142, 'payment', 'insert', 30, '2024-05-03 20:17:23'),
(143, 'flight', 'update', 30, '2024-05-03 20:17:23'),
(144, 'flight', 'update', 30, '2024-05-03 20:17:23'),
(145, 'passenger_profile', 'delete', 9, '2024-05-03 21:09:48'),
(146, 'passenger_profile', 'insert', 9, '2024-05-03 21:10:26'),
(147, 'payment', 'insert', 30, '2024-05-03 21:10:45'),
(148, 'flight', 'update', 30, '2024-05-03 21:10:45'),
(149, 'flight', 'update', 30, '2024-05-03 21:10:45');

-- --------------------------------------------------------

--
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `city` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `cities`
--

INSERT INTO `cities` (`city`) VALUES
('San Jose'),
('Chicago'),
('Olisphis'),
('Shiburn'),
('Weling'),
('Chiby'),
('Odonhull'),
('Hegan'),
('Oriaridge'),
('Flerough'),
('Yleigh'),
('Oyladnard'),
('Trerdence'),
('Zhotrora'),
('Otiginia'),
('Plueyby'),
('Vrexledo'),
('Ariosey');

-- --------------------------------------------------------

--
-- Table structure for table `email_notifications`
--

CREATE TABLE `email_notifications` (
  `notification_id` int(11) NOT NULL,
  `flight_id` int(11) DEFAULT NULL,
  `notification_message` varchar(255) DEFAULT NULL,
  `notified_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feedback`
--

CREATE TABLE `feedback` (
  `feed_id` int(11) NOT NULL,
  `email` varchar(50) NOT NULL,
  `q1` varchar(250) NOT NULL,
  `q2` varchar(20) NOT NULL,
  `q3` varchar(250) NOT NULL,
  `rate` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `flight`
--

CREATE TABLE `flight` (
  `flight_id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `arrivale` datetime NOT NULL,
  `departure` datetime NOT NULL,
  `Destination` varchar(20) NOT NULL,
  `source` varchar(20) NOT NULL,
  `airline` varchar(20) NOT NULL,
  `Seats` varchar(110) NOT NULL,
  `duration` varchar(20) NOT NULL,
  `Price` int(11) NOT NULL,
  `status` varchar(6) DEFAULT NULL,
  `issue` varchar(50) DEFAULT NULL,
  `last_seat` varchar(5) DEFAULT '',
  `bus_seats` int(11) DEFAULT 20,
  `last_bus_seat` varchar(5) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `flight`
--

INSERT INTO `flight` (`flight_id`, `admin_id`, `arrivale`, `departure`, `Destination`, `source`, `airline`, `Seats`, `duration`, `Price`, `status`, `issue`, `last_seat`, `bus_seats`, `last_bus_seat`) VALUES
(27, 1, '2024-04-19 20:02:00', '2024-04-19 18:02:00', 'Oriaridge', 'Chiby', 'Echo Airline', '195', '4', 66, '', '', '25A', 20, ''),
(28, 1, '2024-04-23 20:48:00', '2024-04-22 19:45:00', 'Oyladnard', 'Weling', 'Nep Airways', '213', '3', 345, '', '', '21B', 20, ''),
(29, 1, '2024-04-23 20:52:00', '2024-04-23 19:51:00', 'Flerough', 'Yleigh', 'GoldStar Airways', '205', '5', 675, 'issue', '', '', 20, ''),
(30, 1, '2024-04-29 10:54:00', '2024-04-29 08:55:00', 'Flerough', 'Hegan', 'Echo Airline', '213', '7', 879, '', '', '22A', 20, ''),
(31, 1, '2024-04-24 10:56:00', '2024-04-23 05:56:00', 'Hegan', 'Yleigh', 'Blue Airlines', '200', '34', 675, '', '', '', 20, ''),
(32, 1, '2024-04-25 02:57:00', '2024-04-24 20:57:00', 'Zhotrora', 'Shiburn', 'Homelander Airways', '185', '33', 845, '', '', '', 20, ''),
(33, 1, '2024-04-25 07:58:00', '2024-04-25 02:58:00', 'Zhotrora', 'Chiby', 'Aero Airways', '210', '66', 487, '', '', '', 20, ''),
(34, 1, '2024-04-26 20:00:00', '2024-04-26 18:00:00', 'Odonhull', 'Oyladnard', 'Jhon', '200', '77', 378, '', '', '', 20, ''),
(35, 1, '2024-04-27 00:05:00', '2024-04-26 21:00:00', 'Oriaridge', 'Chicago', 'Nep Airways', '204', '84', 1545, '', '', '22E', 20, ''),
(36, 1, '2024-04-27 11:04:00', '2024-04-27 08:01:00', 'Flerough', 'Trerdence', 'Peak Airways', '210', '56', 754, '', '', '', 20, ''),
(37, 1, '2024-04-28 08:02:00', '2024-04-28 06:04:00', 'Oyladnard', 'Zhotrora', 'Delta Airlines', '135', '82', 945, '', '', '', 20, '');

--
-- Triggers `flight`
--
DELIMITER $$
CREATE TRIGGER `flight_audit_trigger` AFTER INSERT ON `flight` FOR EACH ROW BEGIN
    INSERT INTO audit_log (table_name, operation, record_id)
    VALUES ('flight', 'insert', NEW.flight_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `flight_delete_audit_trigger` AFTER DELETE ON `flight` FOR EACH ROW BEGIN
    INSERT INTO audit_log (table_name, operation, record_id)
    VALUES ('flight', 'delete', OLD.flight_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `flight_update_audit_trigger` AFTER UPDATE ON `flight` FOR EACH ROW BEGIN
    INSERT INTO audit_log (table_name, operation, record_id)
    VALUES ('flight', 'update', NEW.flight_id);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `passenger_profile`
--

CREATE TABLE `passenger_profile` (
  `passenger_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL,
  `mobile` varchar(110) NOT NULL,
  `dob` datetime NOT NULL,
  `f_name` varchar(20) DEFAULT NULL,
  `m_name` varchar(20) DEFAULT NULL,
  `l_name` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `passenger_profile`
--

INSERT INTO `passenger_profile` (`passenger_id`, `user_id`, `flight_id`, `mobile`, `dob`, `f_name`, `m_name`, `l_name`) VALUES
(2, 1, 35, '773446523', '2000-02-08 00:00:00', 'isuri', 'j', 'samaranayake'),
(3, 1, 35, '718336754', '2000-03-06 00:00:00', 'isuri', 'j', 'samaranayake'),
(5, 12, 27, '776892255', '2000-02-06 00:00:00', 'kasun', 'k', 'herath'),
(8, 12, 27, '776551078', '2000-02-06 00:00:00', 'kasun', 'k', 'herath'),
(9, 11, 30, '766008527', '1997-02-04 00:00:00', 'Isuru', 'd', 'Bandara');

--
-- Triggers `passenger_profile`
--
DELIMITER $$
CREATE TRIGGER `passenger_profile_audit_trigger` AFTER INSERT ON `passenger_profile` FOR EACH ROW BEGIN
    INSERT INTO audit_log (table_name, operation, record_id)
    VALUES ('passenger_profile', 'insert', NEW.passenger_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `passenger_profile_delete_audit_trigger` AFTER DELETE ON `passenger_profile` FOR EACH ROW BEGIN
    INSERT INTO audit_log (table_name, operation, record_id)
    VALUES ('passenger_profile', 'delete', OLD.passenger_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `passenger_profile_update_audit_trigger` AFTER UPDATE ON `passenger_profile` FOR EACH ROW BEGIN
    INSERT INTO audit_log (table_name, operation, record_id)
    VALUES ('passenger_profile', 'update', NEW.passenger_id);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `card_no` varchar(16) NOT NULL,
  `user_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL,
  `expire_date` varchar(5) DEFAULT NULL,
  `amount` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`card_no`, `user_id`, `flight_id`, `expire_date`, `amount`) VALUES
('1212121232323332', 11, 30, '11/11', 1758),
('1234123412344321', 11, 30, '11/11', 1758),
('1234432112344321', 11, 30, '11/11', 1758),
('2345621347854312', 12, 27, '04/23', 264),
('3476238765124567', 12, 27, '04/15', 132),
('3652764891254367', 12, 27, '04/12', 132),
('3657842896543276', 1, 35, '03/28', 3090),
('4573489651278545', 12, 27, '03/14', 264),
('5487342917651236', 12, 27, '04/23', 264),
('5684397321865493', 1, 35, '04/13', 3090),
('6517638926519835', 1, 35, '03/16', 3090);

--
-- Triggers `payment`
--
DELIMITER $$
CREATE TRIGGER `payment_audit_trigger` AFTER INSERT ON `payment` FOR EACH ROW BEGIN
    INSERT INTO audit_log (table_name, operation, record_id)
    VALUES ('payment', 'insert', NEW.flight_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `payment_delete_audit_trigger` AFTER DELETE ON `payment` FOR EACH ROW BEGIN
    INSERT INTO audit_log (table_name, operation, record_id)
    VALUES ('payment', 'delete', OLD.flight_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `payment_update_audit_trigger` AFTER UPDATE ON `payment` FOR EACH ROW BEGIN
    INSERT INTO audit_log (table_name, operation, record_id)
    VALUES ('payment', 'update', NEW.flight_id);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pwdreset`
--

CREATE TABLE `pwdreset` (
  `pwd_reset_id` int(11) NOT NULL,
  `pwd_reset_email` varchar(50) NOT NULL,
  `pwd_reset_selector` varchar(80) NOT NULL,
  `pwd_reset_token` varchar(120) NOT NULL,
  `pwd_reset_expires` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `pwdreset`
--

INSERT INTO `pwdreset` (`pwd_reset_id`, `pwd_reset_email`, `pwd_reset_selector`, `pwd_reset_token`, `pwd_reset_expires`) VALUES
(1, 'kasun@mail.com', 'f1bbbb70787f14fa', '$2y$10$ywgze5UqG5ksw531ELGHeuT8k98LTadS7Q7ZmaDsZwWsAAYYAUe9G', '1714553376');

-- --------------------------------------------------------

--
-- Table structure for table `ticket`
--

CREATE TABLE `ticket` (
  `ticket_id` int(11) NOT NULL,
  `passenger_id` int(11) NOT NULL,
  `flight_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `seat_no` varchar(10) NOT NULL,
  `cost` int(11) NOT NULL,
  `class` varchar(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `ticket`
--

INSERT INTO `ticket` (`ticket_id`, `passenger_id`, `flight_id`, `user_id`, `seat_no`, `cost`, `class`) VALUES
(71, 8, 27, 12, '24E', 193, 'E'),
(72, 8, 27, 12, '24F', 193, 'E'),
(73, 8, 27, 12, '25A', 193, 'E'),
(78, 8, 27, 12, '24E', 193, 'E'),
(79, 8, 27, 12, '24F', 193, 'E'),
(80, 8, 27, 12, '25A', 193, 'E'),
(81, 9, 30, 11, '21F', 1758, 'E'),
(82, 9, 30, 11, '22A', 1758, 'E');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`) VALUES
(1, 'isuri', 'isuri@mail.com', 'f71459ce3167b35f10e8a18629187876'),
(9, 'Er', 'er@mail.com', '202cb962ac59075b964b07152d234b70'),
(10, 'nimal', 'nimal@mail.com', '202cb962ac59075b964b07152d234b70'),
(11, 'gayan', 'gayan@mail.com', '202cb962ac59075b964b07152d234b70'),
(12, 'kasun', 'kasun@mail.com', '202cb962ac59075b964b07152d234b70'),
(17, 'isuru', 'isuru@gmail.com', '202cb962ac59075b964b07152d234b70'),
(19, 'isurugg', 'test@gmaggil.com', 'f71459ce3167b35f10e8a18629187876');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `admin_uname` (`admin_uname`),
  ADD UNIQUE KEY `admin_email` (`admin_email`),
  ADD UNIQUE KEY `idx_admin_uname` (`admin_uname`),
  ADD UNIQUE KEY `idx_admin_email` (`admin_email`);

--
-- Indexes for table `airline`
--
ALTER TABLE `airline`
  ADD PRIMARY KEY (`airline_id`);

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `table_name` (`table_name`),
  ADD KEY `operation` (`operation`),
  ADD KEY `record_id` (`record_id`),
  ADD KEY `timestamp` (`timestamp`),
  ADD KEY `idx_timestamp` (`timestamp`),
  ADD KEY `idx_table_operation_record` (`table_name`,`operation`,`record_id`);

--
-- Indexes for table `email_notifications`
--
ALTER TABLE `email_notifications`
  ADD PRIMARY KEY (`notification_id`);

--
-- Indexes for table `feedback`
--
ALTER TABLE `feedback`
  ADD PRIMARY KEY (`feed_id`);

--
-- Indexes for table `flight`
--
ALTER TABLE `flight`
  ADD PRIMARY KEY (`flight_id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `source` (`source`),
  ADD KEY `Destination` (`Destination`),
  ADD KEY `airline` (`airline`),
  ADD KEY `status` (`status`),
  ADD KEY `fk_admin_id` (`admin_id`),
  ADD KEY `idx_source` (`source`),
  ADD KEY `idx_destination` (`Destination`),
  ADD KEY `idx_departure` (`departure`),
  ADD KEY `idx_airline` (`airline`),
  ADD KEY `idx_price` (`Price`);

--
-- Indexes for table `passenger_profile`
--
ALTER TABLE `passenger_profile`
  ADD PRIMARY KEY (`passenger_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `flight_id` (`flight_id`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`card_no`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `flight_id` (`flight_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_flight_id` (`flight_id`),
  ADD KEY `idx_card_no` (`card_no`);

--
-- Indexes for table `pwdreset`
--
ALTER TABLE `pwdreset`
  ADD PRIMARY KEY (`pwd_reset_id`);

--
-- Indexes for table `ticket`
--
ALTER TABLE `ticket`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `flight_id` (`flight_id`),
  ADD KEY `passenger_id` (`passenger_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `idx_username` (`username`),
  ADD UNIQUE KEY `idx_email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `airline`
--
ALTER TABLE `airline`
  MODIFY `airline_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=150;

--
-- AUTO_INCREMENT for table `email_notifications`
--
ALTER TABLE `email_notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `feedback`
--
ALTER TABLE `feedback`
  MODIFY `feed_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `flight`
--
ALTER TABLE `flight`
  MODIFY `flight_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `passenger_profile`
--
ALTER TABLE `passenger_profile`
  MODIFY `passenger_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `pwdreset`
--
ALTER TABLE `pwdreset`
  MODIFY `pwd_reset_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ticket`
--
ALTER TABLE `ticket`
  MODIFY `ticket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `flight`
--
ALTER TABLE `flight`
  ADD CONSTRAINT `flight_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`);

--
-- Constraints for table `passenger_profile`
--
ALTER TABLE `passenger_profile`
  ADD CONSTRAINT `passenger_profile_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `passenger_profile_ibfk_2` FOREIGN KEY (`flight_id`) REFERENCES `flight` (`flight_id`);

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `payment_ibfk_2` FOREIGN KEY (`flight_id`) REFERENCES `flight` (`flight_id`);

--
-- Constraints for table `ticket`
--
ALTER TABLE `ticket`
  ADD CONSTRAINT `ticket_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `ticket_ibfk_2` FOREIGN KEY (`flight_id`) REFERENCES `flight` (`flight_id`),
  ADD CONSTRAINT `ticket_ibfk_3` FOREIGN KEY (`passenger_id`) REFERENCES `passenger_profile` (`passenger_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
