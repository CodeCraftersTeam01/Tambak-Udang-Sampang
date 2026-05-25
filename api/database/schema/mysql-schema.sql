/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `kolams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kolams` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pemilik` bigint(20) unsigned NOT NULL,
  `nama_kolam` varchar(255) NOT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `long` decimal(10,7) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '0 Tidak Aktif, 1 Aktif',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `pakans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pakans` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nama_pakan` varchar(255) NOT NULL,
  `jumlah_perminggu_kg` decimal(8,2) NOT NULL DEFAULT 0.00 COMMENT 'Jumlah per minggu dalam KG',
  `kolam_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pakans_kolam_id_foreign` (`kolam_id`),
  CONSTRAINT `pakans_kolam_id_foreign` FOREIGN KEY (`kolam_id`) REFERENCES `kolams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `panens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `panens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tanggal_panen` date NOT NULL,
  `jumlah_panen_kg` decimal(10,2) NOT NULL DEFAULT 0.00,
  `jenis_panen` enum('parsial','total') NOT NULL,
  `kolam_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `panens_kolam_id_foreign` (`kolam_id`),
  CONSTRAINT `panens_kolam_id_foreign` FOREIGN KEY (`kolam_id`) REFERENCES `kolams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `produksis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `produksis` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tanggal_pemasangan_benor` date NOT NULL,
  `ukuran_benor` varchar(255) NOT NULL,
  `kolam_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `produksis_kolam_id_foreign` (`kolam_id`),
  CONSTRAINT `produksis_kolam_id_foreign` FOREIGN KEY (`kolam_id`) REFERENCES `kolams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_role_id_foreign` (`role_id`),
  CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (1,'2026_04_28_050951_create_roles_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (2,'2026_04_28_051000_create_users_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (3,'2026_05_20_090000_create_kolams_table',2);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (4,'2026_05_20_091000_create_produksis_table',2);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (5,'2026_05_20_092000_create_pakans_table',2);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (6,'2026_05_20_093000_create_panens_table',2);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (7,'2026_05_24_151426_add_deleted_at_to_kolams_table',3);
