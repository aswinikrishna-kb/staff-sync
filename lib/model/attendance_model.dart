class AttendanceModel {
  final String staffId;
  final String staffName;
  final String date;
  final String status;
  final String punchInTime;

  AttendanceModel({
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.status,
    required this.punchInTime,

  });

  Map<String, dynamic> toMap() {
    return {
      "staffId": staffId,
      "staffName": staffName,
      "date": date,
      "status": status,
      "punchInTime": punchInTime,

    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      staffId: map["staffId"],
      staffName: map["staffName"],
      date: map["date"],
      status: map["status"],
      punchInTime: map["punchInTime"],

    );
  }
}