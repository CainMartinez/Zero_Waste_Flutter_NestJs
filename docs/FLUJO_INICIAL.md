# 📱 Flujo Inicial de la Aplicación - EcoBocado

---

## 1. Punto de entrada: main.dart

### Descripción
El archivo `main.dart` es el punto de entrada de toda la aplicación Flutter. Su responsabilidad principal es inicializar los servicios necesarios antes de lanzar la app.

### Flujo de ejecución

```dart
Future<void> main() async {
  // 1. Asegurar que Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cargar SharedPreferences (almacenamiento local persistente)
  final sharedPreferences = await SharedPreferences.getInstance();

  // 3. Lanzar la app con Riverpod
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const EcoBocadoApp(),
    ),
  );
}
```

### Widgets y dependencias utilizadas

| Widget/Clase | Propósito | ¿Por qué se usa? |
|--------------|-----------|------------------|
| **WidgetsFlutterBinding.ensureInitialized()** | Inicializar el binding de Flutter | Necesario para usar servicios nativos (como SharedPreferences) antes de `runApp()` |
| **SharedPreferences.getInstance()** | Obtener instancia de almacenamiento local | Permite persistir datos del usuario (preferencias, tokens de autenticación) entre sesiones |
| **ProviderScope** | Contenedor raíz de Riverpod | Proporciona el sistema de gestión de estado a toda la aplicación |
| **sharedPreferencesProvider.overrideWithValue()** | Inyección de dependencias | Hace disponible la instancia de SharedPreferences en todos los providers de la app |

### Decisiones de diseño

**¿Por qué async/await en main?**
- Necesitamos esperar a que `SharedPreferences` se inicialice completamente antes de lanzar la app
- Garantiza que los providers que dependen de SharedPreferences tengan acceso inmediato a los datos persistidos

**¿Por qué override del provider?**
- Pattern de **Dependency Injection**: permite inyectar la instancia real de SharedPreferences
- Sin el override, el provider lanzaría `UnimplementedError`
- Facilita testing: podemos inyectar mocks en lugar de la instancia real

---

## 2. Widget raíz: app.dart

### Descripción
`EcoBocadoApp` es el widget raíz que configura el tema y el sistema de navegación de la aplicación.

### Arquitectura

```
EcoBocadoApp (ConsumerWidget)
  ├── Observa authProvider
  ├── Observa preferencesProvider
  └── Retorna MaterialApp.router
      ├── Theme configuration
      └── Router configuration
```

### Código detallado

```dart
class EcoBocadoApp extends ConsumerWidget {
  const EcoBocadoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Obtener el router desde el provider
    final router = ref.watch(routerProvider);
    
    // 2. Observar las preferencias del usuario
    final preferencesAsync = ref.watch(preferencesProvider);
    final darkMode = preferencesAsync.when(
      data: (prefs) => prefs.darkMode ?? false,
      loading: () => false,
      error: (_, __) => false,
    );

    // 3. Configurar MaterialApp con router
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EcoBocado',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
```

### Widgets y características

| Elemento | Tipo | Propósito |
|----------|------|-----------|
| **ConsumerWidget** | Base class | Permite acceso a `ref.watch()` para observar providers |
| **MaterialApp.router** | Widget | Configuración de la app con navegación declarativa (go_router) |
| **routerConfig** | Propiedad | Conecta el sistema de navegación personalizado |
| **theme / darkTheme** | Configuración | Define los temas claro y oscuro de la app |
| **themeMode** | Propiedad | Controla qué tema se muestra según las preferencias del usuario |

### Providers observados

#### 1. routerProvider
```dart
final router = ref.watch(routerProvider);
```
- **Qué hace**: Proporciona la instancia de `GoRouter` configurada
- **Por qué se observa**: El router NO debe recrearse en cada build (optimización de rendimiento)
- **Tipo**: `Provider<GoRouter>` (inmutable)

#### 2. preferencesProvider
```dart
final preferencesAsync = ref.watch(preferencesProvider);
```
- **Qué hace**: Lee las preferencias del usuario desde SharedPreferences
- **Por qué se observa**: Para reaccionar a cambios en modo oscuro/claro en tiempo real
- **Tipo**: `AsyncNotifierProvider<Preferences>` (mutable, con estados loading/error/data)

### Flujo de reactividad

```
Usuario cambia modo oscuro en Settings
          ↓
PreferencesNotifier actualiza el estado
          ↓
preferencesProvider notifica cambio
          ↓
EcoBocadoApp se reconstruye
          ↓
MaterialApp.router cambia themeMode
          ↓
UI se actualiza con el nuevo tema
```

### Decisiones de diseño

**¿Por qué ConsumerWidget en lugar de StatelessWidget?**
- Necesitamos acceso a `ref.watch()` para observar providers
- Alternativa sería usar `Consumer` wrapper, pero ConsumerWidget es más limpio

**¿Por qué MaterialApp.router en lugar de MaterialApp?**
- Permite navegación declarativa con `go_router`
- Deep linking nativo
- Mejor manejo de navegación compleja (ShellRoute, rutas anidadas)
- URLs amigables para web

