import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAttendance(AttendanceModel attendance, String officeId) async {
    // We use date + staffId as the document ID to ensure only one record per day
    final docId = "${attendance.date}_${attendance.staffId.replaceAll('.', '_')}";
    final data = attendance.toMap();
    data['officeId'] = officeId; // Ensure officeId is stored for admin filtering
    await _firestore.collection('attendance').doc(docId).set(data);
  }

  Future<void> updatePunchOut(String staffId, String date, String punchOutTime) async {
    final docId = "${date}_${staffId.replaceAll('.', '_')}";
    await _firestore.collection('attendance').doc(docId).update({
      'punchOutTime': punchOutTime,
    });
  }

  Stream<AttendanceModel?> watchTodayAttendance(String staffId, String date) {
    final docId = "${date}_${staffId.replaceAll('.', '_')}";
    return _firestore.collection('attendance').doc(docId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return AttendanceModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Generic watch method
  Stream<List<AttendanceModel>> watchAttendance() {
    return _firestore.collection('attendance').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Admin View: All attendance for their specific office
  Stream<List<AttendanceModel>> watchAttendanceByOffice(String officeId) {
    return _firestore
        .collection('attendance')
        .where('officeId', isEqualTo: officeId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromMap(doc.data()))
            .toList());
  }

  // Staff View: Personal history
  Stream<List<AttendanceModel>> watchAttendanceByStaff(String staffId) {
    return _firestore
        .collection('attendance')
        .where('staffId', isEqualTo: staffId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromMap(doc.data()))
            .toList());
  }
}
