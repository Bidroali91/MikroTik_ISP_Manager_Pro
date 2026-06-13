import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_tools_provider.dart';

class NetworkToolsScreen extends ConsumerStatefulWidget {
  const NetworkToolsScreen({super.key});

  @override
  ConsumerState<NetworkToolsScreen> createState() => _NetworkToolsScreenState();
}

class _NetworkToolsScreenState extends ConsumerState<NetworkToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(networkToolsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(networkToolsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('أدوات الشبكة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(networkToolsProvider.notifier).refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.speed), text: 'المراقبة'),
            Tab(icon: Icon(Icons.settings_ethernet), text: 'المنافذ'),
            Tab(icon: Icon(Icons.devices), text: 'DHCP'),
            Tab(icon: Icon(Icons.shield), text: 'الجدار'),
            Tab(icon: Icon(Icons.article), text: 'السجلات'),
          ],
        ),
      ),
      body: state.isLoading && state.interfaces.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.interfaces.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(state.error!, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tab,
                  children: [
                    _monitorTab(state),
                    _interfacesTab(state),
                    _dhcpTab(state),
                    _firewallTab(state),
                    _logsTab(state),
                  ],
                ),
    );
  }

  // ===== المراقبة =====
  Widget _monitorTab(NetworkToolsState s) {
    final total = int.tryParse(s.resource['total-memory'] ?? '0') ?? 0;
    final free = int.tryParse(s.resource['free-memory'] ?? '0') ?? 0;
    final ramPct = total > 0 ? ((total - free) / total) : 0.0;
    final cpu = int.tryParse(s.resource['cpu-load'] ?? '0') ?? 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _gauge('استهلاك المعالج (CPU)', cpu / 100, '$cpu%', Colors.orange),
        const SizedBox(height: 16),
        _gauge('استهلاك الذاكرة (RAM)', ramPct, '${(ramPct * 100).round()}%', Colors.blue),
        const SizedBox(height: 16),
        _infoCard('معلومات النظام', {
          'النموذج': s.resource['board-name'] ?? '--',
          'الإصدار': s.resource['version'] ?? '--',
          'مدة التشغيل': s.resource['uptime'] ?? '--',
          'المعالج': s.resource['cpu'] ?? '--',
          'الحرارة': s.health['temperature'] != null ? '${s.health['temperature']}°C' : '--',
          'الفولتية': s.health['voltage'] != null ? '${s.health['voltage']}V' : '--',
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => ref.read(networkToolsProvider.notifier).refreshMonitor(),
          icon: const Icon(Icons.sync),
          label: const Text('تحديث المراقبة'),
        ),
      ],
    );
  }

  Widget _gauge(String label, double value, String text, Color color) {
    final v = value.clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 12,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, Map<String, String> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            ...rows.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(color: Colors.grey)),
                      Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ===== المنافذ =====
  Widget _interfacesTab(NetworkToolsState s) {
    if (s.interfaces.isEmpty) return _empty('لا توجد منافذ');
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: s.interfaces.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final f = s.interfaces[i];
        final disabled = f['disabled'] == 'true';
        final running = f['running'] == 'true';
        return Card(
          child: ListTile(
            leading: Icon(
              running ? Icons.lan : Icons.link_off,
              color: running ? Colors.green : Colors.grey,
            ),
            title: Text(f['name'] ?? '--'),
            subtitle: Text('${f['type'] ?? ''}  ${f['comment'] ?? ''}'),
            trailing: Switch(
              value: !disabled,
              onChanged: (v) async {
                final err = await ref
                    .read(networkToolsProvider.notifier)
                    .toggleInterface(f['.id'] ?? '', v);
                if (err != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $err'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  // ===== DHCP =====
  Widget _dhcpTab(NetworkToolsState s) {
    if (s.dhcpLeases.isEmpty) return _empty('لا توجد أجهزة متصلة');
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: s.dhcpLeases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final l = s.dhcpLeases[i];
        final bound = l['status'] == 'bound';
        return Card(
          child: ListTile(
            leading: Icon(Icons.devices,
                color: bound ? Colors.green : Colors.orange),
            title: Text(l['address'] ?? '--'),
            subtitle: Text('${l['mac-address'] ?? ''}\n${l['host-name'] ?? ''}'),
            isThreeLine: true,
            trailing: Text(l['status'] ?? '',
                style: TextStyle(color: bound ? Colors.green : Colors.orange, fontSize: 12)),
          ),
        );
      },
    );
  }

  // ===== الجدار الناري =====
  Widget _firewallTab(NetworkToolsState s) {
    if (s.firewallRules.isEmpty) return _empty('لا توجد قواعد');
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: s.firewallRules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final r = s.firewallRules[i];
        final action = r['action'] ?? '';
        final isDrop = action == 'drop' || action == 'reject';
        return Card(
          child: ListTile(
            dense: true,
            leading: Icon(isDrop ? Icons.block : Icons.check_circle,
                color: isDrop ? Colors.red : Colors.green, size: 20),
            title: Text('$action  ${r['chain'] ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(r['comment']?.isNotEmpty == true
                ? r['comment']!
                : '${r['protocol'] ?? ''} ${r['dst-port'] ?? ''}'),
          ),
        );
      },
    );
  }

  // ===== السجلات =====
  Widget _logsTab(NetworkToolsState s) {
    if (s.logs.isEmpty) return _empty('لا توجد سجلات');
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: s.logs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final l = s.logs[i];
        final topics = l['topics'] ?? '';
        final isErr = topics.contains('error') || topics.contains('critical');
        return ListTile(
          dense: true,
          leading: Icon(Icons.circle, size: 10, color: isErr ? Colors.red : Colors.blueGrey),
          title: Text(l['message'] ?? '--', style: const TextStyle(fontSize: 13)),
          subtitle: Text('${l['time'] ?? ''}  •  $topics',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        );
      },
    );
  }

  Widget _empty(String text) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
}
