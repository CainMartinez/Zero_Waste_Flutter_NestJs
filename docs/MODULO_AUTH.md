# 🔐 MÓDULO AUTH - Autenticación y Autorización

---

## 📝 Descripción General

El **módulo Auth** gestiona toda la autenticación y autorización de la aplicación. Soporta **dos tipos de usuarios** (clientes y administradores) con flujos de login separados, registro de usuarios, gestión de sesiones con JWT, y persistencia de tokens en almacenamiento seguro.

### Características Principales

- ✅ **Doble Autenticación**: Login para clientes y administradores separados
- 🔐 **JWT Tokens**: Access + Refresh tokens para usuarios, solo Access para admins
- 💾 **Persistencia Segura**: Tokens guardados en FlutterSecureStorage
- 🔄 **Auto-restauración de Sesión**: Recupera la sesión al abrir la app
- 📝 **Registro de Usuarios**: Solo clientes pueden registrarse (admins se crean en DB)
- 🚪 **Logout con Blacklist**: Revocación de tokens en el backend
- 🎨 **UI Moderna**: Switchers animados para modo (Login/Registro) y rol (Cliente/Admin)
- ⚡ **Validación en Tiempo Real**: Validators personalizados para email y contraseña
- 🔒 **Cambio de Contraseña**: Endpoint seguro para actualizar password

### Tecnologías Utilizadas

- **Riverpod 3.0**: `Notifier` para gestión de estado de autenticación
- **FlutterSecureStorage**: Almacenamiento encriptado de tokens
- **Dio**: Cliente HTTP con interceptores para JWT
- **JWT (Backend)**: Access tokens (15min) y Refresh tokens (7 días)
- **Bcrypt**: Hashing de contraseñas en el backend
- **TypeORM**: Repositorios para usuarios, admins y blacklist de tokens

---

## 🏗️ Arquitectura del Módulo

El módulo Auth sigue **Clean Architecture** con separación clara de responsabilidades:

```
auth/
├── data/                          # Capa de Datos
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart   # API calls (Dio)
│   │   └── auth_local_datasource.dart    # Secure Storage
│   └── repositories/
│       └── auth_repository_impl.dart      # Implementación del repositorio
│
├── domain/                        # Capa de Dominio
│   ├── entities/                  # Entidades del dominio
│   │   ├── user.dart              # Usuario (cliente)
│   │   ├── admin.dart             # Administrador
│   │   ├── auth_tokens.dart       # Access + Refresh tokens
│   │   ├── user_session.dart      # Sesión de usuario
│   │   └── admin_session.dart     # Sesión de admin
│   ├── repositories/
│   │   └── auth_repository.dart   # Interface del repositorio
│   └── usecases/
│       └── auth_usecase.dart      # Casos de uso de autenticación
│
└── presentation/                  # Capa de Presentación
    ├── pages/
    │   └── auth_page.dart         # Página de login/registro
    ├── providers/
    │   └── auth_provider.dart     # Provider global de autenticación
    └── widgets/
        ├── login_form.dart        # Formulario de login
        └── register_form.dart     # Formulario de registro
```

### Flujo de Datos

```
Usuario interactúa con formulario
        ↓
    LoginForm / RegisterForm
        ↓
    authProvider.loginUser() / registerUser()
        ↓
    AuthUseCases
        ↓
    AuthRepository (interface)
        ↓
    AuthRepositoryImpl
        ↓
    AuthRemoteDataSource (API) + AuthLocalDataSource (Storage)
        ↓
    Backend API (NestJS)
        ↓
    Respuesta → Entities → State → UI
        ↓
    Navegación automática a Home/Admin según rol
```

---

## 📱 AuthPage - Página Principal

### Descripción

`AuthPage` es un **ConsumerStatefulWidget** que implementa una interfaz unificada para login y registro con switchers para cambiar entre modos y roles.

### Enums

```dart
enum AuthMode { login, register }
enum AuthRole { user, admin }
```

**AuthMode**:
- `login`: Formulario de inicio de sesión
- `register`: Formulario de registro (solo para clientes)

**AuthRole** (solo visible en modo login):
- `user`: Login como cliente
- `admin`: Login como administrador

### Código Principal

