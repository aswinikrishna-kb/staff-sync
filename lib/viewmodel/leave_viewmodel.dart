import 'package:flutter/material.dart';
import '../model/leave_model.dart';
import '../services/leave_service.dart';

class LeaveViewModel extends ChangeNotifier {
  final LeaveService leaveService = LeaveService();
  bool isLoading = false;

  Future<void> applyLeave({
    required String staffId,
    required String staffName,
    required String reason,
    required String fromDate,
    required String toDate,
    required String officeId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      LeaveModel leave = LeaveModel(
        staffId: staffId,
        staffName: staffName,
        reason: reason,
        fromDate: fromDate,
        toDate: toDate,
        status: "Pending",
        officeId: officeId,
      );

      await leaveService.applyLeave(leave);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  getLeave() {
    return leaveService.getLeave();
  }

  Future<void> updateStatus(String docId, String status) async {
    await leaveService.updateLeaveStatus(docId, status);
    notifyListeners();
  }

  getMyLeave(String staffId) {
    return leaveService.getMyLeave(staffId);
  }
}
