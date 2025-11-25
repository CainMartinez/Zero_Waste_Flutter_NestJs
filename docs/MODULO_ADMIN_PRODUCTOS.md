# 🛠️ Módulo Admin - Gestión de Productos

## 📋 Resumen

El **módulo Admin** permite la gestión completa del catálogo de productos con operaciones CRUD (Create, Read, Update, Deactivate), gestión de imágenes, alérgenos y categorías, todo con soporte **bilingüe** (español/inglés).

---

## 🎯 Funcionalidades Principales

### ✅ Operaciones Implementadas

| Operación | Endpoint | Descripción |
|-----------|----------|-------------|
| **Listar** | `GET /admin/products` | Obtener todos los productos (activos e inactivos) |
| **Crear** | `POST /admin/products` | Crear nuevo producto con datos bilingües |
| **Actualizar** | `PATCH /admin/products/:id` | Actualizar producto existente |
| **Desactivar** | `POST /admin/products/:id/deactivate` | Desactivar producto (soft delete) |
| **Reactivar** | `POST /admin/products/:id/reactivate` | Reactivar producto desactivado |
| **Subir imagen** | `POST /admin/products/:id/images` | Subir imagen del producto |
| **Eliminar imagen** | `DELETE /admin/products/:id/images/:imageId` | Eliminar imagen específica |

### 🌍 Características Especiales

- ✅ **Datos bilingües**: Nombre y descripción en español e inglés
- ✅ **Gestión de imágenes**: Upload, preview y eliminación
- ✅ **Alérgenos**: Selección múltiple con estado de contención
- ✅ **Categorías**: Selector con opción de "Sin categoría"
- ✅ **Validaciones**: Formulario completo con mensajes traducidos
- ✅ **Estados**: Activo/Inactivo con indicadores visuales
- ✅ **Soft delete**: Los productos se desactivan, no se eliminan

---

## 🏗️ Arquitectura

### Estructura de Carpetas

```
features/admin/
├── data/
│   ├── datasources/
│   │   └── product_admin_remote_datasource.dart    # API calls
│   ├── models/
│   │   └── product_admin_model.dart                # JSON serialization
│   └── repositories/
│       └── product_admin_repository_impl.dart      # Repository implementation
├── domain/
│   ├── entities/
│   │   ├── product_admin.dart                      # Entity con métodos bilingües
│   │   └── product_allergen.dart                   # Alérgeno entity
│   └── repositories/
│       └── product_admin_repository.dart           # Repository interface
└── presentation/
    ├── pages/
    │   └── products_admin_page.dart                # Página principal
    ├── providers/
    │   └── product_admin_provider.dart             # Riverpod state
    └── widgets/
        ├── product_admin_card.dart                 # Card de producto
        ├── product_form_dialog.dart                # Diálogo crear/editar
        └── form_sections/
            ├── product_basic_info_form.dart        # Datos básicos
            ├── product_category_selector.dart      # Selector categoría
            ├── product_allergen_section.dart       # Selector alérgenos
            └── product_image_section.dart          # Gestión imágenes
```

---

## 📊 Modelo de Datos

### Entity: ProductAdmin

```dart
class ProductAdmin {
  final int id;
  final String nameEs;
  final String nameEn;
  final String descriptionEs;
  final String descriptionEn;
  final double price;
  final bool isVegan;
  final bool isActive;
  final int? categoryId;
  final ProductCategory? category;
  final List<ProductAllergen> allergens;
  final List<String> images;

  // Métodos de traducción
  String name(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? nameEn : nameEs;
  }

  String description(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? descriptionEn : descriptionEs;
  }

  String categoryName(BuildContext context) {
    if (category == null) return '';
    return category!.name(context);
  }
}
```

### Entity: ProductAllergen

```dart
class ProductAllergen {
  final int id;
  final String nameEs;
  final String nameEn;
  final AllergenContainmentStatus containmentStatus;

  String name(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? nameEn : nameEs;
  }
}

enum AllergenContainmentStatus {
  contains,    // Contiene el alérgeno
  mayContain,  // Puede contener el alérgeno
}
```

