import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final conn = ref.watch(routerConnectionProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('الإعدادات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildProfileSection(ref, conn),
          const SizedBox(height: 16),
          _buildAppearanceSection(ref, s),
          const SizedBox(height: 16),
          _buildNotificationSection(ref, s),
          const SizedBox(height: 16),
          _buildRouterSection(conn),
          const SizedBox(height: 16),
          _buildAboutSection(),
          const SizedBox(height: 16),
          _buildLogoutSection(ref),
        ],
      ),
    );
  }

  Widget _buildProfileSection(WidgetRef ref, RouterConnectionState conn) {
    final auth = ref.watch(authProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الحساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              title: Text(auth.email ?? 'مستخدم'),
              subtitle: const Text('مدير النظام'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(WidgetRef ref, SettingsState s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('المظهر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('الوضع الليلي'),
              subtitle: const Text('تبديل بين الوضع الفاتح والداكن'),
              secondary: Icon(
                s.darkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary,
              ),
              value: s.darkMode,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleDarkMode(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(WidgetRef ref, SettingsState s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الإشعارات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('إشعارات التطبيق'),
              subtitle: const Text('استلام إشعارات فورية'),
              secondary: const Icon(Icons.notifications, color: AppColors.primary),
              value: s.notificationsEnabled,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotifications(),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('تحديث تلقائي'),
              subtitle: Text('كل ${s.refreshInterval} ثانية'),
              secondary: const Icon(Icons.refresh, color: AppColors.primary),
              value: s.autoRefresh,
              onChanged: (_) => ref.read(settingsProvider.notifier).toggleAutoRefresh(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouterSection(RouterConnectionState conn) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الراوتر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: conn.isConnected
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.error.withValues(alpha: 0.2),
                child: Icon(
                  Icons.router,
                  color: conn.isConnected ? AppColors.success : AppColors.error,
                ),
              ),
              title: Text(conn.identity.isNotEmpty ? conn.identity : 'غير متصل'),
              subtitle: Text(conn.isConnected ? conn.ip : 'لا يوجد اتصال'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: conn.isConnected
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conn.isConnected ? 'متصل' : 'غير متصل',
                  style: TextStyle(
                    fontSize: 12,
                    color: conn.isConnected ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('حول التطبيق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.primary),
              title: Text('MikroTik ISP Manager Pro'),
              subtitle: Text('الإصدار 1.0.0'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
        onTap: () {
          ref.read(routerConnectionProvider.notifier).disconnect();
          ref.read(authProvider.notifier).signOut();
        },
      ),
    );
  }
}
