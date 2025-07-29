
import 'package:intl/intl.dart';

class AttendanceModel {
  final String empId;
  final String name;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String totalHours;

  AttendanceModel({
    required this.empId,
    required this.name,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.totalHours,
  });

  factory AttendanceModel.fromFirestore(Map<String, dynamic> data) {
    String? in1 = data['punches']?['in-1'];
    String? out2 = data['punches']?['out-2'];

    String totalHours = '0';
    if (in1 != null && out2 != null) {
      try {
        final format = DateFormat('HH:mm');
        final start = format.parse(in1);
        final end = format.parse(out2);
        final diff = end.difference(start);

        if (diff.inMinutes > 0) {
          final hours = diff.inHours;
          final minutes = diff.inMinutes.remainder(60);
          totalHours = '${hours} hrs ${minutes} mins';
        }
      } catch (e) {
        totalHours = '0';
      }
    }

    return AttendanceModel(
      empId: data['empID'] ?? '',
      name: data['name'] ?? '',
      date: data['date'] ?? '',
      checkIn: in1,
      checkOut: out2,
      totalHours: totalHours,
    );
  }
}