**¿Por qué usar .when() con AsyncValue?**
- Maneja los 3 estados posibles: loading, error, data
- Proporciona valor por defecto seguro (`false`) durante carga o error
- Evita crashes por datos no disponibles

---

## 3. Sistema de navegación: router.dart

### Descripción
Define toda la estructura de navegación de la aplicación usando `go_router`. Implementa un patrón de navegación con **shell persistente** (bottom navigation bar que persiste entre rutas).

### Arquitectura de rutas

```
GoRouter
  └── ShellRoute (AppShell)
      ├── /home          → HomePage
      ├── /menu          → ShopPage
      ├── /orders        → AuthGate(OrdersPage)
      ├── /dashboard     → AuthGate(DashboardPage)
      ├── /products      → AuthGate(ProductsAdminPage)
      ├── /billing       → AuthGate(BillingPage)
      └── /profile       → AuthGate(ProfilePage)
```

### Código detallado

```dart
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Rutas PÚBLICAS (sin AuthGate)
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/menu',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShopPage(),
            ),
          ),
          
          // Rutas PROTEGIDAS para USUARIOS (con AuthGate)
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                child: Center(child: Text('Listado de pedidos')),
                authPageKey: ValueKey('orders-auth'),
              ),
            ),
          ),
          
          // Rutas PROTEGIDAS para ADMIN (con AuthGate)
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                child: Center(child: Text('Dashboard')),
                authPageKey: ValueKey('dashboard-auth'),
              ),
            ),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                child: ProductsAdminPage(),
                authPageKey: ValueKey('products-auth'),
              ),
            ),
          ),
          
          // Ruta COMÚN (protegida)
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                child: ProfilePage(),
                authPageKey: ValueKey('profile-auth'),
              ),
            ),
          ),
        ],
      ),
    ],
  );
});
```

### Componentes clave

#### 1. GlobalKey<NavigatorState>
```dart
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
```
- **Propósito**: Permite acceso programático al Navigator
- **Uso**: Navegación imperativa desde fuera del árbol de widgets (ej: desde providers)
- **debugLabel**: Ayuda en debugging identificando este Navigator específico

#### 2. Provider vs StateNotifier
```dart
final routerProvider = Provider<GoRouter>((ref) { ... });
```
- **¿Por qué Provider?**: El router es **inmutable** y no cambia durante la vida de la app
- **Ventaja**: No causa rebuilds innecesarios
- **Alternativa descartada**: `StateNotifierProvider` causaría rebuilds de toda la app en cada navegación

#### 3. ShellRoute
```dart
ShellRoute(
  builder: (context, state, child) => AppShell(child: child),
  routes: [ ... ]
)
```
- **Propósito**: Mantener un layout persistente (AppBar + BottomNavigationBar)
- **Funcionamiento**: `child` es la página actual que cambia, pero `AppShell` permanece
- **Beneficio**: El BottomNavigationBar no se reconstruye al cambiar de ruta

#### 4. NoTransitionPage
```dart
pageBuilder: (context, state) => const NoTransitionPage(child: HomePage())
```
- **Propósito**: Elimina las animaciones de transición entre páginas
- **¿Por qué?**: En una navegación con bottom bar, las transiciones animadas son confusas
- **Efecto**: Cambio instantáneo de contenido, como pestañas

#### 5. AuthGate wrapper
```dart
child: AuthGate(
  child: ProductsAdminPage(),
  authPageKey: ValueKey('products-auth'),
)
```
- **Propósito**: Proteger rutas que requieren autenticación
- **Funcionamiento**: Si el usuario NO está autenticado, muestra `AuthPage` en su lugar
- **authPageKey**: Key única para evitar conflictos de estado entre instancias de AuthPage

### Clasificación de rutas

| Ruta | Tipo | Acceso | AuthGate | Descripción |
|------|------|--------|----------|-------------|
| `/home` | Pública | Todos | ❌ No | Página de inicio/bienvenida |
| `/menu` | Pública | Todos | ❌ No | Catálogo de productos (shop) |
| `/orders` | Protegida | Usuario/Admin | ✅ Sí | Historial de pedidos |
| `/dashboard` | Protegida | Solo Admin | ✅ Sí | Panel de control administrativo |
| `/products` | Protegida | Solo Admin | ✅ Sí | Gestión de productos (CRUD) |
| `/billing` | Protegida | Solo Admin | ✅ Sí | Facturación y reportes |
| `/profile` | Protegida | Usuario/Admin | ✅ Sí | Perfil del usuario/admin |

### Flujo de navegación

```
Usuario hace tap en BottomNavigationBar
              ↓
context.go('/products')
              ↓
GoRouter busca la ruta coincidente
              ↓
ShellRoute construye AppShell
              ↓
AuthGate verifica autenticación
              ↓
    ┌─────────┴─────────┐
    │                   │
Autenticado         No autenticado
    │                   │
    ↓                   ↓
ProductsAdminPage    AuthPage
```

