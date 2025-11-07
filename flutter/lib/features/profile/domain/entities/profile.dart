import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String ownerType; // 'user' | 'admin'
  final int ownerId;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? phone;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? postalCode; // String para ser flexible con el backend
  final String? countryCode;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Profile({
    required this.ownerType,
    required this.ownerId,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postalCode,
    this.countryCode,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    // Convertir postalCode a String sin importar si viene como int o String
    String? postalCode;
    if (json['postalCode'] != null) {
      postalCode = json['postalCode'].toString();
    }

    // Convertir isActive de int (1/0) a bool
    bool isActive = true;
    if (json['isActive'] != null) {
      if (json['isActive'] is bool) {
        isActive = json['isActive'] as bool;
      } else if (json['isActive'] is int) {
        isActive = json['isActive'] == 1;
      }
    }

    return Profile(
      ownerType: json['ownerType'] as String,
      ownerId: json['ownerId'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      postalCode: postalCode,
      countryCode: json['countryCode'] as String?,
      isActive: isActive,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Profile copyWith({
    String? ownerType,
    int? ownerId,
    String? email,
    String? name,
    String? avatarUrl,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? postalCode,
    String? countryCode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isUser => ownerType == 'user';
  bool get isAdmin => ownerType == 'admin';

  String get fullAddress {
    final parts = <String>[];
    if (addressLine1 != null && addressLine1!.isNotEmpty) parts.add(addressLine1!);
    if (addressLine2 != null && addressLine2!.isNotEmpty) parts.add(addressLine2!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        ownerType,
        ownerId,
        email,
        name,
        avatarUrl,
        phone,
        addressLine1,
        addressLine2,
        city,
        postalCode,
        countryCode,
        isActive,
        createdAt,
        updatedAt,
      ];
}