### Respuesta del Backend (GET /admin/products)

```json
{
  "id": 1,
  "nameEs": "Hamburguesa Vegana",
  "nameEn": "Vegan Burger",
  "descriptionEs": "Hamburguesa 100% vegetal con aguacate y tomate",
  "descriptionEn": "100% plant-based burger with avocado and tomato",
  "price": 8.50,
  "isVegan": true,
  "isActive": true,
  "categoryId": 2,
  "category": {
    "id": 2,
    "nameEs": "Hamburguesas",
    "nameEn": "Burgers"
  },
  "allergens": [
    {
      "id": 3,
      "nameEs": "Gluten",
      "nameEn": "Gluten",
      "containmentStatus": "contains"
    },
    {
      "id": 7,
      "nameEs": "Soja",
      "nameEn": "Soy",
      "containmentStatus": "mayContain"
    }
  ],
  "images": [
    "https://api.example.com/images/burger-vegan-1.jpg",
    "https://api.example.com/images/burger-vegan-2.jpg"
  ]
}
```

---

## 🎨 UI/UX - Página Principal

### ProductsAdminPage

```dart
class ProductsAdminPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final productsAsync = ref.watch(productAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.reload,
            onPressed: () => ref.refresh(productAdminProvider),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductAdminCard(product: products[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorStateWidget(
          error: error,
          onRetry: () => ref.refresh(productAdminProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductFormDialog(context, null),
        icon: const Icon(Icons.add),
        label: Text(l10n.newProduct),
      ),
    );
  }
}
```

### Características de la Página

- **AppBar**: Título traducido + botón de recargar
- **Estados**:
  - `loading`: CircularProgressIndicator
  - `data`: Lista de productos (activos e inactivos)
  - `error`: Mensaje de error con botón "Reintentar"
- **FAB**: Botón flotante para crear nuevo producto
- **Cards**: Cada producto con acciones rápidas (editar, activar/desactivar)

---

## 🃏 ProductAdminCard

### Diseño

```dart
class ProductAdminCard extends ConsumerWidget {
  final ProductAdmin product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Imagen principal
          if (product.images.isNotEmpty)
            Image.network(
              product.images.first,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + Badges
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name(context),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (product.isVegan)
                      Chip(
                        label: Text(l10n.vegan),
                        backgroundColor: Colors.green[100],
                      ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        product.isActive ? l10n.active : l10n.inactive,
                      ),
                      backgroundColor: product.isActive 
                          ? Colors.blue[100] 
                          : Colors.grey[300],
                    ),
                  ],
                ),
                
                // Descripción
                Text(
                  product.description(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Categoría
                Text(
                  product.categoryName(context).isEmpty 
                      ? l10n.noCategory 
                      : product.categoryName(context),
                ),
                
                // Precio
                Text(
                  '${product.price.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Editar
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showProductFormDialog(context, product),
                    ),
                    
                    // Activar/Desactivar
                    if (product.isActive)
                      IconButton(
                        icon: const Icon(Icons.block),
                        onPressed: () => _confirmDeactivate(context, product),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.check_circle),
                        onPressed: () => _reactivateProduct(context, product),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Elementos Visuales

- **Imagen**: Primera imagen del array (si existe)
- **Título**: `product.name(context)` - Traducido según locale
- **Badges**:
  - `Vegano` (verde) - Si `isVegan == true`
  - `Activo/Inactivo` (azul/gris) - Estado del producto
- **Descripción**: Máximo 2 líneas con ellipsis
- **Categoría**: `product.categoryName(context)` o "Sin categoría"
- **Precio**: Formato `X.XX €`
- **Acciones**:
  - ✏️ Editar → Abre diálogo de edición
  - 🚫 Desactivar / ✅ Reactivar → Según estado actual

---

## 📝 Formulario de Producto

### ProductFormDialog

Diálogo completo con 4 secciones:

#### 1. Información Básica (ProductBasicInfoForm)

```dart
// Campos requeridos
AppTextField(
  controller: _nameEsController,
  label: l10n.nameEs,                    // "Nombre (ES) *"
  validator: (v) => Validators.required(context, v),
)

