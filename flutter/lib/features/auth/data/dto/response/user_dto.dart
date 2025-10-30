import 'dart:convert';

class UserDto {
  final int id;
  final String? uuid;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserDto({
    required this.id,
    required this.email,
    required this.name,
    this.uuid,
    this.avatarUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String?,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] is bool ? json['isActive'] as bool : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (uuid != null) 'uuid': uuid,
        'email': email,
        'name': name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (isActive != null) 'isActive': isActive,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  factory UserDto.fromJsonString(String source) =>
      UserDto.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());

  UserDto copyWith({
    int? id,
    String? uuid,
    String? email,
    String? name,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDto(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}