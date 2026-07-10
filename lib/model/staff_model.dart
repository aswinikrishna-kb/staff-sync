class StaffModel {
  String id;
  String name;
  String phone;
  String email;
  String department;
  String designation;
  String joiningDate;
  String address;
  String employeeId;
  String adminUid;   // The Admin who added this staff
  String adminEmail; // Used as the Referral ID for staff signup
  String companyName;

  StaffModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.department,
    required this.designation,
    required this.joiningDate,
    required this.adminUid,
    required this.adminEmail,
    required this.companyName,
    this.address = '',
    this.employeeId = '',
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
      "email": email,
      "department": department,
      "designation": designation,
      "joiningDate": joiningDate,
      "address": address,
      "employeeId": employeeId,
      "adminUid": adminUid,
      "adminEmail": adminEmail,
      "companyName": companyName,
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
      joiningDate: map["joiningDate"] ?? '',
      address: map["address"] ?? '',
      employeeId: map["employeeId"] ?? '',
      adminUid: map["adminUid"] ?? '',
      adminEmail: map["adminEmail"] ?? '',
      companyName: map["companyName"] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
