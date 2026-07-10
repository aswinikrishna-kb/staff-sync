import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/staff_model.dart';
import '../services/staff_service.dart';

class StaffViewModel extends ChangeNotifier {
  final StaffService _staffService = StaffService();

  bool isLoading = false;

  Future<void> addStaff({
    required String name,
    required String phone,
    required String email,
    required String department,
    required String designation,
    required String joiningDate,
    required String companyName, // Added
    String address = '',
    String employeeId = '',
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Admin not logged in");

      final staff = StaffModel(
        id: '',
        name: name,
        phone: phone,
        email: email.toLowerCase(),
        department: department,
        designation: designation,
        joiningDate: joiningDate,
        address: address,
        employeeId: employeeId,
        adminUid: currentUser.uid,          // Current Admin's UID
        adminEmail: currentUser.email!,     // Current Admin's Email (Referral ID)
        companyName: companyName,           // Admin's Company Name
      );

      await _staffService.addStaff(staff);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<StaffModel>> watchStaff() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value([]);
    
    // Only watch staff added by this specific Admin
    return _staffService.watchStaffByAdmin(currentUser.uid);
  }

  // NEW: Exposes registered users to the UI
  Stream<List<StaffModel>> watchRegisteredUsers() {
    return _staffService.watchRegisteredUsers();
  }

  getProfile(String email) {
    return _staffService.getProfile(email);
  }
}
