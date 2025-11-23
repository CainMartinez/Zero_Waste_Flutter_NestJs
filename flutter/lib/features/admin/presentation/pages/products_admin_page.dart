import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/core/l10n/app_localizations.dart';
import 'package:pub_diferent/features/admin/presentation/providers/product_admin_provider.dart';
import 'package:pub_diferent/features/admin/presentation/widgets/product_admin_card.dart';
import 'package:pub_diferent/features/admin/presentation/widgets/product_form_dialog.dart';

class ProductsAdminPage extends ConsumerStatefulWidget {
  const ProductsAdminPage({super.key});

  @override
  ConsumerState<ProductsAdminPage> createState() => _ProductsAdminPageState();
}

class _ProductsAdminPageState extends ConsumerState<ProductsAdminPage> {
  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar
    Future.microtask(() {
      ref.read(productAdminProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productAdminProvider);
    final notifier = ref.read(productAdminProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadProducts(),
            tooltip: l10n.reload,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: cs.error),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorLoadingProducts,
                        style: tt.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage!,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                        onPressed: () => notifier.loadProducts(),
                      ),
                    ],
                  ),
                )
              : state.products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: cs.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noProducts,
                            style: tt.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.createFirstProduct,
                            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => notifier.loadProducts(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return ProductAdminCard(
                            product: product,
                            key: ValueKey(product.id),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => const ProductFormDialog(),
          );
          // Recargar productos después de cerrar el modal
          if (mounted) {
            ref.read(productAdminProvider.notifier).loadProducts();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newProduct),
      ),
    );
  }
}
