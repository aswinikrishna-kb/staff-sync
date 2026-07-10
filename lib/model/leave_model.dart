class LeaveModel {
  final String staffId;
  final String staffName;
  final String reason;
  final String fromDate;
  final String toDate;
  final String status;
  final String officeId;

  LeaveModel({
    required this.staffId,
    required this.staffName,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.officeId,
  });

  Map<String, dynamic> toMap() {
    return {
      "staffId": staffId,
      "staffName": staffName,
      "reason": reason,
      "fromDate": fromDate,
      "toDate": toDate,
      "status": status,
      "officeId": officeId,
    };
  }

  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    return LeaveModel(
      staffId: map["staffId"] ?? '',
      staffName: map["staffName"] ?? '',
      reason: map["reason"] ?? '',
      fromDate: map["fromDate"] ?? '',
      toDate: map["toDate"] ?? '',
      status: map["status"] ?? '',
      officeId: map["officeId"] ?? '',
    );
  }
}
