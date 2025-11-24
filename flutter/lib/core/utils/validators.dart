import 'package:flutter/material.dart';
import 'package:eco_bocado/core/l10n/app_localizations.dart';

class Validators {
  static String? required(BuildContext context, String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return fieldName != null 
          ? l10n.fieldRequired(fieldName)
          : l10n.required;
    }
    return null;
  }

  static String? email(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.emailRequired;
    }
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return l10n.invalidEmail;
    }
    return null;
  }

  static String? password(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    if (value.length < 8) {
      return l10n.passwordMinLength;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n.passwordUppercase;
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return l10n.passwordLowercase;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return l10n.passwordNumber;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return l10n.passwordSpecialChar;
    }
    return null;
  }

  static String? confirmPassword(BuildContext context, String? value, String? originalPassword) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.confirmPasswordRequired;
    }
    if (value != originalPassword) {
      return l10n.passwordsDoNotMatch;
    }
    return null;
  }

  static String? name(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.nameRequired;
    }
    if (value.trim().length < 2) {
      return l10n.nameTooShort;
    }
    return null;
  }
}