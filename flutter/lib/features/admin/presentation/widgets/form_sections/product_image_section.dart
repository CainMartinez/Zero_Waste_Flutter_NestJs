import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:pub_diferent/features/admin/domain/entities/product_admin.dart';
import 'package:pub_diferent/core/config/env.dart';

class ProductImageSection extends StatelessWidget {
  final List<ProductImage> existingImages;
  final List<XFile> newImages;
  final List<int> imagesToDelete;
  final VoidCallback onPickImages;
  final Function(int) onRemoveNewImage;
  final Function(int) onToggleDeleteExisting;

  const ProductImageSection({
    super.key,
    required this.existingImages,
    required this.newImages,
    required this.imagesToDelete,
    required this.onPickImages,
    required this.onRemoveNewImage,
    required this.onToggleDeleteExisting,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = Env.minioBaseUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (existingImages.isNotEmpty) ...[
          const Text(
            'Imágenes actuales:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: existingImages.length,
              itemBuilder: (context, index) {
                final image = existingImages[index];
                final isMarkedForDeletion = imagesToDelete.contains(image.id);
                
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
                          onPressed: () => onToggleDeleteExisting(image.id),
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
        OutlinedButton.icon(
          onPressed: onPickImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: Text(newImages.isEmpty 
            ? 'Agregar imágenes' 
            : 'Agregar más imágenes (${newImages.length} seleccionadas)'),
        ),
        const SizedBox(height: 8),
        if (newImages.isNotEmpty) ...[
          const Text(
            'Imágenes nuevas a subir:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: newImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                          ? Image.network(
                              newImages[index].path,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(newImages[index].path),
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
                          onPressed: () => onRemoveNewImage(index),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
