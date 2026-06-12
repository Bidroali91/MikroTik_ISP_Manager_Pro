import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';

class PppoeListScreen extends ConsumerStatefulWidget {
  const PppoeListScreen({super.key});

  @override
  ConsumerState<PppoeListScreen> createState() => _PppoeListScreenState();
}

class _PppoeListScreenState extends ConsumerState<PppoeListScreen> {
  List<Map<String, String>> _subscribers = [];
  List<Map<String, String>> _activeSessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final conn = ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) {
      setState(() {
        _isLoading = false;
        _error = 'غير متصل بالراوتر';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final subscribers = await conn.service!.pppoe.listUsers();
      final active = await conn.service!.pppoe.getActiveSessions();
      setState(() {
        _subscribers = subscribers;
        _activeSessions = active;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'خطأ في جلب البيانات: ${e.toString()}';
      });
    }
  }

  bool _isUserActive(String userName) {
    return _activeSessions.any((s) => s['user'] == userName || s['name'] == userName);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة PPPoE'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
            IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog()),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المشتركين'),
              Tab(text: 'الجلسات النشطة'),
              Tab(text: 'البروفايلات'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    children: [
                      _buildSubscribersList(),
                      _buildActiveSessions(),
                      _buildProfilesList(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSubscribersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _subscribers.length,
      itemBuilder: (_, i) {
        final u = _subscribers[i];
        final name = u['name'] ?? '';
        final profile = u['profile'] ?? 'default';
        final disabled = u['disabled'] == 'true';
        final active = _isUserActive(name);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: active
                  ? AppColors.success.withOpacity(0.2)
                  : disabled
                      ? AppColors.error.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.2),
              child: Icon(
                active ? Icons.wifi : disabled ? Icons.wifi_off : Icons.person,
                color: active
                    ? AppColors.success
                    : disabled
                        ? AppColors.error
                        : AppColors.primary,
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('$profile${active ? " • متصل" : ""}'),
            trailing: PopupMenuButton<String>(
              itemBuilder: (_) => [
                if (disabled)
                  const PopupMenuItem(value: 'enable', child: Text('تفعيل'))
                else
                  const PopupMenuItem(value: 'disable', child: Text('تعطيل')),
                const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('حذف', style: TextStyle(color: AppColors.error)),
                ),
              ],
              onSelected: (v) => _handleAction(v, u),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveSessions() {
    if (_activeSessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lan, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد جلسات نشطة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _activeSessions.length,
      itemBuilder: (_, i) {
        final s = _activeSessions[i];
        final user = s['user'] ?? s['name'] ?? '';
        final address = s['address'] ?? '--';
        final uptime = s['uptime'] ?? '--';
        final service = s['service'] ?? 'pppoe';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.success.withOpacity(0.2),
              child: const Icon(Icons.wifi, color: AppColors.success, size: 20),
            ),
            title: Text(user, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('$service • $address • uptime: $uptime'),
            trailing: IconButton(
              icon: const Icon(Icons.link_off, color: AppColors.error),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('قطع الاتصال'),
                    content: Text('هل تريد قطع اتصال $user؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('إلغاء')),
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(true),
                        child: const Text('قطع', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final conn = ref.read(routerConnectionProvider);
                  if (conn.isConnected && conn.service != null) {
                    final id = s['.id'] ?? '';
                    await conn.service!.pppoe.disconnectSession(id);
                    _loadData();
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilesList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.speed)),
            title: const Text('PPPoE Sessions', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_activeSessions.length} جلسة نشطة'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(String action, Map<String, String> user) async {
    final conn = ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) return;

    final id = user['.id'] ?? '';
    final name = user['name'] ?? '';

    switch (action) {
      case 'enable':
        await conn.service!.pppoe.enableUser(id);
        break;
      case 'disable':
        await conn.service!.pppoe.disableUser(id);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('حذف المشترك'),
            content: Text('هل أنت متأكد من حذف $name؟'),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('إلغاء')),
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(true),
                child: const Text('حذف', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await conn.service!.pppoe.removeUser(id);
        }
        break;
    }
    _loadData();
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedProfile = 'default';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إضافة مشترك PPPoE'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedProfile,
              items: const [
                DropdownMenuItem(value: 'default', child: Text('default')),
                DropdownMenuItem(value: '1M', child: Text('1M')),
                DropdownMenuItem(value: '5M', child: Text('5M')),
                DropdownMenuItem(value: '10M', child: Text('10M')),
              ],
              onChanged: (v) => selectedProfile = v ?? 'default',
              decoration: const InputDecoration(labelText: 'البروفايل'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final conn = ref.read(routerConnectionProvider);
              if (conn.isConnected && conn.service != null) {
                await conn.service!.pppoe.addUser(
                  nameCtrl.text,
                  passCtrl.text,
                  'pppoe',
                  selectedProfile,
                );
                Navigator.of(dialogCtx).pop();
                _loadData();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
