import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/salary_model.dart';

class SalaryService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addSalary(SalaryModel salary) async {
    await firestore.collection("salary").add(salary.toMap());
  }

  // Fetch all salaries or filter by Year and Month
  Stream<QuerySnapshot> getSalary({String? year, String? month}) {
    Query query = firestore.collection("salary");

    if (year != null && year != "All") {
      query = query.where("year", isEqualTo: year);
    }

    if (month != null && month != "All") {
      query = query.where("month", isEqualTo: month);
    }

    return query.snapshots();
  }

  Stream<QuerySnapshot> getMySalary(String staffId) {
    return firestore
        .collection("salary")
        .where("staffId", isEqualTo: staffId)
        .snapshots();
  }

  Future<void> updateSalary(String docId, SalaryModel salary) async {
    await firestore.collection("salary").doc(docId).update(salary.toMap());
  }

  Future<void> deleteSalary(String docId) async {
    await firestore.collection("salary").doc(docId).delete();
  }
}
