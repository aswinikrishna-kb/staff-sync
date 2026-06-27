import 'package:flutter/material.dart';

import '../model/attendance_model.dart';
import '../services/auth_service.dart';
import '../services/attendance_service.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final AuthService _authService = AuthService();

  bool isLoading = false;

  String get currentStaffId => _authService.currentUser?.uid ?? '';

  String get currentStaffName =>
      _authService.currentUser?.email ?? 'Unknown';

  String get currentDate =>
      DateTime.now().toString().substring(0, 10);

  String get currentPunchInTime {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> punchIn() async {
    await addAttendance(
      staffId: currentStaffId,
      staffName: currentStaffName,
      date: currentDate,
      status: 'Present',
      punchInTime: currentPunchInTime,
    );
  }

  Future<void> addAttendance({
    required String staffId,
    required String staffName,
    required String date,
    required String status,
    required String punchInTime,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final attendance = AttendanceModel(
        staffId: staffId,
        staffName: staffName,
        date: date,
        status: status,
        punchInTime: punchInTime,
      );

      await _attendanceService.addAttendance(attendance);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<AttendanceModel>> watchAttendance() {
    return _attendanceService.watchAttendance();
  }

  Stream<List<AttendanceModel>> watchMyAttendance() {
    return _attendanceService.watchAttendanceByStaff(currentStaffId);
  }
}
