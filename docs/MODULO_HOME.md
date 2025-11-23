# 🏠 Módulo Home - Página de Inicio

---

## 1. Descripción general

### Propósito del módulo
El módulo **Home** es la página de bienvenida de la aplicación "EcoBocado". Su objetivo es:
- 🎯 **Presentar la propuesta de valor** del negocio (Zero Waste, comida sostenible)
- 🌱 **Destacar características clave** (ecológico, vegano, rápido)
- 🎁 **Promocionar el programa de fidelidad**
- 📸 **Mostrar contenido visual atractivo** de los productos

### Características principales
- **Página estática**: No requiere estado ni providers (StatelessWidget)
- **Diseño modular**: Compuesta por widgets reutilizables
- **Responsive**: Se adapta a diferentes tamaños de pantalla
- **Accesible**: Toda la información es pública (no requiere autenticación)

### Ubicación en la navegación
```
BottomNavigationBar (Usuario)
  └── Inicio (HOME) ← Estás aquí
  └── Menú
  └── Pedidos
  └── Perfil
```

---

## 2. Arquitectura del módulo

### Estructura de archivos
```
features/home/
  └── presentation/
      ├── pages/
      │   └── home_page.dart           # Página principal
      └── widgets/
          ├── home_hero_header.dart    # Hero destacado con título y badges
          ├── featured_big_card.dart   # Card grande con imagen
          ├── loyalty_gradient_banner.dart  # Banner de fidelización
          └── info_small_card.dart     # Cards informativos pequeños (no usada actualmente)
```

### Jerarquía de componentes

```
HomePage (StatelessWidget)
  └── ListView
      ├── HomeHeroHeader
      │   ├── Título "Comida Deliciosa Sin Desperdicios"
      │   ├── Subtítulo descriptivo
      │   └── Badges [Cero Desperdicios, Menús Veganos]
      │
      ├── Card (Features)
      │   ├── Columna 1: Comida Ecológica (Icon + Text)
      │   ├── Divider vertical
      │   └── Columna 2: Recogida rápida (Icon + Text)
      │
      ├── FeaturedBigCard
      │   ├── Imagen de fondo (home.jpg)
      │   ├── Gradiente overlay
      │   ├── Badge "100% Sostenible"
      │   └── Título "Envases compostables"
      │
      └── LoyaltyGradientBanner
          ├── Icono de regalo
          ├── Título "¡PROGRAMA DE FIDELIDAD!"
          ├── Subtítulo explicativo
          └── Badge "NUEVO!"
```

### Dependencias

| Dependencia | Tipo | Propósito |
|-------------|------|-----------|
| **flutter/material.dart** | Framework | Widgets base de Material Design |
| **app_badge.dart** | Widget del core | Badges reutilizables con iconos |
| **app_palette.dart** | Theme | Colores personalizados (success, warning) |

**Nota importante**: Este módulo NO tiene:
- ❌ Providers (no maneja estado)
- ❌ DataSources (no hace peticiones)
- ❌ Repositories (no accede a datos)
- ❌ UseCases (no tiene lógica de negocio)

---

## 3. HomePage: Página principal

### Código completo

