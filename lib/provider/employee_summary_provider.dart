import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class EmployeeSummaryProvider extends ChangeNotifier {
  int _totalEmployees = 0;
  int _activeEmployees = 0;
  int _absentEmployees = 0;

  int get totalEmployees => _totalEmployees;
  int get activeEmployees => _activeEmployees;
  int get absentEmployees => _absentEmployees;

  Future<void> fetchSummary() async {
    final firestore = FirebaseFirestore.instance;
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    try {
      // 1. Get all employee documents
      final employeeSnapshot = await firestore.collection('employeeDetails').get();
      final empDocs = employeeSnapshot.docs;
      _totalEmployees = empDocs.length;

      // 2. Extract all employee IDs
      final allEmpIds = empDocs.map((doc) => doc['empID'].toString()).toList();

      // 3. Get all today's attendance records
      final attendanceSnapshot = await firestore
          .collection('attendanceCollection')
          .where('date', isEqualTo: today)
          .get();

      final presentEmpIds = attendanceSnapshot.docs
          .map((doc) => doc['empID'].toString())
          .toSet();

      _activeEmployees = presentEmpIds.length;
      _absentEmployees = _totalEmployees - _activeEmployees;
    } catch (e) {
      debugPrint('Error fetching employee summary: $e');
    }

    notifyListeners();
  }
}
