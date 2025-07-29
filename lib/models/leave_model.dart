class Leave {
  final String empID, leaveType, startDate, endDate;
  final String? daysTaken; // Make daysTaken nullable
  final DateTime createdAt;
  String? empName;

  Leave({
    required this.empID,
    required this.leaveType,
    this.daysTaken, // Remove required
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.empName
  });
}