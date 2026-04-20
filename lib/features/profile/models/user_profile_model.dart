class UserProfileModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? address;
  final Map<String, dynamic>? preferences;

  UserProfileModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    this.address,
    this.preferences,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      address: map['address'],
      preferences: map['preferences'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'address': address,
      'preferences': preferences,
    };
  }

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? address,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      preferences: preferences ?? this.preferences,
    );
  }
}
