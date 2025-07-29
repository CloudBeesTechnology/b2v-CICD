import 'package:b2v_admin_panel/pages/attendance_page.dart';
import 'package:b2v_admin_panel/pages/home_page.dart';
import 'package:b2v_admin_panel/pages/leave_page.dart';
import 'package:b2v_admin_panel/pages/report_page.dart';
import 'package:b2v_admin_panel/pages/time_sheet_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;
  const NavigationScreen({super.key, this.initialIndex = 0});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late List<Widget> screens;
  late int _selectedIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    screens = [
      const HomePage(),
      const LeavePage(),
      const AttendancePage(),
      const TimeSheetPage(),
      const ReportPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex], // Use _selectedIndex, not currentIndex
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFD5ECFA),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black87,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Leave"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.watch_later), label: "Time sheet"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Report"),
        ],
      ),
    );
  }
}
