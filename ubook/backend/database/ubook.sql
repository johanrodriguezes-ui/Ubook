-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-10-2024 a las 04:43:13
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ubook`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `calendar`
--

CREATE TABLE `calendar` (
  `reminder_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `creation_date` datetime DEFAULT current_timestamp(),
  `reminder_message` text NOT NULL,
  `reminder_date` date NOT NULL,
  `is_completed` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `chatlist`
--

CREATE TABLE `chatlist` (
  `chatlist_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `chat_partner_id` int(11) NOT NULL,
  `last_message` text NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `chatlist`
--

INSERT INTO `chatlist` (`chatlist_id`, `user_id`, `chat_partner_id`, `last_message`, `timestamp`) VALUES
(3, 7, 8, 'al fin funciona', '2024-10-10 20:24:40'),
(4, 8, 9, 'ojala', '2024-10-11 23:00:07'),
(5, 6, 9, 'hola', '2024-10-17 00:12:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `communities`
--

CREATE TABLE `communities` (
  `community_id` int(11) NOT NULL,
  `community_name` varchar(255) NOT NULL,
  `community_image` varchar(255) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmessage_c` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `communities`
--

INSERT INTO `communities` (`community_id`, `community_name`, `community_image`, `created_by`, `created_at`, `lastmessage_c`) VALUES
(3, 'los picudos', '', 6, '2024-10-16 19:17:33', ''),
(4, 'ggggggg', '', 6, '2024-10-16 20:07:43', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `community_groups`
--

CREATE TABLE `community_groups` (
  `community_group_id` int(11) NOT NULL,
  `community_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `community_groups`
--

INSERT INTO `community_groups` (`community_group_id`, `community_id`, `group_id`) VALUES
(1, 4, 6),
(2, 3, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `community_members`
--

CREATE TABLE `community_members` (
  `id` int(11) NOT NULL,
  `community_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `community_members`
--

INSERT INTO `community_members` (`id`, `community_id`, `user_id`, `joined_at`) VALUES
(1, 4, 6, '2024-10-16 20:07:43');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dateperson`
--

CREATE TABLE `dateperson` (
  `uid` int(11) NOT NULL,
  `identy` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile` varchar(255) DEFAULT NULL,
  `cover` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `search` varchar(255) DEFAULT NULL,
  `facebook` varchar(255) DEFAULT NULL,
  `instagram` varchar(255) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `program` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `dateperson`
--

INSERT INTO `dateperson` (`uid`, `identy`, `name`, `email`, `password`, `profile`, `cover`, `status`, `search`, `facebook`, `instagram`, `birthdate`, `program`) VALUES
(6, 11, '22', '22', '$2y$10$YW25amBnbq5tmylk14yrPuGK48kZ/VUTMGhq4i4cI1g38t6vIcsIm', NULL, NULL, NULL, NULL, NULL, NULL, '2024-10-01', 'Ingeniería Agroindustrial'),
(7, 34, '33', '33', '$2y$10$E9atZ6S0LHaF4.d7ttoEGOJYiwavX2HNuKDFrnu0rO48XtKPonK3G', NULL, NULL, NULL, NULL, NULL, NULL, '2024-10-01', 'Ingeniería Agroindustrial'),
(8, 44, '44', '44', '$2y$10$gE49BCaxCMs6OPm0DC0R1uGzoiz8waP1mSwrdrSEXet77y9NjEyfO', NULL, NULL, NULL, NULL, NULL, NULL, '2024-10-07', 'Ingeniería Agroindustrial'),
(9, 55, '55', '55', '$2y$10$huvJoNqStgCYHbt67lVpOeAB7KBj3/GuN1hEcaTureoDI9lJVdK5S', NULL, NULL, NULL, NULL, NULL, NULL, '2024-10-02', 'Contaduría Pública');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `groupmembers`
--

CREATE TABLE `groupmembers` (
  `idgroupmembers` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `groupmembers`
--

INSERT INTO `groupmembers` (`idgroupmembers`, `group_id`, `user_id`) VALUES
(2, 5, 6),
(3, 6, 6),
(4, 5, 9),
(5, 5, 8),
(6, 6, 9);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `groupmessages`
--

CREATE TABLE `groupmessages` (
  `idgroupmessages` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `message` text DEFAULT NULL,
  `is_seengmessages` tinyint(1) DEFAULT 0,
  `url` varchar(255) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `groupmessages`
--

INSERT INTO `groupmessages` (`idgroupmessages`, `group_id`, `sender_id`, `message`, `is_seengmessages`, `url`, `timestamp`) VALUES
(1, 6, 6, 'holaaaa', 0, '', '2024-10-12 21:39:39'),
(2, 6, 9, 'holaaa', 0, '', '2024-10-12 21:41:13'),
(3, 5, 6, 'holaaaa', 0, '', '2024-10-12 23:45:32'),
(4, 6, 6, 'Asi esta mejor', 0, '', '2024-10-13 01:35:29'),
(5, 5, 6, 'hey', 0, '', '2024-10-16 23:44:43'),
(6, 6, 6, 'eso debe cambiar', 0, '', '2024-10-16 23:45:23'),
(7, 5, 6, 'que tal?', 0, '', '2024-10-17 00:32:05'),
(8, 5, 9, 'ni idea', 0, '', '2024-10-17 00:32:16'),
(9, 5, 6, 'oye', 0, '', '2024-10-17 01:11:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `groups`
--

CREATE TABLE `groups` (
  `group_id` int(11) NOT NULL,
  `group_name` varchar(255) NOT NULL,
  `group_image` varchar(255) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastmessage` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `groups`
--

INSERT INTO `groups` (`group_id`, `group_name`, `group_image`, `created_by`, `created_at`, `lastmessage`) VALUES
(5, 'kamimases 2', 'flutter_icon_default', 6, '2024-10-12 03:29:21', 'oye'),
(6, 'jopos', 'flutter_icon_default', 6, '2024-10-12 03:47:21', 'eso debe cambiar');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `messages`
--

CREATE TABLE `messages` (
  `message_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `message` text DEFAULT NULL,
  `is_seenmessages` tinyint(1) DEFAULT 0,
  `url` varchar(255) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `messages`
--

INSERT INTO `messages` (`message_id`, `sender_id`, `receiver_id`, `message`, `is_seenmessages`, `url`, `timestamp`) VALUES
(6, 7, 8, 'hola', 0, NULL, '2024-10-10 16:44:44'),
(8, 8, 7, 'que tal?', 0, NULL, '2024-10-10 16:54:32'),
(9, 8, 7, 'parece que falla el globa', 0, NULL, '2024-10-10 16:54:52'),
(11, 8, 7, 'gggg', 0, NULL, '2024-10-10 19:53:06'),
(12, 8, 9, 'gggg', 0, NULL, '2024-10-10 20:06:21'),
(13, 8, 9, 'gggg', 0, NULL, '2024-10-10 20:06:46'),
(14, 8, 7, 'genial', 0, NULL, '2024-10-10 20:23:36'),
(15, 8, 7, 'al fin funciona', 0, NULL, '2024-10-10 20:23:50'),
(16, 8, 7, 'al fin funciona', 0, NULL, '2024-10-10 20:24:40'),
(17, 6, 9, 'hola', 0, NULL, '2024-10-11 21:07:01'),
(18, 6, 9, 'que paso?', 0, NULL, '2024-10-11 21:07:13'),
(19, 6, 9, 'hola', 0, NULL, '2024-10-11 22:31:38'),
(20, 6, 9, 'holaaaaa', 0, NULL, '2024-10-11 22:42:19'),
(21, 9, 6, 'holaaa', 0, NULL, '2024-10-11 22:54:43'),
(22, 6, 9, 'se arreglo', 0, NULL, '2024-10-11 22:55:14'),
(23, 9, 6, 'siii', 0, NULL, '2024-10-11 22:57:07'),
(24, 9, 6, 'que bien', 0, NULL, '2024-10-11 22:57:20'),
(25, 6, 9, 'haber si asi es mas rapido', 0, NULL, '2024-10-11 22:58:21'),
(26, 9, 6, 'parece que si', 0, NULL, '2024-10-11 22:58:32'),
(27, 9, 8, 'ojala', 0, NULL, '2024-10-11 23:00:07'),
(28, 6, 9, 'parece bien supon', 0, NULL, '2024-10-11 23:00:26'),
(30, 6, 9, 'parece bien supon', 0, NULL, '2024-10-11 23:28:32'),
(31, 6, 9, 'holaaa', 0, NULL, '2024-10-12 20:22:00'),
(32, 6, 9, 'lo envio dos veces', 0, NULL, '2024-10-12 20:22:16'),
(33, 6, 9, 'esta raro', 0, NULL, '2024-10-12 20:22:30'),
(34, 6, 9, 'se cambio', 0, NULL, '2024-10-12 20:22:44'),
(35, 6, 9, 'hhhh', 0, NULL, '2024-10-16 23:49:15'),
(36, 6, 9, 'hey', 0, NULL, '2024-10-17 00:01:01'),
(37, 6, 9, 'no se que pasa', 0, NULL, '2024-10-17 00:01:12'),
(38, 6, 9, 'tal vez no funciona', 0, NULL, '2024-10-17 00:01:22'),
(39, 6, 9, 'sdsd', 0, NULL, '2024-10-17 00:01:26'),
(40, 6, 9, 'dsdsdsd', 0, NULL, '2024-10-17 00:01:34'),
(41, 6, 9, 'dsdsdsdsd', 0, NULL, '2024-10-17 00:01:36'),
(42, 6, 9, 'dsdsdsds', 0, NULL, '2024-10-17 00:01:38'),
(43, 6, 9, 'dsdsdsd', 0, NULL, '2024-10-17 00:01:41'),
(44, 6, 9, 'ddsdsdsd', 0, NULL, '2024-10-17 00:01:43'),
(45, 6, 9, 'hola', 0, NULL, '2024-10-17 00:12:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `is_read`, `created_at`) VALUES
(115, 11, 'Nuevo post añadido', 'Un usuario ha publicado: hola princesa', 0, '2024-10-17 09:16:27'),
(116, 34, 'Nuevo post añadido', 'Un usuario ha publicado: hola princesa', 0, '2024-10-17 09:16:27'),
(117, 44, 'Nuevo post añadido', 'Un usuario ha publicado: hola princesa', 0, '2024-10-17 09:16:27'),
(118, 55, 'Nuevo post añadido', 'Un usuario ha publicado: hola princesa', 0, '2024-10-17 09:16:27'),
(119, 11, 'Nuevo post añadido', 'Un usuario ha publicado: hola queridimos', 0, '2024-10-17 09:31:09'),
(120, 34, 'Nuevo post añadido', 'Un usuario ha publicado: hola queridimos', 0, '2024-10-17 09:31:09'),
(121, 44, 'Nuevo post añadido', 'Un usuario ha publicado: hola queridimos', 0, '2024-10-17 09:31:09'),
(122, 55, 'Nuevo post añadido', 'Un usuario ha publicado: hola queridimos', 0, '2024-10-17 09:31:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `posts`
--

CREATE TABLE `posts` (
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `post_date` datetime DEFAULT current_timestamp(),
  `likes` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `posts`
--

INSERT INTO `posts` (`post_id`, `user_id`, `content`, `post_date`, `likes`) VALUES
(3, 6, 'hola princesa', '2024-10-16 21:16:26', 3),
(4, 6, 'hola queridimos', '2024-10-16 21:31:08', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tokens`
--

CREATE TABLE `tokens` (
  `user_id` int(11) NOT NULL,
  `token` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `calendar`
--
ALTER TABLE `calendar`
  ADD PRIMARY KEY (`reminder_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `chatlist`
--
ALTER TABLE `chatlist`
  ADD PRIMARY KEY (`chatlist_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `chat_partner_id` (`chat_partner_id`);

--
-- Indices de la tabla `communities`
--
ALTER TABLE `communities`
  ADD PRIMARY KEY (`community_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indices de la tabla `community_groups`
--
ALTER TABLE `community_groups`
  ADD PRIMARY KEY (`community_group_id`),
  ADD KEY `community_id` (`community_id`),
  ADD KEY `group_id` (`group_id`);

--
-- Indices de la tabla `community_members`
--
ALTER TABLE `community_members`
  ADD PRIMARY KEY (`id`),
  ADD KEY `community_id` (`community_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `dateperson`
--
ALTER TABLE `dateperson`
  ADD PRIMARY KEY (`uid`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `groupmembers`
--
ALTER TABLE `groupmembers`
  ADD PRIMARY KEY (`idgroupmembers`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `groupmessages`
--
ALTER TABLE `groupmessages`
  ADD PRIMARY KEY (`idgroupmessages`),
  ADD KEY `group_id` (`group_id`),
  ADD KEY `sender_id` (`sender_id`);

--
-- Indices de la tabla `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`group_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indices de la tabla `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `receiver_id` (`receiver_id`);

--
-- Indices de la tabla `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`post_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indices de la tabla `tokens`
--
ALTER TABLE `tokens`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `calendar`
--
ALTER TABLE `calendar`
  MODIFY `reminder_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `chatlist`
--
ALTER TABLE `chatlist`
  MODIFY `chatlist_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `communities`
--
ALTER TABLE `communities`
  MODIFY `community_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `community_groups`
--
ALTER TABLE `community_groups`
  MODIFY `community_group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `community_members`
--
ALTER TABLE `community_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `dateperson`
--
ALTER TABLE `dateperson`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `groupmembers`
--
ALTER TABLE `groupmembers`
  MODIFY `idgroupmembers` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `groupmessages`
--
ALTER TABLE `groupmessages`
  MODIFY `idgroupmessages` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `groups`
--
ALTER TABLE `groups`
  MODIFY `group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT de la tabla `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=123;

--
-- AUTO_INCREMENT de la tabla `posts`
--
ALTER TABLE `posts`
  MODIFY `post_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `calendar`
--
ALTER TABLE `calendar`
  ADD CONSTRAINT `calendar_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `dateperson` (`uid`);

--
-- Filtros para la tabla `chatlist`
--
ALTER TABLE `chatlist`
  ADD CONSTRAINT `chatlist_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `dateperson` (`uid`) ON DELETE CASCADE,
  ADD CONSTRAINT `chatlist_ibfk_2` FOREIGN KEY (`chat_partner_id`) REFERENCES `dateperson` (`uid`) ON DELETE CASCADE;

--
-- Filtros para la tabla `communities`
--
ALTER TABLE `communities`
  ADD CONSTRAINT `communities_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `dateperson` (`uid`) ON DELETE CASCADE;

--
-- Filtros para la tabla `community_groups`
--
ALTER TABLE `community_groups`
  ADD CONSTRAINT `community_groups_ibfk_1` FOREIGN KEY (`community_id`) REFERENCES `communities` (`community_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `community_groups_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `community_members`
--
ALTER TABLE `community_members`
  ADD CONSTRAINT `community_members_ibfk_1` FOREIGN KEY (`community_id`) REFERENCES `communities` (`community_id`),
  ADD CONSTRAINT `community_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `dateperson` (`uid`);

--
-- Filtros para la tabla `groupmembers`
--
ALTER TABLE `groupmembers`
  ADD CONSTRAINT `groupmembers_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `groupmembers_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `dateperson` (`uid`) ON DELETE CASCADE;

--
-- Filtros para la tabla `groupmessages`
--
ALTER TABLE `groupmessages`
  ADD CONSTRAINT `groupmessages_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `groupmessages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `dateperson` (`uid`) ON DELETE CASCADE;

--
-- Filtros para la tabla `groups`
--
ALTER TABLE `groups`
  ADD CONSTRAINT `groups_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `dateperson` (`uid`) ON DELETE CASCADE;

--
-- Filtros para la tabla `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `dateperson` (`uid`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `dateperson` (`uid`) ON DELETE CASCADE;

--
-- Filtros para la tabla `posts`
--
ALTER TABLE `posts`
  ADD CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `dateperson` (`uid`);

--
-- Filtros para la tabla `tokens`
--
ALTER TABLE `tokens`
  ADD CONSTRAINT `tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `dateperson` (`uid`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
