import 'package:flutter/material.dart';
import 'package:pub_diferent/core/widgets/app_button.dart';

/// Botón de submit reutilizable para formularios.
/// Gestiona estado de carga, expansión a ancho completo y adornos opcionales.
class AppFormSubmit extends StatelessWidget {
  const AppFormSubmit({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.variant = AppButtonVariant.primary,
    this.leading,
    this.trailing,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;
  final AppButtonVariant variant;
  final Widget? leading;
  final Widget? trailing;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    final buttonChild = _ButtonFacade(
      isLoading: isLoading,
      variant: variant,
      onPressed: onPressed,
      child: content,
    );

    final wrapped = Semantics(
      button: true,
      enabled: !isLoading && onPressed != null,
      label: semanticLabel ?? label,
      child: expand
          ? SizedBox(width: double.infinity, child: buttonChild)
          : buttonChild,
    );

    return wrapped;
  }

  Widget _buildContent(BuildContext context) {
    final text = Text(
      isLoading ? 'Procesando...' : label,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    final rowChildren = <Widget>[];

    if (leading != null) {
      rowChildren.add(Padding(
        padding: const EdgeInsets.only(right: 8),
        child: leading!,
      ));
    }

    if (isLoading) {
      rowChildren.add(const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ));
      rowChildren.add(const SizedBox(width: 8));
    }

    rowChildren.add(Flexible(child: text));

    if (trailing != null) {
      rowChildren.add(Padding(
        padding: const EdgeInsets.only(left: 8),
        child: trailing!,
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: rowChildren,
    );
  }
}

class _ButtonFacade extends StatelessWidget {
  const _ButtonFacade({
    required this.isLoading,
    required this.variant,
    required this.onPressed,
    required this.child,
  });

  final bool isLoading;
  final AppButtonVariant variant;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: isLoading ? null : onPressed,
      child: child,
    );
  }
}