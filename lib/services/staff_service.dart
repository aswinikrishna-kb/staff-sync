import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/staff_model.dart';

class StaffService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getProfile(String email) {
    return _firestore
        .collection("staffs")
        .where("email", isEqualTo: email)
        .snapshots();
  }

  Future<void> addStaff(StaffModel staff) async {
    await _firestore.collection('staffs').add(staff.toMap());
  }

  // Watches the 'staffs' collection (manually added)
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

  // NEW: Watches the 'users' collection for registered staff members
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
                    name: data['username'] ?? 'No Name', // Registered users use 'username'
                    phone: data['phone'] ?? '',
                    email: data['email'] ?? '',
                    department: 'Registered', // Default for signed-up users
                    designation: 'Staff',
                  );
                },
              )
              .toList(),
        );
  }
}
