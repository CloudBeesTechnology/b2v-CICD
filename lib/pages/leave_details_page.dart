import 'package:b2v_admin_panel/utils/contant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/leave_manage_provider.dart';
import '../utils/height_width.dart';

class LeaveDetailsPage extends StatefulWidget {
  final Map<String, dynamic> leaveData;

  const LeaveDetailsPage({super.key, required this.leaveData});

  @override
  State<LeaveDetailsPage> createState() => _LeaveDetailsPageState();
}

class _LeaveDetailsPageState extends State<LeaveDetailsPage> {
  final TextEditingController _remarkController = TextEditingController();
  String employeeName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployeeName();
  }

  Future<void> fetchEmployeeName() async {
    final empId = widget.leaveData['empID'];
    final snap = await FirebaseFirestore.instance
        .collection('employeeDetails')
        .where('empID', isEqualTo: empId)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      setState(() {
        employeeName = snap.docs.first['name'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        employeeName = 'Not Found';
        isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final leaveData = widget.leaveData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Details'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ?  Center(child: CircularProgressIndicator(color: appColor,))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Details table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildTableRow('Emp ID', leaveData['empID'] ?? ''),
                  _buildDivider(),
                  _buildTableRow('Leave Type', leaveData['leaveType'] ?? ''),
                  _buildDivider(),
                  _buildTableRow('Name', employeeName), // ✅ From employeeDetails
                  _buildDivider(),
                  _buildTableRow('From Date', _formatDate(leaveData['startDate'])),
                  _buildDivider(),
                  _buildTableRow('To Date', _formatDate(leaveData['endDate'])),
                  _buildDivider(),
                  _buildTableRow('Reason', leaveData['leaveReason'] ?? ''),
                ],
              ),
            ),

            // Comments
             SizedBox(height: SizeConfig.height(25)),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: SizeConfig.height(8)),
            Container(
              height: SizeConfig.height(60),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade500),
                borderRadius: BorderRadius.circular(8),
              ),
              child:  TextField(
                controller: _remarkController,
                decoration: InputDecoration(
                  hintText: 'Enter reason',
                  border: InputBorder.none,
                ),
                maxLines: 2,
              ),
            ),

            // Action buttons
            if (leaveData['leaveStatus'] == 'Pending') ...[
               SizedBox(height: SizeConfig.height(32)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateLeaveStatus(context, 'Rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize:  Size(SizeConfig.width(125), SizeConfig.height(40)),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: appColor),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text('Reject', style: TextStyle(fontSize: 16, color: appColor)),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateLeaveStatus(context, 'Approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      minimumSize:  Size(SizeConfig.width(125), SizeConfig.height(40)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Approve', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width:  SizeConfig.width(120),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
           SizedBox(width:  SizeConfig.width(16)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade300,
      indent: 16,
      endIndent: 16,
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _updateLeaveStatus(BuildContext context, String status) async {
    final docId = widget.leaveData['docId'];
    try {
      await FirebaseFirestore.instance
          .collection('leaveStatus')
          .doc(docId)
          .set({
        'adminStatus': status,
        'adminRemarks':_remarkController.text.trim(),
      }, SetOptions(merge: true));

      showSuccessDialog(
        context: context,
        message: 'Leave $status Successfully!',
        onOkay: () {
          Navigator.pop(context); // Close LeaveDetails page
        },
      );
    } catch (e) {
      showSuccessDialog(
        context: context,
        message: 'Failed to update status: $e',
        // onOkay: () {
        //   Navigator.pop(context); // Close LeaveDetails page
        // },
      );
    }
  }
}