### Decisiones de diseño

**¿Por qué ShellRoute en lugar de múltiples GoRoute independientes?**
- **Persistencia del layout**: AppBar y BottomNavigationBar no se reconstruyen
- **Mejor UX**: Transiciones más fluidas y consistentes
- **Menos código**: Layout definido una sola vez

**¿Por qué authPageKey con ValueKey único?**
- **Problema sin key**: Si vas de `/orders` a `/profile`, ambos crean una instancia de AuthPage con la misma key
- **Solución**: Keys únicas fuerzan a Flutter a tratar cada AuthPage como widget diferente
- **Resultado**: Estado de formulario no se comparte entre rutas

**¿Por qué initialLocation = '/home'?**
- Ruta por defecto al abrir la app
- Asegura que siempre haya una ruta activa
- Evita pantallas en blanco o rutas inexistentes

---

## 4. Layout principal: app_shell.dart

### Descripción
`AppShell` es el **scaffold persistente** que envuelve todas las páginas de la aplicación. Proporciona:
- **AppBar** con logo, título dinámico, información del usuario y acceso a settings
- **BottomNavigationBar** adaptativo según el rol (Usuario vs Admin)
- **Body** dinámico que cambia según la ruta actual

### Arquitectura del componente

```
AppShell (ConsumerStatefulWidget)
  ├── Observa authProvider
  ├── Lee estado de autenticación
  ├── Determina rol (usuario/admin)
  └── Construye Scaffold
      ├── AppBar
      │   ├── Logo + Título
      │   ├── Separador
      │   ├── Nombre de usuario + Badge ADMIN
      │   ├── Avatar
      │   └── Botón Settings
      ├── Body (widget.child)
      └── BottomNavigationBar
          ├── Si es ADMIN: Dashboard, Productos, Facturación, Perfil
          └── Si es USUARIO: Inicio, Menú, Pedidos, Perfil
```

### Código detallado con explicaciones

#### Estado y observadores

```dart
class _AppShellState extends ConsumerState<AppShell> {
  // Método auxiliar para abrir settings con navegación imperativa
  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // 1. Observar el estado de autenticación
    final authAsync = ref.watch(authProvider);
    
    // 2. Extraer el estado con manejo de loading/error
    final auth = authAsync.when(
      data: (value) => value,
      loading: () => null,
      error: (e, st) => null,
    );

    // 3. Derivar información del usuario
    final isLogged = auth?.isAuthenticated ?? false;
    final isAdmin = auth?.isAdmin ?? false;
    final displayName = auth?.displayName;
    final avatarUrl = auth?.avatarUrl;
```

**¿Por qué ConsumerStatefulWidget?**
- Necesitamos `ref.watch()` (Riverpod)
- Necesitamos `setState()` local para animaciones futuras
- Combinación de gestión de estado global (auth) y local (UI)

#### Navegación adaptativa por rol

```dart
    // 4. Definir rutas según el rol del usuario
    final List<String> paths;
    final List<String> titles;
    
    if (isAdmin) {
      paths = ['/dashboard', '/products', '/billing', '/profile'];
      titles = ['Dashboard', 'Productos', 'Facturación', 'Perfil'];
    } else {
      paths = ['/home', '/menu', '/orders', '/profile'];
      titles = ['Inicio', 'Menú', 'Pedidos', 'Perfil'];
    }

    // 5. Calcular índice actual basado en la URL
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = paths.indexOf(location);
    final selectedIndex = currentIndex >= 0 ? currentIndex : 0;

    final currentTitle = titles[selectedIndex];
```

**Decisiones técnicas:**
- **Listas dinámicas**: Cambian completamente según el rol, no solo ocultar/mostrar items
- **indexOf para selectedIndex**: Sincroniza URL con UI (importante para deep links)
- **Fallback a 0**: Si la URL no coincide, selecciona el primer item (evita crashes)

#### AppBar con información contextual

```dart
return Scaffold(
  appBar: AppBar(
    titleSpacing: 0,
    title: Row(
      children: [
        const SizedBox(width: 12),
        
        // Logo clickeable que navega a home/dashboard
        GestureDetector(
          onTap: () => context.go(isAdmin ? '/dashboard' : '/home'),
          child: Row(
            children: [
              // Logo de la marca
              Image.asset('assets/images/logo.jpg', height: 72),
              const SizedBox(width: 8),
              
              // Nombre de la app + Título de la sección actual
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EcoBocado',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    currentTitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Separador visual
        Container(
          width: 1,
          height: 24,
          color: cs.outlineVariant.withOpacity(0.4),
        ),
        
        const SizedBox(width: 16),
      ],
    ),
```

**Widgets utilizados:**
- **GestureDetector**: Hace el logo clickeable (navegación a home)
- **Image.asset**: Carga logo desde assets locales (mejor performance que network)
- **Column con CrossAxisAlignment.start**: Alinea textos a la izquierda
- **Container con width/height**: Separador vertical personalizado

#### Acciones del AppBar

