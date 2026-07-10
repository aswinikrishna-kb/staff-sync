import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Verify if the staff member was pre-added by an admin and belongs to that admin
  Future<Map<String, dynamic>?> verifyStaffPermission(String email, String employeeId, String adminEmail) async {
    final snapshot = await _firestore
        .collection('staffs')
        .where('email', isEqualTo: email.toLowerCase())
        .where('employeeId', isEqualTo: employeeId)
        .where('adminEmail', isEqualTo: adminEmail.toLowerCase())
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  Future<User?> signup({
    required String username,
    required String phone,
    required String email,
    required String password,
    required String role,
    String? companyName,
    String? employeeId,
    String? adminReferral,
  }) async {
    String officeId = '';
    String finalCompanyName = companyName ?? '';

    // Staff Signup Protection
    if (role == 'staff') {
      if (employeeId == null || adminReferral == null) {
        throw Exception("Employee ID and Admin Email are required");
      }
      
      final staffData = await verifyStaffPermission(email, employeeId, adminReferral);
      if (staffData == null) {
        throw Exception("Registration denied. Details do not match our records for this Admin.");
      }
      
      // Inherit the office link from the admin who added them
      officeId = staffData['adminUid'] ?? '';
      finalCompanyName = staffData['companyName'] ?? '';
    }

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user != null) {
      // If user is Admin, they become their own office owner
      if (role == 'admin') {
        officeId = user.uid;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid, // ✅ Added UID to the document
        'username': username,
        'phone': phone,
        'email': email.toLowerCase(),
        'role': role,
        'employeeId': employeeId ?? '',
        'officeId': officeId,
        'companyName': finalCompanyName,
      });
    }

    return user;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc['role'] as String?;
    }

    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
