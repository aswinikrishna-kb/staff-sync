import 'package:flutter/material.dart';
import '../model/salary_model.dart';
import '../services/salary_service.dart';

class SalaryViewModel extends ChangeNotifier {
  final SalaryService salaryService = SalaryService();
  bool isLoading = false;

  Future<void> addSalary({
    required String staffId,
    required String staffName,
    required String month,
    required String year,
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
      year: year,
      basicSalary: basicSalary,
      bonus: bonus,
      deduction: deduction,
      netSalary: netSalary,
    );

    await salaryService.addSalary(salary);

    isLoading = false;
    notifyListeners();
  }

  getSalary({String? year, String? month}) {
    return salaryService.getSalary(year: year, month: month);
  }

  getMySalary(String staffId) {
    return salaryService.getMySalary(staffId);
  }

  Future<void> updateSalary({
    required String docId,
    required String staffId,
    required String staffName,
    required String month,
    required String year,
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
      year: year,
      basicSalary: basicSalary,
      bonus: bonus,
      deduction: deduction,
      netSalary: netSalary,
    );

    await salaryService.updateSalary(docId, salary);

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteSalary(String docId) async {
    await salaryService.deleteSalary(docId);
    notifyListeners();
  }
}
