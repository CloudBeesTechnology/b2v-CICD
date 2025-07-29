import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import '../models/permission_model.dart';

class ReportProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<Leave> leaves = [];
  List<Permission> permissions = [];

  Future<void> fetchFiltered({
      required bool isLeave,
    DateTime? start, DateTime? end, String? empId}) async {
    print('Fetching ${isLeave ? "Leave" : "Permission"} Report');
    print('Start: $start | End: $end | empID: $empId');

    if (isLeave) {
      Query q = _db.collection('leaveStatus');

      if (start != null) {
        final startStr = DateFormat('yyyy-MM-dd').format(start);
        print('Filtering startDate >= $startStr');
        q = q.where('startDate', isGreaterThanOrEqualTo: startStr);
      }

      if (end != null) {
        final endStr = DateFormat('yyyy-MM-dd').format(end);
        print('Filtering endDate <= $endStr');
        q = q.where('endDate', isLessThanOrEqualTo: endStr);
      }

      if ((empId ?? '').isNotEmpty) {
        print('Filtering empID == $empId');
        q = q.where('empID', isEqualTo: empId);
      }

      final snap = await q.get();
      print('Fetched ${snap.docs.length} leave documents');

      leaves = await Future.wait(snap.docs.map((d) async {
        final data = d.data() as Map<String, dynamic>;
        final emp = await _getEmpName(data['empID']);
        return Leave(
          empID: data['empID'] ?? '',
          leaveType: data['leaveType'] ?? '',
          daysTaken: data['takenDay'],
          startDate: data['startDate'] ?? '',
          endDate: data['endDate'] ?? '',
          createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime(2000),
          empName: emp,
        );
      }).toList());

    } else {
      Query q = _db.collection('applyPermission');
      if (start != null) q = q.where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(start));
      if (end != null) q = q.where('date', isLessThanOrEqualTo: DateFormat('yyyy-MM-dd').format(end));
      if ((empId ?? '').isNotEmpty) q = q.where('empID', isEqualTo: empId);

      final snap = await q.get();
      permissions = await Future.wait(snap.docs.map((d) async {
        final data = d.data() as Map<String, dynamic>;
        final emp = await _getEmpName(data['empID'] ?? '');
        return Permission(
          empID: data['empID'] ?? '',
          totalHours: data['totalHours'],
          date: data['date'] ?? '',
          fromTime: data['fromTime'] ?? '',
          toTime: data['toTime'] ?? '',
          reason: data['reason'] ?? '',
          createdAt: DateTime.parse(data['createdAt'] ?? ''),
          empName: emp,
        );
      }).toList());
    }

    notifyListeners();
  }

  Future<String> _getEmpName(String empID) async {
    final snap = await _db.collection('employeeDetails').where('empID', isEqualTo: empID).limit(1).get();
    return snap.docs.isNotEmpty ? snap.docs.first.data()['name'] : empID;
  }
}
