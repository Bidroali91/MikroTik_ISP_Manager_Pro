import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';

class HotspotListScreen extends ConsumerStatefulWidget {
  const HotspotListScreen({super.key});

  @override
  ConsumerState<HotspotListScreen> createState() => _HotspotListScreenState();
}

class _HotspotListScreenState extends ConsumerState<HotspotListScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, String>> _users = [];
  List<Map<String, String>> _activeSessions = [];
  List<Map<String, String>> _filtered = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
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
      final users = await conn.service!.hotspot.listUsers();
      final active = await conn.service!.hotspot.getActiveUsers();
      setState(() {
        _users = users;
        _activeSessions = active;
        _filtered = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'خطأ في جلب البيانات: ${e.toString()}';
      });
    }
  }

  bool _isActive(String userName) {
    return _activeSessions.any((s) => s['user'] == userName || s['name'] == userName);
  }

  String _getUptime(String userName) {
    for (final s in _activeSessions) {
      if (s['user'] == userName || s['name'] == userName) {
        return s['uptime'] ?? '--';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مستخدمي Hotspot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'بحث عن مستخدم...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _filtered = _users);
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() {
                _filtered = _users
                    .where((u) => (u['name'] ?? '').contains(v))
                    .toList();
              }),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUsers,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filtered.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Text('المجموع: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${_filtered.length} مستخدم',
                            style: const TextStyle(color: AppColors.primary),
                          ),
                          const Spacer(),
                          Text(
                            '${_activeSessions.length} متصل حالياً',
                            style: const TextStyle(color: AppColors.success, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }
                  final u = _filtered[i - 1];
                  final name = u['name'] ?? '';
                  final profile = u['profile'] ?? 'default';
                  final disabled = u['disabled'] == 'true';
                  final active = _isActive(name);
                  final uptime = _getUptime(name);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: active
                            ? AppColors.success.withOpacity(0.2)
                            : disabled
                                ? AppColors.error.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                        child: Icon(
                          active ? Icons.wifi : disabled ? Icons.wifi_off : Icons.person,
                          color: active
                              ? AppColors.success
                              : disabled
                                  ? AppColors.error
                                  : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '$profile${uptime.isNotEmpty ? " • uptime: $uptime" : ""}',
                      ),
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
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleAction(String action, Map<String, String> user) async {
    final conn = ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) return;

    final id = user['.id'] ?? '';
    final name = user['name'] ?? '';

    switch (action) {
      case 'enable':
        await conn.service!.hotspot.enableUser(id);
        break;
      case 'disable':
        await conn.service!.hotspot.disableUser(id);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('حذف المستخدم'),
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
          await conn.service!.hotspot.removeUser(id);
        }
        break;
    }
    _loadUsers();
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedProfile = 'default';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إضافة مستخدم Hotspot'),
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
                DropdownMenuItem(value: '1-Day', child: Text('1-Day')),
                DropdownMenuItem(value: '1-Week', child: Text('1-Week')),
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
                await conn.service!.hotspot.addUser(
                  nameCtrl.text,
                  passCtrl.text,
                  selectedProfile,
                );
                Navigator.of(dialogCtx).pop();
                _loadUsers();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
