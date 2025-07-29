import 'package:b2v_admin_panel/provider/leave_manage_provider.dart';
import 'package:b2v_admin_panel/utils/contant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/leave_provider.dart';
import '../utils/height_width.dart';
import 'leave_details_page.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr); // expects yyyy-MM-dd
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr; // fallback to original string if parsing fails
    }
  }


  int selectedIndex = 0;

  Color get indicatorColor {
    switch (selectedIndex) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeaveManageProvider>(context, listen: false).fetchLeaves();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final leaveProvider = Provider.of<LeaveManageProvider>(context);
    return  DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Leave Management'),
          centerTitle: true,
          backgroundColor: Colors.white,
          bottom: TabBar(
            onTap: (index) {
              setState(() => selectedIndex = index);
            },
            indicatorColor: indicatorColor,
            tabs: const [
              Tab(text: 'Request'),
              Tab(text: 'Rejected'),
              Tab(text: 'Approved'),
            ],
          ),
        ),
        backgroundColor: Colors.white,

        body: TabBarView(
          children: [
            _buildLeaveListView(leaveProvider.pending,'Pending'),
            _buildLeaveListView(leaveProvider.rejected,'Rejected'),
            _buildLeaveListView(leaveProvider.approved,'Approved'),
          ],
        ),
      ),
    );
  }


  Widget _buildLeaveListView(List<Map<String, dynamic>> leaveItems, String status) {
    if (leaveItems.isEmpty) {
      return const Center(child: Text('No Leave'));
    }

    return ListView.builder(
      itemCount: leaveItems.length,
      itemBuilder: (context, index) {
        final item = leaveItems[index];
        final isPending = status == 'Pending';

        return GestureDetector(
          onTap: isPending ? () => _navigateToLeaveDetails(context, item) : null,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                color: lightGrey,
                border: Border.all(width: 1, color: Colors.grey),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListTile(
                title: Text('Emp ID: ${item['empID'] ?? ''}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${_formatDate(item['startDate'])} - ${_formatDate(item['endDate'])}',
                    ),
                    Text('Type: ${item['leaveType']}'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  void _navigateToLeaveDetails(BuildContext context, Map<String, dynamic> leaveData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaveDetailsPage(leaveData: leaveData),
      ),
    );
  }

}
