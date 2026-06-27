import 'package:flutter/material.dart';

import '../model/salary_model.dart';
import '../services/salary_service.dart';

class SalaryViewModel
    extends ChangeNotifier {

  final SalaryService salaryService =
  SalaryService();

  bool isLoading = false;

  Future<void> addSalary({

    required String staffId,
    required String staffName,
    required String month,
    required String basicSalary,
    required String bonus,
    required String deduction,
    required String netSalary,

  }) async {

    isLoading = true;
    notifyListeners();

    SalaryModel salary = SalaryModel(

      staffId: staffId,
      staffName: staffName,
      month: month,
      basicSalary: basicSalary,
      bonus: bonus,
      deduction: deduction,
      netSalary: netSalary,

    );

    await salaryService.addSalary(
        salary);

    isLoading = false;
    notifyListeners();
  }

  getSalary() {
    return salaryService.getSalary();
  }

  getMySalary(String staffId) {
    return salaryService.getMySalary(
        staffId);
  }
}