```dart
class _AuthPageState extends ConsumerState<AuthPage> {
  AuthMode _mode = AuthMode.login;
  AuthRole _role = AuthRole.user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            children: [
              const SizedBox(height: 6),
              AppHeaderLogo(
                title: _mode == AuthMode.login ? 'Inicia sesión' : 'Crea tu cuenta',
                subtitle: 'Comidas zero waste, recogida sin esperas.',
              ),
              const SizedBox(height: 26),

              // Switcher Login/Registro
              _AuthModeSwitcher(
                mode: _mode,
                onChanged: (m) {
                  ref.read(authProvider.notifier).clearError();
                  setState(() => _mode = m);
                },
              ),
              const SizedBox(height: 14),

              // Switcher Cliente/Admin (solo en Login)
              if (_mode == AuthMode.login)
                _AuthRoleSwitcher(
                  role: _role,
                  onChanged: (r) => setState(() => _role = r),
                ),

              const SizedBox(height: 22),

              // AnimatedSwitcher para transición suave entre formularios
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _mode == AuthMode.login
                    ? LoginForm(
                        key: const ValueKey('login_form'),
                        isAdmin: _role == AuthRole.admin,
                      )
                    : const RegisterForm(
                        key: ValueKey('register_form'),
                      ),
              ),

              const SizedBox(height: 20),
              Text(
                'Al continuar aceptas la recogida rápida y el sistema de puntos.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Características Clave

#### 1. **GestureDetector para Unfocus**

```dart
GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  child: Scaffold(...)
)
```

**¿Por qué?**
- Al tocar fuera de un campo de texto, el teclado se cierra
- Mejora la UX en móviles
- Patrón estándar en aplicaciones Flutter

#### 2. **Limpieza de Errores al Cambiar Modo**

```dart
_AuthModeSwitcher(
  mode: _mode,
  onChanged: (m) {
    ref.read(authProvider.notifier).clearError();
    setState(() => _mode = m);
  },
)
```

**¿Por qué clearError?**
- Si hubo error en login, no debe mostrarse al cambiar a registro
- Evita confusión del usuario
- Estado limpio para cada modo

#### 3. **AnimatedSwitcher con Keys**

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  child: _mode == AuthMode.login
      ? LoginForm(key: const ValueKey('login_form'), ...)
      : const RegisterForm(key: ValueKey('register_form')),
)
```

**¿Por qué keys?**
- `AnimatedSwitcher` necesita keys únicas para detectar cambios
- Sin keys, Flutter reutilizaría el mismo widget
- Permite animación de fade entre formularios

---

### Widgets de Switcher

#### _AuthModeSwitcher (Login / Registro)

```dart
class _AuthModeSwitcher extends StatelessWidget {
  const _AuthModeSwitcher({
    required this.mode,
    required this.onChanged,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _Pill(
            label: 'Login',
            icon: Icons.login_rounded,
            selected: mode == AuthMode.login,
            onTap: () => onChanged(AuthMode.login),
          ),
          _Pill(
            label: 'Registro',
            icon: Icons.person_add_alt_1_rounded,
            selected: mode == AuthMode.register,
            onTap: () => onChanged(AuthMode.register),
          ),
        ],
      ),
    );
  }
}
```

#### _AuthRoleSwitcher (Cliente / Admin)

```dart
class _AuthRoleSwitcher extends StatelessWidget {
  const _AuthRoleSwitcher({
    required this.role,
    required this.onChanged,
  });

  final AuthRole role;
  final ValueChanged<AuthRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _Pill(
            label: 'Cliente',
            icon: Icons.person_outline,
            selected: role == AuthRole.user,
            onTap: () => onChanged(AuthRole.user),
          ),
          _Pill(
            label: 'Admin',
            icon: Icons.verified_user_outlined,
            selected: role == AuthRole.admin,
            onTap: () => onChanged(AuthRole.admin),
          ),
        ],
      ),
    );
  }
}
```

#### _Pill (Componente Reutilizable)

```dart
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: selected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Características del diseño**:
- **BorderRadius 999**: Efecto de píldora redondeada
- **Expanded**: Cada pill ocupa 50% del ancho
- **InkWell**: Efecto ripple al tocar
- **Color condicional**: Fondo blanco cuando está seleccionado
- **Material Design 3**: Usa colorScheme del tema

---

## 📝 Formularios de Autenticación

### 1. LoginForm

```dart
class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _errorShown = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorShown = false;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final notifier = ref.read(authProvider.notifier);

    if (widget.isAdmin) {
      await notifier.loginAdmin(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    } else {
      await notifier.loginUser(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    // Detectar errores directamente en el build
    if (authState.hasError && !_errorShown) {
      _errorShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final errorString = authState.error?.toString() ?? 'No se pudo iniciar sesión';
        // Quitar el prefijo "Exception: " si existe
        final message = errorString.startsWith('Exception: ') 
            ? errorString.substring(11) 
            : errorString;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _emailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
          ),
          const SizedBox(height: 12),
          AppPasswordField(
            controller: _passwordCtrl,
            label: 'Contraseña',
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!isLoading) _submit();
            },
            validator: Validators.password,
          ),
          const SizedBox(height: 20),
          AppFormSubmit(
            label: isLoading ? 'Entrando...' : 'Entrar',
            isLoading: isLoading,
            onPressed: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
```

#### Características Destacadas

**1. Gestión de Errores con `_errorShown`**:
```dart
bool _errorShown = false;

if (authState.hasError && !_errorShown) {
  _errorShown = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  });
}
```

**¿Por qué este patrón?**
- Evita mostrar el SnackBar múltiples veces en cada rebuild
- `addPostFrameCallback` espera a que el build termine
- Se resetea en `_submit()` para permitir nuevos errores

**2. Limpieza del mensaje de error**:
```dart
final message = errorString.startsWith('Exception: ') 
    ? errorString.substring(11) 
    : errorString;
