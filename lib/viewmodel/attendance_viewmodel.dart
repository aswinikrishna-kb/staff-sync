import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // --- Getters for UI ---
  String get currentDate => DateTime.now().toIso8601String().split('T')[0];

  String get currentTime {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String get currentStaffId => FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';
  String get currentStaffName => FirebaseAuth.instance.currentUser?.displayName ?? 'Staff Member';
  String get currentPunchInTime => currentTime;

  // Check today's status for the logged-in staff
  Stream<AttendanceModel?> watchTodayStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return Stream.value(null);
    return _attendanceService.watchTodayAttendance(user.email!.toLowerCase(), currentDate);
  }

  // Proper punchIn method
  Future<void> punchIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final officeId = userDoc.data()?['officeId'] ?? '';
      final username = userDoc.data()?['username'] ?? currentStaffName;

      final attendance = AttendanceModel(
        staffId: user.email!.toLowerCase(),
        staffName: username,
        date: currentDate,
        status: 'Present',
        punchInTime: currentTime,
        punchOutTime: '',
      );

      await _attendanceService.addAttendance(attendance, officeId);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> punchOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {
      isLoading = true;
      notifyListeners();
      await _attendanceService.updatePunchOut(user.email!.toLowerCase(), currentDate, currentTime);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Admin View: Watch attendance for their specific office only
  Stream<List<AttendanceModel>> watchAttendance() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    
    // We fetch the admin's officeId to ensure they only see their own staff's records
    return Stream.fromFuture(_firestore.collection('users').doc(user.uid).get())
        .asyncExpand((doc) {
          final officeId = doc.data()?['officeId'] ?? '';
          return _attendanceService.watchAttendanceByOffice(officeId);
        });
  }

  Stream<List<AttendanceModel>> watchMyAttendance() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return Stream.value([]);
    return _attendanceService.watchAttendanceByStaff(user.email!.toLowerCase());
  }

  // Alias for backward compatibility
  Future<void> addAttendance({
    required String staffId,
    required String staffName,
    required String date,
    required String status,
    required String punchInTime,
  }) async {
    await punchIn();
  }
}