```dart
import 'package:flutter/material.dart';
import 'package:pub_diferent/core/widgets/app_badge.dart';
import 'package:pub_diferent/features/home/presentation/widgets/home_hero_header.dart';
import 'package:pub_diferent/features/home/presentation/widgets/featured_big_card.dart';
import 'package:pub_diferent/features/home/presentation/widgets/loyalty_gradient_banner.dart';
import 'package:pub_diferent/app/theme/app_palette.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener paleta de colores personalizada
    final palette = appPaletteOf(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Hero principal con título y badges
        HomeHeroHeader(
          titlePrimary: 'Comida Deliciosa',
          titleAccent: 'Sin Desperdicios',
          subtitle:
              'Disfruta de la mejor comida para llevar mientras cuidamos nuestro planeta. '
              'Envases reutilizables, ingredientes locales y cero desperdicios.',
          badges: const [
            AppBadge(
              label: 'Cero Desperdicios',
              icon: Icons.recycling,
              color: Colors.teal,
            ),
            AppBadge(
              label: 'Menús Veganos',
              icon: Icons.flatware,
              color: Colors.green,
            ),
          ],
        ),
        
        // 2. Card con características principales
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Característica 1: Comida Ecológica
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.eco, 
                        size: 32, 
                        color: palette.success,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Comida Ecológica',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Zero Waste',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Divider vertical
                Container(
                  width: 1,
                  height: 80,
                  color: Theme.of(context).dividerColor,
                ),
                
                // Característica 2: Recogida rápida
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.flash_on, 
                        size: 32, 
                        color: palette.warning,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Recogida rápida',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sin esperas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 3. Card destacada con imagen
        const FeaturedBigCard(
          image: AssetImage('assets/images/home.jpg'),
          badge: AppBadge(
            label: '100% Sostenible',
            icon: Icons.energy_savings_leaf,
            color: Colors.green,
          ),
          title: 'Envases compostables y reutilizables',
        ),
        
        const SizedBox(height: 4),
        
        // 4. Banner de programa de fidelidad
        const LoyaltyGradientBanner(
          title: '¡PROGRAMA DE FIDELIDAD! 10 compras = 1 menú GRATIS',
          subtitle: 'Acumula puntos y canjéalos por recompensas deliciosas.',
          showNewBadge: true,
        ),
      ],
    );
  }
}
```

### Widgets utilizados

#### ListView
```dart
return ListView(
  padding: const EdgeInsets.all(16),
  children: [ ... ],
);
```
- **¿Por qué ListView y no Column?**: ListView es scrollable por defecto
- **Ventaja**: Si el contenido es muy largo, se puede hacer scroll
- **Padding uniforme**: 16px en todos los lados para espaciado consistente

#### Card con Row (Features)
```dart
Card(
  elevation: 2,
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        Expanded(child: ...), // Icono + Texto
        Container(...),       // Divider
        Expanded(child: ...), // Icono + Texto
      ],
    ),
  ),
)
```

**Características técnicas:**
- **Expanded**: Distribuye el espacio equitativamente (50%-50%)
- **Container como divider**: Línea vertical de 1px
- **Icons con colores de paleta**: `palette.success` y `palette.warning`

#### Divider vertical personalizado
```dart
Container(
  width: 1,
  height: 80,
  color: Theme.of(context).dividerColor,
)
```
- **¿Por qué no usar VerticalDivider?**: Más control sobre altura y posicionamiento
- **dividerColor**: Se adapta automáticamente al tema (claro/oscuro)

### Flujo de renderizado

```
1. AppShell muestra HomePage como child
              ↓
2. ListView se construye con padding de 16px
              ↓
3. Renderiza en orden:
   ├── HomeHeroHeader (gradiente + título + badges)
   ├── Card (features con iconos)
   ├── FeaturedBigCard (imagen + overlay)
   └── LoyaltyGradientBanner (promo)
              ↓
4. Usuario puede hacer scroll si necesario
```

### Decisiones de diseño

**¿Por qué StatelessWidget?**
- No hay estado que cambiar (contenido estático)
- Mejor performance (no se reconstruye innecesariamente)
- Más simple de entender y mantener

**¿Por qué const en los widgets?**
```dart
const AppBadge(...)           // ✅ const: no cambia nunca
const FeaturedBigCard(...)    // ✅ const: propiedades inmutables
```
- **Optimización**: Flutter reutiliza instancias const (menos memoria)
- **Performance**: No se reconstruyen en cada build
- **Best practice**: Siempre que sea posible, usar const

**¿Por qué no usar un Grid?**
- **Diseño vertical**: HomePage es una secuencia lineal de secciones
- **Responsividad simple**: ListView maneja overflow automáticamente
- **Alternativa futura**: Se podría usar `GridView` para cards de características

---

## 4. Widgets personalizados

### 4.1. HomeHeroHeader

#### Descripción
Widget destacado que actúa como **hero principal** de la página. Presenta el mensaje clave del negocio con un diseño visual impactante.

#### Propiedades

