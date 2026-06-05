# MiniPOS

Aplicacion Flutter para administrar productos y registrar ventas en un punto de venta pequeno. Incluye inicio de sesion, registro de usuarios, CRUD de productos, busqueda por codigo de barras, escaneo con camara y resumen de venta.

## Funcionalidades principales

- Autenticacion de usuario.
- Alta, consulta, edicion y eliminacion de productos.
- Busqueda manual o por camara usando codigos de barras.
- Carrito de venta con cantidades, subtotal, total y registro final.
- Tema claro/oscuro usando Material Design.

## Tecnologias

- Flutter y Dart.
- Provider para estado.
- HTTP para comunicacion con API REST.
- mobile_scanner para lectura de codigos de barras.

## Configuracion de API

La URL del servidor no esta hardcodeada en el proyecto. Debe enviarse al ejecutar o compilar usando `API_BASE_URL`.

```powershell
flutter run --dart-define=API_BASE_URL=http://TU_SERVIDOR:8000
```

Para generar APK de debug:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=http://TU_SERVIDOR:8000
```

Si no se define `API_BASE_URL`, la app puede compilar, pero las operaciones que dependen del servidor no funcionaran.

## Comandos de verificacion

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=http://TU_SERVIDOR:8000
```

## Estructura general

- `lib/core`: configuracion comun, rutas, red, almacenamiento y hardware.
- `lib/features/auth`: autenticacion.
- `lib/features/products`: administracion de productos.
- `lib/features/sales`: flujo de ventas.
- `lib/shared`: tema visual compartido.
