import 'dart:convert';

/// DTO de entrada para POST /auth/admin/login
class AdminLoginRequestDto {
  final String email;
  final String password;

  const AdminLoginRequestDto._({
    required this.email,
    required this.password,
  });

  /// Crea el DTO normalizando los campos igual que el backend.
  factory AdminLoginRequestDto.create({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password;
    return AdminLoginRequestDto._(
      email: normalizedEmail,
      password: normalizedPassword,
    );
  }

  /// Valida los campos
  /// - Email: formato válido
  /// - Password: longitud entre 8 y 30 caracteres
  Map<String, String>? validate() {
    final errors = <String, String>{};

    if (!_isValidEmail(email)) {
      errors['email'] = 'El email debe tener este formato xxx@xxx.com';
    }

    if (password.isEmpty) {
      errors['password'] = 'La contraseña debe ser texto';
    } else if (password.length < 8) {
      errors['password'] = 'La contraseña debe tener mínimo 8 caracteres';
    } else if (password.length > 30) {
      errors['password'] = 'La contraseña debe tener máximo 30 caracteres';
    }

    return errors.isEmpty ? null : errors;
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  String toJsonString() => jsonEncode(toJson());

  static bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(value);
  }
}