```dart
class HomeHeroHeader extends StatelessWidget {
  const HomeHeroHeader({
    super.key,
    required this.titlePrimary,    // "Comida Deliciosa"
    required this.titleAccent,     // "Sin Desperdicios"
    required this.subtitle,        // Descripción larga
    required this.badges,          // Lista de AppBadge
    this.padding,                  // Opcional
    this.actions,                  // Opcional (botones/iconos)
  });
}
```

#### Código clave

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final tt = theme.textTheme;
  final isDark = theme.brightness == Brightness.dark;

  // Gradiente suave adaptativo al tema
  final gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      cs.secondary.withOpacity(isDark ? 0.22 : 0.16),
      cs.secondary.withOpacity(isDark ? 0.10 : 0.08),
    ],
  );

  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Título con RichText (dos colores diferentes)
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: tt.headlineLarge?.copyWith(
              color: cs.onSurface,
              height: 1.15,
            ),
            children: [
              TextSpan(text: '$titlePrimary\n'),
              TextSpan(
                text: titleAccent,
                style: tt.headlineLarge?.copyWith(
                  color: cs.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Subtítulo
        Text(
          subtitle,
          textAlign: TextAlign.justify,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Badges centrados
        if (badges.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: badges,
          ),
      ],
    ),
  );
}
```

#### Widgets utilizados

| Widget | Propósito | ¿Por qué? |
|--------|-----------|-----------|
| **Container con BoxDecoration** | Fondo con gradiente y sombra | Permite combinar múltiples efectos visuales |
| **RichText** | Título con dos estilos diferentes | Necesitamos colorear "Sin Desperdicios" diferente |
| **TextSpan** | Fragmentos de texto con estilos propios | Compone el título multicolor |
| **Wrap** | Layout flexible para badges | Se adapta si no caben en una línea |
| **WrapAlignment.center** | Centrar badges horizontalmente | Diseño equilibrado |

#### Adaptación al tema

```dart
final isDark = theme.brightness == Brightness.dark;

// Opacidades diferentes según tema
colors: [
  cs.secondary.withOpacity(isDark ? 0.22 : 0.16),  // Más opaco en oscuro
  cs.secondary.withOpacity(isDark ? 0.10 : 0.08),
],

// Sombra más pronunciada en tema oscuro
BoxShadow(
  color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
  blurRadius: 20,
  offset: const Offset(0, 8),
)
```

**¿Por qué diferente opacidad?**
- En **tema claro**: Gradiente sutil para no distraer
- En **tema oscuro**: Gradiente más visible para contraste

#### Decisiones de diseño

**¿Por qué RichText en lugar de dos Text widgets?**
```dart
// ❌ Opción descartada (dos widgets)
Column(
  children: [
    Text('Comida Deliciosa'),
    Text('Sin Desperdicios', style: TextStyle(color: secondary)),
  ],
)
// Problema: Difícil controlar el espaciado entre líneas

