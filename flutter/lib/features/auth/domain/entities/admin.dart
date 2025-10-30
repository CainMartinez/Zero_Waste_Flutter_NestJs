class Admin {
  final int? id;
  final String? uuid;

  final String email;
  final String name;
  final String? avatarUrl;

  final bool? isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Admin({
    required this.id,
    required this.email,
    required this.name,
    this.uuid,
    this.avatarUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  Admin copyWith({
    int? id,
    String? uuid,
    String? email,
    String? name,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Admin(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      uuid: uuid ?? this.uuid,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Admin(id: $id, email: $email, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Admin &&
        other.id == id &&
        other.uuid == uuid &&
        other.email == email &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      (uuid?.hashCode ?? 0) ^
      email.hashCode ^
      name.hashCode ^
      (avatarUrl?.hashCode ?? 0) ^
      (isActive?.hashCode ?? 0) ^
      (createdAt?.hashCode ?? 0) ^
      (updatedAt?.hashCode ?? 0);
}