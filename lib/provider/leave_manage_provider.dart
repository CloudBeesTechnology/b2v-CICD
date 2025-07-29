import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveManageProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _approved = [];
  List<Map<String, dynamic>> _rejected = [];

  List<Map<String, dynamic>> get pending => _pending;
  List<Map<String, dynamic>> get approved => _approved;
  List<Map<String, dynamic>> get rejected => _rejected;

  bool _isFetched = false;

  Future<void> fetchLeaves() async {
    if (_isFetched) return; // Don't fetch again

    final snapshot = await _firestore.collection('leaveStatus').get();

    _pending.clear();
    _approved.clear();
    _rejected.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      data['docId'] = doc.id;

      final leaveStatus = data['leaveStatus'] ?? '';
      final leadStatus = (data['leadStatus'] ?? '').toString().trim();
      final managerStatus = (data['managerStatus'] ?? '').toString().trim();
      final adminStatus = (data['adminStatus'] ?? '').toString().trim().isEmpty
          ? 'Pending'
          : data['adminStatus'].toString().trim();

      // Skip cancelled leaves
      if (leaveStatus == 'Cancelled') continue;

      // 1. Any Rejected → Rejected
      if ([leadStatus, managerStatus, adminStatus].contains('Rejected')) {
        _rejected.add(data);
      }
      // 2. Any Approved → Approved
      else if ([leadStatus, managerStatus, adminStatus].contains('Approved')) {
        _approved.add(data);
      }
      // 3. All Pending → Pending
      else if (leadStatus == 'Pending' && managerStatus == 'Pending' && adminStatus == 'Pending') {
        _pending.add(data);
      }
    }



    // ✅ Sort after all data is processed
    int sortByDateDesc(Map<String, dynamic> a, Map<String, dynamic> b) {
      DateTime parseDate(dynamic value) {
        if (value is Timestamp) return value.toDate();
        if (value is String) return DateTime.tryParse(value) ?? DateTime(2000);
        return DateTime(2000);
      }

      final aDate = parseDate(a['startDate']);
      final bDate = parseDate(b['startDate']);

      return bDate.compareTo(aDate);
    }

    _pending.sort(sortByDateDesc);
    _approved.sort(sortByDateDesc);
    _rejected.sort(sortByDateDesc);

    print('Pending: ${pending.length}');
    print('Approved: ${approved.length}');
    print('Rejected: ${rejected.length}');

    _isFetched = true;
    notifyListeners();
  }


}