// ✅ Opción elegida (RichText)
RichText(
  text: TextSpan(
    children: [
      TextSpan(text: 'Comida Deliciosa\n'),
      TextSpan(text: 'Sin Desperdicios', style: ...),
    ],
  ),
)
// Ventaja: Control total sobre line-height y alineación
```

---

### 4.2. FeaturedBigCard

#### Descripción
Card destacada con **imagen de fondo, overlay degradado, badge y título**. Ideal para mostrar características visuales del producto.

#### Propiedades

```dart
class FeaturedBigCard extends StatelessWidget {
  const FeaturedBigCard({
    super.key,
    required this.image,    // ImageProvider (AssetImage o NetworkImage)
    required this.badge,    // AppBadge
    required this.title,    // Texto descriptivo
  });
}
```

#### Código clave

```dart
@override
Widget build(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;

  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Stack(
      children: [
        // 1. Imagen de fondo con aspect ratio 16:9
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildImage(cs),
        ),
        
        // 2. Gradiente overlay (oscurece abajo para legibilidad)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.55),
                ],
              ),
            ),
          ),
        ),
        
        // 3. Badge y título superpuestos
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              badge,
              const SizedBox(height: 8),
              Text(
                title,
                style: tt.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildImage(ColorScheme cs) {
  // Soporte para AssetImage y NetworkImage
  if (image is NetworkImage) {
    final url = (image as NetworkImage).url;
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: cs.errorContainer,
          child: Icon(Icons.broken_image, color: cs.onErrorContainer),
        );
      },
    );
  }
  
  // AssetImage (más común en este caso)
  return Image(
    image: image,
    fit: BoxFit.cover,
  );
}
```

#### Widgets utilizados

| Widget | Propósito | ¿Por qué? |
|--------|-----------|-----------|
| **ClipRRect** | Bordes redondeados | Clips todo el contenido interno (imagen + overlays) |
| **Stack** | Superposición de capas | Permite poner gradiente y texto sobre la imagen |
| **AspectRatio** | Mantener proporción 16:9 | Consistencia visual, evita imágenes deformadas |
| **Positioned.fill** | Overlay que cubre toda la imagen | Gradiente de arriba a abajo |
| **DecoratedBox** | Aplicar gradiente | Más ligero que Container si solo necesitas decoration |
| **Positioned (bottom)** | Posicionar badge/título al fondo | Legibilidad con el gradiente oscuro |

#### Gradiente para legibilidad

```dart
gradient: LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.transparent,                  // Arriba: imagen visible
    Colors.black.withOpacity(0.35),      // Medio: transición
    Colors.black.withOpacity(0.55),      // Abajo: oscuro para texto
  ],
)
```

**Progresión del oscurecimiento:**
```
   0% opacidad  ←  Imagen claramente visible
       ↓
      35% opacidad  ←  Transición suave
       ↓
      55% opacidad  ←  Texto legible (blanco sobre oscuro)
```

#### Soporte de imágenes

```dart
// ✅ AssetImage (local, más rápida)
const FeaturedBigCard(
  image: AssetImage('assets/images/home.jpg'),
  ...
)

// ✅ NetworkImage (remota, con loading/error)
FeaturedBigCard(
  image: NetworkImage('https://example.com/image.jpg'),
  ...
)
```

**¿Por qué ImageProvider en lugar de String?**
- **Type-safe**: El compilador valida el tipo
- **const-friendly**: `AssetImage` puede ser const
- **Flexible**: Soporta múltiples tipos de imágenes (Asset, Network, File, Memory)

#### Decisiones de diseño

**¿Por qué AspectRatio 16:9?**
- **Estándar universal**: Formato de video y fotografía moderno
- **Responsive**: Se adapta al ancho de la pantalla manteniendo proporción
- **Consistencia**: Todas las featured cards tienen la misma proporción

**¿Por qué Positioned.fill para el gradiente?**
```dart
// ❌ Alternativa rechazada
Container(
  width: double.infinity,
  height: double.infinity,
  decoration: BoxDecoration(gradient: ...),
)
// Problema: width/height infinitos causan errores en Stack

// ✅ Solución elegida
Positioned.fill(
  child: DecoratedBox(decoration: ...),
)
// Ventaja: Se expande automáticamente al tamaño del Stack
```

---

### 4.3. LoyaltyGradientBanner

#### Descripción
Banner con **gradiente cálido y llamativo** para promocionar el programa de fidelidad. Diseñado para captar la atención del usuario.

#### Propiedades

```dart
class LoyaltyGradientBanner extends StatelessWidget {
  const LoyaltyGradientBanner({
    super.key,
    required this.title,          // "¡PROGRAMA DE FIDELIDAD!"
    required this.subtitle,       // Descripción
    this.showNewBadge = true,     // Mostrar badge "NUEVO!"
    this.padding,                 // Opcional
  });
}
```

#### Código clave

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final tt = theme.textTheme;
  final isDark = theme.brightness == Brightness.dark;

  // Gradiente cálido con tonos ámbar/naranja
  final gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFFFC107).withOpacity(isDark ? 0.90 : 0.88), // Amber
      const Color(0xFFFF7043).withOpacity(isDark ? 0.95 : 0.92), // Deep orange
      cs.secondary.withOpacity(isDark ? 0.92 : 0.90),            // Theme secondary
    ],
  );

  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    padding: padding ?? const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono de regalo
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.card_giftcard,
            color: Colors.white,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Textos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: tt.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.92),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        
        // Badge "NUEVO!" (condicional)
        if (showNewBadge) ...[
          const SizedBox(width: 8),
          const AppBadge(
            label: 'NUEVO!',
            color: Colors.white,
            size: AppBadgeSize.small,
          ),
        ],
      ],
    ),
  );
}
```

