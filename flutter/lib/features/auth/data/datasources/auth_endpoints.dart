import 'package:pub_diferent/core/config/env.dart';

class AuthEndpoints {
  static Uri get registerUser => Env.apiUri('/auth/register');
  static Uri get loginUser => Env.apiUri('/auth/login');
  static Uri get loginAdmin => Env.apiUri('/auth/admin/login');
  static Uri get logoutUser => Env.apiUri('/auth/logout');
  static Uri get logoutAdmin => Env.apiUri('/auth/admin/logout');
}