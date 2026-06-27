import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/leave_model.dart';

class LeaveService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<void> applyLeave(
      LeaveModel leave) async {

    await firestore
        .collection("leave")
        .add(leave.toMap());
  }

  Stream<QuerySnapshot> getLeave() {
    return firestore
        .collection("leave")
        .snapshots();
  }
  Future<void> updateLeaveStatus(
      String docId,
      String status,
      ) async {

    await firestore
        .collection("leave")
        .doc(docId)
        .update({
      "status": status,
    });

  }
  Stream<QuerySnapshot> getMyLeave(String staffId) {
    return firestore
        .collection("leave")
        .where("staffId", isEqualTo: staffId)
        .snapshots();
  }
}