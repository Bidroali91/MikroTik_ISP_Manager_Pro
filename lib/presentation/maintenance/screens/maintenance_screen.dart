import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  bool _isExecuting = false;
  final List<Map<String, dynamic>> _history = [];

  Future<void> _clearHotspotSessions() async {
    final conn = ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) return;

    setState(() => _isExecuting = true);

    try {
      await conn.service!.hotspot.clearActiveSessions();
      final cleared = 'تم';
      setState(() {
        _history.insert(0, {
          'action': 'مسح جلسات Hotspot',
          'details': 'تم مسح $cleared جلسة',
          'time': DateTime.now(),
          'success': true,
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم مسح $cleared جلسة بنجاح'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() {
        _history.insert(0, {
          'action': 'مسح جلسات Hotspot',
          'details': 'فشل: $e',
          'time': DateTime.now(),
          'success': false,
        });
      });
    }

    setState(() => _isExecuting = false);
  }

  Future<void> _removeExpiredUsers() async {
    final conn = ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) return;

    setState(() => _isExecuting = true);

    try {
      final users = await conn.service!.hotspot.listUsers();
      final active = await conn.service!.hotspot.getActiveUsers();
      final activeNames = active.map((s) => s['user'] ?? s['name'] ?? '').toSet();

      int removed = 0;
      for (final user in users) {
        final name = user['name'] ?? '';
        final disabled = user['disabled'] == 'true';
        if (disabled && !activeNames.contains(name)) {
          final id = user['.id'] ?? '';
          if (id.isNotEmpty) {
            await conn.service!.hotspot.removeUser(id);
            removed++;
          }
        }
      }
      setState(() {
        _history.insert(0, {
          'action': 'حذف المستخدمين المنتهيين',
          'details': 'تم حذف $removed مستخدم',
          'time': DateTime.now(),
          'success': true,
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف $removed مستخدم'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() {
        _history.insert(0, {
          'action': 'حذف المستخدمين المنتهيين',
          'details': 'فشل: $e',
          'time': DateTime.now(),
          'success': false,
        });
      });
    }

    setState(() => _isExecuting = false);
  }

  Future<void> _rebootRouter() async {
    final conn = ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إعادة تشغيل الراوتر'),
        content: const Text('هل أنت متأكد؟ سي断 الاتصال مؤقتاً'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('إعادة التشغيل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isExecuting = true);

    try {
      await conn.service!.system.reboot();
      setState(() {
        _history.insert(0, {
          'action': 'إعادة تشغيل الراوتر',
          'details': 'تمت إعادة التشغيل',
          'time': DateTime.now(),
          'success': true,
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إعادة تشغيل الراوتر'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      setState(() {
        _history.insert(0, {
          'action': 'إعادة تشغيل الراوتر',
          'details': 'فشل: $e',
          'time': DateTime.now(),
          'success': false,
        });
      });
    }

    setState(() => _isExecuting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصيانة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إجراءات سريعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _ActionTile(
                    icon: Icons.wifi_off,
                    label: 'مسح جلسات Hotspot',
                    desc: 'حذف جميع الجلسات النشطة',
                    onTap: _clearHotspotSessions,
                    isLoading: _isExecuting,
                  ),
                  const Divider(),
                  _ActionTile(
                    icon: Icons.delete_sweep,
                    label: 'حذف المستخدمين المنتهيين',
                    desc: 'حذف المستخدمين المعطلين غير المتصلين',
                    onTap: _removeExpiredUsers,
                    isLoading: _isExecuting,
                  ),
                  const Divider(),
                  _ActionTile(
                    icon: Icons.restart_alt,
                    label: 'إعادة تشغيل الراوتر',
                    desc: 'إعادة تشغيل الجهاز',
                    onTap: _rebootRouter,
                    isDestructive: true,
                    isLoading: _isExecuting,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('سجل الصيانة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.build_circle, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('لا توجد عمليات بعد', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ..._history.map((h) {
              final time = h['time'] as DateTime;
              final success = h['success'] as bool;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: success
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.error.withOpacity(0.2),
                    child: Icon(
                      success ? Icons.check_circle : Icons.error,
                      color: success ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                  ),
                  title: Text(h['action']),
                  subtitle: Text('${h['details']} • ${time.hour}:${time.minute.toString().padLeft(2, '0')}'),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLoading;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.desc,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading
          ? null
          : () => showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: Text(label),
                  content: Text('هل أنت متأكد؟ $desc'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('إلغاء')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        onTap();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('تأكيد'),
                    ),
                  ],
                ),
              ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 15)),
                  Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.chevron_left, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
