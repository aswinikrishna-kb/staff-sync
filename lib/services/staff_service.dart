import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/staff_model.dart';

class StaffService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addStaff(StaffModel staff) async {
    await _firestore.collection('staffs').add(staff.toMap());
  }

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
}
