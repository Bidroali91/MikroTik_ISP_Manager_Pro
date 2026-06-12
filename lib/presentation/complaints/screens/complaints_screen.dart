import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/complaints_provider.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(complaintsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الشكاوى'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'مفتوحة (${s.openComplaints.length})'),
            Tab(text: 'قيد المراجعة (${s.inProgressComplaints.length})'),
            Tab(text: 'محلولة (${s.resolvedComplaints.length})'),
          ],
        ),
      ),
      body: s.isLoading
          ? const Center(child: CircularProgressIndicator())
          : s.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(s.error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(complaintsProvider.notifier).refresh(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(s.openComplaints, 'open'),
                    _buildList(s.inProgressComplaints, 'in_progress'),
                    _buildList(s.resolvedComplaints, 'resolved'),
                  ],
                ),
    );
  }

  Widget _buildList(List<Complaint> complaints, String status) {
    if (complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status == 'resolved' ? Icons.check_circle : Icons.inbox,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'open' ? 'لا توجد شكاوى مفتوحة' :
              status == 'in_progress' ? 'لا توجد شكاوى قيد المراجعة' :
              'لا توجد شكاوى محلولة',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(complaintsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: complaints.length,
        itemBuilder: (_, i) {
          final c = complaints[i];
          final priorityColor = _getPriorityColor(c.priority);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: priorityColor.withValues(alpha: 0.2),
                child: Icon(Icons.report, color: priorityColor, size: 20),
              ),
              title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => [
                  if (status == 'open')
                    const PopupMenuItem(value: 'in_progress', child: Text('قيد المراجعة')),
                  if (status != 'resolved')
                    const PopupMenuItem(value: 'resolved', child: Text('حل المشكلة')),
                  const PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(color: AppColors.error))),
                ],
                onSelected: (v) {
                  if (v == 'delete') {
                    ref.read(complaintsProvider.notifier).deleteComplaint(c.id);
                  } else {
                    ref.read(complaintsProvider.notifier).updateStatus(c.id, v);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.blue;
    }
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إضافة شكوى'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: priority,
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                  DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                  DropdownMenuItem(value: 'high', child: Text('عالية')),
                ],
                onChanged: (v) => priority = v ?? 'medium',
                decoration: const InputDecoration(labelText: 'الأولوية'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                ref.read(complaintsProvider.notifier).addComplaint(
                  titleCtrl.text,
                  descCtrl.text,
                  priority,
                );
                Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
