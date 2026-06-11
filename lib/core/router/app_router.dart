import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/screens/login_screen.dart';
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

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => DashboardShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/hotspot', builder: (_, __) => const HotspotListScreen()),
          GoRoute(path: '/pppoe', builder: (_, __) => const PppoeListScreen()),
          GoRoute(path: '/sales', builder: (_, __) => const SalesDashboardScreen()),
          GoRoute(path: '/backup', builder: (_, __) => const BackupScreen()),
          GoRoute(path: '/security', builder: (_, __) => const SecurityScreen()),
          GoRoute(path: '/complaints', builder: (_, __) => const ComplaintsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/maintenance', builder: (_, __) => const MaintenanceScreen()),
          GoRoute(path: '/electricity', builder: (_, __) => const ElectricityScreen()),
          GoRoute(path: '/telegram', builder: (_, __) => const TelegramScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => _navigate(context, i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.wifi), label: Text('Hotspot')),
                NavigationRailDestination(icon: Icon(Icons.lan), label: Text('PPPoE')),
                NavigationRailDestination(icon: Icon(Icons.monetization_on), label: Text('Sales')),
                NavigationRailDestination(icon: Icon(Icons.backup), label: Text('Backup')),
                NavigationRailDestination(icon: Icon(Icons.security), label: Text('Security')),
                NavigationRailDestination(icon: Icon(Icons.report), label: Text('Complaints')),
                NavigationRailDestination(icon: Icon(Icons.notifications), label: Text('Alerts')),
                NavigationRailDestination(icon: Icon(Icons.build), label: Text('Maintenance')),
                NavigationRailDestination(icon: Icon(Icons.bolt), label: Text('Power')),
                NavigationRailDestination(icon: Icon(Icons.telegram), label: Text('Telegram')),
                NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
              ],
            ),
          Expanded(
            child: Column(
              children: [
                if (MediaQuery.of(context).size.width <= 600)
                  _buildBottomNav(context),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int get _currentIndex => 0;

  void _navigate(BuildContext context, int index) {
    final routes = ['/dashboard','/hotspot','/pppoe','/sales','/backup','/security','/complaints','/notifications','/maintenance','/electricity','/telegram','/settings'];
    if (index < routes.length) context.go(routes[index]);
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (i) => _navigate(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'Hotspot'),
        BottomNavigationBarItem(icon: Icon(Icons.lan), label: 'PPPoE'),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Sales'),
      ],
    );
  }
}
