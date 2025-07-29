import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/contant.dart';

class TaskDetailPage extends StatefulWidget {
  final String empId;
  final String date;
  final List<String> descriptions;

  const TaskDetailPage({
    super.key,
    required this.empId,
    required this.date,
    required this.descriptions,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _remarkController = TextEditingController();
  bool _isSubmitting = false;

  String formatDate(String dateStr) {
    try {
      final DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> _rejectTask() async {
    if (_remarkController.text.trim().isEmpty) {
      showSuccessDialog(
        context: context,
        message: 'Please enter a remark',
        // onOkay: () {
        //   Navigator.pop(context); // Close LeaveDetails page
        // },
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('taskData')
          .where('empID', isEqualTo: widget.empId)
          .where('taskStartDate', isEqualTo: widget.date)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await FirebaseFirestore.instance
            .collection('taskData')
            .doc(docId)
            .update({
          'status': 'Rejected',
          'managerRemarks': _remarkController.text.trim(),
        });

        showSuccessDialog(
          context: context,
          message: 'Task Rejected Successfully!',
          onOkay: () {
            Navigator.pop(context); // Close LeaveDetails page
          },
        );

        // Navigator.pop(context); // Go back after update
      } else {
        showSuccessDialog(
          context: context,
          message: 'Task Not found',
          // onOkay: () {
          //   Navigator.pop(context); // Close LeaveDetails page
          // },
        );
      }
    } catch (e) {
      showSuccessDialog(
        context: context,
        message: 'Error : $e',
        // onOkay: () {
        //   Navigator.pop(context); // Close LeaveDetails page
        // },
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task detail'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${formatDate(widget.date)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text('Descriptions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.descriptions.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(widget.descriptions[index]),
                            ),
                          ],
                        ),
                      ),
                      if (index < widget.descriptions.length - 1)
                        const Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 0,
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 35),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 60,
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
            const SizedBox(height: 10),
            Center(
              child:ElevatedButton(
                onPressed: _isSubmitting ? null : _rejectTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(120, 40),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: appColor),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child:  _isSubmitting
                    ?  SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(color: appColor,),
                )
                    : Text('Reject', style: TextStyle(fontSize: 16, color: appColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
