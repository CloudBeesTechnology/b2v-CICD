import 'package:b2v_admin_panel/utils/contant.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/leave_model.dart';
import '../models/permission_model.dart';
import '../provider/report_provider.dart';
import '../utils/height_width.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime? startDate;
  DateTime? endDate;
  int selectedTabIndex = 0;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

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


  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr; // fallback if parsing fails
    }
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


  int _calculateTotalLeaveDays(List<Leave> leaves) {
    int total = 0;
    for (var leave in leaves) {
      final days = int.tryParse(leave.daysTaken ?? '');
      if (days != null) {
        total += days;
      }
    }
    return total;
  }




  Widget buildTabs() {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    return Row(
      children: [
        // Leave Report Tab
        GestureDetector(
          onTap: () async {
            setState(() {
              selectedTabIndex = 0;
              isLoading = true;
            });

            final hasFilters = startDate != null && endDate != null && searchController.text.trim().isNotEmpty;

            if (hasFilters) {
              await reportProvider.fetchFiltered(
                isLeave: true,
                start: startDate,
                end: endDate,
                empId: searchController.text.toUpperCase().trim(),
              );
            }

            setState(() => isLoading = false);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selectedTabIndex == 0 ? const Color(0xFFD7ECFB) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Leave Report',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedTabIndex == 0 ? Colors.black : Colors.black87,
              ),
            ),
          ),
        ),
         SizedBox(width: SizeConfig.height(12)),
        // Permission Report Tab
        GestureDetector(
          onTap: () async {
            setState(() {
              selectedTabIndex = 1;
              isLoading = true;
            });

            final hasFilters = startDate != null && endDate != null && searchController.text.trim().isNotEmpty;

            if (hasFilters) {
              await reportProvider.fetchFiltered(
                isLeave: false,
                start: startDate,
                end: endDate,
                empId: searchController.text.toUpperCase().trim(),
              );
            }

            setState(() => isLoading = false);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selectedTabIndex == 1 ? const Color(0xFFD7ECFB) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Permission Report',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedTabIndex == 1 ? Colors.black : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildLeaveTable(List<Leave> leaves) {
    if (leaves.isEmpty) {
      return const Center(
        child: Text(
          'No leave data for the selected period.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              dataRowHeight: 40,
              headingRowHeight: 40,
              columns: const [
                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('From', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('To', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Days', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: leaves.map((leave) {
                return DataRow(cells: [
                  DataCell(Text(leave.empName ?? leave.empID)),
                  DataCell(Text(leave.leaveType ?? '')),
                  DataCell(Text(_formatDate(leave.startDate))),
                  DataCell(Text(_formatDate(leave.endDate))),
                  DataCell(Text(leave.daysTaken ?? '')),
                ]);
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Total Leave Days: ${_calculateTotalLeaveDays(leaves)}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }



// Permission Report Table Widget
  Widget _buildPermissionTable(List<Permission> permissions) {

    if (permissions.isEmpty) {
      return const Center(
        child: Text(
          'No permission data for the selected period.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }


    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        dataRowHeight: 40,
        headingRowHeight: 40,
        columns: const [
          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('From', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('To', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Hours', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: permissions.map((permission) {
          return DataRow(cells: [
            DataCell(Text(permission.empName ?? permission.empID)),
            DataCell(Text(_formatDate(permission.date))),
            DataCell(Text(permission.fromTime ?? '')),
            DataCell(Text(permission.toTime ?? '')),
            DataCell(Text(permission.totalHours ?? '')), // Using the totalHours directly from the data
          ]);
        }).toList(),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    final hasFilters = startDate != null && endDate != null && searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Report', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter controls (same as before)
            Row(
              children: [
                buildDateField("Start Date", startDate, () => pickDate(isStart: true)),
                 SizedBox(width: SizeConfig.width(8)),
                buildDateField("End Date", endDate, () => pickDate(isStart: false)),
                 SizedBox(width: SizeConfig.width(8)),
                Expanded(
                  child: SizedBox(
                    height: SizeConfig.height(42),
                    child: TextField(
                      controller: searchController,
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
                            onPressed: () async {
                              setState(() => isLoading = true);
                              await Provider.of<ReportProvider>(context, listen: false).fetchFiltered(
                                isLeave: selectedTabIndex == 0,
                                start: startDate,
                                end: endDate,
                                empId: searchController.text.toUpperCase().trim(),
                              );
                              setState(() => isLoading = false);
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
             SizedBox(height: SizeConfig.height(24)),
            // Tabs (same as before)
            buildTabs(),

             SizedBox(height: SizeConfig.height(24)),
            // Content area
            Expanded(
              child: isLoading
                  ?  Center(child: CircularProgressIndicator(color: appColor,))
                  : hasFilters
                  ? (selectedTabIndex == 0
                  ? _buildLeaveTable(reportProvider.leaves)
                  : _buildPermissionTable(reportProvider.permissions))
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     SizedBox(height: SizeConfig.height(16)),
                    Text(
                      'Select date range and enter Employee ID',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                     SizedBox(height: SizeConfig.height(8)),
                    Text(
                      'to view report data',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

