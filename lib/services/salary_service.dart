import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/salary_model.dart';

class SalaryService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<void> addSalary(
      SalaryModel salary) async {

    await firestore
        .collection("salary")
        .add(salary.toMap());
  }

  Stream<QuerySnapshot> getSalary() {
    return firestore
        .collection("salary")
        .snapshots();
  }

  Stream<QuerySnapshot> getMySalary(
      String staffId) {

    return firestore
        .collection("salary")
        .where("staffId",
        isEqualTo: staffId)
        .snapshots();
  }
}