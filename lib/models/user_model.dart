class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final String? qualification;
  bool isApproved;
  bool isQuizPassed;
  String profileImageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.qualification,
    required this.isApproved,
    required this.isQuizPassed,
    required this.profileImageUrl,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType.name, // Store enum as String
      'qualification': qualification,
      'isApproved': isApproved,
      'isQuizPassed': isQuizPassed,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create UserModel from Map (from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.name == map['userType'],
        orElse: () => UserType.customer, // fallback
      ),
      qualification: map['qualification'],
      isApproved: map['isApproved'] ?? false,
      isQuizPassed: map['isQuizPassed'] ?? false,
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }
}

enum UserType { customer, designer, admin }