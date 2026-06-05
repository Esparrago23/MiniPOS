# MiniPOS

Aplicacion Flutter para administrar productos y registrar ventas en un punto de venta pequeno. Se conecta con la API REST de MiniPOS para autenticacion, inventario y ventas.

## Funcionalidades

- Registro e inicio de sesion.
- Alta, consulta, edicion y eliminacion de productos.
- Busqueda de productos por codigo de barras.
- Escaneo con camara.
- Carrito de venta con cantidades, subtotal y total.
- Registro de ventas en la API.
- Tema claro/oscuro con Material Design.

## Tecnologias

- Flutter y Dart.
- Provider para manejo de estado.
- HTTP para consumir la API REST.
- mobile_scanner para lectura de codigos de barras.

## Requisitos

- Flutter instalado.
- API MiniPOS ejecutandose de forma local, en Docker o en un servidor.

## Configurar API

La app no tiene una URL hardcodeada. Debes pasar la URL del backend con `API_BASE_URL`.

Para Flutter Web o pruebas desde la misma PC:

```powershell
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Para Android Emulator:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Para celular fisico:

```powershell
flutter run --dart-define=API_BASE_URL=http://IP_DEL_SERVIDOR:8000
```

## Generar APK de debug

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=http://IP_DEL_SERVIDOR:8000
```

El APK queda en:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Verificacion

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=http://IP_DEL_SERVIDOR:8000
```

## Estructura

- `lib/core`: rutas, red, almacenamiento, dependencias y hardware.
- `lib/features/auth`: autenticacion.
- `lib/features/products`: administracion y busqueda de productos.
- `lib/features/sales`: flujo de venta.
- `lib/shared`: tema visual compartido.

