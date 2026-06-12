import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';
import '../providers/dashboard_provider.dart';

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
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(conn),
            const SizedBox(height: 20),
            _buildSectionTitle('حالة الراوتر'),
            const SizedBox(height: 12),
            _buildRouterStats(d),
            const SizedBox(height: 24),
            _buildSectionTitle('الخدمات'),
            const SizedBox(height: 12),
            _buildServiceGrid(context, d),
            if (d.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(d.error!, style: const TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RouterConnectionState conn) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.router_rounded, size: 36, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conn.identity.isNotEmpty ? conn.identity : 'نظام إدارة MikroTik',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conn.ip.isNotEmpty ? conn.ip : 'غير متصل',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: conn.isConnected
                    ? Colors.greenAccent.withOpacity(0.3)
                    : Colors.redAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: conn.isConnected ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    conn.isConnected ? 'متصل' : 'غير متصل',
                    style: TextStyle(
                      color: conn.isConnected ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildRouterStats(DashboardState d) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _InfoCard(
          title: 'حرارة الجهاز',
          value: d.temperature > 0 ? '${d.temperature}°C' : '--',
          icon: Icons.thermostat,
          color: Colors.orange,
        ),
        _InfoCard(
          title: 'المعالج',
          value: '${d.cpuUsage}%',
          icon: Icons.memory,
          color: AppColors.primary,
        ),
        _InfoCard(
          title: 'الذاكرة',
          value: d.internetSpeed,
          icon: Icons.speed,
          color: AppColors.success,
        ),
        _InfoCard(
          title: 'مدة التشغيل',
          value: d.uptime,
          icon: Icons.timer,
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildServiceGrid(BuildContext context, DashboardState d) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        _ServiceCard(
          title: 'Hotspot',
          subtitle: '${d.onlineUsers} متصل',
          icon: Icons.wifi,
          color: AppColors.primary,
          onTap: () => context.go('/user-manager'),
        ),
        _ServiceCard(
          title: 'PPPoE',
          subtitle: '${d.expiredUsers} متصل',
          icon: Icons.lan,
          color: AppColors.success,
          onTap: () => context.go('/pppoe'),
        ),
        _ServiceCard(
          title: 'إدارة المستخدمين',
          subtitle: 'إضافة - حذف - بروفايلات',
          icon: Icons.admin_panel_settings,
          color: AppColors.accent,
          onTap: () => context.go('/user-manager'),
        ),
        _ServiceCard(
          title: 'النسخ الاحتياطي',
          subtitle: 'نسخ وحفظ',
          icon: Icons.backup,
          color: AppColors.warning,
          onTap: () => context.go('/backup'),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _InfoCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
