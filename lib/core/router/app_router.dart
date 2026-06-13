import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/auth/providers/auth_provider.dart';
import '../../presentation/router/screens/router_setup_screen.dart';
import '../../presentation/dashboard/screens/dashboard_screen.dart';
import '../../presentation/hotspot/screens/hotspot_list_screen.dart';
import '../../presentation/pppoe/screens/pppoe_list_screen.dart';
import '../../presentation/sales/screens/sales_dashboard_screen.dart';
import '../../presentation/backup/screens/backup_screen.dart';
import '../../presentation/security/screens/security_screen.dart';
import '../../presentation/complaints/screens/complaints_screen.dart';
import '../../presentation/notifications/screens/notifications_screen.dart';
import '../../presentation/maintenance/screens/maintenance_screen.dart';
import '../../presentation/electricity/screens/electricity_screen.dart';
import '../../presentation/settings/screens/settings_screen.dart';
import '../../presentation/telegram/screens/telegram_screen.dart';
import '../../presentation/user_manager/screens/user_manager_screen.dart';
import '../../presentation/vouchers/screens/vouchers_screen.dart';
import '../../presentation/packages/screens/packages_screen.dart';
import '../../presentation/network_tools/screens/network_tools_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _navRoutes = ['/dashboard','/user-manager','/pppoe','/sales','/vouchers','/backup','/security','/complaints','/notifications','/maintenance','/electricity','/telegram','/settings','/packages','/network-tools'];

int _routeIndex(String loc) {
  for (int i = 0; i < _navRoutes.length; i++) {
    if (loc.startsWith(_navRoutes[i])) return i;
  }
  return 0;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isLoggedIn = authState.isAuthenticated;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!isLoggedIn && !loggingIn) return '/login';
      if (isLoggedIn && loggingIn) return '/router-setup';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/router-setup', builder: (_, __) => const RouterSetupScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, state, child) => DashboardShell(child: child, currentRoute: _routeIndex(state.matchedLocation)),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/user-manager', builder: (_, __) => const UserManagerScreen()),
          GoRoute(path: '/hotspot', builder: (_, __) => const HotspotListScreen()),
          GoRoute(path: '/pppoe', builder: (_, __) => const PppoeListScreen()),
          GoRoute(path: '/sales', builder: (_, __) => const SalesDashboardScreen()),
          GoRoute(path: '/vouchers', builder: (_, __) => const VouchersScreen()),
          GoRoute(path: '/backup', builder: (_, __) => const BackupScreen()),
          GoRoute(path: '/security', builder: (_, __) => const SecurityScreen()),
          GoRoute(path: '/complaints', builder: (_, __) => const ComplaintsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/maintenance', builder: (_, __) => const MaintenanceScreen()),
          GoRoute(path: '/electricity', builder: (_, __) => const ElectricityScreen()),
          GoRoute(path: '/telegram', builder: (_, __) => const TelegramScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          GoRoute(path: '/packages', builder: (_, __) => const PackagesScreen()),
          GoRoute(path: '/network-tools', builder: (_, __) => const NetworkToolsScreen()),
        ],
      ),
    ],
  );
});

class _NavItem { final IconData icon; final String text; final int index; const _NavItem(this.icon, this.text, this.index); }

const _navItems = [
  _NavItem(Icons.dashboard, 'الرئيسية', 0),
  _NavItem(Icons.people, 'إدارة المستخدمين', 1),
  _NavItem(Icons.lan, 'PPPoE', 2),
  _NavItem(Icons.monetization_on, 'المبيعات', 3),
  _NavItem(Icons.vpn_key, 'القسائم', 4),
  _NavItem(Icons.backup, 'النسخ', 5),
  _NavItem(Icons.security, 'الأمان', 6),
  _NavItem(Icons.report, 'الشكاوى', 7),
  _NavItem(Icons.notifications, 'التنبيهات', 8),
  _NavItem(Icons.build, 'الصيانة', 9),
  _NavItem(Icons.bolt, 'الكهرباء', 10),
  _NavItem(Icons.telegram, 'بوت', 11),
  _NavItem(Icons.settings, 'الإعدادات', 12),
  _NavItem(Icons.inventory_2, 'الباقات', 13),
  _NavItem(Icons.network_check, 'أدوات الشبكة', 14),
];

const _navGroups = [
  ('الشبكة', [0, 1, 2, 14]),
  ('الأعمال', [3, 4, 13, 7, 10]),
  ('النظام', [5, 6, 9, 8]),
  ('أخرى', [11, 12]),
];

class DashboardShell extends ConsumerWidget {
  final Widget child;
  final int currentRoute;
  const DashboardShell({super.key, required this.child, required this.currentRoute});

  void _navigate(BuildContext context, int i) {
    if (i < _navRoutes.length) context.go(_navRoutes[i]);
  }

  Widget _sidebar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      width: 200,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.router_rounded, size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('MikroTik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.logout, size: 20), onPressed: () => ref.read(authProvider.notifier).signOut()),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final group in _navGroups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(group.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                  ),
                  for (final i in group.$2)
                    ListTile(
                      dense: true,
                      leading: Icon(_navItems[i].icon, size: 20),
                      title: Text(_navItems[i].text, style: const TextStyle(fontSize: 14)),
                      selected: currentRoute == i,
                      selectedTileColor: theme.colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onTap: () => _navigate(context, i),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      body: Row(
        children: [
          if (isWide) _sidebar(context, ref),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isWide ? null : BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentRoute.clamp(0, 3),
        onTap: (i) => _navigate(context, i),
        items: _navItems.take(4).map((e) => BottomNavigationBarItem(icon: Icon(e.icon), label: e.text)).toList(),
      ),
    );
  }
}
