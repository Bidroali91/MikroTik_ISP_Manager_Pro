import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';

class UserManagerScreen extends ConsumerStatefulWidget {
  const UserManagerScreen({super.key});

  @override
  ConsumerState<UserManagerScreen> createState() => _UserManagerScreenState();
}

class _UserManagerScreenState extends ConsumerState<UserManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, String>> _users = [];
  List<Map<String, String>> _profiles = [];
  List<Map<String, String>> _activeSessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      final users = await conn.service!.hotspot.listUsers();
      final profiles = await conn.service!.hotspot.getProfiles();
      final active = await conn.service!.hotspot.getActiveUsers();
      setState(() {
        _users = users;
        _profiles = profiles;
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

  bool _isActive(String userName) {
    return _activeSessions.any((s) => s['user'] == userName || s['name'] == userName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'المستخدمين'),
            Tab(icon: Icon(Icons.speed), text: 'البروفايلات'),
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
                  controller: _tabController,
                  children: [
                    _buildUsersTab(),
                    _buildProfilesTab(),
                  ],
                ),
    );
  }

  // ==================== المستخدمين ====================
  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'إجمالي: ${_users.length} مستخدم • ${_activeSessions.length} متصل',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة مستخدم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _users.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا يوجد مستخدمين', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _users.length,
                  itemBuilder: (_, i) {
                    final u = _users[i];
                    final name = u['name'] ?? '';
                    final profile = u['profile'] ?? 'default';
                    final disabled = u['disabled'] == 'true';
                    final active = _isActive(name);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: active
                              ? AppColors.success.withValues(alpha: 0.2)
                              : disabled
                                  ? AppColors.error.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.2),
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
                        subtitle: Text(profile),
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
                          onSelected: (v) => _handleUserAction(v, u),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _handleUserAction(String action, Map<String, String> user) async {
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
    _loadData();
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedProfile = _profiles.isNotEmpty ? _profiles.first['name'] ?? 'default' : 'default';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('إضافة مستخدم جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedProfile,
                items: _profiles.map((p) {
                  final pName = p['name'] ?? 'default';
                  return DropdownMenuItem(value: pName, child: Text(pName));
                }).toList(),
                onChanged: (v) => selectedProfile = v ?? 'default',
                decoration: const InputDecoration(labelText: 'البروفايل', prefixIcon: Icon(Icons.speed)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('أدخل اسم المستخدم وكلمة المرور'), backgroundColor: Colors.red),
                );
                return;
              }
              final conn = ref.read(routerConnectionProvider);
              if (conn.isConnected && conn.service != null) {
                final error = await conn.service!.hotspot.addUser(
                  nameCtrl.text,
                  passCtrl.text,
                  selectedProfile,
                );
                Navigator.of(dialogCtx).pop();
                if (error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $error'), backgroundColor: Colors.red),
                  );
                }
                _loadData();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // ==================== البروفايلات ====================
  Widget _buildProfilesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'إجمالي: ${_profiles.length} بروفايل',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddProfileDialog(),
                icon: const Icon(Icons.add),
                label: const Text('إضافة بروفايل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _profiles.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد بروفايلات', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _profiles.length,
                  itemBuilder: (_, i) {
                    final p = _profiles[i];
                    final name = p['name'] ?? '';
                    final rateLimit = p['rate-limit'] ?? 'غير محدود';
                    final sessionTimeout = p['session-timeout'] ?? 'غير محدود';
                    final idleTimeout = p['idle-timeout'] ?? 'غير محدود';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                          child: const Icon(Icons.speed, color: AppColors.primary, size: 20),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('السرعة: $rateLimit'),
                            Text('مدة الجلسة: $sessionTimeout'),
                            Text('الخمول: $idleTimeout'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('حذف', style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                          onSelected: (v) => _handleProfileAction(v, p),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _handleProfileAction(String action, Map<String, String> profile) async {
    final conn = ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) return;

    final id = profile['.id'] ?? '';
    final name = profile['name'] ?? '';

    switch (action) {
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('حذف البروفايل'),
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
          await conn.service!.hotspot.removeProfile(id);
        }
        break;
    }
    _loadData();
  }

  void _showAddProfileDialog() {
    final nameCtrl = TextEditingController();
    int sessionHours = 1;
    int idleMinutes = 30;
    String rateLimit = '';

    final List<Map<String, dynamic>> timeOptions = [
      {'label': 'ساعة واحدة', 'hours': 1},
      {'label': 'ساعتين', 'hours': 2},
      {'label': '3 ساعات', 'hours': 3},
      {'label': '4 ساعات', 'hours': 4},
      {'label': '5 ساعات', 'hours': 5},
      {'label': '6 ساعات', 'hours': 6},
      {'label': '8 ساعات', 'hours': 8},
      {'label': '12 ساعة', 'hours': 12},
      {'label': 'يوم كامل', 'hours': 24},
      {'label': 'يومين', 'hours': 48},
      {'label': '3 أيام', 'hours': 72},
      {'label': 'أسبوع', 'hours': 168},
      {'label': 'أسبوعين', 'hours': 336},
      {'label': 'شهر (30 يوم)', 'hours': 720},
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة بروفايل جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم البروفايل',
                    prefixIcon: Icon(Icons.label),
                    hintText: 'مثال: 1-hour, 1-week',
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('مدة الجلسة:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: timeOptions.map((opt) {
                    final isSelected = sessionHours == opt['hours'];
                    return ChoiceChip(
                      label: Text(opt['label'], style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontSize: 12,
                      )),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      onSelected: (_) => setDialogState(() => sessionHours = opt['hours']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('السرعة (اختياري):', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '512k/512k',
                    '1M/1M',
                    '2M/2M',
                    '5M/5M',
                    '10M/10M',
                    '20M/20M',
                    '50M/50M',
                    '100M/100M',
                  ].map((rate) {
                    final isSelected = rateLimit == rate;
                    return ChoiceChip(
                      label: Text(rate, style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontSize: 11,
                      )),
                      selected: isSelected,
                      selectedColor: AppColors.accent,
                      onSelected: (_) => setDialogState(() {
                        rateLimit = isSelected ? '' : rate;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('timeout الخمول: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: idleMinutes.toDouble(),
                        min: 5,
                        max: 120,
                        divisions: 23,
                        label: '$idleMinutes دقيقة',
                        onChanged: (v) => setDialogState(() => idleMinutes = v.round()),
                      ),
                    ),
                    Text('$idleMinutes دقيقة'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('أدخل اسم البروفايل'), backgroundColor: Colors.red),
                  );
                  return;
                }
                final conn = ref.read(routerConnectionProvider);
                if (conn.isConnected && conn.service != null) {
                  final sessionSeconds = sessionHours * 3600;
                  final idleSeconds = idleMinutes * 60;

                  final error = await conn.service!.hotspot.addProfile(
                    nameCtrl.text,
                    rateLimit: rateLimit,
                    sessionTimeout: sessionSeconds,
                    idleTimeout: idleSeconds,
                  );
                  Navigator.of(dialogCtx).pop();
                  if (error != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: $error'), backgroundColor: Colors.red),
                    );
                  }
                  _loadData();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }
}