AppTextField(
  controller: _nameEnController,
  label: l10n.nameEn,                    // "Nombre (EN) *"
  validator: (v) => Validators.required(context, v),
)

AppTextField(
  controller: _descriptionEsController,
  label: l10n.descriptionEs,             // "Descripción (ES) *"
  maxLines: 3,
  validator: (v) => Validators.required(context, v),
)

AppTextField(
  controller: _descriptionEnController,
  label: l10n.descriptionEn,             // "Descripción (EN) *"
  maxLines: 3,
  validator: (v) => Validators.required(context, v),
)

AppTextField(
  controller: _priceController,
  label: l10n.price,                     // "Precio *"
  keyboardType: TextInputType.number,
  validator: (v) => _validatePrice(context, v),
)

// Checkbox Vegano
CheckboxListTile(
  title: Text(l10n.isVegan),             // "Es vegano"
  value: _isVegan,
  onChanged: (value) => setState(() => _isVegan = value ?? false),
)
```

**Validaciones**:
- Nombre (ES/EN): Obligatorio
- Descripción (ES/EN): Obligatorio
- Precio: Obligatorio, número >= 0

#### 2. Selector de Categoría (ProductCategorySelector)

```dart
DropdownButtonFormField<int?>(
  value: _selectedCategoryId,
  decoration: InputDecoration(
    labelText: l10n.category,            // "Categoría *"
  ),
  items: [
    DropdownMenuItem<int?>(
      value: null,
      child: Text(l10n.noCategory),      // "Sin categoría"
    ),
    ...categories.map((category) => DropdownMenuItem(
      value: category.id,
      child: Text(category.name(context)),
    )),
  ],
  validator: (value) {
    if (value == null) {
      return l10n.mustSelectCategory;    // "Debes seleccionar una categoría"
    }
    return null;
  },
  onChanged: (value) => setState(() => _selectedCategoryId = value),
)
```

**Comportamiento**:
- Dropdown con todas las categorías disponibles
- Opción "Sin categoría" (value = null)
- Validación: Categoría es obligatoria

#### 3. Sección de Alérgenos (ProductAllergenSection)

```dart
Column(
  children: [
    Text(
      l10n.allergensOptional,            // "Alérgenos (opcional)"
      style: Theme.of(context).textTheme.titleMedium,
    ),
    Text(l10n.selectAllergens),          // "Selecciona los alérgenos..."
    
    ...allergens.map((allergen) {
      final isSelected = _selectedAllergens.contains(allergen.id);
      
      return CheckboxListTile(
        title: Text(allergen.name(context)),
        value: isSelected,
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              _selectedAllergens.add(allergen.id);
            } else {
              _selectedAllergens.remove(allergen.id);
            }
          });
        },
        secondary: isSelected
            ? DropdownButton<AllergenContainmentStatus>(
                value: _allergenStatus[allergen.id] ?? AllergenContainmentStatus.contains,
                items: [
                  DropdownMenuItem(
                    value: AllergenContainmentStatus.contains,
                    child: Text(l10n.contains),      // "Contiene"
                  ),
                  DropdownMenuItem(
                    value: AllergenContainmentStatus.mayContain,
                    child: Text(l10n.mayContain),    // "Puede contener"
                  ),
                ],
                onChanged: (status) {
                  setState(() {
                    _allergenStatus[allergen.id] = status!;
                  });
                },
              )
            : null,
      );
    }),
  ],
)
```

**Comportamiento**:
- Lista de checkboxes con todos los alérgenos
- Al seleccionar un alérgeno → Aparece dropdown para elegir:
  - **"Contiene"** (`contains`)
  - **"Puede contener"** (`mayContain`)
- Estado guardado en `Map<int, AllergenContainmentStatus>`

#### 4. Sección de Imágenes (ProductImageSection)

```dart
Column(
  children: [
    Text(
      l10n.imagesOptional,               // "Imágenes (opcional)"
      style: Theme.of(context).textTheme.titleMedium,
    ),
    
    // Imágenes existentes (solo en edición)
    if (widget.product != null && widget.product!.images.isNotEmpty) ...[
      Text(l10n.existingImages),         // "Imágenes existentes:"
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.product!.images.map((imageUrl) {
          return Stack(
            children: [
              Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteExistingImage(imageUrl),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ],
    
    // Botón para añadir imágenes
    ElevatedButton.icon(
      onPressed: _pickImages,
      icon: const Icon(Icons.add_photo_alternate),
      label: Text(l10n.addImages),       // "Añadir imágenes"
    ),
    
    // Preview de imágenes nuevas
    if (_selectedImages.isNotEmpty) ...[
      Text(l10n.selectedImagesWillBeUploaded),  // "Imágenes seleccionadas..."
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selectedImages.map((file) {
          return Stack(
            children: [
              Image.file(File(file.path), width: 100, height: 100, fit: BoxFit.cover),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() => _selectedImages.remove(file)),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ],
  ],
)
```

**Funcionalidades**:
- **Ver imágenes existentes**: Miniatura con botón eliminar (X)
- **Añadir nuevas imágenes**: Botón que abre `ImagePicker`
- **Preview de nuevas**: Muestra imágenes antes de subir
- **Eliminar imágenes**:
  - Existentes → Llamada a API: `DELETE /admin/products/:id/images/:imageId`
  - Nuevas → Quitar del array local

---

## 🔄 Flujos de Operación

### 1. Crear Producto

```
Usuario presiona FAB "Nuevo Producto"
  ↓
Se abre ProductFormDialog (modo: crear)
  ↓
Usuario completa formulario:
  - Nombre ES/EN
  - Descripción ES/EN
  - Precio
  - Categoría
  - ¿Es vegano?
  - Alérgenos (opcional)
  - Imágenes (opcional)
  ↓
Usuario presiona "Crear"
  ↓
Validación del formulario
  ↓
Si hay imágenes seleccionadas:
  - POST /admin/products (crear producto)
  - Respuesta: { id: X, ... }
  - Para cada imagen:
    - POST /admin/products/X/images (subir imagen)
  ↓
Si NO hay imágenes:
  - POST /admin/products (crear producto)
  ↓
SnackBar: "Producto creado correctamente"
  ↓
Refresh productAdminProvider
  ↓
Cerrar diálogo
```

**Request Body (POST /admin/products)**:
```json
{
  "nameEs": "Hamburguesa Vegana",
  "nameEn": "Vegan Burger",
  "descriptionEs": "Hamburguesa 100% vegetal...",
  "descriptionEn": "100% plant-based burger...",
  "price": 8.50,
  "isVegan": true,
  "categoryId": 2,
  "allergens": [
    {
      "allergenId": 3,
      "containmentStatus": "contains"
    },
    {
      "allergenId": 7,
      "containmentStatus": "mayContain"
    }
  ]
}
```

### 2. Editar Producto

```
Usuario presiona botón "Editar" en ProductAdminCard
  ↓
Se abre ProductFormDialog (modo: editar)
  - Pre-llena campos con datos del producto
  - Muestra imágenes existentes
  ↓
Usuario modifica campos
  ↓
Usuario presiona "Actualizar"
  ↓
Validación del formulario
  ↓
PATCH /admin/products/:id (actualizar datos)
  ↓
Si hay imágenes nuevas:
  - Para cada imagen:
    - POST /admin/products/:id/images
  ↓
SnackBar: "Producto actualizado correctamente"
  ↓
Refresh productAdminProvider
  ↓
Cerrar diálogo
```

**Request Body (PATCH /admin/products/:id)**:
```json
{
  "nameEs": "Hamburguesa Vegana Premium",
  "nameEn": "Premium Vegan Burger",
  "price": 9.50
  // Solo los campos modificados
}
```

### 3. Desactivar Producto

```
Usuario presiona botón "Desactivar" (🚫)
  ↓
Diálogo de confirmación:
  Título: "Confirmar desactivación"
  Mensaje: "¿Estás seguro de que deseas desactivar el producto 'X'?"
  Botones: [Cancelar, Desactivar]
  ↓
Usuario confirma
  ↓
POST /admin/products/:id/deactivate
  ↓
SnackBar: "Producto desactivado"
  ↓
Refresh productAdminProvider
  ↓
El producto ahora muestra badge "Inactivo" (gris)
```

### 4. Reactivar Producto

```
Usuario presiona botón "Reactivar" (✅)
  ↓
POST /admin/products/:id/reactivate
  ↓
SnackBar: "Producto reactivado"
  ↓
Refresh productAdminProvider
  ↓
El producto ahora muestra badge "Activo" (azul)
```

### 5. Eliminar Imagen

```
Usuario presiona "X" en imagen existente
  ↓
Confirmación implícita (o diálogo según UX)
  ↓
DELETE /admin/products/:id/images/:imageId
  ↓
Si éxito:
  - Quitar imagen del estado local
  - SnackBar: "Imagen eliminada"
  ↓
Si error:
  - SnackBar: "Error al eliminar imagen"
```

---

## 🔐 Seguridad y Permisos

### Guards del Backend

```typescript
// backend-nest/src/auth/presentation/guards/admin.guard.ts
@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('Usuario no autenticado');
    }

    if (!user.isAdmin) {
      throw new ForbiddenException('Acceso denegado: se requieren permisos de administrador');
    }

    return true;
  }
}
```

### Aplicación del Guard

```typescript
// backend-nest/src/admin/presentation/controllers/products-admin.controller.ts
@Controller('admin/products')
@UseGuards(JwtAuthGuard, AdminGuard)  // Requiere JWT + ser Admin
export class ProductsAdminController {
  @Get()
  async getAll() { /* ... */ }

  @Post()
  async create(@Body() dto: CreateProductDto) { /* ... */ }

  @Patch(':id')
  async update(@Param('id') id: number, @Body() dto: UpdateProductDto) { /* ... */ }
  
  // ...
}
```

### Validación en Flutter

```dart
// app_shell.dart - Solo admins pueden acceder
final isAdmin = authState.value?.isAdmin ?? false;

if (isAdmin) {
  destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard), label: l10n.dashboard),
    NavigationDestination(icon: Icon(Icons.inventory), label: l10n.products),
    NavigationDestination(icon: Icon(Icons.receipt), label: l10n.billing),
    NavigationDestination(icon: Icon(Icons.person), label: l10n.profile),
  ];
} else {
  // Vista de usuario normal (sin acceso a admin)
}
```

---

## 🌐 Internacionalización

### Traducciones Implementadas (44 claves)

| Key | Español | Inglés |
|-----|---------|--------|
| `productManagement` | Gestión de Productos | Product Management |
| `newProduct` | Nuevo Producto | New Product |
| `createProduct` | Crear Producto | Create Product |
| `editProduct` | Editar Producto | Edit Product |
| `nameEs` | Nombre (ES) * | Name (ES) * |
| `nameEn` | Nombre (EN) * | Name (EN) * |
| `descriptionEs` | Descripción (ES) * | Description (ES) * |
| `descriptionEn` | Descripción (EN) * | Description (EN) * |
| `price` | Precio * | Price * |
| `isVegan` | Es vegano | Is vegan |
| `category` | Categoría * | Category * |
| `mustSelectCategory` | Debes seleccionar una categoría | You must select a category |
| `allergensOptional` | Alérgenos (opcional) | Allergens (optional) |
| `selectAllergens` | Selecciona los alérgenos que aplican... | Select the allergens that apply... |
| `contains` | Contiene | Contains |
| `mayContain` | Puede contener | May contain |
| `imagesOptional` | Imágenes (opcional) | Images (optional) |
| `existingImages` | Imágenes existentes: | Existing images: |
| `addImages` | Añadir imágenes | Add images |
| `selectedImagesWillBeUploaded` | Imágenes seleccionadas (se subirán al guardar): | Selected images (will be uploaded on save): |
| `create` | Crear | Create |
| `update` | Actualizar | Update |
| `productCreatedSuccessfully` | Producto creado correctamente | Product created successfully |
| `productUpdatedSuccessfully` | Producto actualizado correctamente | Product updated successfully |
| `confirmDeactivation` | Confirmar desactivación | Confirm deactivation |
| `confirmDeactivationMessage` | ¿Estás seguro de que deseas desactivar el producto '{productName}'? | Are you sure you want to deactivate the product '{productName}'? |
| `deactivate` | Desactivar | Deactivate |
| `productDeactivated` | Producto desactivado | Product deactivated |
| `reactivate` | Reactivar | Reactivate |
| `productReactivated` | Producto reactivado | Product reactivated |
| `vegan` | Vegano | Vegan |
| `active` | Activo | Active |
| `inactive` | Inactivo | Inactive |
| `noCategory` | Sin categoría | No category |
| `errorLoadingProducts` | Error al cargar productos | Error loading products |
| `errorSelectingImages` | Error al seleccionar imágenes | Error selecting images |
| `errorDeletingImage` | Error al eliminar imagen | Error deleting image |
| `errorUploadingImage` | Error al subir imagen | Error uploading image |
| `errorUpdatingAllergens` | Error al actualizar alérgenos | Error updating allergens |

### Uso en Código

```dart
// Títulos
Text(l10n.productManagement)
Text(l10n.createProduct)
Text(l10n.editProduct)

// Labels de formulario
AppTextField(label: l10n.nameEs)
AppTextField(label: l10n.descriptionEn)

// Mensajes de éxito
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(l10n.productCreatedSuccessfully)),
)

