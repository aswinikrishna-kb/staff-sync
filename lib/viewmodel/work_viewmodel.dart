import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/work_update_model.dart';
import '../services/work_service.dart';

class WorkViewModel extends ChangeNotifier {
  final WorkService _workService = WorkService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  Future<void> submitWorkUpdate({
    String id = '',
    required String officeId,
    required String staffName,
    required String workDescription,
    required String status,
    String? date,
    String? time,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final now = DateTime.now();
      final finalDate = date ?? "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final finalTime = time ?? "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final work = WorkUpdateModel(
        id: id,
        staffId: user.email!.toLowerCase(),
        staffName: staffName,
        officeId: officeId,
        workDescription: workDescription,
        date: finalDate,
        time: finalTime,
        status: status,
      );

      await _workService.submitWorkUpdate(work);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<WorkUpdateModel>> watchMyWorkUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    return _workService.watchMyWorkUpdates(user.email!.toLowerCase());
  }

  // Watches only for TODAY'S work updates for the staff
  Stream<List<WorkUpdateModel>> watchMyTodaysWork(String date) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);
    
    return _firestore
        .collection('work_updates')
        .where('staffId', isEqualTo: user.email!.toLowerCase())
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkUpdateModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Admin View: Watch all updates for the office
  Stream<List<WorkUpdateModel>> watchOfficeWorkUpdates(String officeId, String date) {
    return _workService.watchOfficeWorkUpdates(officeId, date);
  }

  Future<void> deleteWork(String id) async {
    await _workService.deleteWorkUpdate(id);
  }
}