```dart
    actions: [
      // Mostrar nombre solo si está autenticado
      if (isLogged && displayName != null) ...[
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hola, $displayName',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              // Badge ADMIN (solo para administradores)
              if (auth?.isAdmin == true) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
      
      // Avatar (siempre visible)
      GestureDetector(
        onTap: () => context.go('/profile'),
        child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: cs.secondaryContainer,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? NetworkImage(avatarUrl)
                : null,
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
        ),
      ),
      
      // Botón de settings
      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Preferencias',
        onPressed: () => _openSettings(context),
      ),
      const SizedBox(width: 6),
    ],
```

**Características técnicas:**
- **Spread operator (...[])**: Añade widgets condicionalmente sin if/else anidados
- **CircleAvatar con fallback**: Muestra NetworkImage si hay URL, sino icono genérico
- **GestureDetector vs InkWell**: GestureDetector no tiene efecto de ripple (diseño más limpio)

#### BottomNavigationBar adaptativo

```dart
  bottomNavigationBar: NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: (index) => context.go(paths[index]),
    destinations: isAdmin
        ? const [
            // Navegación para ADMIN
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Productos',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_outlined),
              selectedIcon: Icon(Icons.receipt),
              label: 'Facturación',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ]
        : const [
            // Navegación para USUARIO
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Menú',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Pedidos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
    backgroundColor: cs.surface,
  ),
```

**Widgets utilizados:**
- **NavigationBar**: Nuevo componente Material 3 (reemplaza BottomNavigationBar)
- **NavigationDestination**: Items de navegación con iconos outlined/filled
- **selectedIcon vs icon**: Diferencia visual entre seleccionado/no seleccionado

### Flujo de interacción

```
Usuario hace tap en "Productos" (BottomNav)
              ↓
onDestinationSelected(index: 1) se ejecuta
              ↓
context.go(paths[1]) → context.go('/products')
              ↓
GoRouter cambia de ruta
              ↓
ShellRoute mantiene AppShell
              ↓
widget.child cambia a ProductsAdminPage
              ↓
AppShell se reconstruye
              ↓
selectedIndex se recalcula → 1
              ↓
BottomNavigationBar marca "Productos" como seleccionado
              ↓
currentTitle cambia a "Productos"
              ↓
AppBar actualiza el título
```

### Decisiones de diseño

**¿Por qué ConsumerStatefulWidget en lugar de ConsumerWidget?**
- Aunque actualmente no usa `setState()`, la arquitectura permite añadir estado local futuro
- Método `_openSettings` es más limpio como método de instancia que como función libre
- Preparado para animaciones (ej: expandir/colapsar AppBar)

**¿Por qué context.go() en lugar de Navigator.push()?**
- Consistencia: todas las navegaciones usan go_router
- Deep linking: URLs reflejan el estado de la app
- Back button funciona correctamente en web

**¿Por qué NavigationBar en lugar de BottomNavigationBar?**
- **Material 3**: Diseño moderno y accesible
- **Mejor adaptabilidad**: Funciona bien en tablets y desktops
- **Animaciones**: Transiciones más fluidas entre items

**¿Por qué el Badge ADMIN es condicional y no un role en el perfil?**
- **Visibilidad**: El admin necesita saber en todo momento que está en modo admin
- **UX**: Evita confusiones al cambiar entre cuentas
- **Seguridad**: Indicador visual claro de permisos elevados

---

## 5. Sistema de autenticación: auth_gate.dart

### Descripción
`AuthGate` es un **widget guardián** que protege rutas que requieren autenticación. Decide qué mostrar basándose en el estado del usuario:
- **Autenticado** → Muestra el contenido protegido
- **No autenticado** → Muestra la página de login/registro
- **Loading** → Muestra un indicador de carga
- **Error** → Muestra la página de login (fallback seguro)

### Arquitectura

```
AuthGate (ConsumerWidget)
  ├── Observa authProvider
  ├── Evalúa AsyncValue<AuthViewState>
  └── Decide qué renderizar
      ├── data + isLogged → child (contenido protegido)
      ├── data + !isLogged → AuthPage
      ├── loading → CircularProgressIndicator
      └── error → AuthPage (fallback)
```

### Código completo con explicaciones

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_bocado/features/auth/presentation/pages/auth_page.dart';
import 'package:eco_bocado/features/auth/presentation/providers/auth_provider.dart';

