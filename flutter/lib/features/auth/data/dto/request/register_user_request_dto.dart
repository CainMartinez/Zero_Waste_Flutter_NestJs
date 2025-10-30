import 'dart:convert';

/// DTO de entrada para POST /auth/register
class RegisterUserRequestDto {
  final String email;
  final String name;
  final String password;

  const RegisterUserRequestDto._({
    required this.email,
    required this.name,
    required this.password
  });

  factory RegisterUserRequestDto.create({
    required String email,
    required String name,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();

    return RegisterUserRequestDto._(
      email: normalizedEmail,
      name: normalizedName,
      password: password,
    );
  }

  /// Validaciones
  Map<String, String>? validate() {
    final errors = <String, String>{};

    // Email
    if (!_isValidEmail(email)) {
      errors['email'] = 'El email debe tener este formato xxx@xxx.com';
    }

    // Nombre
    if (name.isEmpty) {
      errors['name'] = 'El nombre debe ser texto';
    } else if (name.length < 2) {
      errors['name'] = 'El nombre debe tener mínimo 2 caracteres';
    } else if (name.length > 30) {
      errors['name'] = 'El nombre debe tener máximo 30 caracteres';
    }

    // Password
    if (password.isEmpty) {
      errors['password'] = 'La contraseña debe ser texto';
    } else if (password.length < 8) {
      errors['password'] = 'La contraseña debe tener mínimo 8 caracteres';
    } else if (password.length > 30) {
      errors['password'] = 'La contraseña debe tener máximo 30 caracteres';
    } else if (!_meetsPasswordPolicy(password)) {
      errors['password'] =
          'La contraseña debe incluir mayúscula, minúscula y número';
    }
    return errors.isEmpty ? null : errors;
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'password': password,
      };

  String toJsonString() => jsonEncode(toJson());

  static bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(value);
  }

  // Al menos 1 minúscula, 1 mayúscula y 1 número.
  static bool _meetsPasswordPolicy(String value) {
    final policy = RegExp(r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+');
    return policy.hasMatch(value);
  }
}