import 'package:pub_diferent/core/config/env.dart';

/// URL base leída desde las variables de entorno
final baseUrl = Env.apiBaseUrl;

/// Claves para secure storage
const tokenKey = 'access_token';
const refreshKey = 'refresh_token';
const authRoleKey = 'auth_role'; // user o admin