/// Widget que decide qué mostrar en función del estado de autenticación
class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    required this.child,
    this.authPageKey,
  });

  final Widget child;          // Contenido protegido
  final Key? authPageKey;      // Key única para cada instancia de AuthPage

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Observar el estado de autenticación (AsyncValue)
    final auth = ref.watch(authProvider);

    // 2. Manejar los 4 estados posibles
    return auth.when(
      // Estado DATA: Tenemos información del usuario
      data: (authState) {
        // Verificar si hay sesión activa (usuario o admin)
        final isLogged = authState.userSession != null || 
                        authState.adminSession != null;
        
        // Decisión: mostrar contenido protegido o página de auth
        return isLogged ? child : AuthPage(key: authPageKey);
      },
      
      // Estado LOADING: Cargando sesión almacenada
      loading: () => const Center(child: CircularProgressIndicator()),
      
      // Estado ERROR: Falló la carga → asumir no autenticado
      error: (_, __) => AuthPage(key: authPageKey),
    );
  }
}
```

### Widgets y características

| Elemento | Tipo | Propósito |
|----------|------|-----------|
| **ConsumerWidget** | Base class | Permite observar providers con `ref.watch()` |
| **child** | Widget requerido | Contenido que se mostrará si el usuario está autenticado |
| **authPageKey** | Key opcional | Diferencia múltiples instancias de AuthPage en el árbol |
| **AsyncValue.when()** | Pattern matching | Maneja elegantemente los 3 estados (data/loading/error) |

### Flujo de decisión

```
Usuario navega a ruta protegida (/products)
              ↓
Router renderiza AuthGate(child: ProductsAdminPage())
              ↓
AuthGate observa authProvider
              ↓
    ┌─────────┴─────────────┬──────────────┬──────────┐
    │                       │              │          │
  data                   loading        error     data
    │                       │              │      (no logged)
    │                       │              │          │
    ↓                       ↓              ↓          ↓
isLogged?              CircularProgress   AuthPage   AuthPage
    │
    ├─── true ────→ child (ProductsAdminPage)
    │
    └─── false ───→ AuthPage
```

### Estados manejados

#### 1. Loading State
```dart
loading: () => const Center(child: CircularProgressIndicator())
```
- **Cuándo ocurre**: Al iniciar la app, mientras se leen tokens de SharedPreferences
- **Duración**: Milisegundos (lectura local es rápida)
- **UX**: Indicador de carga centrado para feedback visual

#### 2. Error State
```dart
error: (_, __) => AuthPage(key: authPageKey)
```
- **Cuándo ocurre**: 
  - Error al validar token con el backend
  - Token expirado
  - Red no disponible
- **Decisión de diseño**: Asumir no autenticado (principio de **fail-safe**)
- **Resultado**: Usuario puede volver a autenticarse

#### 3. Data State (Logged)
```dart
data: (authState) {
  final isLogged = authState.userSession != null || 
                  authState.adminSession != null;
  return isLogged ? child : AuthPage(key: authPageKey);
}
```
- **Verificación doble**: Puede ser sesión de usuario O sesión de admin
- **Transparencia de rol**: AuthGate no diferencia roles, solo valida autenticación
- **Decisión**: Cada ruta decide qué mostrar según el rol (ej: Dashboard solo para admin)

#### 4. Data State (Not Logged)
```dart
return isLogged ? child : AuthPage(key: authPageKey);
```
- **AuthPage**: Pantalla combinada de login/registro
- **authPageKey**: Evita compartir estado de formularios entre rutas

### Patrón de uso en rutas

```dart
// En router.dart
GoRoute(
  path: '/products',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: AuthGate(
      child: ProductsAdminPage(),               // ← Contenido protegido
      authPageKey: ValueKey('products-auth'),   // ← Key única
    ),
  ),
),
```

**¿Por qué cada ruta tiene su propia Key?**
```
Escenario problemático SIN keys únicas:
1. Usuario va a /orders → AuthGate muestra AuthPage
2. Usuario rellena formulario de login (email, contraseña)
3. Usuario cambia de tab y va a /profile → AuthGate muestra AuthPage
4. Flutter reutiliza la MISMA instancia de AuthPage (misma key)
5. El formulario mantiene los valores del intento anterior
6. ❌ Confusión: ¿es el mismo formulario o uno nuevo?

Solución CON keys únicas:
1. Usuario va a /orders → AuthPage(key: 'orders-auth')
2. Usuario rellena formulario
3. Usuario cambia a /profile → AuthPage(key: 'profile-auth')
4. Flutter crea una NUEVA instancia (diferente key)
5. Formulario vacío y limpio
6. ✅ UX clara: cada ruta tiene su propio flujo de auth
```

### Decisiones de diseño

**¿Por qué ConsumerWidget en lugar de Consumer wrapper?**
```dart
// Alternativa verbose (NO usada)
return Consumer(
  builder: (context, ref, child) {
    final auth = ref.watch(authProvider);
    return auth.when(...);
  },
);

// Solución elegida (SÍ usada)
class AuthGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return auth.when(...);
  }
}
```
- **Más limpio**: Menos indentación
- **Reusable**: Puede usarse como un widget normal
- **Type-safe**: Widget propio con propiedades tipadas

**¿Por qué no usar FutureBuilder?**
- **AsyncValue > Future**: Riverpod maneja caching, reintentOS y estados
- **Reactividad**: Cambios en authProvider actualizan AuthGate automáticamente
- **Consistencia**: Toda la app usa Riverpod, no mezclar con FutureBuilder

**¿Por qué mostrar AuthPage en lugar de un mensaje de error en error state?**
- **Fail-open sería inseguro**: Mostrar contenido protegido en error
- **Fail-safe es correcto**: Forzar re-autenticación
- **UX**: Usuario puede resolver el problema inmediatamente (re-login)

---

## 6. Providers principales

### Descripción
Los **providers** son el corazón del sistema de gestión de estado en esta aplicación. Utilizamos **Riverpod 3.0** con arquitectura basada en **Notifiers** para estado mutable.

### Jerarquía de providers

```
Capa de Infraestructura (Inyección de Dependencias)
  └── sharedPreferencesProvider
            ↓
