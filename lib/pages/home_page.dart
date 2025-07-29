import 'package:b2v_admin_panel/pages/regular_login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../provider/birthday_provider.dart';
import '../provider/employee_summary_provider.dart';
import '../provider/leave_manage_provider.dart';
import '../provider/leave_provider.dart';
import '../provider/user_provider.dart';
import '../service/auth_service.dart';
import '../utils/contant.dart';
import '../utils/height_width.dart';
import 'Navigation_page.dart';
import 'biometric_or_manual_page.dart';
import 'leave_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Optional: Navigation logic can go here
  }


  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr); // expects yyyy-MM-dd
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr; // fallback to original string if parsing fails
    }
  }


  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUserDetails == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userProvider.fetchCurrentUserData();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeSummaryProvider>(context, listen: false).fetchSummary();
    });
  }




  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final authService = context.read<AuthService>();
    final birthdayProvider = Provider.of<BirthdayProvider>(context);
    final leaveProvider = Provider.of<LeaveManageProvider>(context);
    final pendingLeaves = leaveProvider.pending;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                      radius: SizeConfig.height(24),
                        backgroundImage: userProvider.currentUserDetails?.profilePhoto != null
                            ? NetworkImage(userProvider.currentUserDetails!.profilePhoto!)
                            : null,
                        child: userProvider.currentUserDetails?.profilePhoto == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                       SizedBox(width: SizeConfig.width(12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text( userProvider.currentUserDetails?.name ?? 'Loading...', style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () async {
                      await authService.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const BioMetricOptionScreen()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
               SizedBox(height: SizeConfig.height(24)),
              // Employee summary cards
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     _buildSummaryCard(
              //         Icons.groups, "20", "Total Employees", Colors.blue),
              //     _buildSummaryCard(
              //         Icons.verified_user, "17", "Active Employee",
              //         Colors.green),
              //     _buildSummaryCard(
              //         Icons.person_off, "3", "Absent Employee", Colors.red),
              //   ],
              // ),

              buildSummaryRow(),

               SizedBox(height: SizeConfig.height(25)),

              // Leave Status
              const Text("Leave Status Overview", style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
               SizedBox(height: SizeConfig.height(8)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 10,
                  headingRowHeight: 30,
                  headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.blue.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('Emp ID')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('From')),
                    DataColumn(label: Text('To')),
                  ],
                  rows: pendingLeaves.isEmpty
                      ? [
                    DataRow(
                      cells: [
                        DataCell(SizedBox()),
                        DataCell(SizedBox()),
                        DataCell(
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'No leave request',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        DataCell(SizedBox()),
                      ],
                    )
                  ]
                      : pendingLeaves.map((leave) {
                    return DataRow(
                      cells: [
                        DataCell(Text(leave['empID'] ?? ''),
                          onTap: () => _navigateToLeavePage(),
                        ),
                        DataCell(Text(leave['leaveType'] ?? ''),
                          onTap: () => _navigateToLeavePage(),
                        ),
                        DataCell(Text(_formatDate(leave['startDate'])),
                          onTap: () => _navigateToLeavePage(),
                        ),
                        DataCell(Text(_formatDate(leave['endDate'])),
                          onTap: () => _navigateToLeavePage(),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
               SizedBox(height: SizeConfig.height(24)),
              // Birthday Celebration
              const Text("Today's Birthday", style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
               SizedBox(height: SizeConfig.height(8)),
              if (birthdayProvider.todayBirthdays.isEmpty)
                _buildInfoCard(Icons.info_outline, "No birthdays today.")
              else
                ...birthdayProvider.todayBirthdays.map(
                      (b) => _buildInfoCard(Icons.cake, b),
                ),
               SizedBox(height: SizeConfig.height(24)),
              // Holidays
              const Text("Holidays", style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
               SizedBox(height: SizeConfig.height(8)),
              _buildHolidayCard([
                {"date": "Aug 15", "title": "Independence day"},
                {"date": "Aug 27", "title": "Vinayagar Chaturthi"},
                {"date": "Oct 02", "title": "Gandhi Jayanthi"},
                {"date": "Oct 20", "title": "Diwali"},
                {"date": "Dec 25", "title": "Christmas"},
              ]),

               SizedBox(height: SizeConfig.height(24)),
              // Face ID logout,
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: const Color(0xFFD5ECFA),
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: Colors.blue,
      //   unselectedItemColor: Colors.black87,
      //   showUnselectedLabels: true,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Leave"),
      //     BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Attendance"),
      //     BottomNavigationBarItem(icon: Icon(Icons.watch_later), label: "Time sheet"),
      //     BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Report"),
      //   ],
      // ),
    );
  }


  Widget buildSummaryRow() {
    final summaryProvider = Provider.of<EmployeeSummaryProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildSummaryItem(Icons.groups,
                summaryProvider.totalEmployees.toString(), "Total Employees", Colors.blue),
          ),
          _verticalDivider(),
          Expanded(
            child: _buildSummaryItem(Icons.verified_user,
                summaryProvider.activeEmployees.toString(), "Active Employee", Colors.green),
          ),
          _verticalDivider(),
          Expanded(
            child: _buildSummaryItem(Icons.person_off,
                summaryProvider.absentEmployees.toString(), "Absent Employee", Colors.red),
          ),
        ],
      ),
    );
  }



  // Keep your helper methods outside build()
  Widget _buildSummaryItem(IconData icon, String count, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(10)
      ),
      child:Padding(
        padding:EdgeInsets.all(10) ,
        child:  Column(
          children: [
            Icon(icon, size: 36, color: color),
             SizedBox(height: SizeConfig.height(4)),
            Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
             SizedBox(height:  SizeConfig.height(2)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      )
    );
  }

  Widget _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        height:  SizeConfig.height(50),
        width:  SizeConfig.width(1),
        color: Colors.grey.shade400,
      ),
    );
  }


  void _navigateToLeavePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NavigationScreen(initialIndex: 1),
      ),
    );
  }



  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink),
        title: Text(text),
      ),
    );
  }

  Widget _buildHolidayCard(List<Map<String, String>> holidays) {
    return Container(
      decoration: BoxDecoration(
        color:lightGrey
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: holidays.map((holiday) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(holiday['date']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(holiday['title']!),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}




