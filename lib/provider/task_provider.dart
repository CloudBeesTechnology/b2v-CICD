import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';

  class TaskProvider extends ChangeNotifier {
    List<TaskItem> todayTasks = [];
    List<TaskItem> rejectedTasks = [];
    List<TaskItem> approvedTasks = [];

    bool isLoading = false;

    Future<void> fetchTasks({bool forceRefresh = false}) async {
      if (!forceRefresh &&
          todayTasks.isNotEmpty &&
          rejectedTasks.isNotEmpty &&
          approvedTasks.isNotEmpty) return;

      isLoading = true;
      notifyListeners();

      final taskSnap = await FirebaseFirestore.instance.collection('taskData').get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      todayTasks.clear();
      rejectedTasks.clear();
      approvedTasks.clear();

      // Step 1: Build a map of empIDs we need
      final uniqueEmpIds = taskSnap.docs.map((doc) => doc['empID'].toString()).toSet();

      // Step 2: Fetch profile photos in parallel once
      final employeeDetailsMap = await _getEmployeeDetails(uniqueEmpIds);


      for (var doc in taskSnap.docs) {
        final data = doc.data();
        final dateString = data['taskStartDate'];
        final status = (data['status'] ?? 'Pending').toString();
        final empId = data['empID'];
        final rawTiming = data['taskTiming'];
        final rawDescription = data['description'];
        final managerRemarks = data['managerRemarks'];
        final empDetails = employeeDetailsMap[empId] ?? {};
        final empName = empDetails['name'] ?? '';
        final empPhoto = empDetails['profilePhoto'];

        final task = TaskItem(
          empId: empId,
          name: empName,
          date: dateString,
          taskTiming: rawTiming != null && rawTiming is Iterable ? List.from(rawTiming) : [],
          description: rawDescription is List
              ? List<String>.from(rawDescription)
              : [rawDescription?.toString() ?? ''],
          profilePhoto: empPhoto,
          status: status,
          managerRemarks: managerRemarks,
        );

        try {
          final parsedDate = parseFlexibleDate(dateString);
          final isToday = _isSameDate(parsedDate, today) || _isSameDate(parsedDate, yesterday);

          if (status == 'Pending') {
            final parsedDate = parseFlexibleDate(dateString);
            final isToday = _isSameDate(parsedDate, today) || _isSameDate(parsedDate, yesterday);

            if (isToday) {
              todayTasks.add(task);
            }
          } else if (status == 'Rejected') {
            rejectedTasks.add(task);
          } else if (status == 'Approved') {
            approvedTasks.add(task);
          }

        } catch (_) {}
      }

      isLoading = false;
      notifyListeners();
    }



    bool _isSameDate(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    DateTime parseFlexibleDate(String input) {
      if (input.contains('/')) {
        final parts = input.split('/').map(int.parse).toList();
        return DateTime(parts[2], parts[1], parts[0]); // dd/MM/yyyy
      } else if (input.contains('-')) {
        final parts = input.split('-').map(int.parse).toList();
        return DateTime(parts[0], parts[1], parts[2]); // yyyy-MM-dd
      } else {
        throw FormatException('Unrecognized date format: $input');
      }
    }

    Future<Map<String, Map<String, String?>>> _getEmployeeDetails(Set<String> empIds) async {
      final snapshot = await FirebaseFirestore.instance
          .collection('employeeDetails')
          .where('empID', whereIn: empIds.toList())
          .get();

      final Map<String, Map<String, String?>> map = {};
      for (var doc in snapshot.docs) {
        final empId = doc['empID'];
        final name = doc['name'];
        final photo = doc['profilePhoto'];
        map[empId] = {
          'name': name,
          'profilePhoto': photo,
        };
      }
      return map;
    }


  }