Capa de Data (DataSources y Repositories)
  ├── preferencesLocalDSProvider
  └── preferencesRepositoryProvider
            ↓
Capa de Domain (UseCases)
  └── preferencesUseCasesProvider
            ↓
Capa de Presentation (State Management)
  ├── preferencesProvider (AsyncNotifierProvider)
  ├── authProvider (AsyncNotifierProvider)
  └── routerProvider (Provider inmutable)
```

---

### 6.1. sharedPreferencesProvider

#### Código
```dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});
```

#### Características
- **Tipo**: `Provider<SharedPreferences>` (inmutable)
- **Ciclo de vida**: Global, dura toda la ejecución de la app
- **Override**: DEBE ser sobreescrito en `main.dart` con la instancia real

#### ¿Por qué throw UnimplementedError?
```dart
// SIN override (en tests o error de configuración)
final prefs = ref.read(sharedPreferencesProvider);
// ❌ CRASH: UnimplementedError

// CON override (en main.dart)
ProviderScope(
  overrides: [
    sharedPreferencesProvider.overrideWithValue(
      await SharedPreferences.getInstance()
    ),
  ],
  child: const EcoBocadoApp(),
)
// ✅ FUNCIONA: devuelve la instancia real
```

**Ventajas del patrón:**
1. **Type-safe**: El tipo está definido, IDE autocompleta
2. **Fail-fast**: Si olvidas el override, falla inmediatamente (no en runtime tardío)
3. **Testeable**: En tests, puedes inyectar mocks fácilmente

---

### 6.2. preferencesProvider

#### Código completo
```dart
// DataSource
final preferencesLocalDSProvider = Provider<PreferencesLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesLocalDataSource(prefs);
});

// Repository
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final ds = ref.watch(preferencesLocalDSProvider);
  return PreferencesRepositoryImpl(localDataSource: ds);
});

// UseCases
final preferencesUseCasesProvider = Provider<PreferencesUseCases>((ref) {
  final repo = ref.watch(preferencesRepositoryProvider);
  return PreferencesUseCases(repo);
});

// Notifier (Estado Mutable)
class PreferencesNotifier extends AsyncNotifier<Preferences> {
  late final PreferencesUseCases preferencesUseCases;

  @override
  Future<Preferences> build() async {
    preferencesUseCases = ref.watch(preferencesUseCasesProvider);
    return await preferencesUseCases.getPreferences();
  }

  Future<void> updateAppNotifications(bool value) async {
    await _updatePreference(
      (prefs) => prefs.copyWith(appNotifications: value),
      Preferences.appNotificationsConst,
    );
  }

  Future<void> updateDarkMode(bool value) async {
    await _updatePreference(
      (prefs) => prefs.copyWith(darkMode: value),
      Preferences.darkModeConst,
    );
  }

  Future<void> _updatePreference(
    Preferences Function(Preferences) update,
    String key,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = await preferencesUseCases.getPreferences();
      final updated = update(current);
      await preferencesUseCases.updatePreference(key, updated);
      return updated;
    });
  }
}

// Provider del Notifier
final preferencesProvider = AsyncNotifierProvider<PreferencesNotifier, Preferences>(() {
  return PreferencesNotifier();
});
```

#### Arquitectura en capas

```
UI Layer (Widget)
  ↓ ref.watch(preferencesProvider)
PreferencesNotifier (AsyncNotifier)
  ↓ preferencesUseCases
PreferencesUseCases (Domain)
  ↓ preferencesRepository
PreferencesRepository (Data)
  ↓ preferencesLocalDataSource
PreferencesLocalDataSource (Data)
  ↓ SharedPreferences
Almacenamiento persistente (nativo)
```

#### Estados de AsyncNotifier

| Estado | Representación | Cuándo ocurre |
|--------|----------------|---------------|
| **loading** | `AsyncValue<Preferences>.loading()` | Durante `build()` inicial o al guardar cambios |
| **data** | `AsyncValue<Preferences>.data(prefs)` | Cuando hay datos disponibles |
| **error** | `AsyncValue<Preferences>.error(e, st)` | Si falla lectura/escritura |

#### Flujo de actualización

```
Usuario cambia tema a oscuro en SettingsPage
              ↓
ref.read(preferencesProvider.notifier).updateDarkMode(true)
              ↓
PreferencesNotifier._updatePreference()
              ↓
state = AsyncValue.loading() → UI muestra loading
              ↓
getPreferences() → Lee estado actual
              ↓
prefs.copyWith(darkMode: true) → Crea nuevo objeto
              ↓
updatePreference() → Guarda en SharedPreferences
              ↓
