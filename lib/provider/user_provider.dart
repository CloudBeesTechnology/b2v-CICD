import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../models/access_control_model.dart';
import '../models/employee_detail_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  EmployeeDetails? _currentUserDetails;
  AccessControl? _accessControl;
  bool _isLoading = false;

  EmployeeDetails? get currentUserDetails => _currentUserDetails;
  AccessControl? get accessControl => _accessControl;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrentUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Step 1: Get user document from users collection
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data();
      final email = userData?['email'] as String?;
      final empID = userData?['empID'] as String?;

      if (email == null || empID == null) return;

      // Step 2: Get access control data
      final accessQuery = await _firestore.collection('accessControl')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (accessQuery.docs.isNotEmpty) {
        _accessControl = AccessControl.fromMap(accessQuery.docs.first.data());
      }

      // Step 3: Get employee details
      final empQuery = await _firestore.collection('employeeDetails')
          .where('empID', isEqualTo: empID)
          .limit(1)
          .get();

      if (empQuery.docs.isNotEmpty) {
        _currentUserDetails = EmployeeDetails.fromMap(empQuery.docs.first.data());
      }
    } catch (e, st) {
      _logger.e('Error fetching user data', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}