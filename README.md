# Galería de Fotos Flutter

## Descripción

Esta es una aplicación móvil desarrollada en Flutter que permite a los usuarios guardar fotos localmente utilizando SQLite. La aplicación está diseñada para funcionar sin conexión a Internet, lo que permite a los usuarios tomar y almacenar fotos en cualquier momento. Cuando el dispositivo tiene conexión a Wi-Fi, los usuarios pueden sincronizar sus fotos con una API RESTful, que gestiona las operaciones CRUD y la sincronización de bases de datos SQLite y MySQL.

## Características

- **Almacenamiento Local**: Guarda fotos en la base de datos SQLite sin necesidad de conexión a Internet.
- **Sincronización**: Cuando hay conexión a Wi-Fi, permite a los usuarios sincronizar las fotos almacenadas con la API.
- **Gestión de Errores**: Notifica al usuario si no hay conexión a Internet y no se puede realizar la sincronización.
- **API RESTful**: Interacción con un backend desarrollado en Node.js y Express para gestionar la galería de fotos.

- https://github.com/YisusDev200/photo-gallery-api.git

## Instalación

1. Clona el repositorio:

   ```bash
   https://github.com/YisusDev200/flutter_photo_gallery.git
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Configura las variables de entorno .env

# Uso

```bash
flutter run
```

- Sube las fotos desde tu dispositivo local.

- Las fotos se almacenarán localmente en SQLite.

- Cuando tengas conexión a Wi-Fi, presiona el botón de sincronización para subir las fotos a la API.

- Si no hay conexión a Internet, aparecerá un mensaje notificando que no se puede realizar la sincronización.
