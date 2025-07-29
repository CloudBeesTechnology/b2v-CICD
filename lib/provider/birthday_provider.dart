import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class BirthdayProvider extends ChangeNotifier {
  List<String> todayBirthdays = [];
  bool isLoading = true;

  BirthdayProvider() {
    fetchTodayBirthdays();
  }

  Future<void> fetchTodayBirthdays() async {
    try {
      final today = DateFormat('MM-dd').format(DateTime.now());

      final snapshot = await FirebaseFirestore.instance
          .collection('employeeDetails')
          .get();

      todayBirthdays = snapshot.docs
          .where((doc) {
        final dob = doc['dob'];
        if (dob == null || dob == "") return false;

        final formattedDob = DateFormat('yyyy-MM-dd').parse(dob);
        return DateFormat('MM-dd').format(formattedDob) == today;
      })
          .map((doc) => "${doc['name']} (${doc['dob']})")
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      todayBirthdays = [];
      notifyListeners();
    }
  }
}

