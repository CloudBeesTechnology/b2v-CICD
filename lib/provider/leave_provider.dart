import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveProvider with ChangeNotifier {
  List<Map<String, dynamic>> _pendingLeaves = [];

  List<Map<String, dynamic>> get pendingLeaves => _pendingLeaves;

  Future<void> fetchPendingLeaves() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('leaveStatus')
          .where('leaveStatus', isEqualTo: 'Pending')
          .get();

      _pendingLeaves = snapshot.docs.map((doc) => doc.data()).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching pending leaves: $e");
    }
  }
}
