class WorkModel {
  final String id;
  final String staffId;
  final String staffName;
  final String officeId;
  final String description;
  final String date;
  final String time;
  final String status; // Completed, In Progress, etc.

  WorkModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.officeId,
    required this.description,
    required this.date,
    required this.time,
    this.status = 'Completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'officeId': officeId,
      'description': description,
      'date': date,
      'time': time,
      'status': status,
    };
  }

  factory WorkModel.fromMap(String id, Map<String, dynamic> map) {
    return WorkModel(
      id: id,
      staffId: map['staffId'] ?? '',
      staffName: map['staffName'] ?? '',
      officeId: map['officeId'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'Completed',
    );
  }
}
