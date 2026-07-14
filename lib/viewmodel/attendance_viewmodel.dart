import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../model/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceViewModel extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

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

  Stream<AttendanceModel?> watchTodayStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return Stream.value(null);
    return _attendanceService.watchTodayAttendance(user.email!.toLowerCase(), currentDate);
  }

  Future<String> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.name}, ${place.locality}, ${place.administrativeArea}";
      }
      return "${position.latitude}, ${position.longitude}";
    } catch (e) {
      return "${position.latitude}, ${position.longitude}";
    }
  }

  Future<String> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt user to turn on GPS
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled. Please turn on GPS and try again.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. We need your location to verify attendance.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in Settings.');
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return await _getAddressFromLatLng(position);
  }

  Future<void> punchIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final location = await _getLocation();
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
        punchInLocation: location,
        punchOutLocation: '',
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
      
      final location = await _getLocation();
      final docId = "${currentDate}_${user.email!.toLowerCase().replaceAll('.', '_')}";
      
      await _firestore.collection('attendance').doc(docId).update({
        'punchOutTime': currentTime,
        'punchOutLocation': location,
      });
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<AttendanceModel>> watchMyAttendance() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return Stream.value([]);
    return _attendanceService.watchAttendanceByStaff(user.email!.toLowerCase());
  }

  Stream<List<AttendanceModel>> watchAttendance() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    return Stream.fromFuture(_firestore.collection('users').doc(user.uid).get())
        .asyncExpand((doc) {
          final officeId = doc.data()?['officeId'] ?? '';
          return _attendanceService.watchAttendanceByOffice(officeId);
        });
  }
}