// Diálogos de confirmación
AlertDialog(
  title: Text(l10n.confirmDeactivation),
  content: Text(l10n.confirmDeactivationMessage(product.name(context))),
)
```

---

## 🧪 Testing

### Casos de Prueba Manuales

#### 1. Crear Producto Completo
- ✅ Llenar todos los campos obligatorios
- ✅ Seleccionar categoría
- ✅ Marcar como vegano
- ✅ Seleccionar 2 alérgenos (uno "contiene", otro "puede contener")
- ✅ Añadir 3 imágenes
- ✅ Crear producto
- **Esperado**: Producto creado, visible en lista con todos los datos

#### 2. Validaciones de Formulario
- ❌ Intentar crear sin nombre ES → Error: "Nombre (ES) es obligatorio"
- ❌ Intentar crear sin precio → Error: "Precio es obligatorio"
- ❌ Precio negativo → Error: "Debe ser un número válido >= 0"
- ❌ Sin categoría seleccionada → Error: "Debes seleccionar una categoría"
- **Esperado**: Validaciones funcionan, no permite crear con datos inválidos

#### 3. Editar Producto
- ✅ Abrir producto existente
- ✅ Modificar nombre EN
- ✅ Cambiar precio
- ✅ Añadir un nuevo alérgeno
- ✅ Eliminar una imagen existente
- ✅ Añadir una nueva imagen
- ✅ Actualizar
- **Esperado**: Cambios guardados, visibles en la card

#### 4. Desactivar Producto
- ✅ Presionar botón "Desactivar"
- ✅ Confirmar en diálogo
- **Esperado**: 
  - Badge cambia de "Activo" (azul) a "Inactivo" (gris)
  - Botón cambia de 🚫 a ✅
  - SnackBar: "Producto desactivado"

#### 5. Reactivar Producto
- ✅ Presionar botón "Reactivar" en producto inactivo
- **Esperado**:
  - Badge cambia de "Inactivo" (gris) a "Activo" (azul)
  - Botón cambia de ✅ a 🚫
  - SnackBar: "Producto reactivado"

#### 6. Cambio de Idioma
- ✅ Ir a Settings → Cambiar idioma a Inglés
- ✅ Volver a Admin → Ver productos
- **Esperado**:
  - Todos los textos de UI en inglés
  - Nombres de productos en inglés (nameEn)
  - Categorías en inglés
  - Alérgenos en inglés

#### 7. Gestión de Imágenes
- ✅ Crear producto con 3 imágenes
- ✅ Editar producto
- ✅ Eliminar 1 imagen existente
- ✅ Añadir 2 imágenes nuevas
- ✅ Guardar
- **Esperado**: Producto tiene 4 imágenes (2 originales + 2 nuevas)

### Tests Automatizados (Propuesta)

```dart
// test/features/admin/presentation/widgets/product_admin_card_test.dart
testWidgets('ProductAdminCard shows product data correctly', (tester) async {
  final product = ProductAdmin(
    id: 1,
    nameEs: 'Test ES',
    nameEn: 'Test EN',
    descriptionEs: 'Desc ES',
    descriptionEn: 'Desc EN',
    price: 10.50,
    isVegan: true,
    isActive: true,
    // ...
  );

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: ProductAdminCard(product: product)),
    ),
  );

  expect(find.text('Test ES'), findsOneWidget);
  expect(find.text('10.50 €'), findsOneWidget);
  expect(find.text('Vegano'), findsOneWidget);
  expect(find.text('Activo'), findsOneWidget);
});
```

---

## 🚀 Mejores Prácticas Implementadas

### 1. **Clean Architecture**
- ✅ Separación clara: Data / Domain / Presentation
- ✅ Repository pattern para abstraer fuente de datos
- ✅ Entities puras sin dependencias de framework

### 2. **Estado con Riverpod**
```dart
final productAdminProvider = FutureProvider<List<ProductAdmin>>((ref) async {
  final repository = ref.read(productAdminRepositoryProvider);
  return await repository.getAll();
});
```
- ✅ State management reactivo
- ✅ Auto-refresh al mutar datos
- ✅ Loading/error states automáticos

### 3. **Validaciones Centralizadas**
```dart
// lib/core/utils/validators.dart
class Validators {
  static String? required(BuildContext context, String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return fieldName != null 
          ? l10n.fieldRequired(fieldName)
          : l10n.required;
    }
    return null;
  }
}
```
- ✅ Validadores reutilizables
- ✅ Mensajes traducidos
- ✅ Consistencia en toda la app

### 4. **Manejo de Errores**
```dart
try {
  await repository.create(product);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.productCreatedSuccessfully)),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${l10n.errorCreatingProduct}: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```
- ✅ Try-catch en operaciones críticas
- ✅ Feedback visual al usuario
- ✅ Logging de errores

### 5. **Optimización de Imágenes**
```dart
// image_picker con compresión
final picker = ImagePicker();
final images = await picker.pickMultiImage(
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);
```
- ✅ Compresión automática
- ✅ Límite de resolución
- ✅ Reducción de tamaño de payload

---

## 📊 Endpoints del Backend

### Resumen de API

| Método | Endpoint | Descripción | Body | Response |
|--------|----------|-------------|------|----------|
| `GET` | `/admin/products` | Listar todos los productos | - | `ProductAdmin[]` |
| `GET` | `/admin/products/:id` | Obtener producto por ID | - | `ProductAdmin` |
| `POST` | `/admin/products` | Crear nuevo producto | `CreateProductDto` | `ProductAdmin` |
| `PATCH` | `/admin/products/:id` | Actualizar producto | `UpdateProductDto` | `ProductAdmin` |
| `POST` | `/admin/products/:id/deactivate` | Desactivar producto | - | `{ message: string }` |
| `POST` | `/admin/products/:id/reactivate` | Reactivar producto | - | `{ message: string }` |
| `POST` | `/admin/products/:id/images` | Subir imagen | `multipart/form-data` | `{ imageUrl: string }` |
| `DELETE` | `/admin/products/:id/images/:imageId` | Eliminar imagen | - | `{ message: string }` |

### DTOs

#### CreateProductDto
```typescript
{
  nameEs: string;           // Obligatorio
  nameEn: string;           // Obligatorio
  descriptionEs: string;    // Obligatorio
  descriptionEn: string;    // Obligatorio
  price: number;            // Obligatorio, >= 0
  isVegan: boolean;         // Opcional, default: false
  categoryId: number;       // Obligatorio
  allergens?: Array<{       // Opcional
    allergenId: number;
    containmentStatus: 'contains' | 'mayContain';
  }>;
}
```

#### UpdateProductDto
```typescript
{
  nameEs?: string;
  nameEn?: string;
  descriptionEs?: string;
  descriptionEn?: string;
  price?: number;
  isVegan?: boolean;
  categoryId?: number;
  allergens?: Array<{
    allergenId: number;
    containmentStatus: 'contains' | 'mayContain';
  }>;
}
```

---

## 🎯 Roadmap Futuro

### Mejoras Propuestas

#### 1. **Ordenamiento y Filtros**
```dart
// Añadir controles de ordenamiento
SortBy:
  - Nombre (A-Z / Z-A)
  - Precio (menor a mayor / mayor a menor)
  - Categoría
  - Estado (activo/inactivo)

