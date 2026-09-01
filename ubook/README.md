# 📱 ubook

**ubook** es una aplicación social tipo "campus universitario" desarrollada en **Flutter**, con un backend en **PHP + MySQL**. Permite a los usuarios registrarse, publicar posts, chatear en privado o en grupos, unirse a comunidades y organizar recordatorios en un calendario compartido.

> Proyecto desarrollado como trabajo universitario.

## ✨ Funcionalidades

- **Autenticación**: registro e inicio de sesión de usuarios.
- **Feed de publicaciones**: crear posts y darles like.
- **Chat privado**: mensajería 1 a 1 entre usuarios (con soporte para `socket_io_client`).
- **Grupos**: creación de grupos, gestión de miembros y chat grupal.
- **Comunidades**: creación de comunidades, subgrupos dentro de ellas y gestión de miembros.
- **Calendario**: recordatorios personales (crear, editar, eliminar, consultar por día).
- **Notificaciones**: notificaciones dentro de la app.
- **Perfil y ajustes**: foto de perfil, portada y configuración de cuenta.

## 🧱 Estructura del proyecto

```
ubook/
├── mobile/              # App Flutter (frontend)
│   ├── lib/
│   │   ├── config/      # Configuración (URL base de la API)
│   │   ├── services/    # Llamadas HTTP al backend (auth, chat, posts, grupos...)
│   │   └── *.dart       # Pantallas y modelos
│   ├── assets/          # Íconos e imágenes (placeholders, reemplázalos por los tuyos)
│   └── pubspec.yaml
│
└── backend/             # API PHP (backend)
    ├── api/
    │   ├── calendar/    # Endpoints de recordatorios
    │   ├── chat/        # Endpoints de mensajería privada
    │   ├── community/   # Endpoints de comunidades
    │   ├── group/        # Endpoints de grupos
    │   ├── post/         # Endpoints de publicaciones
    │   ├── uploads/      # Imágenes subidas (perfil/portada)
    │   ├── db.php        # Conexión a la base de datos
    │   ├── login.php / register.php / check_email.php / get_notifications.php
    └── database/
        └── ubook.sql     # Script para crear la base de datos y sus tablas
```

## 🛠️ Stack técnico

| Capa       | Tecnología                                   |
|------------|-----------------------------------------------|
| Frontend   | Flutter / Dart                                |
| Backend    | PHP (mysqli)                                  |
| Base de datos | MySQL                                     |
| Tiempo real | socket_io_client (chat)                      |

## ✅ Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.4.4 o superior
- Un servidor local con PHP + MySQL, por ejemplo [XAMPP](https://www.apachefriends.org/) o [Laragon](https://laragon.org/) (Windows/macOS/Linux)
- Un editor como Android Studio o VS Code con los plugins de Flutter/Dart

## 🚀 Cómo correr el proyecto

### 1. Backend (API + base de datos)

1. Instala XAMPP (o similar) y arranca **Apache** y **MySQL**.
2. Copia la carpeta `backend/api` dentro de la carpeta pública de tu servidor:
   - En XAMPP suele ser `C:\xampp\htdocs\api` (Windows) o `/Applications/XAMPP/htdocs/api` (macOS).
3. Crea la base de datos:
   - Abre **phpMyAdmin** (`http://localhost/phpmyadmin`).
   - Crea una base de datos llamada `ubook`.
   - Importa el archivo `backend/database/ubook.sql`.
4. Revisa `backend/api/db.php`: por defecto usa usuario `root` sin contraseña (configuración típica de XAMPP en local). Si tu MySQL tiene otras credenciales, actualízalas ahí.
5. Verifica que la API responde entrando a `http://localhost/api/login.php` en el navegador (debería devolver algún mensaje o error de PHP, no un 404).

### 2. App Flutter (frontend)

1. Entra a la carpeta `mobile/`:
   ```bash
   cd mobile
   flutter pub get
   ```
2. Configura la URL del backend en `mobile/lib/config/api_config.dart`:
   ```dart
   static const String baseUrl = "http://127.0.0.1/api";
   ```
   - **Emulador de Android**: usa `http://10.0.2.2/api` en vez de `127.0.0.1` (Android no puede ver `localhost` de tu PC con ese nombre).
   - **Celular físico**: usa la IP local de tu computador en la misma red Wi-Fi, por ejemplo `http://192.168.1.10/api`.
   - **iOS Simulator / Web / Escritorio**: `http://127.0.0.1/api` funciona normalmente.
3. Corre la app:
   ```bash
   flutter run
   ```


## 👥 Autores

Proyecto desarrollado en conjunto por **Johan David Rodríguez Pérez** y **Juan David Acero Urbano**.

