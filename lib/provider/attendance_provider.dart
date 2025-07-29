import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';


class AttendanceProvider with ChangeNotifier {
  final List<AttendanceModel> _attendanceList = [];
  List<AttendanceModel> get attendanceList => _attendanceList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchAttendance({
    DateTime? start,
    DateTime? end,
    String? empId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      Query query = FirebaseFirestore.instance.collection('attendanceCollection');

      // CASE 1: Filtered by date range
      if (start != null && end != null) {
        final startStr = DateFormat('dd/MM/yyyy').format(start);
        final endStr = DateFormat('dd/MM/yyyy').format(end);
        query = query
            .where('date', isGreaterThanOrEqualTo: startStr)
            .where('date', isLessThanOrEqualTo: endStr);
      }
      // CASE 2: Default – yesterday and today only
      else {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final todayStr = DateFormat('dd/MM/yyyy').format(today);
        final yesterdayStr = DateFormat('dd/MM/yyyy').format(yesterday);
        query = query.where('date', whereIn: [todayStr, yesterdayStr]);
      }

      final snapshot = await query.get();
      _attendanceList.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final matchesSearch = empId == null ||
            empId.isEmpty ||
            (data['empID']?.toString().toLowerCase().contains(empId.toLowerCase()) ?? false) ||
            (data['name']?.toString().toLowerCase().contains(empId.toLowerCase()) ?? false);

        if (matchesSearch) {
          _attendanceList.add(AttendanceModel.fromFirestore(data));
        }
      }

      print("Fetched ${_attendanceList.length} records");
    } catch (e) {
      print('Error fetching attendance: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

}
