import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  List<Map<String, String>> _firewallRules = [];
  List<Map<String, String>> _dhcpLeases = [];
  List<Map<String, String>> _logEntries = [];
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
      final firewall = await conn.service!.hotspot.getFirewallRules();
      final dhcp = await conn.service!.hotspot.getDHCPLeases();
      final logs = await conn.service!.hotspot.getLogEntries();
      setState(() {
        _firewallRules = firewall;
        _dhcpLeases = dhcp;
        _logEntries = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'خطأ في جلب البيانات: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأمان'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
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
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildStatusCards(),
                      const SizedBox(height: 16),
                      _buildFirewallSection(),
                      const SizedBox(height: 16),
                      _buildDHCPSection(),
                      const SizedBox(height: 16),
                      _buildLogSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _StatusCard(
          title: 'قواعد Firewall',
          value: '${_firewallRules.length}',
          icon: Icons.shield,
          color: AppColors.success,
        ),
        _StatusCard(
          title: 'أجهزة DHCP',
          value: '${_dhcpLeases.length}',
          icon: Icons.devices,
          color: AppColors.primary,
        ),
        _StatusCard(
          title: 'سجل الأحداث',
          value: '${_logEntries.length}',
          icon: Icons.article,
          color: AppColors.warning,
        ),
        _StatusCard(
          title: 'الحالة',
          value: 'نشط',
          icon: Icons.check_circle,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildFirewallSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('قواعد Firewall', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_firewallRules.length} قاعدة', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            if (_firewallRules.isEmpty)
              const Center(child: Text('لا توجد قواعد', style: TextStyle(color: Colors.grey)))
            else
              ..._firewallRules.take(10).map((rule) {
                final chain = rule['chain'] ?? '';
                final action = rule['action'] ?? '';
                final srcAddr = rule['src-address'] ?? '';
                final comment = rule['comment'] ?? '';

                return ListTile(
                  dense: true,
                  leading: Icon(
                    action == 'accept' ? Icons.check_circle : Icons.block,
                    color: action == 'accept' ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                  title: Text('$chain → $action', style: const TextStyle(fontSize: 13)),
                  subtitle: Text(
                    srcAddr.isNotEmpty ? 'Source: $srcAddr' : comment,
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildDHCPSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.devices, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('أجهزة DHCP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_dhcpLeases.length} جهاز', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            if (_dhcpLeases.isEmpty)
              const Center(child: Text('لا توجد أجهزة', style: TextStyle(color: Colors.grey)))
            else
              ..._dhcpLeases.take(10).map((lease) {
                final address = lease['address'] ?? '';
                final mac = lease['mac-address'] ?? '';
                final host = lease['host-name'] ?? 'غير معروف';
                final active = lease['status'] == 'bound';

                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: active
                        ? AppColors.success.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    radius: 14,
                    child: Icon(
                      Icons.device_hub,
                      color: active ? AppColors.success : Colors.grey,
                      size: 16,
                    ),
                  ),
                  title: Text(host, style: const TextStyle(fontSize: 13)),
                  subtitle: Text('$address • $mac', style: const TextStyle(fontSize: 10)),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildLogSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.article, color: AppColors.warning),
                const SizedBox(width: 8),
                const Text('سجل الأحداث', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_logEntries.length} سجل', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            if (_logEntries.isEmpty)
              const Center(child: Text('لا توجد سجلات', style: TextStyle(color: Colors.grey)))
            else
              ..._logEntries.take(15).map((log) {
                final topic = log['topic'] ?? '';
                final message = log['message'] ?? '';
                final time = log['time'] ?? '';

                return ListTile(
                  dense: true,
                  leading: Icon(
                    _getLogIcon(topic),
                    color: _getLogColor(topic),
                    size: 16,
                  ),
                  title: Text(topic, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                  trailing: Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              }),
          ],
        ),
      ),
    );
  }

  IconData _getLogIcon(String topic) {
    if (topic.contains('firewall') || topic.contains('filter')) return Icons.shield;
    if (topic.contains('system')) return Icons.settings;
    if (topic.contains('interface')) return Icons.wifi;
    if (topic.contains('hotspot')) return Icons.wifi_tethering;
    return Icons.article;
  }

  Color _getLogColor(String topic) {
    if (topic.contains('error') || topic.contains('critical')) return Colors.red;
    if (topic.contains('warning')) return Colors.orange;
    return AppColors.primary;
  }
}

class _StatusCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatusCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
