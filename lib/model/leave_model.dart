class LeaveModel {
  final String staffId;
  final String staffName;
  final String reason;
  final String fromDate;
  final String toDate;
  final String status;

  LeaveModel({
    required this.staffId,
    required this.staffName,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      "staffId": staffId,
      "staffName": staffName,
      "reason": reason,
      "fromDate": fromDate,
      "toDate": toDate,
      "status": status,
    };
  }
}