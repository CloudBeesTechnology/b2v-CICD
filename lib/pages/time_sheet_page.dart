import 'package:b2v_admin_panel/pages/task_detail_view_page.dart';
import 'package:b2v_admin_panel/utils/contant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../provider/task_provider.dart';
import '../utils/height_width.dart';

class TimeSheetPage extends StatefulWidget {
  const TimeSheetPage({super.key});

  @override
  State<TimeSheetPage> createState() => _TimeSheetPageState();
}

class _TimeSheetPageState extends State<TimeSheetPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';


  String formatDate(String dateStr) {
    try {
      final DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  void initState() {
    super.initState();
    print('🟢 initState called');
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (taskProvider.todayTasks.isEmpty &&
          taskProvider.rejectedTasks.isEmpty &&
          taskProvider.approvedTasks.isEmpty) {
        taskProvider.fetchTasks(forceRefresh: true);
      }
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    // ✅ Move filtering logic here
    final filteredTasks = taskProvider.todayTasks.where((task) {
      return task.empId.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeSheet'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ... your search field ...
          Center(
            child: SizedBox(
              width: SizeConfig.width(260),
              height: SizeConfig.height(35),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Emp ID/Name',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Rejected'),
              Tab(text: 'Approved'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(taskProvider.todayTasks),
                _buildTaskList(taskProvider.rejectedTasks),
                _buildTaskList(taskProvider.approvedTasks),
              ],
            ),

          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<TaskItem> taskList) {

    final filtered = taskList.where((task) {
      return task.empId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (Provider.of<TaskProvider>(context).isLoading) {
      return  Center(child: CircularProgressIndicator(color: appColor,));
    }

    if (filtered.isEmpty) {
      return const Center(child: Text('No matching tasks found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return GestureDetector(
          onTap: item.status == 'Rejected'
              ? null
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailPage(
                  empId: item.empId,
                  date: item.date,
                  descriptions: List<String>.from(item.description),
                  // status: item.status,
                  // managerRemarks: item.managerRemarks,
                ),
              ),
            );
          },
          child: Opacity(
            opacity: item.status == 'Rejected' ? 1.0 : 1.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: SizeConfig.height(24),
                    backgroundImage: item.profilePhoto != null
                        ? NetworkImage(item.profilePhoto!)
                        : null,
                    child: item.profilePhoto == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                   SizedBox(width: SizeConfig.width(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emp id  ${item.empId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                         SizedBox(height: SizeConfig.height(4)),
                        Text(item.formattedTotal, style: const TextStyle(color: Colors.grey)),
                         SizedBox(height: SizeConfig.height(5)),
                        Text(formatDate(item.date), style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}




