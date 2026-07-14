class AttendanceModel {
  final String staffId;
  final String staffName;
  final String date;
  final String status;
  final String punchInTime;
  final String punchOutTime;
  final String punchInLocation; // New field for location
  final String punchOutLocation; // New field for location

  AttendanceModel({
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.status,
    required this.punchInTime,
    this.punchOutTime = '',
    this.punchInLocation = '',
    this.punchOutLocation = '',
  });

  Map<String, dynamic> toMap() {
    return {
      "staffId": staffId,
      "staffName": staffName,
      "date": date,
      "status": status,
      "punchInTime": punchInTime,
      "punchOutTime": punchOutTime,
      "punchInLocation": punchInLocation,
      "punchOutLocation": punchOutLocation,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      staffId: map["staffId"] ?? '',
      staffName: map["staffName"] ?? '',
      date: map["date"] ?? '',
      status: map["status"] ?? '',
      punchInTime: map["punchInTime"] ?? '',
      punchOutTime: map["punchOutTime"] ?? '',
      punchInLocation: map["punchInLocation"] ?? '',
      punchOutLocation: map["punchOutLocation"] ?? '',
    );
  }
}