```

**¿Por qué?**
- Los errores de Dart incluyen prefijo "Exception: "
- Mejora la UX mostrando solo el mensaje limpio
- Ejemplo: "Exception: Email incorrecto" → "Email incorrecto"

**3. Submit al presionar Enter**:
```dart
AppPasswordField(
  textInputAction: TextInputAction.done,
  onFieldSubmitted: (_) {
    if (!isLoading) _submit();
  },
)
```

---

### 2. RegisterForm

```dart
class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _errorShown = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorShown = false;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // Guardar el contexto antes de hacer la llamada async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final notifier = ref.read(authProvider.notifier);
    final user = await notifier.registerUser(
      email: _emailCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    
    if (user != null) {
      final userName = user.name ?? 'Usuario';
      final userEmail = user.email ?? '';
      
      // Usar el ScaffoldMessenger guardado que sigue siendo válido
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('¡Te has registrado con éxito $userName con el email $userEmail!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    // Detectar errores
    if (authState.hasError && !_errorShown) {
      _errorShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final errorString = authState.error?.toString() ?? 'Error en el registro';
        final message = errorString.startsWith('Exception: ') 
            ? errorString.substring(11) 
            : errorString;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _nameCtrl,
            label: 'Nombre',
            textInputAction: TextInputAction.next,
            validator: Validators.name,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _emailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
          ),
          const SizedBox(height: 12),
          AppPasswordField(
            controller: _passwordCtrl,
            label: 'Contraseña',
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!isLoading) _submit();
            },
            validator: Validators.password,
          ),
          const SizedBox(height: 20),
          AppFormSubmit(
            label: isLoading ? 'Creando cuenta...' : 'Crear cuenta',
            isLoading: isLoading,
            onPressed: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
```

#### Patrón de Context Guardado

```dart
Future<void> _submit() async {
  // Guardar el contexto antes de async
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  
  final user = await notifier.registerUser(...);
  
  if (user != null) {
    // Usar el messenger guardado (sigue siendo válido)
    scaffoldMessenger.showSnackBar(...);
  }
}
```

**¿Por qué este patrón?**
- `context` puede no ser válido después de un `await` (el widget puede haberse desmontado)
- `ScaffoldMessenger.of(context)` captura el messenger antes del async
- Evita errores de "Tried to use context after widget was disposed"
- Es el patrón recomendado por Flutter para operaciones async

---

## 🔄 AuthProvider - Estado Global

### AuthViewState

```dart
class AuthViewState {
  final UserSession? userSession;
  final AdminSession? adminSession;

  const AuthViewState({
    this.userSession,
    this.adminSession,
  });

  const AuthViewState.anonymous()
      : userSession = null,
        adminSession = null;

  bool get isAuthenticated => userSession != null || adminSession != null;
  bool get isAnonymous => !isAuthenticated;
  bool get isAdmin => adminSession != null;

  String? get displayName =>
      userSession?.user.name ?? adminSession?.admin.name;

  String? get avatarUrl =>
      userSession?.user.avatarUrl ?? adminSession?.admin.avatarUrl;
}
```

**Características**:
- **Dos sesiones mutualmente excluyentes**: Solo una puede estar activa
- **Getters de conveniencia**: `isAuthenticated`, `isAdmin`, `displayName`
- **Factory anonymous**: Estado inicial sin autenticación

---

### AuthNotifier

```dart
class AuthNotifier extends Notifier<AsyncValue<AuthViewState>> {
  late AuthUseCases _auth;
  bool _initialized = false;
  bool _manuallySet = false;
  
  @override
  AsyncValue<AuthViewState> build() {
    if (!_initialized) {
      _initialized = true;
      _initialize();
    }
    
    return const AsyncValue.loading();
  }

  Future<void> _initialize() async {
    final remote = AuthRemoteDataSource();
    final local = AuthLocalDataSource();
    final AuthRepository repo = AuthRepositoryImpl(remote, local);
    _auth = AuthUseCases(repo);

    final stored = await _auth.readStoredSession();
    final access = stored.accessToken;
    
    if (_manuallySet) {
      return;
    }
    
    if (access == null || access.isEmpty) {
      state = const AsyncValue.data(AuthViewState.anonymous());
      return;
    }

    final name = await local.readSessionName();
    final email = await local.readSessionEmail();
    final avatar = await local.readSessionAvatar();

    final role = stored.role; // 'admin' | 'user'
    
    if (role == 'admin') {
      final admin = Admin(
        id: null,
        uuid: null,
        email: email ?? '',
        name: name ?? '',
        avatarUrl: avatar,
        isActive: true,
        createdAt: null,
        updatedAt: null,
      );

      state = AsyncValue.data(AuthViewState(
        adminSession: AdminSession(
          tokens: AuthTokens(accessToken: access),
          admin: admin,
        ),
      ));
      return;
    }

    // Usuario normal
    final user = User(
      id: null,
      uuid: null,
      email: email ?? '',
      name: name ?? '',
      avatarUrl: avatar,
      isActive: true,
      createdAt: null,
      updatedAt: null,
    );

    state = AsyncValue.data(AuthViewState(
      userSession: UserSession(
        tokens: AuthTokens(
          accessToken: access,
          refreshToken: stored.refreshToken,
        ),
        user: user,
      ),
    ));
  }
}
```

#### Características Clave

**1. Inicialización Lazy**:
```dart
@override
AsyncValue<AuthViewState> build() {
  if (!_initialized) {
    _initialized = true;
    _initialize();
  }
  return const AsyncValue.loading();
}
```

**¿Por qué lazy?**
- Evita múltiples inicializaciones si el provider se reconstruye
- `_initialize()` es async, pero `build()` debe ser síncrono
- Retorna `loading` mientras se inicializa

**2. Flag `_manuallySet`**:
```dart
bool _manuallySet = false;

if (_manuallySet) {
  return;
}
```

**¿Para qué?**
- Evita que la inicialización sobrescriba un login manual reciente
- Se activa en `loginUser`/`loginAdmin`
- Se resetea en caso de error

**3. Restauración de Sesión por Rol**:
```dart
final role = stored.role; // 'admin' | 'user'

if (role == 'admin') {
  // Crear AdminSession
} else {
  // Crear UserSession
}
```

---

### Métodos Públicos

#### loginUser

```dart
Future<void> loginUser(String email, String password) async {
  try {
    _manuallySet = true;
    state = const AsyncValue.loading();
    final session = await _auth.loginUser(email: email, password: password);
    state = AsyncValue.data(AuthViewState(userSession: session));
    ref.invalidate(profileProvider);
  } catch (e, st) {
    _manuallySet = false;
    state = AsyncValue.error(e, st);
  }
}
```

**Flujo**:
1. Marca `_manuallySet = true` para evitar sobrescritura por `_initialize`
2. Pone estado en loading
3. Llama al use case con credenciales
4. Si éxito: actualiza estado con UserSession e invalida profileProvider
5. Si error: resetea `_manuallySet` y pone el error en el estado

#### loginAdmin

```dart
Future<void> loginAdmin(String email, String password) async {
  try {
    _manuallySet = true;
    state = const AsyncValue.loading();
    final session = await _auth.loginAdmin(email: email, password: password);
    state = AsyncValue.data(AuthViewState(adminSession: session));
    ref.invalidate(profileProvider);
  } catch (e, st) {
    _manuallySet = false;
    state = AsyncValue.error(e, st);
  }
}
```

**Diferencia con loginUser**:
- Usa `loginAdmin` del use case
- Crea `AdminSession` en lugar de `UserSession`
- Sin refresh token (admins solo usan access token)

#### registerUser

```dart
Future<User?> registerUser({
  required String email,
  required String name,
  required String password,
}) async {
  try {
    state = const AsyncLoading();
    final user = await _auth.registerUser(
      email: email,
      name: name,
      password: password,
    );
    state = const AsyncValue.data(AuthViewState.anonymous());
    return user;
  } catch (e, st) {
    state = AsyncError(e, st);
    return null;
  }
}
```

**¿Por qué retorna User?**
- Permite mostrar mensaje de éxito con el nombre del usuario
- No inicia sesión automáticamente (usuario debe hacer login manualmente)
- Vuelve a estado anonymous tras el registro

#### logout

```dart
Future<void> logout() async {
  final current = state.value;
  
  try {
    if (current != null && current.isAdmin) {
      await _auth.logoutAdmin();
    } else {
      await _auth.logoutUser();
    }
    
    state = const AsyncValue.data(AuthViewState.anonymous());
    ref.invalidate(profileProvider);
  } catch (e, st) {
    state = const AsyncValue.data(AuthViewState.anonymous());
    ref.invalidate(profileProvider);
    state = AsyncValue.error(e, st);
  }
}
```

**Lógica especial**:
- Detecta si es admin o usuario para llamar al endpoint correcto
- Limpia el estado SIEMPRE (incluso si falla el API call)
- Invalida profileProvider para limpiar datos del perfil
- Doble setState: primero anonymous, luego error si lo hay

#### clearError

```dart
void clearError() {
  if (state.hasError) {
    state = const AsyncValue.data(AuthViewState.anonymous());
  }
}
```

**Uso**:
- Se llama al cambiar de modo (Login → Registro)
- Limpia errores previos para no confundir al usuario

---

## 🎯 Casos de Uso

### AuthUseCases

```dart
class AuthUseCases {
  final Future<UserSession> Function({
    required String email,
    required String password,
  }) loginUser;

  final Future<AdminSession> Function({
    required String email,
    required String password,
  }) loginAdmin;

  final Future<User> Function({
    required String email,
    required String name,
    required String password,
  }) registerUser;

  final Future<void> Function() logoutUser;
  final Future<void> Function() logoutAdmin;

  final Future<({String? accessToken, String? refreshToken, String? role})>
      Function() readStoredSession;

  AuthUseCases(AuthRepository repo)
      : loginUser = repo.loginUser,
        loginAdmin = repo.loginAdmin,
        registerUser = repo.registerUser,
        logoutUser = repo.logoutUser,
        logoutAdmin = repo.logoutAdmin,
        readStoredSession = repo.readStoredSession;
}
```

**Patrón de diseño**:
- **Function fields**: En lugar de métodos, usa campos de función
- **Dependency Injection**: Recibe el repositorio en el constructor
- **Delegación directa**: Cada campo apunta al método del repositorio
- **Ventajas**: 
  - Fácil de testear (puedes mockear funciones individuales)
  - Sintaxis limpia sin boilerplate
  - Separación clara entre capa de aplicación y dominio

---

## 💾 Capa de Datos

### 1. AuthRepository (Interface)

```dart
abstract class AuthRepository {
  Future<UserSession> loginUser({
    required String email,
    required String password,
  });

  Future<AdminSession> loginAdmin({
    required String email,
    required String password,
  });

  Future<User> registerUser({
    required String email,
    required String name,
    required String password,
  });

  Future<void> logoutUser();

  Future<void> logoutAdmin();

  Future<({String? accessToken, String? refreshToken, String? role})>
      readStoredSession();
}
```

---

### 2. AuthRepositoryImpl

```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  const AuthRepositoryImpl(
    this._remote,
    this._local,
  );

  @override
  Future<UserSession> loginUser({
    required String email,
    required String password,
  }) async {
    await _local.clearAll();
    await Future.delayed(const Duration(milliseconds: 100));
    
    final data = await _remote.loginUser(email: email, password: password);
    
    final access = data['accessToken'] as String;
    final refresh = data['refreshToken'] as String?;
    final u = data['user'] as Map<String, dynamic>;

    final user = User(
      id: u['id'] as int,
      uuid: u['uuid'] as String?,
      email: u['email'] as String,
      name: u['name'] as String,
      avatarUrl: u['avatarUrl'] as String?,
      isActive: u['isActive'] as bool?,
      createdAt: u['createdAt'] != null 
          ? DateTime.tryParse(u['createdAt'] as String)
          : null,
      updatedAt: u['updatedAt'] != null
          ? DateTime.tryParse(u['updatedAt'] as String)
          : null,
    );

    await _local.saveUserSession(
      accessToken: access,
      refreshToken: refresh,
      role: 'user',
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
    );

    return UserSession(
      tokens: AuthTokens(accessToken: access, refreshToken: refresh),
      user: user,
    );
  }

  @override
  Future<AdminSession> loginAdmin({
    required String email,
    required String password,
  }) async {
    await _local.clearAll();
    await Future.delayed(const Duration(milliseconds: 100));
    
    final data = await _remote.loginAdmin(email: email, password: password);
    
    final access = data['accessToken'] as String;

    final admin = Admin(
      id: null,
      uuid: null,
      email: data['email'] as String,
      name: data['name'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      isActive: true,
      createdAt: null,
      updatedAt: null,
    );

    await _local.saveUserSession(
      accessToken: access,
      refreshToken: null,
      role: 'admin',
      name: admin.name,
      email: admin.email,
      avatarUrl: admin.avatarUrl,
    );

    return AdminSession(
      tokens: AuthTokens(accessToken: access),
      admin: admin,
    );
  }

  @override
  Future<User> registerUser({
    required String email,
    required String name,
    required String password,
  }) async {
    final data = await _remote.registerUser(
      email: email,
      name: name,
      password: password,
    );

    return User(
      id: data['id'] as int?,
      uuid: data['uuid'] as String?,
      email: data['email'] as String?,
      name: data['name'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      isActive: data['isActive'] as bool?,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'] as String)
          : null,
    );
  }

  @override
  Future<void> logoutUser() async {
    await _remote.logoutUser();
    await _local.clearAll();
  }

  @override
  Future<void> logoutAdmin() async {
    await _remote.logoutAdmin();
    await _local.clearAll();
  }

  Future<({String? accessToken, String? refreshToken, String? role})>
      readStoredSession() async {
    final accessToken = await _local.readAccessToken();
    final refreshToken = await _local.readRefreshToken();
    final role = await _local.readAuthRole();
    return (
      accessToken: accessToken,
      refreshToken: refreshToken,
      role: role,
    );
  }
}
```

#### Detalles de Implementación

**1. Limpieza de storage antes de login**:
```dart
await _local.clearAll();
await Future.delayed(const Duration(milliseconds: 100));
```

**¿Por qué?**
- Evita mezclar tokens de sesiones anteriores
- El delay asegura que FlutterSecureStorage termine la operación
- Previene race conditions en storage

**2. Parseo de DateTime**:
```dart
createdAt: u['createdAt'] != null 
    ? DateTime.tryParse(u['createdAt'] as String)
    : null,
```

**¿Por qué tryParse?**
- El backend puede enviar diferentes formatos de fecha
- `tryParse` retorna `null` si falla (no lanza excepción)
- Más seguro que `DateTime.parse` que puede romper la app

---

### 3. AuthRemoteDataSource

```dart
class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  /// POST /auth/login (usuarios)
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final Response res = await AppServices.dio.post(
        '/auth/login',
        data: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Extraer mensaje del backend si existe
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] ?? data['error'] ?? 'Error en login';
        throw Exception(message);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  /// POST /auth/admin/login
  Future<Map<String, dynamic>> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final Response res = await AppServices.dio.post(
        '/auth/admin/login',
        data: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] ?? data['error'] ?? 'Error en login de admin';
        throw Exception(message);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  /// POST /auth/register
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      final Response res = await AppServices.dio.post(
        '/auth/register',
        data: jsonEncode({
          'email': email.trim(),
          'name': name.trim(),
          'password': password,
        }),
      );

      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] ?? data['error'] ?? 'Error en registro';
        throw Exception(message);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  /// POST /auth/logout (usuario)
  Future<void> logoutUser() async {
    await AppServices.dio.post('/auth/logout');
  }

  /// POST /auth/admin/logout
  Future<void> logoutAdmin() async {
    await AppServices.dio.post('/auth/admin/logout');
  }
}
```

**Manejo de errores consistente**:
- Captura `DioException` específicamente
- Extrae mensaje del backend si está disponible
- Fallback a mensajes genéricos
- Lanza `Exception` con mensaje limpio

---

### 4. AuthLocalDataSource

```dart
class AuthLocalDataSource {
  const AuthLocalDataSource();

  static const _tokenKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _authRoleKey = 'auth_role';
  static const _sessionNameKey = 'auth_session_name';
  static const _sessionEmailKey = 'auth_session_email';
  static const _sessionAvatarKey = 'auth_session_avatar';

  Future<void> saveUserSession({
    required String accessToken,
    String? refreshToken,
    required String role,
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    await AppServices.storage.write(key: _tokenKey, value: accessToken);
    await AppServices.storage.write(key: _authRoleKey, value: role);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await AppServices.storage.write(key: _refreshKey, value: refreshToken);
    } else {
      await AppServices.storage.delete(key: _refreshKey);
    }

    final safeName = name?.trim();
    final safeEmail = email?.trim();
    final safeAvatar = avatarUrl?.trim();

    if (safeName != null && safeName.isNotEmpty) {
      await AppServices.storage.write(key: _sessionNameKey, value: safeName);
    } else {
      await AppServices.storage.delete(key: _sessionNameKey);
    }

    if (safeEmail != null && safeEmail.isNotEmpty) {
      await AppServices.storage.write(key: _sessionEmailKey, value: safeEmail);
    } else {
      await AppServices.storage.delete(key: _sessionEmailKey);
    }

    if (safeAvatar != null && safeAvatar.isNotEmpty) {
      await AppServices.storage.write(key: _sessionAvatarKey, value: safeAvatar);
    } else {
      await AppServices.storage.delete(key: _sessionAvatarKey);
    }

    // Delay para esperar a que el storage termine de escribir
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<String?> readAccessToken() =>
      AppServices.storage.read(key: _tokenKey);

  Future<String?> readRefreshToken() =>
      AppServices.storage.read(key: _refreshKey);

  Future<String?> readAuthRole() =>
      AppServices.storage.read(key: _authRoleKey);

  Future<String?> readSessionName() =>
      AppServices.storage.read(key: _sessionNameKey);

  Future<String?> readSessionEmail() =>
      AppServices.storage.read(key: _sessionEmailKey);

  Future<String?> readSessionAvatar() =>
      AppServices.storage.read(key: _sessionAvatarKey);

  Future<void> clearAll() async {
    await AppServices.storage.delete(key: _tokenKey);
    await AppServices.storage.delete(key: _refreshKey);
    await AppServices.storage.delete(key: _authRoleKey);
    await AppServices.storage.delete(key: _sessionNameKey);
    await AppServices.storage.delete(key: _sessionEmailKey);
    await AppServices.storage.delete(key: _sessionAvatarKey);
  }
}
```

**Características**:
- **FlutterSecureStorage**: Encriptación nativa (Keychain en iOS, KeyStore en Android)
- **Delay tras escritura**: Asegura persistencia antes de continuar
- **Manejo de nulls**: Delete keys si el valor es null/vacío
- **6 keys separadas**: Tokens, role, nombre, email, avatar

---

## 🔗 Integración con Backend

### Endpoints

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| POST | `/auth/register` | Registro de nuevos usuarios | No |
| POST | `/auth/login` | Login de usuarios (clientes) | No |
| POST | `/auth/admin/login` | Login de administradores | No |
| POST | `/auth/logout` | Logout de usuarios | Sí (JWT) |
| POST | `/auth/admin/logout` | Logout de administradores | Sí (JWT) |
| POST | `/auth/refresh` | Renovar access token con refresh token | Sí (Refresh Token) |
| POST | `/auth/change-password` | Cambiar contraseña del usuario autenticado | Sí (JWT) |

---

### 1. LoginUseCase (Backend)

```typescript
@Injectable()
export class LoginUseCase {
  private readonly logger = new Logger(LoginUseCase.name);

  constructor(
    private readonly usersRepository: IUsersRepository,
    private readonly passwordHasher: PasswordHasherService,
    private readonly jwtTokens: JwtTokenService,
  ) {}

  async execute(dto: LoginRequestDto): Promise<LoginResult> {
    const email = dto.email.trim().toLowerCase();

    const user = await this.usersRepository.findByEmail(email);
    if (!user) {
      throw new UserNotFoundException(email);
    }

    const isValid = await this.passwordHasher.verify(user.passwordHash, dto.password);
    if (!isValid) {
      throw new InvalidPasswordException();
    }

    const { token: accessToken } = await this.jwtTokens.signAccessToken(user, 'user');
    const { token: refreshToken } = await this.jwtTokens.signRefreshToken(user, 'user');

    this.logger.log(`Login correcto: ${user.email}`);
    return { accessToken, refreshToken, user };
  }
}
```

**Flujo**:
1. Busca usuario por email
2. Verifica contraseña con bcrypt
3. Genera access token (15min) y refresh token (7 días)
4. Retorna tokens y datos del usuario

---

### 2. AdminLoginUseCase (Backend)

```typescript
@Injectable()
export class AdminLoginUseCase {
  private readonly logger = new Logger(AdminLoginUseCase.name);

  constructor(
    private readonly adminsRepo: IAdminsRepository,
    private readonly passwordHasher: PasswordHasherService,
    private readonly jwtTokens: JwtTokenService,
  ) {}

  async execute(dto: AdminLoginRequestDto): Promise<AdminLoginResult> {
    const email = dto.email.trim().toLowerCase();

    const admin = await this.adminsRepo.findByEmail(email);
    if (!admin) {
      throw new UserNotFoundException(email);
    }

    const isValid = await this.passwordHasher.verify(admin.passwordHash, dto.password);
    if (!isValid) {
      throw new InvalidPasswordException();
    }

    // Solo access token para admins (sin refresh)
    const { token: accessToken } = await this.jwtTokens.signAccessToken(admin, 'admin');

    this.logger.log(`Admin login correcto: ${admin.email}`);
    return { accessToken, admin };
  }
}
```

**Diferencia con LoginUseCase**:
- **Sin refresh token**: Los admins solo reciben access token
- **Repositorio separado**: `IAdminsRepository` en lugar de `IUsersRepository`
- **Tabla separada**: `admins` en lugar de `users`

---

### 3. LogoutUseCase (Backend)

```typescript
@Injectable()
export class LogoutUseCase {
  constructor(
    private readonly blacklistRepo: IJwtBlacklistRepository,
    private readonly jwtTokens: JwtTokenService,
  ) {}

  async execute(params: { userId: number; token: string }): Promise<void> {
    const decoded = await this.safeVerify(params.token);
    if (!decoded) {
      throw new UnauthorizedException('Token inválido');
    }

    const { exp } = decoded as { exp: number };
    const expiresAt = new Date(exp * 1000);

    // Añadir access token a blacklist
    await this.blacklistRepo.addToBlacklist(params.token, expiresAt);

    // Si hay refresh token en la request, también revocarlo
    // (implementación opcional)
  }

  private async safeVerify(token: string): Promise<unknown> {
    try {
      return await this.jwtTokens.verify(token);
    } catch {
      return null;
    }
  }
}
```

**Sistema de Blacklist**:
- Los tokens JWT son **stateless** (no se pueden "invalidar" por defecto)
- La blacklist es una tabla en DB que guarda tokens revocados
- Al verificar un token, se comprueba si está en la blacklist
- Los tokens expirados se eliminan automáticamente de la blacklist

---

## 🔑 Sistema de Tokens JWT

### Estructura de Tokens

#### Access Token (15 minutos)

```json
{
  "sub": 123,
  "email": "user@example.com",
  "role": "user",
  "iat": 1700000000,
  "exp": 1700000900,
  "iss": "zero-waste-api",
  "aud": "zero-waste-clients"
}
```

**Campos**:
- `sub`: User ID (subject)
- `email`: Email del usuario
- `role`: "user" o "admin"
- `iat`: Issued at (timestamp de creación)
- `exp`: Expiration (timestamp de expiración)
- `iss`: Issuer (quien emitió el token)
- `aud`: Audience (para quien es el token)

#### Refresh Token (7 días)

```json
{
  "sub": 123,
  "type": "refresh",
  "iat": 1700000000,
  "exp": 1700604800,
  "iss": "zero-waste-api",
  "aud": "zero-waste-clients"
}
```

**Diferencias**:
- Duración mucho mayor (7 días vs 15min)
- Campo `type: "refresh"` para identificarlo
- Solo contiene `sub` (sin email ni role)

---

### Flujo de Renovación de Token

```
1. Cliente hace request con access token expirado
        ↓
2. Dio interceptor detecta 401 Unauthorized
        ↓
3. Automáticamente llama POST /auth/refresh con refresh token
        ↓
4. Backend valida refresh token
        ↓
5. Si válido, genera nuevo access token
        ↓
6. Interceptor guarda nuevo access token
        ↓
7. Reintenta el request original con nuevo token
        ↓
8. Si falla, redirige a login
```

---

## 💡 Decisiones de Diseño

### 1. ¿Por qué Login Separado para Admin?

**Decisión**: Dos flujos de login distintos (`/auth/login` y `/auth/admin/login`)

**Alternativas**:
- ❌ Un solo endpoint con campo `role` en el body
- ✅ **Dos endpoints separados**

**Justificación**:
- **Seguridad**: Los admins no se pueden registrar, solo crear desde DB
- **Lógica diferente**: Admins sin refresh token, users con refresh token
- **Tablas separadas**: `users` vs `admins` en la base de datos
- **Auditoría**: Logs separados para intentos de login de cada tipo
- **Escalabilidad**: Permite diferentes reglas de negocio en el futuro

---

### 2. ¿Por qué Admins Sin Refresh Token?

**Decisión**: Admins solo reciben access token (15min), sin refresh token

**Alternativas**:
- ❌ Admins con refresh token igual que usuarios
- ✅ **Admins sin refresh token**

**Justificación**:
- **Seguridad mejorada**: Sesiones de admin expiran pronto
- **Menor superficie de ataque**: Un token menos que robar/comprometer
- **Fuerza reautenticación**: Admins deben loguearse cada 15min
- **Cumplimiento**: Muchas normativas requieren sesiones cortas para admins
- **Simplicidad**: Menos lógica de refresh para roles privilegiados

---

### 3. ¿Por qué FlutterSecureStorage?

**Decisión**: Usar FlutterSecureStorage para tokens

**Alternativas**:
- ❌ SharedPreferences (inseguro, texto plano)
- ❌ Hive (mejor que SharedPreferences, pero sin encriptación nativa)
- ✅ **FlutterSecureStorage** (encriptación nativa del SO)

**Justificación**:
- **Encriptación nativa**: Usa Keychain (iOS) y KeyStore (Android)
- **Seguridad del SO**: El sistema operativo protege las claves
- **Estándar de la industria**: Patrón recomendado para tokens
- **Fácil de usar**: API sencilla (read/write/delete)
- **Sin dependencias extras**: No requiere gestionar claves manualmente

---

### 4. ¿Por qué No Auto-Login Tras Registro?

**Decisión**: Después de registrarse, el usuario debe hacer login manualmente

**Alternativas**:
- ❌ Auto-login tras registro exitoso
- ✅ **Requiere login manual**

**Justificación**:
- **Verificación de email futura**: Preparado para añadir confirmación por email
- **Seguridad**: El usuario confirma que recuerda su contraseña
- **UX clara**: Separa el flujo de registro del de autenticación
- **Consistencia**: Todos los logins pasan por el mismo flujo

---

### 5. ¿Por qué `_manuallySet` Flag?

**Decisión**: Usar flag `_manuallySet` para evitar race conditions

**Problema**:
```
1. Usuario hace login
2. Login exitoso, guarda tokens en storage
3. Provider se reconstruye
4. _initialize() lee storage y sobrescribe el estado con datos parciales
5. Se pierde información completa del usuario
```

**Solución**:
```dart
Future<void> loginUser(...) async {
  _manuallySet = true;  // Bloquea _initialize
  // ... login logic
}

Future<void> _initialize() async {
  if (_manuallySet) return;  // No sobrescribir login manual
  // ... restore session
}
```

---

### 6. ¿Por qué AsyncValue en lugar de Custom State?

**Decisión**: Usar `AsyncValue<AuthViewState>` en lugar de clase custom

**Alternativas**:
- ❌ Estado custom con campos `isLoading`, `error`, `data`
- ✅ **AsyncValue de Riverpod**

**Justificación**:
- **Patrón estándar de Riverpod**: Menos código, más idiomático
- **Manejo automático de estados**: loading, data, error
- **Métodos helper**: `when`, `maybeWhen`, `hasError`, `isLoading`
- **Type-safe**: El compilador garantiza que manejas todos los casos
- **Menos bugs**: No te puedes olvidar de resetear `isLoading`

---

### 7. ¿Por qué Guardar Name/Email en Storage?

**Decisión**: Guardar `name`, `email`, `avatar` además de los tokens

**Alternativas**:
- ❌ Solo guardar tokens, hacer `/me` al abrir la app
- ✅ **Guardar datos del usuario en storage**

**Justificación**:
- **Performance**: No requiere llamada API al abrir la app
- **UX**: Muestra el nombre del usuario instantáneamente
- **Offline-first**: Funciona aunque no haya internet
- **Menos carga en backend**: Un request menos por sesión
- **Datos no sensibles**: Name/email no son datos críticos (solo los tokens)

---

## 🎯 Resumen del Flujo Completo

### Login de Usuario

```
1. Usuario ingresa email y contraseña
        ↓
2. LoginForm valida campos con Validators
        ↓
3. authProvider.loginUser() cambia estado a loading
        ↓
4. AuthUseCases.loginUser() llama a AuthRepository
        ↓
5. AuthRepositoryImpl limpia storage y llama a API
        ↓
6. AuthRemoteDataSource POST /auth/login
        ↓
7. Backend LoginUseCase valida credenciales
        ↓
8. Backend genera access + refresh tokens (JWT)
        ↓
9. Backend retorna tokens + datos del usuario
        ↓
10. AuthRepositoryImpl guarda tokens en FlutterSecureStorage
        ↓
11. AuthRepositoryImpl crea UserSession
        ↓
12. authProvider actualiza estado con UserSession
        ↓
13. AuthGate detecta isAuthenticated = true
        ↓
14. Navega a Home automáticamente (GoRouter)
        ↓
15. Dio interceptor usa token en headers de futuras requests
```

### Restauración de Sesión

```
1. Usuario abre la app
        ↓
2. AuthNotifier.build() llama _initialize()
        ↓
3. Lee tokens de FlutterSecureStorage
        ↓
4. Si hay access token válido:
   - Lee name, email, avatar, role
   - Crea User/Admin entity
   - Crea UserSession/AdminSession
   - Actualiza estado
        ↓
5. AuthGate detecta isAuthenticated = true
        ↓
6. Navega a Home/Admin según rol
```

### Logout

```
1. Usuario presiona botón logout en ProfilePage
        ↓
2. authProvider.logout()
        ↓
3. Detecta si es admin o user
        ↓
4. Llama endpoint correspondiente (/auth/logout o /auth/admin/logout)
        ↓
5. Backend añade token a blacklist
        ↓
6. AuthRepositoryImpl limpia FlutterSecureStorage
        ↓
7. authProvider actualiza estado a anonymous
        ↓
8. AuthGate detecta isAnonymous = true
        ↓
9. Navega a AuthPage automáticamente
```

---

## 📊 Conclusión

El **módulo Auth** demuestra:

✅ **Clean Architecture** con separación clara de capas  
✅ **Seguridad robusta** con JWT, bcrypt, blacklist y secure storage  
✅ **Doble autenticación** con flujos separados para usuarios y admins  
✅ **UX moderna** con switchers animados y validación en tiempo real  
✅ **Estado global** gestionado con Riverpod 3.0  
✅ **Persistencia** de sesión con auto-restauración al abrir la app  
✅ **Manejo de errores** completo con mensajes personalizados del backend  
✅ **Escalabilidad** preparada para verificación de email, 2FA, etc.  