#### Widgets utilizados

| Widget | Propósito | ¿Por qué? |
|--------|-----------|-----------|
| **Container con gradiente** | Fondo llamativo | Captar atención con colores cálidos |
| **Row** | Layout horizontal | Icono + Texto + Badge en línea |
| **Container como icono decorado** | Fondo semi-transparente para el icono | Jerarquía visual, separar del texto |
| **Expanded** | Texto ocupa espacio disponible | El texto se expande, badge se mantiene compacto |
| **if (showNewBadge)** | Mostrar badge condicionalmente | Flexibilidad para ocultar el badge después |

#### Gradiente cálido

```dart
colors: [
  const Color(0xFFFFC107).withOpacity(...), // #FFC107 - Amber (amarillo dorado)
  const Color(0xFFFF7043).withOpacity(...), // #FF7043 - Deep Orange
  cs.secondary.withOpacity(...),            // Color secundario del tema
]
```

**Paleta de colores:**
- **Amber (#FFC107)**: Asociado con oro, recompensas, premium
- **Deep Orange (#FF7043)**: Energía, urgencia, call-to-action
- **Secondary del tema**: Coherencia con la identidad de marca

#### Iconografía y jerarquía

```dart
// Icono con fondo semi-transparente
Container(
  width: 44,
  height: 44,
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.18),  // Sutil, no distrae
    borderRadius: BorderRadius.circular(12),
  ),
  child: const Icon(
    Icons.card_giftcard,  // Representa regalo/recompensa
    color: Colors.white,
    size: 24,
  ),
)
```

**Jerarquía visual:**
1. **Título** → Negrita, grande, blanco puro (máxima visibilidad)
2. **Subtítulo** → Blanco semi-transparente (información secundaria)
3. **Icono** → Fondo sutil (complemento visual)
4. **Badge "NUEVO!"** → Contraste blanco (llamada a la acción)

#### Decisiones de diseño

**¿Por qué gradiente cálido en lugar del color del tema?**
- **Psicología del color**: Naranja/amarillo = recompensa, urgencia
- **Contraste**: Destaca del resto de la página
- **Emoción**: Genera entusiasmo y FOMO (fear of missing out)

**¿Por qué showNewBadge condicional?**
```dart
// Uso futuro: Ocultar después de X días
const LoyaltyGradientBanner(
  title: '...',
  subtitle: '...',
  showNewBadge: false,  // Ya no es nuevo
)
```
- **Flexibilidad**: Permite mostrar/ocultar sin cambiar el widget
- **Gradual**: Después de que los usuarios conozcan el programa, se puede quitar

---

## 5. Widgets reutilizables del core

### 5.1. AppBadge

#### Descripción
Widget **reutilizable** para mostrar badges/etiquetas con icono opcional. Usado en múltiples partes de la app (no solo Home).

#### Ubicación
```
lib/core/widgets/app_badge.dart
```

#### Propiedades

```dart
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,              // Texto del badge
    this.color,                       // Color personalizado (opcional)
    this.icon,                        // Icono (opcional)
    this.variant = AppBadgeVariant.filled,  // filled u outline
    this.size = AppBadgeSize.medium,  // small, medium, large
  });
}
```

#### Variantes

```dart
enum AppBadgeVariant {
  filled,   // Fondo de color, texto blanco
  outline,  // Borde de color, fondo transparente
}

enum AppBadgeSize {
  small,    // Padding reducido, fuente pequeña
  medium,   // Tamaño estándar
  large,    // Padding amplio, fuente grande
}
```

#### Código clave

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final baseColor = color ?? theme.colorScheme.primary;
  final isDark = theme.brightness == Brightness.dark;
  final surface = theme.colorScheme.surface;

  // Padding y tamaños según el size
  final (
    horizontalPadding,
    verticalPadding,
    fontSize,
    iconSize,
    gap,
  ) = switch (size) {
    AppBadgeSize.small => (8.0, 4.0, 10.0, 14.0, 4.0),
    AppBadgeSize.medium => (12.0, 6.0, 12.0, 16.0, 6.0),
    AppBadgeSize.large => (16.0, 8.0, 14.0, 18.0, 8.0),
  };

  final outline = variant == AppBadgeVariant.outline;
  
  final backgroundColor = _badgeBackgroundColor(
    base: baseColor,
    surface: surface,
    isOutlined: outline,
    isDark: isDark,
  );
  
  final foregroundColor = _badgeForegroundColor(
    base: baseColor,
    isOutlined: outline,
    isDark: isDark,
  );

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    ),
    decoration: BoxDecoration(
      color: backgroundColor,
      border: outline ? Border.all(color: baseColor, width: 1.5) : null,
      borderRadius: BorderRadius.circular(999), // Pill shape
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: foregroundColor),
          SizedBox(width: gap),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
      ],
    ),
  );
}
```

#### Uso en HomePage

```dart
// Badge filled con icono
const AppBadge(
  label: 'Cero Desperdicios',
  icon: Icons.recycling,
  color: Colors.teal,
)

