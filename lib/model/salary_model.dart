class SalaryModel {
  final String staffId;
  final String staffName;
  final String month;
  final String basicSalary;
  final String bonus;
  final String deduction;
  final String netSalary;

  SalaryModel({
    required this.staffId,
    required this.staffName,
    required this.month,
    required this.basicSalary,
    required this.bonus,
    required this.deduction,
    required this.netSalary,
  });

  Map<String, dynamic> toMap() {
    return {
      "staffId": staffId,
      "staffName": staffName,
      "month": month,
      "basicSalary": basicSalary,
      "bonus": bonus,
      "deduction": deduction,
      "netSalary": netSalary,
    };
  }

  factory SalaryModel.fromMap(Map<String, dynamic> map) {
    return SalaryModel(
      staffId: map["staffId"],
      staffName: map["staffName"],
      month: map["month"],
      basicSalary: map["basicSalary"],
      bonus: map["bonus"],
      deduction: map["deduction"],
      netSalary: map["netSalary"],
    );
  }
}