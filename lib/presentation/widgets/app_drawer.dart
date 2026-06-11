import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;
  final VoidCallback onLogout;

  const AppDrawer({super.key, required this.currentRoute, required this.onNavigate, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.accentDark], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.router, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                const Text('MikroTik ISP Manager', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Admin', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
          _DrawerItem(icon: Icons.dashboard, label: 'Dashboard', route: '/dashboard', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.wifi, label: 'Hotspot', route: '/hotspot', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.lan, label: 'PPPoE', route: '/pppoe', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.monetization_on, label: 'Sales', route: '/sales', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.backup, label: 'Backup', route: '/backup', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.security, label: 'Security', route: '/security', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.report, label: 'Complaints', route: '/complaints', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.notifications, label: 'Notifications', route: '/notifications', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.build, label: 'Maintenance', route: '/maintenance', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.bolt, label: 'Electricity', route: '/electricity', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.telegram, label: 'Telegram', route: '/telegram', current: currentRoute, onTap: onNavigate),
          _DrawerItem(icon: Icons.settings, label: 'Settings', route: '/settings', current: currentRoute, onTap: onNavigate),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: AppColors.error), title: const Text('Sign Out'), onTap: onLogout),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon; final String label; final String route; final String current; final void Function(String) onTap;
  const _DrawerItem({required this.icon, required this.label, required this.route, required this.current, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final selected = current == route;
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : null),
      title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? AppColors.primary : null)),
      selected: selected,
      onTap: () { Navigator.pop(context); onTap(route); },
    );
  }
}
