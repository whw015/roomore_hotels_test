-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 24, 2025 at 11:14 AM
-- Server version: 8.0.43-34
-- PHP Version: 8.3.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fjgbsgmy_roomoreDB`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int NOT NULL,
  `hotel_code` varchar(50) NOT NULL,
  `guest_id` int NOT NULL,
  `booking_code` varchar(50) NOT NULL,
  `checkin` date NOT NULL,
  `checkout` date NOT NULL,
  `room_type_en` varchar(100) DEFAULT NULL,
  `room_type_ar` varchar(100) DEFAULT NULL,
  `status` enum('pending','confirmed','checked_in','checked_out','canceled') DEFAULT 'confirmed',
  `total_amount` decimal(10,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'SAR',
  `notes_en` text,
  `notes_ar` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `hotel_code`, `guest_id`, `booking_code`, `checkin`, `checkout`, `room_type_en`, `room_type_ar`, `status`, `total_amount`, `currency`, `notes_en`, `notes_ar`, `created_at`) VALUES
(1, 'default', 1, 'RM-1001', '2025-09-12', '2025-09-15', 'Deluxe King', 'ديلوكس كينغ', 'canceled', 1450.00, 'SAR', 'Sea view\n[CANCEL REASON] ظرف طارئ', 'إطلالة بحرية\n[سبب الإلغاء] ظرف طارئ', '2025-09-05 07:32:40'),
(2, 'default', 1, 'RM-1002', '2025-10-05', '2025-10-08', 'Twin Suite', 'جناح توين', 'pending', 2100.00, 'SAR', 'Late arrival', 'وصول متأخر', '2025-09-05 07:32:40');

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `status` enum('open','checked_out') DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `hotel_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `status`, `created_at`, `hotel_id`) VALUES
(1, 2, 'open', '2025-09-04 18:04:42', 1),
(2, 1, 'open', '2025-09-15 05:08:10', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` int NOT NULL,
  `cart_id` int NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `cart_items`
--

INSERT INTO `cart_items` (`id`, `cart_id`, `item_id`, `quantity`, `created_at`) VALUES
(1, 1, 1, 3, '2025-09-04 18:07:54');

-- --------------------------------------------------------

--
-- Table structure for table `employee_groups`
--

CREATE TABLE `employee_groups` (
  `id` int NOT NULL,
  `hotel_id` int NOT NULL,
  `name` varchar(120) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employee_group_members`
--

CREATE TABLE `employee_group_members` (
  `group_id` int NOT NULL,
  `employee_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `group_permissions`
--

CREATE TABLE `group_permissions` (
  `id` int NOT NULL,
  `group_id` int NOT NULL,
  `can_receive_orders` tinyint(1) NOT NULL DEFAULT '1',
  `can_accept_orders` tinyint(1) NOT NULL DEFAULT '1',
  `can_reject_orders` tinyint(1) NOT NULL DEFAULT '1',
  `can_update_items` tinyint(1) NOT NULL DEFAULT '0',
  `can_manage_sections` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `group_section_assignments`
--

CREATE TABLE `group_section_assignments` (
  `group_id` int NOT NULL,
  `section_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guests`
--

CREATE TABLE `guests` (
  `id` int NOT NULL,
  `hotel_code` varchar(50) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `name_en` varchar(190) DEFAULT NULL,
  `name_ar` varchar(190) DEFAULT NULL,
  `verify_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `guests`
--

INSERT INTO `guests` (`id`, `hotel_code`, `email`, `phone`, `name_en`, `name_ar`, `verify_token`, `created_at`) VALUES
(1, 'default', 'test@example.com', '966500000000', 'Test Guest', 'ضيف تجريبي', 'VX-TEST-12345', '2025-09-05 07:32:40');

-- --------------------------------------------------------

--
-- Table structure for table `hotels`
--

CREATE TABLE `hotels` (
  `id` int NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `hotels`
--

INSERT INTO `hotels` (`id`, `code`, `name`, `slug`, `city`, `created_at`) VALUES
(1, 'RMR001', 'Default Hotel', 'default', 'Najran', '2025-09-05 06:06:26'),
(2, 'RMR2', 'فندق السعادة', 'alsaadah', 'Riyadh', '2025-09-08 04:45:35'),
(3, 'RMR3', 'Sea View Hotel', 'seaview', 'Jeddah', '2025-09-08 04:45:35');

-- --------------------------------------------------------

--
-- Table structure for table `hotel_employees`
--

CREATE TABLE `hotel_employees` (
  `id` int NOT NULL,
  `hotel_id` int NOT NULL,
  `name` varchar(120) NOT NULL,
  `email` varchar(160) DEFAULT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hotel_guests`
--

CREATE TABLE `hotel_guests` (
  `id` int NOT NULL,
  `hotel_id` int NOT NULL,
  `user_id` int NOT NULL,
  `room_number` varchar(20) NOT NULL,
  `status` enum('pending','active','checked_in','checked_out','canceled') NOT NULL DEFAULT 'pending',
  `check_in` date NOT NULL,
  `check_out` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `hotel_guests`
--

INSERT INTO `hotel_guests` (`id`, `hotel_id`, `user_id`, `room_number`, `status`, `check_in`, `check_out`, `created_at`, `updated_at`) VALUES
(1, 2, 1, '521', 'active', '2025-09-08', '2025-09-10', '2025-09-08 14:15:19', NULL),
(2, 2, 1, '521', 'active', '2025-09-08', '2025-09-10', '2025-09-08 21:03:51', NULL),
(3, 2, 1, '521', 'active', '2025-09-08', '2025-09-10', '2025-09-08 21:18:46', NULL),
(4, 2, 1, '521', 'active', '2025-09-08', '2025-09-10', '2025-09-08 21:45:08', NULL),
(5, 1, 1, '101', 'active', '2025-09-13', '2025-09-15', '2025-09-13 00:45:52', '2025-09-13 21:22:52');

-- --------------------------------------------------------

--
-- Table structure for table `hotel_qr_codes`
--

CREATE TABLE `hotel_qr_codes` (
  `id` int NOT NULL,
  `hotel_id` int NOT NULL,
  `code` varchar(64) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `hotel_qr_codes`
--

INSERT INTO `hotel_qr_codes` (`id`, `hotel_id`, `code`, `created_at`) VALUES
(1, 2, 'alsaadah', '2025-09-08 14:15:01'),
(2, 1, 'default', '2025-09-08 14:15:01'),
(3, 3, 'seaview', '2025-09-08 14:15:01');

-- --------------------------------------------------------

--
-- Table structure for table `invoices`
--

CREATE TABLE `invoices` (
  `id` int NOT NULL,
  `hotel_code` varchar(50) NOT NULL,
  `booking_id` int NOT NULL,
  `number` varchar(40) NOT NULL,
  `status` enum('draft','issued','paid','voided') DEFAULT 'issued',
  `currency` varchar(10) DEFAULT 'SAR',
  `subtotal` decimal(10,2) DEFAULT '0.00',
  `tax_amount` decimal(10,2) DEFAULT '0.00',
  `total` decimal(10,2) DEFAULT '0.00',
  `notes_en` text,
  `notes_ar` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `invoices`
--

INSERT INTO `invoices` (`id`, `hotel_code`, `booking_id`, `number`, `status`, `currency`, `subtotal`, `tax_amount`, `total`, `notes_en`, `notes_ar`, `created_at`) VALUES
(1, 'default', 1, 'INV-2025-0001', 'issued', 'SAR', 500.00, 75.00, 575.00, NULL, NULL, '2025-09-05 20:23:14');

-- --------------------------------------------------------

--
-- Table structure for table `invoice_items`
--

CREATE TABLE `invoice_items` (
  `id` int NOT NULL,
  `invoice_id` int NOT NULL,
  `description_en` varchar(255) DEFAULT NULL,
  `description_ar` varchar(255) DEFAULT NULL,
  `qty` decimal(10,2) NOT NULL DEFAULT '1.00',
  `unit_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `sort_order` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `invoice_items`
--

INSERT INTO `invoice_items` (`id`, `invoice_id`, `description_en`, `description_ar`, `qty`, `unit_price`, `total`, `sort_order`) VALUES
(1, 1, 'Room charge', 'رسوم الغرفة', 2.00, 250.00, 500.00, 0);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `title_en` varchar(200) NOT NULL,
  `title_ar` varchar(200) NOT NULL,
  `body_en` text NOT NULL,
  `body_ar` text NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int NOT NULL,
  `hotel_id` int NOT NULL,
  `stay_id` int DEFAULT NULL,
  `status` enum('pending','in_progress','done','canceled') NOT NULL DEFAULT 'pending',
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(3) NOT NULL DEFAULT 'SAR',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `hotel_id`, `stay_id`, `status`, `subtotal`, `tax`, `total`, `currency`, `notes`, `created_at`) VALUES
(1, 1, 2, 4, 'pending', 28.00, 4.20, 32.20, 'SAR', 'بدون سكر', '2025-09-09 01:50:44'),
(2, 1, 2, 4, 'pending', 28.00, 4.20, 32.20, 'SAR', 'بدون سكر', '2025-09-09 01:53:05'),
(3, 1, 2, 4, 'pending', 28.00, 0.00, 28.00, 'SAR', 'بدون سكر', '2025-09-09 01:59:54'),
(4, 1, 2, 4, 'pending', 28.00, 0.00, 28.00, 'SAR', 'بدون سكر', '2025-09-09 02:02:26'),
(5, 1, 2, 4, 'pending', 28.00, 0.00, 28.00, 'SAR', 'بدون سكر', '2025-09-09 02:04:50'),
(6, 1, 2, 4, 'pending', 28.00, 0.00, 28.00, 'SAR', 'بدون سكر', '2025-09-09 02:07:16'),
(7, 1, 1, NULL, 'pending', 24.00, 0.00, 24.00, 'SAR', 'via app', '2025-09-15 08:45:59');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int UNSIGNED NOT NULL,
  `order_id` int UNSIGNED NOT NULL,
  `item_id` int DEFAULT NULL,
  `name_en` varchar(190) DEFAULT NULL,
  `name_ar` varchar(190) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `qty` int NOT NULL DEFAULT '1',
  `line_total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `item_id`, `name_en`, `name_ar`, `price`, `qty`, `line_total`, `created_at`) VALUES
(1, 1, 10, '', 'قهوة عربية', 12.50, 2, 25.00, '2025-09-09 01:50:44'),
(2, 1, 5, 'Water', '', 3.00, 1, 3.00, '2025-09-09 01:50:44'),
(3, 2, 10, '', 'قهوة عربية', 12.50, 2, 25.00, '2025-09-09 01:53:05'),
(4, 2, 5, 'Water', '', 3.00, 1, 3.00, '2025-09-09 01:53:05'),
(5, 3, 10, '', 'قهوة عربية', 12.50, 2, 25.00, '2025-09-09 01:59:54'),
(6, 3, 5, 'Water', '', 3.00, 1, 3.00, '2025-09-09 01:59:54'),
(7, 4, 10, '', 'قهوة عربية', 12.50, 2, 25.00, '2025-09-09 02:02:26'),
(8, 4, 5, 'Water', '', 3.00, 1, 3.00, '2025-09-09 02:02:26'),
(9, 5, 10, '', 'قهوة عربية', 12.50, 2, 25.00, '2025-09-09 02:04:50'),
(10, 5, 5, 'Water', '', 3.00, 1, 3.00, '2025-09-09 02:04:50'),
(11, 6, 10, '', 'قهوة عربية', 12.50, 2, 25.00, '2025-09-09 02:07:16'),
(12, 6, 5, 'Water', '', 3.00, 1, 3.00, '2025-09-09 02:07:16'),
(13, 7, 10, 'Fresh Orange Juice', 'عصير برتقال طازج', 12.00, 2, 24.00, '2025-09-15 08:45:59'),
(14, 7, 5, 'Live Music Night', 'أمسية موسيقية', 0.00, 1, 0.00, '2025-09-15 08:45:59');

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `token` varchar(190) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int NOT NULL,
  `hotel_code` varchar(50) NOT NULL,
  `booking_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(10) DEFAULT 'SAR',
  `method` enum('cash','card','transfer','wallet') DEFAULT 'cash',
  `reference` varchar(100) DEFAULT NULL,
  `status` enum('captured','refunded','voided','failed') DEFAULT 'captured',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `hotel_code`, `booking_id`, `amount`, `currency`, `method`, `reference`, `status`, `notes`, `created_at`) VALUES
(1, 'default', 1, 500.00, 'SAR', 'card', 'AUTH123', 'captured', 'دفعة مقدّم', '2025-09-05 17:21:20');

-- --------------------------------------------------------

--
-- Table structure for table `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` int NOT NULL,
  `token` varchar(128) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `section_employees`
--

CREATE TABLE `section_employees` (
  `id` int NOT NULL,
  `section_id` varchar(64) NOT NULL,
  `employee_id` int DEFAULT NULL,
  `group_id` int DEFAULT NULL,
  `can_accept` tinyint(1) NOT NULL DEFAULT '1',
  `can_reject` tinyint(1) NOT NULL DEFAULT '1',
  `can_view` tinyint(1) NOT NULL DEFAULT '1'
) ;

-- --------------------------------------------------------

--
-- Table structure for table `service_items`
--

CREATE TABLE `service_items` (
  `id` int NOT NULL,
  `section_id` int NOT NULL,
  `name_en` varchar(160) NOT NULL,
  `name_ar` varchar(160) NOT NULL,
  `description_en` text,
  `description_ar` text,
  `price` decimal(10,2) DEFAULT '0.00',
  `image_url` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `hotel_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `service_items`
--

INSERT INTO `service_items` (`id`, `section_id`, `name_en`, `name_ar`, `description_en`, `description_ar`, `price`, `image_url`, `active`, `hotel_id`) VALUES
(1, 1, 'Room Cleaning', 'تنظيف الغرفة', 'Daily room cleaning', 'تنظيف يومي', 10.00, NULL, 1, 1),
(2, 2, 'Airport Pickup', 'توصيل المطار', 'Pickup from airport', 'توصيل من المطار', 25.00, NULL, 1, 1),
(3, 3, 'Sedan - 24h', 'سيدان - 24 ساعة', 'Sedan car rental (24h)', 'تأجير سيارة سيدان (24 ساعة)', 60.00, NULL, 1, 1),
(4, 4, 'Old Town Tour', 'جولة البلدة القديمة', '2h guided tour', 'جولة مرشدة ساعتين', 15.00, NULL, 1, 1),
(5, 5, 'Live Music Night', 'أمسية موسيقية', 'Friday live music', 'أمسية موسيقية الجمعة', 0.00, NULL, 1, 1),
(8, 11, 'Cheeseburger', 'تشيز برغر', 'Grilled beef burger with cheese', 'برغر لحم مشوي مع الجبن', 32.00, NULL, 1, NULL),
(9, 11, 'Caesar Salad', 'سلطة سيزر', 'Classic Caesar salad', 'سلطة سيزر الكلاسيكية', 24.00, NULL, 1, NULL),
(10, 11, 'Fresh Orange Juice', 'عصير برتقال طازج', 'Freshly squeezed orange juice', 'عصير برتقال طبيعي', 12.00, NULL, 1, NULL),
(11, 12, 'Shirt Washing', 'غسيل قميص', 'Standard wash and press', 'غسيل وكوي عادي', 8.00, NULL, 1, NULL),
(12, 12, 'Suit Dry Clean', 'تنظيف جاف للبدلة', 'Dry clean one suit', 'تنظيف جاف لبدلة واحدة', 35.00, NULL, 1, NULL),
(13, 13, 'Full Room Cleaning', 'تنظيف شامل للغرفة', 'Deep cleaning with linen change', 'تنظيف عميق مع تغيير الأغطية', 20.00, NULL, 1, NULL),
(14, 13, 'Towels Replacement', 'استبدال المناشف', 'Replace towels and toiletries', 'استبدال المناشف ومواد الحمّام', 0.00, NULL, 1, NULL),
(15, 2, 'Spa Reservation', 'حجز سبا', 'Partner spa reservation', 'حجز في سبا شريك', 0.00, NULL, 1, NULL),
(16, 4, 'Boulevard Riyadh City', 'بوليفارد رياض سيتي', 'Entertainment and events area', 'منطقة ترفيه وفعاليات', 0.00, NULL, 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `service_sections`
--

CREATE TABLE `service_sections` (
  `id` int NOT NULL,
  `code` varchar(64) NOT NULL,
  `title_en` varchar(160) NOT NULL,
  `title_ar` varchar(160) NOT NULL,
  `hotel_id` int DEFAULT NULL,
  `parentSectionId` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `service_sections`
--

INSERT INTO `service_sections` (`id`, `code`, `title_en`, `title_ar`, `hotel_id`, `parentSectionId`) VALUES
(1, 'hotel_services', 'Hotel Services', 'خدمات الفندق', 1, NULL),
(2, 'external_services', 'External Services', 'الخدمات الخارجية', 1, NULL),
(3, 'car_rental', 'Car Rental', 'تأجير سيارات', 1, NULL),
(4, 'tourist_places', 'Tourist Places', 'الأماكن السياحية', 1, NULL),
(5, 'events', 'Events', 'الفعاليات', 1, NULL),
(11, 'food_beverage', 'Food & Beverage', 'مأكولات ومشروبات', NULL, NULL),
(12, 'laundry', 'Laundry', 'غسيل الملابس', NULL, NULL),
(13, 'room_cleaning', 'Room Cleaning', 'تنظيف الغرفة', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `stays`
--

CREATE TABLE `stays` (
  `id` int NOT NULL,
  `hotel_id` int NOT NULL,
  `guest_email` varchar(190) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `guest_phone` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nationality` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `age` int DEFAULT NULL,
  `room_number` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `check_in` datetime DEFAULT NULL,
  `check_out` datetime DEFAULT NULL,
  `status` enum('active','checked_out') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `user_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stays`
--

INSERT INTO `stays` (`id`, `hotel_id`, `guest_email`, `guest_phone`, `first_name`, `last_name`, `gender`, `nationality`, `age`, `room_number`, `check_in`, `check_out`, `status`, `user_id`, `created_at`) VALUES
(1, 1, 'wael@example.com', '966501234567', 'وائل', 'شملان', 'male', 'SA', 30, '521', '2025-09-04 00:20:34', '2025-09-07 00:20:34', 'active', NULL, '2025-09-05 06:20:34'),
(2, 1, 'nazeel.ar@example.com', '966501111111', 'أحمد', 'الغامدي', 'ذكر', 'السعودية', 35, '210', '2025-09-04 00:30:36', '2025-09-08 00:30:36', 'active', NULL, '2025-09-05 06:30:36'),
(3, 1, 'guest.en@example.com', '966502222222', 'John', 'Smith', 'male', 'USA', 29, '305', '2025-09-03 00:30:52', '2025-09-10 00:30:52', 'active', NULL, '2025-09-05 06:30:52'),
(4, 2, 'wael@example.com', NULL, 'Wael', 'Shamlan', NULL, NULL, NULL, '521', '2025-09-07 07:45:35', '2025-09-10 07:45:35', 'active', NULL, '2025-09-08 04:45:35'),
(5, 2, NULL, '0550009521', 'Sara', 'Khaled', NULL, NULL, NULL, '305', '2025-09-07 07:45:35', '2025-09-09 07:45:35', 'active', NULL, '2025-09-08 04:45:35'),
(6, 2, 'omar@example.com', NULL, 'Omar', 'Nasser', NULL, NULL, NULL, '110', '2025-09-06 07:45:35', '2025-09-07 07:45:35', 'checked_out', NULL, '2025-09-08 04:45:35'),
(7, 3, 'layla@example.com', NULL, 'Layla', 'Hamad', NULL, NULL, NULL, '207', '2025-09-07 07:45:35', '2025-09-09 07:45:35', 'active', NULL, '2025-09-08 04:45:35'),
(8, 1, 'test@example.com', NULL, 'Test', 'User', NULL, NULL, NULL, '101', '2025-09-13 00:45:52', '2025-09-15 21:22:52', 'active', 1, '2025-09-13 06:45:52');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `age` smallint DEFAULT NULL,
  `accepted_terms` tinyint(1) NOT NULL DEFAULT '0',
  `avatar_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `first_name`, `last_name`, `age`, `accepted_terms`, `avatar_url`, `created_at`, `updated_at`) VALUES
(1, 'test@example.com', '$2y$10$c/MlRCTEG2ecJj1y2oLd3uJ/E1R71QVFI2T6prTya3aaQww4GnXF2', 'Test', 'User', 28, 1, NULL, '2025-09-02 20:18:18', '2025-09-07 02:37:40'),
(2, 'dev@example.com', '$2y$10$JvUfloRWb5LMbrjzjMI4E.E.ZuAntg26dyqjuER.dYr.Xddr.eLx6', 'Dev', 'User', 28, 1, NULL, '2025-09-02 20:21:56', '2025-09-02 20:21:56'),
(4, 'test500@example.com', '$2y$10$F/4iGr2Lui8frsSvdgBvdupI17yvwPtK3IAZ08MyTtnepezysWxjC', 'Test', 'User', 28, 1, NULL, '2025-09-06 16:00:06', '2025-09-06 16:00:06'),
(6, 'tester@example.com', '$2y$10$eQs44vWr1Yu2uAYL5T3hK.0c.hmh3p7JvMHGdNNd89NgEgOV3Ff0W', 'Test', 'User', 28, 1, NULL, '2025-09-07 02:44:43', '2025-09-07 02:44:43'),
(7, 'tes5ter@example.com', '$2y$10$Sr9syIOMkCJlL/uHTwdGLejVloCihgMuXhIYqv2QIBgXLkLCK62va', 'Test', 'User', 28, 1, NULL, '2025-09-07 08:27:54', '2025-09-07 08:27:54'),
(8, 'tes55ter@example.com', '$2y$10$QgLWjB3RE4UelxZNyy7HO.SK3OysnOUz/HIDLoPuEnMaWJfiRScYi', 'Test', 'User', 28, 1, NULL, '2025-09-07 08:30:45', '2025-09-07 08:30:45'),
(9, 'tes555ter@example.com', '$2y$10$GaO4dQLczAA8DSTs413VQOdDhkyp1yeRzAumUWj0qw2tlWS6gxq5K', 'Test', 'User', 28, 1, NULL, '2025-09-07 08:58:48', '2025-09-07 08:58:48'),
(10, 'tes5755ter@example.com', '$2y$10$5ZzTDYImLyLGII6iXEt7nuRT9l/SIxLJoPm55XBILaGWVZGL2iyZq', 'Test', 'User', 28, 1, NULL, '2025-09-07 09:33:21', '2025-09-07 09:33:21');

-- --------------------------------------------------------

--
-- Table structure for table `work_groups`
--

CREATE TABLE `work_groups` (
  `id` int NOT NULL,
  `hotel_id` int NOT NULL,
  `code` varchar(64) NOT NULL,
  `name_ar` varchar(255) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `work_group_permissions`
--

CREATE TABLE `work_group_permissions` (
  `id` int NOT NULL,
  `group_id` int NOT NULL,
  `permission` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_booking_code` (`booking_code`),
  ADD KEY `guest_id` (`guest_id`);

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cart_id` (`cart_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `employee_groups`
--
ALTER TABLE `employee_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_group_name` (`hotel_id`,`name`),
  ADD KEY `idx_group_hotel` (`hotel_id`);

--
-- Indexes for table `employee_group_members`
--
ALTER TABLE `employee_group_members`
  ADD PRIMARY KEY (`group_id`,`employee_id`),
  ADD KEY `employee_id` (`employee_id`);

--
-- Indexes for table `group_permissions`
--
ALTER TABLE `group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `group_section_assignments`
--
ALTER TABLE `group_section_assignments`
  ADD PRIMARY KEY (`group_id`,`section_id`),
  ADD KEY `idx_gsa_section` (`section_id`);

--
-- Indexes for table `guests`
--
ALTER TABLE `guests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_guest_hotel_email` (`hotel_code`,`email`),
  ADD UNIQUE KEY `uq_guest_hotel_phone` (`hotel_code`,`phone`);

--
-- Indexes for table `hotels`
--
ALTER TABLE `hotels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD UNIQUE KEY `uq_hotels_code` (`code`);

--
-- Indexes for table `hotel_employees`
--
ALTER TABLE `hotel_employees`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_hotel_email` (`hotel_id`,`email`),
  ADD KEY `idx_emp_hotel` (`hotel_id`);

--
-- Indexes for table `hotel_guests`
--
ALTER TABLE `hotel_guests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `status` (`status`),
  ADD KEY `check_in` (`check_in`),
  ADD KEY `check_out` (`check_out`);

--
-- Indexes for table `hotel_qr_codes`
--
ALTER TABLE `hotel_qr_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `hotel_id` (`hotel_id`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_invoice_number` (`number`),
  ADD KEY `idx_hotel_booking` (`hotel_code`,`booking_id`);

--
-- Indexes for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_invoice` (`invoice_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `stay_id` (`stay_id`),
  ADD KEY `status` (`status`),
  ADD KEY `idx_orders_hotel_created` (`hotel_id`,`created_at`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_hotel_booking` (`hotel_code`,`booking_id`),
  ADD KEY `fk_payments_booking` (`booking_id`);

--
-- Indexes for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `expires_at` (`expires_at`);

--
-- Indexes for table `section_employees`
--
ALTER TABLE `section_employees`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_se_emp` (`employee_id`),
  ADD KEY `fk_se_group` (`group_id`);

--
-- Indexes for table `service_items`
--
ALTER TABLE `service_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_items_hotel_section` (`hotel_id`,`section_id`),
  ADD KEY `idx_items_section_active` (`section_id`,`active`);

--
-- Indexes for table `service_sections`
--
ALTER TABLE `service_sections`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_sections_hotel_parent` (`hotel_id`,`parentSectionId`),
  ADD KEY `idx_sections_hotel_parent_v2` (`hotel_id`,`parentSectionId`);

--
-- Indexes for table `stays`
--
ALTER TABLE `stays`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_hotel_guest` (`hotel_id`,`guest_email`,`guest_phone`),
  ADD KEY `idx_dates` (`check_in`,`check_out`),
  ADD KEY `idx_stays_user` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `work_groups`
--
ALTER TABLE `work_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_group_hotel_code` (`hotel_id`,`code`);

--
-- Indexes for table `work_group_permissions`
--
ALTER TABLE `work_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_group_permission` (`group_id`,`permission`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `carts`
--
ALTER TABLE `carts`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `employee_groups`
--
ALTER TABLE `employee_groups`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `group_permissions`
--
ALTER TABLE `group_permissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guests`
--
ALTER TABLE `guests`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `hotels`
--
ALTER TABLE `hotels`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `hotel_employees`
--
ALTER TABLE `hotel_employees`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hotel_guests`
--
ALTER TABLE `hotel_guests`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `hotel_qr_codes`
--
ALTER TABLE `hotel_qr_codes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `invoice_items`
--
ALTER TABLE `invoice_items`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `section_employees`
--
ALTER TABLE `section_employees`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `service_items`
--
ALTER TABLE `service_items`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `service_sections`
--
ALTER TABLE `service_sections`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `stays`
--
ALTER TABLE `stays`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `work_groups`
--
ALTER TABLE `work_groups`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `work_group_permissions`
--
ALTER TABLE `work_group_permissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`);

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `service_items` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `employee_group_members`
--
ALTER TABLE `employee_group_members`
  ADD CONSTRAINT `employee_group_members_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `employee_groups` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `employee_group_members_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `hotel_employees` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `group_permissions`
--
ALTER TABLE `group_permissions`
  ADD CONSTRAINT `group_permissions_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `employee_groups` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `group_section_assignments`
--
ALTER TABLE `group_section_assignments`
  ADD CONSTRAINT `group_section_assignments_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `employee_groups` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `group_section_assignments_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `service_sections` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `hotel_guests`
--
ALTER TABLE `hotel_guests`
  ADD CONSTRAINT `fk_guest_hotel` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_guest_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `hotel_qr_codes`
--
ALTER TABLE `hotel_qr_codes`
  ADD CONSTRAINT `fk_qr_hotel` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_hotel` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE RESTRICT;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `password_resets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_payments_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`);

--
-- Constraints for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD CONSTRAINT `fk_refresh_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `section_employees`
--
ALTER TABLE `section_employees`
  ADD CONSTRAINT `fk_se_emp` FOREIGN KEY (`employee_id`) REFERENCES `hotel_employees` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_se_group` FOREIGN KEY (`group_id`) REFERENCES `work_groups` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `service_items`
--
ALTER TABLE `service_items`
  ADD CONSTRAINT `service_items_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `service_sections` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `work_group_permissions`
--
ALTER TABLE `work_group_permissions`
  ADD CONSTRAINT `fk_wgp_group` FOREIGN KEY (`group_id`) REFERENCES `work_groups` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