state = AsyncValue.data(updatedPrefs) → UI actualiza
              ↓
EcoBocadoApp detecta cambio en darkMode
              ↓
MaterialApp.router cambia themeMode
              ↓
Toda la app cambia de tema
```

#### Métodos públicos

```dart
// Actualizar notificaciones
await ref.read(preferencesProvider.notifier).updateAppNotifications(true);

// Actualizar tema oscuro
await ref.read(preferencesProvider.notifier).updateDarkMode(true);
```

#### Decisiones de diseño

**¿Por qué AsyncNotifier en lugar de StateNotifier?**
- **Async**: Las operaciones son asíncronas (lectura/escritura en disco)
- **Estados explícitos**: Diferencia clara entre loading/data/error
- **Immutability**: `Preferences` es inmutable, cada cambio crea un nuevo objeto

**¿Por qué copyWith() en lugar de mutación directa?**
```dart
// ❌ MAL (mutación directa)
prefs.darkMode = true;

// ✅ BIEN (inmutabilidad)
final updated = prefs.copyWith(darkMode: true);
```
- **Immutable state**: Riverpod detecta cambios comparando referencias
- **Predictibilidad**: El estado anterior no se modifica
- **Debugging**: Puedes ver el estado en cada punto del tiempo

---

### 6.3. authProvider

#### Código completo
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
    
    if (_manuallySet) return;
    
    if (access == null || access.isEmpty) {
      state = const AsyncValue.data(AuthViewState.anonymous());
      return;
    }

    final name = await local.readSessionName();
    final email = await local.readSessionEmail();
    final avatar = await local.readSessionAvatar();
    final role = stored.role;
    
    if (role == 'admin') {
      final admin = Admin(name: name ?? '', email: email ?? '', avatarUrl: avatar);
      state = AsyncValue.data(AuthViewState(
        adminSession: AdminSession(admin: admin, tokens: stored),
      ));
    } else {
      final user = User(name: name ?? '', email: email ?? '', avatarUrl: avatar);
      state = AsyncValue.data(AuthViewState(
        userSession: UserSession(user: user, tokens: stored),
      ));
    }
  }

  // Métodos públicos: loginUser, loginAdmin, logout, etc.
}

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<AuthViewState>>(() {
  return AuthNotifier();
});
```

#### Estructura de AuthViewState

```
AuthViewState
  ├── userSession?: UserSession
  │     ├── user: User
  │     │    ├── name
  │     │    ├── email
  │     │    └── avatarUrl
  │     └── tokens: AuthTokens
  │          ├── accessToken
  │          └── refreshToken
  │
  ├── adminSession?: AdminSession
  │     ├── admin: Admin
  │     │    ├── name
  │     │    ├── email
  │     │    └── avatarUrl
  │     └── tokens: AuthTokens
  │
  └── Computed properties:
        ├── isAuthenticated
        ├── isAdmin
        ├── displayName
        └── avatarUrl
```

#### Flujo de inicialización

```
App inicia → authProvider se crea
              ↓
build() se ejecuta por primera vez
              ↓
_initialize() inicia de forma asíncrona
              ↓
state = AsyncValue.loading()
              ↓
    ┌─────────┴─────────┐
    │                   │
Token encontrado    Token NO encontrado
    │                   │
    ↓                   ↓
Validar con backend   state = data(anonymous)
    │
    ├─── Token válido ───→ Crear sesión (user/admin)
    │                      state = data(AuthViewState con sesión)
    │
    └─── Token inválido ──→ state = data(anonymous)
```

#### Métodos públicos principales

```dart
// Login como usuario
await ref.read(authProvider.notifier).loginUser(email, password);

// Login como admin
await ref.read(authProvider.notifier).loginAdmin(email, password);

// Logout
await ref.read(authProvider.notifier).logout();

// Actualizar perfil
await ref.read(authProvider.notifier).updateProfile(name, avatar);
```

#### Decisiones de diseño

**¿Por qué Notifier<AsyncValue<T>> en lugar de AsyncNotifier<T>?**
```dart
// AsyncNotifier (auto-loading en build)
class AuthNotifier extends AsyncNotifier<AuthViewState> {
  @override
  Future<AuthViewState> build() async {
    // ❌ build() debe completarse para que el provider esté disponible
    await _longInitialization(); // Bloquea toda la app
    return AuthViewState();
  }
}

// Notifier<AsyncValue<T>> (control manual de estados)
class AuthNotifier extends Notifier<AsyncValue<AuthViewState>> {
  @override
  AsyncValue<AuthViewState> build() {
    // ✅ Retorna inmediatamente
    _initialize(); // Ejecuta en background
    return const AsyncValue.loading();
  }
}
```

**Ventajas del enfoque elegido:**
- **No bloquea el inicio**: La app carga mientras se valida la sesión
- **Control fino**: Podemos decidir cuándo cambiar de loading a data
- **Manejo de race conditions**: `_manuallySet` previene sobrescrituras

