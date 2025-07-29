
class Permission {
  final String empID, date, fromTime, toTime, reason;
  final String? totalHours; // Make totalHours nullable
  final DateTime createdAt;
  String? empName;

  Permission({
    required this.empID,
    this.totalHours, // Remove required
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.reason,
    required this.createdAt,
    this.empName
  });
}
