/// User Model

class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? phone;
  final String? address;
  final String? profileImage;
  final String? livingSpace;
  final bool hasYard;
  final bool hasChildren;
  final bool hasOtherPets;
  final String? activityLevel;
  final String? experienceWithPets;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.phone,
    this.address,
    this.profileImage,
    this.livingSpace,
    this.hasYard = false,
    this.hasChildren = false,
    this.hasOtherPets = false,
    this.activityLevel,
    this.experienceWithPets,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: json['role'] ?? 'user',
      phone: json['phone'],
      address: json['address'],
      profileImage: json['profile_image'],
      livingSpace: json['living_space'],
      hasYard: json['has_yard'] ?? false,
      hasChildren: json['has_children'] ?? false,
      hasOtherPets: json['has_other_pets'] ?? false,
      activityLevel: json['activity_level'],
      experienceWithPets: json['experience_with_pets'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
      'living_space': livingSpace,
      'has_yard': hasYard,
      'has_children': hasChildren,
      'has_other_pets': hasOtherPets,
      'activity_level': activityLevel,
      'experience_with_pets': experienceWithPets,
    };
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  
  bool get isAdmin => role == 'admin';
}
