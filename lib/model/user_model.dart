class UserModel {
  final String uid;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String officeId;
  final String adminEmail; // Office Mail
  final String companyName; // Office Name

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.officeId,
    required this.adminEmail,
    required this.companyName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'officeId': officeId,
      'adminEmail': adminEmail,
      'companyName': companyName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'staff',
      officeId: map['officeId'] ?? '',
      adminEmail: map['adminEmail'] ?? '',
      companyName: map['companyName'] ?? '',
    );
  }
}
