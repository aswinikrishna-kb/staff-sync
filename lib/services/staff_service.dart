import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/staff_model.dart';

class StaffService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getProfile(String email) {
    return _firestore
        .collection("staffs")
        .where("email", isEqualTo: email.toLowerCase())
        .snapshots();
  }

  Future<void> addStaff(StaffModel staff) async {
    await _firestore.collection('staffs').add(staff.toMap());
  }

  // Watches only staff added by a specific Admin
  Stream<List<StaffModel>> watchStaffByAdmin(String adminUid) {
    return _firestore
        .collection('staffs')
        .where('adminUid', isEqualTo: adminUid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => StaffModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  // NEW: Watches the 'users' collection for registered staff members belonging to this Admin's office
  Stream<List<StaffModel>> watchRegisteredUsersByAdmin(String officeId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .where('officeId', isEqualTo: officeId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) {
                  final data = doc.data();
                  return StaffModel(
                    id: doc.id,
                    name: data['username'] ?? 'No Name',
                    phone: data['phone'] ?? '',
                    email: data['email'] ?? '',
                    department: 'Registered',
                    designation: 'Staff',
                    joiningDate: data['joiningDate'] ?? '',
                    address: data['address'] ?? '',
                    employeeId: data['employeeId'] ?? '',
                    adminUid: data['officeId'] ?? '',
                    adminEmail: '', // Not needed for registered list
                    companyName: data['companyName'] ?? '',
                  );
                },
              )
              .toList(),
        );
  }

  // Watches the 'staffs' collection (kept for backward compatibility if needed, but should use watchStaffByAdmin)
  Stream<List<StaffModel>> watchStaff() {
    return _firestore.collection('staffs').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => StaffModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  // Watches all registered staff (kept for backward compatibility, but should use filtered version)
  Stream<List<StaffModel>> watchRegisteredUsers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) {
                  final data = doc.data();
                  return StaffModel(
                    id: doc.id,
                    name: data['username'] ?? 'No Name',
                    phone: data['phone'] ?? '',
                    email: data['email'] ?? '',
                    department: 'Registered',
                    designation: 'Staff',
                    joiningDate: data['joiningDate'] ?? '',
                    address: data['address'] ?? '',
                    employeeId: data['employeeId'] ?? '',
                    adminUid: data['officeId'] ?? '',
                    adminEmail: '',
                    companyName: data['companyName'] ?? '',
                  );
                },
              )
              .toList(),
        );
  }
}
