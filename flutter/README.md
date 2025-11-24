# EcoBocado · Flutter

> Este readme se irá actualizando a medida que la aplicación vaya creciendo, se centrará solamente en la parte técnica de flutter.

![Identidad visual](assets/images/logo.jpg)

Aplicación multiplataforma (iOS, Android, web y escritorio) para el restaurante EcoBocado. Permite a clientes ver y comprar los platos disponibles de comida para llevar y reservar una hora concreta evitando colas y los administradores consultar y modificar todos los productos, además de ver la facturación total mediante el uso de la aplicación, ambos usuarios deben autenticarse para gestionar su perfil y a nivel de aplicación se permite ajustar preferencias locales como el tema, idioma o envío de notificaciones.

## Objetivo y alcance
- Centralizar la experiencia zero-waste del EcoBocado en una sola app con navegación adaptada a clientes y administradores.


## Arquitectura funcional
- **Estado y DI:** `flutter_riverpod` para auth, perfil y preferencias (`authProvider`, `profileProvider`, `preferencesProvider`).
- **Ruteo:** `go_router` + `ShellRoute` (`lib/app/router.dart`) para compartir `AppShell` y adaptar tabs según rol (usuario o admin).
- **Tema:** `AppTheme` y `AppPalette` controlan modo claro/oscuro; el `PreferencesNotifier` activa automáticamente el `ThemeMode`.
- **Networking:** `dio` configurado en `core/utils/app_services.dart` con interceptores para agregar `Bearer` y refrescar tokens.
- **Catálogo de UI:** Cada widget core se demuestra en `lib/catalog` y se puede navegar desde la pantalla de ajustes.

## Catálogo de componentes
El catálogo expone los componentes reutilizables con su objetivo, archivo fuente y rutas donde se usan. Cada demo incluye capturas interactuando con los widgets dentro de la app (ver **Preferencias → Ver Catálogo**).

| Grupo | Objetivo | Widgets / archivo | Uso en la app | Captura |
| --- | --- | --- | --- | --- |
| Botones | CTA primarios/estado de formularios | `AppButton`, `AppFormSubmit` (`lib/core/widgets/app_button.dart`, `app_form_submit.dart`) | Home, Auth, Orders, Profile | `ButtonsDemo` muestra variantes primary/danger (`lib/catalog/demos/buttons_demo.dart`). |
| Formularios | Inputs validados y accesibles | `AppTextField`, `AppPasswordField` (`lib/core/widgets/*field.dart`) | Login, Register, Profile | `InputsDemo` reproduce el formulario de autenticación. |
| Etiquetas | Badges con variantes filled/outline | `AppBadge` (`lib/core/widgets/app_badge.dart`) | Home, Shop, Orders | `BadgesDemo` incluye capturas con iconos y tamaños. |
| Tarjetas | Tarjetas ricas para platos y pedidos | `FoodMenuCard`, `OrderCard` (`lib/features/shop/.../food_menu_card.dart`, `features/orders/.../order_card.dart`) | Home, Shop, Orders | `CardsDemo` reutiliza imágenes de `assets/images/home.jpg` para documentar cada card. |
| Layout & feedback | Barras, loaders y snackbars consistentes | `PrimaryCtaBar`, `AppLoader`, `AppSnackbar`, `AppHeaderLogo` (`lib/core/widgets/*.dart`) | Settings, Catalog, cualquier flujo con formularios | Capturas disponibles desde `SettingsPage` → `Ver Catálogo` (sección Layout). |

---

## Persistencia local

