import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eco_bocado/core/l10n/app_localizations.dart';
import 'package:eco_bocado/features/admin/domain/entities/product_admin.dart';
import 'package:eco_bocado/features/admin/presentation/providers/product_admin_provider.dart';
import 'form_sections/product_basic_info_form.dart';
import 'form_sections/product_category_selector.dart';
import 'form_sections/product_image_section.dart';
import 'form_sections/product_allergen_section.dart';

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
  final List<XFile> _newImages = []; // Imágenes nuevas a subir
  List<ProductImage> _existingImages = []; // Imágenes ya existentes en el servidor
  final List<int> _imagesToDelete = []; // IDs de imágenes marcadas para eliminar
  bool _uploadingImages = false;
  
  // Alérgenos seleccionados: Map<code, {contains, mayContain}>
  final Map<String, Map<String, bool>> _selectedAllergens = {};

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
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorSelectingImages}: $e')),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mustSelectCategory),
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
                content: Text('${AppLocalizations.of(context)!.errorDeletingImage}: $e'),
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
                content: Text('${AppLocalizations.of(context)!.errorUploadingImage}: $e'),
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
              content: Text('${AppLocalizations.of(context)!.errorUpdatingAllergens}: $e'),
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
      final l10n = AppLocalizations.of(context)!;
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? l10n.productCreatedSuccessfully
                : l10n.productUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(productAdminProvider).errorMessage ?? l10n.unknownError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.product == null ? l10n.createProduct : l10n.editProduct),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información básica
                ProductBasicInfoForm(
                  nameEsCtrl: _nameEsCtrl,
                  nameEnCtrl: _nameEnCtrl,
                  descEsCtrl: _descEsCtrl,
                  descEnCtrl: _descEnCtrl,
                  priceCtrl: _priceCtrl,
                  isVegan: _isVegan,
                  onVeganChanged: (value) => setState(() => _isVegan = value),
                ),
                const SizedBox(height: 16),

                // Selector de categoría
                ProductCategorySelector(
                  selectedCategoryId: _categoryId,
                  onCategoryChanged: (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: 16),

                // Sección de imágenes
                ProductImageSection(
                  existingImages: _existingImages,
                  newImages: _newImages,
                  imagesToDelete: _imagesToDelete,
                  onPickImages: _pickImages,
                  onRemoveNewImage: (index) {
                    setState(() => _removeNewImage(index));
                  },
                  onToggleDeleteExisting: (imageId) {
                    setState(() {
                      if (_imagesToDelete.contains(imageId)) {
                        _imagesToDelete.remove(imageId);
                      } else {
                        _imagesToDelete.add(imageId);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Sección de alérgenos
                ProductAllergenSection(
                  selectedAllergens: _selectedAllergens,
                  onAllergenChanged: (code, value) {
                    setState(() {
                      if (value == null) {
                        _selectedAllergens.remove(code);
                      } else {
                        _selectedAllergens[code] = value;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: (_isLoading || _uploadingImages) ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: (_isLoading || _uploadingImages) ? null : _submit,
          child: (_isLoading || _uploadingImages)
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.product == null ? l10n.create : l10n.update),
        ),
      ],
    );
  }
}
