import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAttendance(AttendanceModel attendance) async {
    await _firestore.collection('attendance').add(attendance.toMap());
  }

  Stream<List<AttendanceModel>> watchAttendance() {
    return _firestore.collection('attendance').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AttendanceModel.fromMap(doc.data()),
              )
              .toList(),
        );
  }

  Stream<List<AttendanceModel>> watchAttendanceByStaff(String staffId) {
    return watchAttendance().map(
      (records) =>
          records.where((record) => record.staffId == staffId).toList(),
    );
  }
}
