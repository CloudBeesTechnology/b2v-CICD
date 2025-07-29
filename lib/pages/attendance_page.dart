import 'package:b2v_admin_panel/utils/contant.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/attendance_provider.dart';
import '../utils/height_width.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController _searchController = TextEditingController();

  Future<void> pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }



    String formatDate(DateTime? date, String label) {
    if (date == null) return label;
    return DateFormat('dd.MM.yyyy').format(date);
  }


  Widget buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFD9D9D9)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Text(
            formatDate(date, label),
            style: const TextStyle(color: Colors.black, fontSize: 10),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.black),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<AttendanceProvider>().fetchAttendance();
    });
  }


  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date pickers and search bar
            Row(
              children: [
                // Start Date
                buildDateField("Start Date", startDate, () => pickDate(isStart: true)),
                SizedBox(width: SizeConfig.width(8)),
                buildDateField("End Date", endDate, () => pickDate(isStart: false)),
                SizedBox(width: SizeConfig.width(8)),
                const SizedBox(width: 12),
                // Search Bar
                Expanded(
            child: SizedBox(
          height: SizeConfig.height(42),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              filled: true,
              hintStyle: const TextStyle(fontSize: 14),
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              suffixIconConstraints: const BoxConstraints(
                minHeight: 35,
                minWidth: 35,
              ),
              suffixIcon: Container(
                width: SizeConfig.width(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF007BFF),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
                ),
                child: IconButton(
                    onPressed: () {
                      final provider = context.read<AttendanceProvider>();
                      if (startDate == null && endDate == null && _searchController.text.trim().isEmpty) {
                        provider.fetchAttendance(); // Reset to today/yesterday
                      } else {
                        provider.fetchAttendance(
                          start: startDate,
                          end: endDate,
                          empId: _searchController.text.trim(),
                        );
                      }
                    },
                    icon: const Icon(Icons.search, color: Colors.white, size: 18),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
          ),
        ),
      ),
              ],
            ),
            const SizedBox(height: 20),
            // Table
            Expanded(
              child: provider.isLoading
                  ?  Center(child: CircularProgressIndicator(color: appColor,))
                  :  SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(appColor),
                    columnSpacing: 10,
                    headingRowHeight: 30,
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    columns: const [
                      DataColumn(label: Text("Empid")),
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("Check in")),
                      DataColumn(label: Text("Check Out")),
                      DataColumn(label: Text("Total hours")),
                    ],
                    rows: provider.attendanceList.map((entry) {
                      return DataRow(
                        cells: [
                          DataCell(Text(entry.empId)),
                          DataCell(Text(entry.name)),
                          DataCell(Text(entry.date)),
                          DataCell(Text(entry.checkIn ?? '0')),
                          DataCell(Text(entry.checkOut ?? '0')),
                          DataCell(Text(entry.totalHours)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              // ),
            )

          ],
        ),
      ),
    );
  }
}