| Módulo | Tecnología | Claves | ¿Qué se guarda? | Archivo |
| --- | --- | --- | --- | --- |
| Autenticación | `flutter_secure_storage` (encriptado) | `access_token`, `refresh_token`, `auth_role`, `auth_session_name`, `auth_session_email`, `auth_session_avatar` | Tokens, rol (`user`/`admin`) y datos mínimos para rehidratar la sesión sin re-login. | `lib/features/auth/data/datasources/auth_local_datasource.dart` |
| Preferencias | `SharedPreferences` | `pref_app_notifications`, `pref_email_notifications`, `pref_whatsapp_notifications`, `pref_dark_mode`, `pref_language` | Flags de notificaciones, modo oscuro y código de idioma (`es`/`en`). | `lib/features/settings/data/datasources/preferences_local_datasource.dart` |

La inicialización global ocurre en `lib/main.dart`, donde se sobreescribe `sharedPreferencesProvider` para que cualquier widget pueda leer/escribir preferencias.

## API y endpoints
La base se define con `--dart-define=API_BASE_URL=<url>` y se normaliza en `Env.apiBaseUrl`. Por defecto apunta a `http://127.0.0.1:8080/api` (servidor NestJS en `backend-nest/`). Todos los endpoints están centralizados en data sources para evitar duplicidad.

| Método | Endpoint | Uso | Fuente |
| --- | --- | --- | --- |
| `POST` | `/auth/login` | Login de usuarios (guardado de access/refresh tokens). | `lib/features/auth/data/datasources/auth_remote_datasource.dart` |
| `POST` | `/auth/admin/login` | Login de administradores (solo access token). | id. |
| `POST` | `/auth/register` | Registro de clientes (name/email/password). | id. |
| `POST` | `/auth/logout` | Logout de usuarios (envía refreshToken si existe). | id. y `ProfileRemoteDataSource.logout()` |
| `POST` | `/auth/admin/logout` | Logout de admins. | id. |
| `POST` | `/auth/refresh` | Refresh del access token usando el refresh guardado. | `AppServices._tryRefreshToken` y `AuthRemoteDataSource` |
| `PATCH` | `/auth/password` | Cambio de contraseña para usuarios autenticados. | `lib/features/profile/data/datasources/profile_remote_datasource.dart` |
| `GET` | `/profile/me` | Trae los datos del perfil (usuario/admin). | id. |
| `PATCH` | `/profile/update` | Actualiza datos de contacto y avatar. | id. |

> Los interceptores de `AppServices` reintentan automáticamente peticiones que fallen con 401, siempre que exista un `refreshToken`.

## Cómo ejecutar la app

1. **Requisitos**
   - Flutter 3.24.x (Dart 3.9) o superior (`sdk: ^3.9.2`).
   - Dispositivo/emulador configurado (Android Studio, Xcode o Chrome).
   - Backend NestJS levantado (opcional pero recomendado) en `http://127.0.0.1:8080/api`. Puedes usar `docker-compose up backend` o `cd ../backend-nest && npm install && npm run start:dev`.

2. **Instalación de dependencias**
   ```bash
   cd flutter
   flutter pub get
   ```

3. **Definir la API**
   - Local desktop/web: `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080/api`
   - Emulador Android: `flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080/api`
   - Genymotion: `flutter run --dart-define=API_BASE_URL=http://10.0.3.2:8080/api`
   - iPhone físico: `open ios/Runner.xcworkspace` y ejecuta desde Xcode pasando el `dart-define` en *Arguments Passed On Launch*.

4. **Ejecutar**
   ```bash
   flutter run --flavor development --dart-define=API_BASE_URL=http://127.0.0.1:8080/api
   ```
   *(El flag `--flavor` es opcional; la app funciona también sin él.)*

5. **Ver el catálogo**
   - Abre la app → ícono de ajustes → botón **Ver Catálogo** en la barra CTA inferior.

## Problemas comunes y tips
- **API inaccesible:** revisa que `API_BASE_URL` use la IP correcta para tu emulador; los 401 repetidos indican que el refresh token no coincide.
- **Cache de tokens corrupta:** borra la app o usa la opción de “Cerrar sesión” en `ProfilePage`. Eso limpia `flutter_secure_storage`.