// Badge outline pequeño
const AppBadge(
  label: 'NUEVO!',
  color: Colors.white,
  size: AppBadgeSize.small,
  variant: AppBadgeVariant.outline,
)
```

#### Decisiones de diseño

**¿Por qué un widget reutilizable en lugar de código inline?**
- **DRY (Don't Repeat Yourself)**: Se usa en Home, Shop, Admin, etc.
- **Consistencia**: Todos los badges se ven igual en toda la app
- **Mantenibilidad**: Cambios en un solo lugar

**¿Por qué switch expression para tamaños?**
```dart
// ✅ Modern Dart 3.0 syntax
final (padding, fontSize, ...) = switch (size) {
  AppBadgeSize.small => (8.0, 10.0, ...),
  AppBadgeSize.medium => (12.0, 12.0, ...),
  AppBadgeSize.large => (16.0, 14.0, ...),
};

// ❌ Old approach (más verbose)
double padding;
double fontSize;
if (size == AppBadgeSize.small) {
  padding = 8.0;
  fontSize = 10.0;
} else if ...
```

**¿Por qué BorderRadius.circular(999)?**
- **Pill shape**: Bordes completamente redondeados
- **999 es suficientemente grande**: Nunca será más pequeño que el badge
- **Alternativa**: `BorderRadius.circular(100)` también funciona

---

## 6. Decisiones de diseño

### 6.1. ¿Por qué no usar estado (providers)?

```dart
// ❌ Innecesario en Home
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeProvider);
    // ...
  }
}

// ✅ Correcto: Contenido estático
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [...]);
  }
}
```

**Razones:**
- **Contenido estático**: No cambia basándose en datos del backend
- **Performance**: StatelessWidget es más rápido
- **Simplicidad**: Menos código, más fácil de entender
- **Futuro**: Si se necesita contenido dinámico (CMS), se añadiría un provider

---

### 6.2. ¿Por qué widgets separados en lugar de un solo archivo?

```
✅ Estructura actual:
home_page.dart          (159 líneas)
home_hero_header.dart   (117 líneas)
featured_big_card.dart  (107 líneas)
loyalty_gradient_banner.dart (128 líneas)

❌ Alternativa rechazada:
home_page.dart          (511 líneas)
```

**Ventajas de la separación:**
- **Legibilidad**: Cada archivo tiene una responsabilidad única
- **Reusabilidad**: `FeaturedBigCard` se puede usar en otras páginas
- **Testabilidad**: Cada widget se puede testear independientemente
- **Colaboración**: Múltiples personas pueden trabajar en paralelo

---

### 6.3. ¿Por qué ListView en lugar de SingleChildScrollView + Column?

```dart
// ✅ Opción elegida
ListView(
  children: [widget1, widget2, widget3],
)

// ❌ Alternativa rechazada
SingleChildScrollView(
  child: Column(
    children: [widget1, widget2, widget3],
  ),
)
```

**Ventajas de ListView:**
- **Lazy loading**: Si hay muchos items, solo renderiza los visibles
- **Menos código**: No necesita wrapper de SingleChildScrollView
- **Best practice**: Recomendado por Flutter para listas scrollables

**Cuando usar SingleChildScrollView:**
- Contenido que no es una lista (ej: un formulario complejo)
- Cuando necesitas `physics` personalizadas

---

### 6.4. Paleta de colores personalizada

```dart
final palette = appPaletteOf(context);