// Filtros
FilterBy:
  - Categoría
  - Vegano/No vegano
  - Activo/Inactivo
  - Con/Sin imágenes
```

#### 2. **Búsqueda**
```dart
AppBar(
  title: TextField(
    decoration: InputDecoration(
      hintText: l10n.searchProducts,  // "Buscar productos..."
      prefixIcon: Icon(Icons.search),
    ),
    onChanged: (query) {
      // Filtrar productos por nombre/descripción
    },
  ),
)
```

#### 3. **Paginación**
```dart
// Implementar lazy loading
ListView.builder(
  controller: _scrollController,
  itemBuilder: (context, index) {
    if (index == products.length) {
      // Cargar más productos
      ref.read(productAdminProvider.notifier).loadMore();
      return CircularProgressIndicator();
    }
    return ProductAdminCard(product: products[index]);
  },
)
```

#### 4. **Duplicar Producto**
```dart
// Botón en ProductAdminCard
IconButton(
  icon: Icon(Icons.copy),
  tooltip: l10n.duplicateProduct,
  onPressed: () => _duplicateProduct(context, product),
)
```

#### 5. **Historial de Cambios**
```dart
// Ver audit log de modificaciones
GET /admin/products/:id/history
Response:
[
  {
    "timestamp": "2025-11-23T10:30:00Z",
    "user": "admin@example.com",
    "action": "UPDATE",
    "changes": {
      "price": { "before": 8.50, "after": 9.50 }
    }
  }
]
```

#### 6. **Exportación**
```dart
// Botón en AppBar
IconButton(
  icon: Icon(Icons.download),
  tooltip: l10n.exportProducts,
  onPressed: () {
    // Exportar a CSV/Excel/PDF
  },
)
```

---

## 📚 Recursos Adicionales

### Documentación Relacionada
- [LOCALIZACION_L10N.md](LOCALIZACION_L10N.md) - Sistema de internacionalización
- [MODULO_AUTH.md](MODULO_AUTH.md) - Autenticación y autorización
- [MODULO_SHOP.md](MODULO_SHOP.md) - Catálogo de productos (vista usuario)

### Librerías Utilizadas
- **Riverpod**: State management
- **Dio**: HTTP client
- **image_picker**: Selector de imágenes
- **flutter_localizations**: Internacionalización

### Convenciones de Código
- **Naming**: `snake_case` para archivos, `camelCase` para variables, `PascalCase` para clases
- **Imports**: Agrupados y ordenados (dart → flutter → packages → local)
- **Comentarios**: Solo en lógica compleja, código auto-documentado
- **Async**: Siempre usar `async/await`, nunca `.then()`