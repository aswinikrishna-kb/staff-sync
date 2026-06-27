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
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final staff = StaffModel(
        id: '',
        name: name,
        phone: phone,
        email: email,
        department: department,
        designation: designation,
      );

      await _staffService.addStaff(staff);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<StaffModel>> watchStaff() {
    return _staffService.watchStaff();
  }
}
