import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});
  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaints'), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog()),
      ]),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Open', icon: Icon(Icons.error_outline)),
                Tab(text: 'In Progress', icon: Icon(Icons.hourglass_top)),
                Tab(text: 'Resolved', icon: Icon(Icons.check_circle_outline)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(status: 'open'),
                  _buildList(status: 'in_progress'),
                  _buildList(status: 'resolved'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList({required String status}) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 15,
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: [AppColors.error, AppColors.warning, AppColors.success][status == 'open' ? 0 : status == 'in_progress' ? 1 : 2].withOpacity(0.2),
            child: Icon([Icons.error_outline, Icons.hourglass_top, Icons.check_circle][status == 'open' ? 0 : status == 'in_progress' ? 1 : 2],
              color: [AppColors.error, AppColors.warning, AppColors.success][status == 'open' ? 0 : status == 'in_progress' ? 1 : 2], size: 20),
          ),
          title: Text('Internet Issue #${1000 + i}'),
          subtitle: Text('Customer: User${2000 + i} • ${DateTime.now().subtract(Duration(hours: i)).toString().substring(0, 16)}'),
          trailing: const Icon(Icons.chevron_left),
        ),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('New Complaint'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(decoration: const InputDecoration(labelText: 'Customer Name')),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Submit')),
      ],
    ));
  }
}