// Uso
Icon(Icons.eco, color: palette.success)      // Verde
Icon(Icons.flash_on, color: palette.warning) // Naranja
```

**¿Qué es appPaletteOf?**
```dart
// En app/theme/app_palette.dart
class AppPalette {
  final Color success;
  final Color warning;
  final Color info;
  // ...
}

AppPalette appPaletteOf(BuildContext context) {
  // Devuelve paleta según tema actual (claro/oscuro)
}
```

**¿Por qué no usar directamente Colors.green?**
- **Consistencia**: Todos los verdes son el mismo tono
- **Tema adaptativo**: Cambia automáticamente en dark mode
- **Semántica**: `palette.success` es más descriptivo que `Colors.green`

---

### 6.5. AssetImage vs NetworkImage

```dart
// HomePage usa AssetImage
const FeaturedBigCard(
  image: AssetImage('assets/images/home.jpg'),
  ...
)
```

**¿Por qué AssetImage en Home?**
- **Siempre disponible**: No depende de internet
- **Instantánea**: No hay loading time
- **Const**: Mejor performance
- **Control total**: La imagen nunca cambia

**Cuando usar NetworkImage:**
- Contenido dinámico del CMS
- Imágenes de productos/usuarios
- Imágenes que cambian frecuentemente

---

## Resumen ejecutivo

### Flujo completo del módulo Home

```
1. Usuario abre la app
   └── Router muestra AppShell con HomePage como child

2. HomePage se construye (StatelessWidget)
   └── ListView renderiza widgets en orden

3. Componentes renderizados:
   ├── HomeHeroHeader
   │   ├── Gradiente adaptativo al tema
   │   ├── Título dos colores (RichText)
   │   ├── Subtítulo justificado
   │   └── Badges [Cero Desperdicios, Menús Veganos]
   │
   ├── Card de características
   │   ├── Icono Eco (verde)
   │   ├── Divider vertical
   │   └── Icono Flash (naranja)
   │
   ├── FeaturedBigCard
   │   ├── Imagen de assets (home.jpg)
   │   ├── Gradiente overlay
   │   ├── Badge "100% Sostenible"
   │   └── Título sobre imagen
   │
   └── LoyaltyGradientBanner
       ├── Gradiente cálido (amber/orange)
       ├── Icono regalo
       ├── Título/subtítulo
       └── Badge "NUEVO!"

4. Usuario puede hacer scroll si el contenido no cabe
```

### Componentes clave

| Componente | Tipo | Propósito | Reusable |
|------------|------|-----------|----------|
| **HomePage** | StatelessWidget | Página principal | ❌ No (específica de Home) |
| **HomeHeroHeader** | StatelessWidget | Hero destacado | ✅ Sí (con propiedades) |
| **FeaturedBigCard** | StatelessWidget | Card con imagen | ✅ Sí (shop, admin) |
| **LoyaltyGradientBanner** | StatelessWidget | Banner promocional | ✅ Sí (cualquier promo) |
| **AppBadge** | StatelessWidget | Badge reutilizable | ✅ Sí (toda la app) |

### Características técnicas

✅ **Sin estado**: StatelessWidget (contenido estático)  
✅ **Sin providers**: No accede a backend  
✅ **Modular**: Widgets separados y reutilizables  
✅ **Responsive**: Se adapta a diferentes tamaños  
✅ **Tema adaptativo**: Funciona en claro y oscuro  
✅ **Performance optimizada**: Uso extensivo de const  
✅ **Accesible**: Textos descriptivos y contrastes adecuados  

### Patrones aplicados

1. **Composition over inheritance**: Widgets componibles
2. **Single Responsibility**: Cada widget una responsabilidad
3. **DRY (Don't Repeat Yourself)**: AppBadge reutilizable
4. **Progressive Enhancement**: Loading states en NetworkImage
5. **Adaptive Design**: Gradientes diferentes en dark mode