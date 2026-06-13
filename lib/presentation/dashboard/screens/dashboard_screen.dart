import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';
import '../providers/dashboard_provider.dart';

/// لوحة تحكم بأسلوب "متروكيك": بطاقات إحصائية ملوّنة + شبكة خدمات.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(dashboardProvider);
    final conn = ref.watch(routerConnectionProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _statsPanel(d, conn),
              const SizedBox(height: 20),
              _troubleBanner(),
              const SizedBox(height: 16),
              _servicesGrid(context, d),
              if (d.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _errorCard(d.error!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // اللوحة العلوية الملوّنة
  Widget _statsPanel(DashboardState d, RouterConnectionState conn) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: () => context.go('/router-setup'),
                tooltip: 'قطع الاتصال',
              ),
              const Spacer(),
              Text(
                conn.identity.isNotEmpty ? conn.identity : (conn.ip.isNotEmpty ? conn.ip : 'غير متصل'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _tile('الحرارة', d.temperature > 0 ? '${d.temperature}°' : 'مئوية',
                  const Color(0xFFF9A825)),
              const SizedBox(width: 6),
              _tile('الفولط', '--', const Color(0xFF9E9D24)),
              const SizedBox(width: 6),
              _tile('المعالج', '${d.cpuUsage}%', const Color(0xFF00897B), big: true),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _tile('سرعة النت', conn.ip.isNotEmpty ? conn.ip : '--',
                  const Color(0xFFC2185B)),
              const SizedBox(width: 6),
              _tile('مدة التشغيل', d.uptime, const Color(0xFF1976D2)),
            ],
          ),
          const SizedBox(height: 6),
          _storageBar(d),
        ],
      ),
    );
  }

  Widget _tile(String label, String value, Color color, {bool big = false}) {
    return Expanded(
      flex: big ? 1 : 1,
      child: Container(
        height: big ? 64 : 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: big ? 18 : 12,
                    fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _storageBar(DashboardState d) {
    final ramText = d.internetSpeed; // مثل "52% RAM"
    final pct = double.tryParse(
            RegExp(r'(\d+)').firstMatch(ramText)?.group(1) ?? '0') ??
        0;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B9A),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          const Text('الذاكرة/التخزين',
              style: TextStyle(color: Colors.white, fontSize: 11)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0, 1),
              minHeight: 14,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 2),
          Text('${pct.toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _troubleBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Icon(Icons.search, size: 36, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 4),
          Text('البحث عن المشاكل',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _servicesGrid(BuildContext context, DashboardState d) {
    final items = [
      (_Svc('البرودباند', Icons.router, () => context.go('/pppoe'))),
      (_Svc('الاكتف', Icons.smartphone, () => context.go('/network-tools'))),
      (_Svc('هوتسبوت', Icons.wifi, () => context.go('/hotspot'))),
      (_Svc('يوزر منجر', Icons.people, () => context.go('/user-manager'))),
      (_Svc('نسخة/استعادة', Icons.cloud_sync, () => context.go('/backup'))),
      (_Svc('الإضافات', Icons.insights, () => context.go('/maintenance'))),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items.map((s) => _serviceCard(s)).toList(),
    );
  }

  Widget _serviceCard(_Svc s) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: s.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(s.icon, size: 38, color: const Color(0xFF1565C0)),
            const SizedBox(height: 8),
            Text(s.title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0))),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(error, style: const TextStyle(color: Colors.red))),
            TextButton(
              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
              child: const Text('إعادة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Svc {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _Svc(this.title, this.icon, this.onTap);
}
