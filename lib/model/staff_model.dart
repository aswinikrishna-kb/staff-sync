class StaffModel {
  String id;
  String name;
  String phone;
  String email;
  String department;
  String designation;

  StaffModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.department,
    required this.designation,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
      "email": email,
      "department": department,
      "designation": designation,
    };
  }

  factory StaffModel.fromMap(String id, Map<String, dynamic> map) {
    return StaffModel(
      id: id,
      name: map["name"] ?? '',
      phone: map["phone"] ?? '',
      email: map["email"] ?? '',
      department: map["department"] ?? '',
      designation: map["designation"] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
