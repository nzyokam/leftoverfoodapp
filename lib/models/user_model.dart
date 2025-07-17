class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String userType;
  final String? profileImageUrl;
  final String? organizationName;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.userType,
    this.profileImageUrl,
    this.organizationName,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '', // default fallback
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'],
      userType: json['user_type'] ?? 'user', // default user type
      profileImageUrl: json['profile_image_url'],
      organizationName: json['organization_name'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(), // fallback for safety
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'user_type': userType,
      'profile_image_url': profileImageUrl,
      'organization_name': organizationName,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'preferences': preferences,
    };
  }
}
