import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pub_diferent/features/admin/domain/entities/product_admin.dart';
import 'package:pub_diferent/features/admin/presentation/providers/product_admin_provider.dart';
import 'package:pub_diferent/core/config/env.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final ProductAdmin? product; // null = crear, no null = editar

  const ProductFormDialog({super.key, this.product});

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  late final TextEditingController _nameEsCtrl;
  late final TextEditingController _nameEnCtrl;
  late final TextEditingController _descEsCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _priceCtrl;
  
  late bool _isVegan;
  late int? _categoryId;
  bool _isLoading = false;
  List<XFile> _newImages = []; // Imágenes nuevas a subir
  List<ProductImage> _existingImages = []; // Imágenes ya existentes en el servidor
  List<int> _imagesToDelete = []; // IDs de imágenes marcadas para eliminar
  bool _uploadingImages = false;
  
  // Alérgenos seleccionados: Map<code, {contains, mayContain}>
  Map<String, Map<String, bool>> _selectedAllergens = {};

  @override
  void initState() {
    super.initState();
    
    // Cargar categorías y alérgenos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productAdminProvider.notifier).loadCategories();
      ref.read(productAdminProvider.notifier).loadAllergens();
    });
    
    // Inicializar controladores
    _nameEsCtrl = TextEditingController(text: widget.product?.nameEs ?? '');
    _nameEnCtrl = TextEditingController(text: widget.product?.nameEn ?? '');
    _descEsCtrl = TextEditingController(text: widget.product?.descriptionEs ?? '');
    _descEnCtrl = TextEditingController(text: widget.product?.descriptionEn ?? '');
    _priceCtrl = TextEditingController(
      text: widget.product?.price.toStringAsFixed(2) ?? '',
    );
    
    _isVegan = widget.product?.isVegan ?? false;
    _categoryId = widget.product?.categoryId;
    
    // Cargar imágenes existentes si estamos editando
    if (widget.product != null) {
      _existingImages = List.from(widget.product!.images);
      
      // Cargar alérgenos existentes
      for (var allergen in widget.product!.allergens) {
        _selectedAllergens[allergen.code] = {
          'contains': allergen.contains,
          'mayContain': allergen.mayContain,
        };
      }
    }
  }

  @override
  void dispose() {
    _nameEsCtrl.dispose();
    _nameEnCtrl.dispose();
    _descEsCtrl.dispose();
    _descEnCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // Método para seleccionar imágenes nuevas
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      setState(() {
        _newImages.addAll(images);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imágenes: $e')),
        );
      }
    }
  }

  // Método para eliminar una imagen nueva (no subida aún)
  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  // Método para marcar una imagen existente para eliminación
  void _removeExistingImage(int index) {
    final image = _existingImages[index];
    setState(() {
      // Marcar para eliminar al actualizar
      if (!_imagesToDelete.contains(image.id)) {
        _imagesToDelete.add(image.id);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final notifier = ref.read(productAdminProvider.notifier);
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;

    bool success;
    int? productId;
    
    if (widget.product == null) {
      // Crear nuevo producto
      final result = await notifier.createProduct(
        nameEs: _nameEsCtrl.text.trim(),
        nameEn: _nameEnCtrl.text.trim(),
        descriptionEs: _descEsCtrl.text.trim(),
        descriptionEn: _descEnCtrl.text.trim(),
        price: price,
        isVegan: _isVegan,
        categoryId: _categoryId!,
      );
      success = result != null;
      productId = result?.id;
    } else {
      // Actualizar producto existente
      productId = widget.product!.id;
      success = await notifier.updateProduct(
        id: productId,
        nameEs: _nameEsCtrl.text.trim(),
        nameEn: _nameEnCtrl.text.trim(),
        descriptionEs: _descEsCtrl.text.trim(),
        descriptionEn: _descEnCtrl.text.trim(),
        price: price,
        isVegan: _isVegan,
        categoryId: _categoryId,
      );
    }

    // Eliminar imágenes marcadas para eliminación
    if (success && _imagesToDelete.isNotEmpty) {
      for (var imageId in _imagesToDelete) {
        try {
          await notifier.deleteProductImage(imageId);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al eliminar imagen: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    }

    // Subir imágenes nuevas si hay alguna seleccionada
    if (success && _newImages.isNotEmpty && productId != null) {
      setState(() => _uploadingImages = true);
      
      for (var image in _newImages) {
        try {
          // Pasar el XFile directamente para soportar web y mobile
          await notifier.uploadProductImage(productId, image);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al subir imagen: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
      
      setState(() => _uploadingImages = false);
    }

    // Actualizar alérgenos del producto
    if (success && productId != null) {
      final allergensList = _selectedAllergens.entries.map((entry) {
        return {
          'code': entry.key,
          'contains': entry.value['contains'] ?? true,
          'mayContain': entry.value['mayContain'] ?? false,
        };
      }).toList();

      try {
        await notifier.updateProductAllergens(productId, allergensList);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar alérgenos: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }

    // Recargar productos para actualizar la vista con las imágenes correctas
    if (success) {
      await notifier.loadProducts();
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Producto creado correctamente'
                : 'Producto actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(productAdminProvider).errorMessage ?? 'Error desconocido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productAdminProvider);
    final categories = state.categories;
    final isLoadingCategories = state.isLoadingCategories;
    final isEditing = widget.product != null;
    final baseUrl = Env.minioBaseUrl;

    return AlertDialog(
      title: Text(widget.product == null ? 'Crear Producto' : 'Editar Producto'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre ES
                TextFormField(
                  controller: _nameEsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre (ES) *',
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Nombre EN
                TextFormField(
                  controller: _nameEnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre (EN) *',
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Descripción ES
                TextFormField(
                  controller: _descEsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (ES) *',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Descripción EN
                TextFormField(
                  controller: _descEnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (EN) *',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requerido' : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Precio
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Precio *',
                    prefixIcon: Icon(Icons.euro),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    final val = double.tryParse(v);
                    if (val == null || val < 0) {
                      return 'Debe ser un número válido >= 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown de categorías
                isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoría *',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat['id'] as int,
                          child: Text(cat['nameEs'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _categoryId = value);
                      },
                      validator: (v) => v == null ? 'Selecciona una categoría' : null,
                    ),
                const SizedBox(height: 16),

                // Sección de imágenes existentes (solo al editar)
                if (isEditing && _existingImages.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Imágenes actuales:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _existingImages.length,
                      itemBuilder: (context, index) {
                        final image = _existingImages[index];
                        final isMarkedForDeletion = _imagesToDelete.contains(image.id);
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: isMarkedForDeletion ? 0.3 : 1.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '$baseUrl${image.path}',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (isMarkedForDeletion)
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.red.withOpacity(0.5),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: Icon(
                                    isMarkedForDeletion ? Icons.undo : Icons.close,
                                    color: Colors.white,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: isMarkedForDeletion ? Colors.orange : Colors.red,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(24, 24),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isMarkedForDeletion) {
                                        // Desmarcar para eliminación
                                        _imagesToDelete.remove(image.id);
                                      } else {
                                        // Marcar para eliminación
                                        _removeExistingImage(index);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botón para añadir nuevas imágenes
                OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(_newImages.isEmpty 
                    ? 'Agregar imágenes' 
                    : 'Agregar más imágenes (${_newImages.length} seleccionadas)'),
                ),
                const SizedBox(height: 8),

                // Preview de nuevas imágenes seleccionadas
                if (_newImages.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Imágenes nuevas a subir:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _newImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                  ? Image.network(
                                      _newImages[index].path,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_newImages[index].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black54,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(24, 24),
                                  ),
                                  onPressed: () => _removeNewImage(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Checkbox vegano
                CheckboxListTile(
                  value: _isVegan,
                  onChanged: (val) => setState(() => _isVegan = val ?? false),
                  title: const Text('Es vegano'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                // Sección de alérgenos
                const Text(
                  'Alérgenos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(productAdminProvider);
                    
                    if (state.isLoadingAllergens) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (state.allergens.isEmpty) {
                      return const Text('No hay alérgenos disponibles');
                    }
                    
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.allergens.map((allergen) {
                        final code = allergen['code'] as String;
                        final nameEs = allergen['nameEs'] as String;
                        final isSelected = _selectedAllergens.containsKey(code);
                        final contains = _selectedAllergens[code]?['contains'] ?? true;
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (!isSelected) {
                                // Primera selección: contiene
                                _selectedAllergens[code] = {
                                  'contains': true,
                                  'mayContain': false,
                                };
                              } else if (contains) {
                                // Segunda selección: puede contener trazas
                                _selectedAllergens[code] = {
                                  'contains': false,
                                  'mayContain': true,
                                };
                              } else {
                                // Tercera selección: deseleccionar
                                _selectedAllergens.remove(code);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (contains ? Colors.red.shade100 : Colors.orange.shade100)
                                  : Colors.grey.shade200,
                              border: Border.all(
                                color: isSelected
                                    ? (contains ? Colors.red.shade400 : Colors.orange.shade400)
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected
                                      ? (contains ? Icons.warning : Icons.info_outline)
                                      : Icons.circle_outlined,
                                  size: 18,
                                  color: isSelected
                                      ? (contains ? Colors.red.shade700 : Colors.orange.shade700)
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  nameEs,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? (contains ? Colors.red.shade900 : Colors.orange.shade900)
                                        : Colors.grey.shade800,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    contains ? '✓' : '~',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: contains ? Colors.red.shade700 : Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Toca una vez: contiene • Toca dos veces: puede contener trazas • Toca tres veces: quitar',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: (_isLoading || _uploadingImages) ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: (_isLoading || _uploadingImages) ? null : _submit,
          child: (_isLoading || _uploadingImages)
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.product == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }
}
