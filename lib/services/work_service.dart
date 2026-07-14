import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/work_update_model.dart';

class WorkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitWorkUpdate(WorkUpdateModel work) async {
    if (work.id.isEmpty) {
      // New Task
      await _firestore.collection('work_updates').add(work.toMap());
    } else {
      // Update Existing Task
      await _firestore.collection('work_updates').doc(work.id).update(work.toMap());
    }
  }

  Future<void> deleteWorkUpdate(String id) async {
    await _firestore.collection('work_updates').doc(id).delete();
  }

  Stream<List<WorkUpdateModel>> watchMyWorkUpdates(String staffEmail) {
    return _firestore
        .collection('work_updates')
        .where('staffId', isEqualTo: staffEmail)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkUpdateModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<WorkUpdateModel>> watchOfficeWorkUpdates(String officeId, String date) {
    return _firestore
        .collection('work_updates')
        .where('officeId', isEqualTo: officeId)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkUpdateModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}
