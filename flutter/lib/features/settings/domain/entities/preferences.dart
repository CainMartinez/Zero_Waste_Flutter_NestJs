import 'package:equatable/equatable.dart';

class Preferences extends Equatable {
  final bool? appNotifications;
  final bool? emailNotifications;
  final bool? whatsappNotifications;
  final bool? darkMode;
  final String? language;

  const Preferences({
    this.appNotifications,
    this.emailNotifications,
    this.whatsappNotifications,
    this.darkMode,
    this.language,
  });

  static const String appNotificationsConst = 'APP_NOTIFICATIONS';
  static const String emailNotificationsConst = 'EMAIL_NOTIFICATIONS';
  static const String whatsappNotificationsConst = 'WHATSAPP_NOTIFICATIONS';
  static const String darkModeConst = 'DARK_MODE';
  static const String languageConst = 'LANGUAGE';

  Preferences copyWith({
    bool? appNotifications,
    bool? emailNotifications,
    bool? whatsappNotifications,
    bool? darkMode,
    String? language,
  }) {
    return Preferences(
      appNotifications: appNotifications ?? this.appNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      whatsappNotifications: whatsappNotifications ?? this.whatsappNotifications,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        appNotifications,
        emailNotifications,
        whatsappNotifications,
        darkMode,
        language,
      ];
}
