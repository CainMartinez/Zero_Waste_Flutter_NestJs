import 'package:flutter/material.dart';
import 'package:eco_bocado/core/l10n/app_localizations.dart';

/// Utilidad para traducir errores del backend usando análisis de mensajes
class ErrorTranslator {
  /// Traduce un mensaje de error del backend según el contenido del mensaje
  /// 
  /// El backend devuelve mensajes de error en español que analizamos
  /// y traducimos según el locale actual.
  static String translate(BuildContext context, String errorMessage) {
    final l10n = AppLocalizations.of(context)!;
    
    // Limpiar el mensaje de prefijos
    final cleanMessage = _cleanErrorMessage(errorMessage);
    
    // Buscar por palabras clave específicas del backend
    return _translateByKeywords(l10n, cleanMessage);
  }
  
  /// Limpia el mensaje de error eliminando prefijos comunes
  static String _cleanErrorMessage(String message) {
    return message
        .replaceFirst(RegExp(r'^Exception:\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^Error:\s*', caseSensitive: false), '')
        .trim();
  }
  
  /// Traduce basándose en palabras clave exactas del backend
  static String _translateByKeywords(AppLocalizations l10n, String message) {
    // Mensajes exactos del backend (ver backend-nest/src/auth/domain/exceptions/)
    
    // UserNotFoundException: "No existe un usuario con el email: {email}"
    if (message.contains('No existe un usuario con el email')) {
      return l10n.errorUserNotFound;
    }
    
    // InvalidPasswordException: "La contraseña introducida es incorrecta."
    if (message.contains('La contraseña introducida es incorrecta')) {
      return l10n.errorInvalidPassword;
    }
    
    // EmailAlreadyInUseException: "El correo electrónico \"{email}\" ya está registrado."
    if (message.contains('ya está registrado') || message.contains('ya existe')) {
      return l10n.errorEmailAlreadyInUse;
    }
    
    // WeakPasswordException: "La contraseña no cumple los requisitos mínimos de seguridad."
    if (message.contains('no cumple los requisitos') && message.contains('seguridad')) {
      return l10n.errorWeakPassword;
    }
    
    // Errores de autorización generales
    if (message.contains('Usuario no autenticado') || message.contains('no autenticado')) {
      return l10n.errorUnauthorized;
    }
    
    if (message.contains('Acceso denegado') || message.contains('permisos de administrador')) {
      return l10n.errorForbidden;
    }
    
    // Errores de token
    if (message.contains('Refresh token no proporcionado') || 
        message.contains('token de acceso') ||
        message.contains('Falta el token')) {
      return l10n.errorTokenNotProvided;
    }
    
    if (message.contains('caducado') && message.contains('token')) {
      return l10n.errorTokenExpired;
    }
    
    if (message.contains('Token inválido') || 
        message.contains('Token sin claims') ||
        message.contains('Token de acceso inválido')) {
      return l10n.errorInvalidToken;
    }
    
    // Errores de recursos
    if (message.contains('Usuario no encontrado') || message.contains('no se pudo determinar')) {
      return l10n.errorNotFound;
    }
    
    // Errores de red/conexión
    if (message.contains('Error de conexión') || 
        message.contains('network') ||
        message.contains('connection')) {
      return l10n.errorNetwork;
    }
    
    // Si no coincide con ningún patrón conocido, devolver el mensaje limpio
    // Esto permite que errores inesperados se muestren tal cual vienen del backend
    return message;
  }
}
