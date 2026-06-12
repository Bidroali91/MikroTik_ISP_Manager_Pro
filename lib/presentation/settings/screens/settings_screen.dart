import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Appearance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark/light theme'),
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                  secondary: const Icon(Icons.dark_mode),
                ),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive alerts and updates'),
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                  secondary: const Icon(Icons.notifications),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Router Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.router),
                  title: const Text('Connected Routers'),
                  subtitle: const Text('3 routers configured'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Add New Router'),
                  subtitle: const Text('Connect a new MikroTik device'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Integrations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.telegram, color: AppColors.info),
                  title: const Text('Telegram Bot'),
                  subtitle: const Text('Configure bot token and alerts'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  subtitle: const Text('admin@mikrotik.com'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  onTap: () {},
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          const Center(child: Text('MikroTik ISP Manager Pro v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }
}
