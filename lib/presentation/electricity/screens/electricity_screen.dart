import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';

class ElectricityScreen extends ConsumerStatefulWidget {
  const ElectricityScreen({super.key});

  @override
  ConsumerState<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends ConsumerState<ElectricityScreen> {
  Map<String, String> _resource = {};
  Map<String, String> _health = {};
  List<Map<String, String>> _interfaces = [];
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
      final resource = await conn.service!.system.getResource();
      final health = await conn.service!.system.getHealth();
      final interfaces = await conn.service!.system.getInterfaces();
      setState(() {
        _resource = resource;
        _health = health;
        _interfaces = interfaces;
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
        title: const Text('مراقبة النظام'),
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
                      _buildSystemInfo(),
                      const SizedBox(height: 16),
                      _buildResourceCards(),
                      const SizedBox(height: 16),
                      _buildInterfacesSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSystemInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('معلومات النظام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _InfoRow(label: 'الاسم', value: _resource['identity'] ?? '--'),
            _InfoRow(label: 'الموديل', value: _resource['board-name'] ?? '--'),
            _InfoRow(label: 'الإصدار', value: _resource['version'] ?? '--'),
            _InfoRow(label: 'مدة التشغيل', value: _resource['uptime'] ?? '--'),
            _InfoRow(label: 'الحرارة', value: _health['temperature'] != null ? '${_health['temperature']}°C' : '--'),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCards() {
    final cpuLoad = int.tryParse(_resource['cpu-load'] ?? '0') ?? 0;
    final totalMem = int.tryParse(_resource['total-memory'] ?? '0') ?? 0;
    final freeMem = int.tryParse(_resource['free-memory'] ?? '0') ?? 0;
    final usedMem = totalMem - freeMem;
    final memPercent = totalMem > 0 ? ((usedMem / totalMem) * 100).round() : 0;
    final totalDisk = int.tryParse(_resource['total-hdd-space'] ?? '0') ?? 0;
    final freeDisk = int.tryParse(_resource['free-hdd-space'] ?? '0') ?? 0;
    final usedDisk = totalDisk - freeDisk;
    final diskPercent = totalDisk > 0 ? ((usedDisk / totalDisk) * 100).round() : 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _ResourceCard(
          title: 'المعالج',
          value: '$cpuLoad%',
          progress: cpuLoad / 100,
          color: cpuLoad > 80 ? Colors.red : AppColors.primary,
          icon: Icons.memory,
        ),
        _ResourceCard(
          title: 'الذاكرة',
          value: '$memPercent%',
          progress: memPercent / 100,
          color: memPercent > 80 ? Colors.red : AppColors.success,
          icon: Icons.sd_storage,
        ),
        _ResourceCard(
          title: 'القرص',
          value: '$diskPercent%',
          progress: diskPercent / 100,
          color: diskPercent > 80 ? Colors.red : AppColors.warning,
          icon: Icons.storage,
        ),
        _ResourceCard(
          title: 'الحرارة',
          value: _health['temperature'] != null ? '${_health['temperature']}°C' : '--',
          progress: _health['temperature'] != null ? (int.tryParse(_health['temperature']!) ?? 0) / 100 : 0,
          color: Colors.orange,
          icon: Icons.thermostat,
        ),
      ],
    );
  }

  Widget _buildInterfacesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('الواجهات (${_interfaces.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (_interfaces.isEmpty)
              const Center(child: Text('لا توجد واجهات', style: TextStyle(color: Colors.grey)))
            else
              ..._interfaces.map((iface) {
                final name = iface['name'] ?? '';
                final type = iface['type'] ?? '';
                final running = iface['running'] == 'true';
                final mac = iface['mac-address'] ?? '';
                final txBytes = int.tryParse(iface['tx-byte'] ?? '0') ?? 0;
                final rxBytes = int.tryParse(iface['rx-byte'] ?? '0') ?? 0;

                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: running
                        ? AppColors.success.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    child: Icon(
                      running ? Icons.wifi : Icons.wifi_off,
                      color: running ? AppColors.success : Colors.grey,
                      size: 18,
                    ),
                  ),
                  title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text('$type • $mac', style: const TextStyle(fontSize: 10)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('↑ ${_formatBytes(txBytes)}', style: const TextStyle(fontSize: 10, color: AppColors.success)),
                      Text('↓ ${_formatBytes(rxBytes)}', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title, value;
  final double progress;
  final Color color;
  final IconData icon;
  const _ResourceCard({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
