class WorkUpdateModel {
  final String id;
  final String staffId;
  final String staffName;
  final String officeId;
  final String workDescription;
  final String date;
  final String time;
  final String status; // Program, Completed, In Progress

  WorkUpdateModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.officeId,
    required this.workDescription,
    required this.date,
    required this.time,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'officeId': officeId,
      'workDescription': workDescription,
      'date': date,
      'time': time,
      'status': status,
    };
  }

  factory WorkUpdateModel.fromMap(String id, Map<String, dynamic> map) {
    return WorkUpdateModel(
      id: id,
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      officeId: map['officeId'] ?? '',
      workDescription: map['workDescription'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'Program',
    );
  }
}
