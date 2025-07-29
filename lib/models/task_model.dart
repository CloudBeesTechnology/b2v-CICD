
class TaskItem {
  final String empId;
  final String name;
  final String date;
  final List<dynamic> taskTiming;
  final List<String> description;
  final String? profilePhoto;
  final String status;
  final String? managerRemarks;

  TaskItem({
    required this.empId,
    required this.name,
    required this.date,
    this.taskTiming = const [],
    this.description = const [],
    this.profilePhoto,
    this.status = 'Pending',
    this.managerRemarks,
  });

  double get totalHours {
    double total = 0;
    for (var time in taskTiming) {
      try {
        final parts = time.toString().split(':');
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        total += hours + (minutes / 60);
      } catch (_) {}
    }
    return total;
  }

  String get formattedTotal => '${totalHours.toStringAsFixed(2)} Hours Logged';
}