**¿Por qué AuthViewState en lugar de dos providers separados?**
```dart
// Alternativa rechazada
final userSessionProvider = ...;
final adminSessionProvider = ...;

// ❌ Problemas:
// 1. Sincronización: ¿qué pasa si ambos tienen valor?
// 2. Lógica duplicada: isAuthenticated en dos lugares
// 3. Más complejo: dos providers para observar

// Solución elegida
final authProvider = NotifierProvider<AuthNotifier, AsyncValue<AuthViewState>>();

// ✅ Ventajas:
// 1. Un solo source of truth
// 2. Lógica centralizada (isAdmin, displayName)
// 3. Observers solo necesitan un ref.watch()
```

---

### 6.4. routerProvider

#### Código
```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [ ... ],
  );
});
```

#### Características
- **Tipo**: `Provider<GoRouter>` (inmutable)
- **Ciclo de vida**: Se crea una vez al inicio y nunca cambia
- **Observadores**: `EcoBocadoApp` lo observa con `ref.watch()`

#### ¿Por qué Provider y no StateNotifier?

```dart
// ❌ Si usáramos StateNotifier
final routerProvider = StateNotifierProvider<RouterNotifier, GoRouter>(...);

// Problema: Cada cambio de estado recrearía TODA la app
context.go('/products');
  ↓
routerProvider cambia de estado
  ↓
EcoBocadoApp se reconstruye completamente
  ↓
MaterialApp.router se recrea
  ↓
❌ Pérdida de estado, animaciones interrumpidas
```

```dart
// ✅ Con Provider inmutable
final router = ref.watch(routerProvider);

// El router nunca cambia de referencia
context.go('/products');
  ↓
GoRouter maneja la navegación internamente
  ↓
Solo el contenido de ShellRoute cambia
  ↓
EcoBocadoApp NO se reconstruye
  ↓
✅ Performance óptima, estado preservado
```

---

## Resumen ejecutivo

### Flujo completo desde el inicio

```
1. main()
   ├── Inicializa WidgetsFlutterBinding
   ├── Carga SharedPreferences
   └── Lanza ProviderScope con overrides

2. EcoBocadoApp (app.dart)
   ├── Observa routerProvider (sistema de navegación)
   ├── Observa preferencesProvider (tema oscuro/claro)
   └── Configura MaterialApp.router

3. GoRouter (router.dart)
   ├── Define todas las rutas de la app
   ├── Implementa ShellRoute con AppShell
   └── Protege rutas con AuthGate

4. AppShell (app_shell.dart)
   ├── Observa authProvider (rol y estado del usuario)
   ├── Muestra AppBar con logo, título, avatar
   ├── Muestra BottomNavigationBar adaptativo (user/admin)
   └── Renderiza el child (página actual)

5. AuthGate (auth_gate.dart)
   ├── Observa authProvider
   ├── Si isAuthenticated → muestra child
   └── Si NO authenticated → muestra AuthPage

6. Providers (gestión de estado)
   ├── sharedPreferencesProvider: Almacenamiento persistente
   ├── preferencesProvider: Tema, notificaciones, etc.
   ├── authProvider: Sesión de usuario/admin
   └── routerProvider: Sistema de navegación
```

### Widgets clave utilizados

| Widget | Propósito | ¿Por qué? |
|--------|-----------|-----------|
| **ProviderScope** | Contenedor de Riverpod | Hace disponibles los providers en toda la app |
| **ConsumerWidget** | Widget reactivo | Permite `ref.watch()` para observar providers |
| **MaterialApp.router** | App con navegación declarativa | Integración con go_router para URLs y deep linking |
| **ShellRoute** | Layout persistente | AppBar y BottomNav no se reconstruyen al cambiar de ruta |
| **NavigationBar** | Bottom navigation (M3) | Navegación moderna y accesible |
| **CircleAvatar** | Avatar circular | Muestra foto de perfil o icono por defecto |
| **AsyncValue.when()** | Pattern matching | Maneja elegantemente estados loading/data/error |

### Providers clave y su rol

| Provider | Tipo | Responsabilidad |
|----------|------|-----------------|
| **sharedPreferencesProvider** | Provider | Inyectar SharedPreferences en la app |
| **preferencesProvider** | AsyncNotifierProvider | Gestionar preferencias del usuario (tema, notificaciones) |
| **authProvider** | NotifierProvider | Gestionar sesión de autenticación (user/admin) |
| **routerProvider** | Provider | Proporcionar el sistema de navegación (GoRouter) |

### Patrones de arquitectura aplicados

1. **Clean Architecture**: Separación en capas (Data, Domain, Presentation)
2. **Dependency Injection**: Providers inyectan dependencias
3. **State Management**: Riverpod con Notifiers para estado mutable
4. **Repository Pattern**: Abstracción de fuentes de datos
5. **UseCase Pattern**: Lógica de negocio en casos de uso
6. **Observer Pattern**: Widgets reaccionan a cambios en providers
7. **Guard Pattern**: AuthGate protege rutas según autenticación
8. **Immutable State**: Estados nunca se mutan, siempre se reemplazan