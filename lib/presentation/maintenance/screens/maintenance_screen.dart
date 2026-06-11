import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});
  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _ActionTile(icon: Icons.wifi_off, label: 'Clear Hotspot Sessions', desc: 'Remove all active hotspot sessions', onTap: () {}),
                const Divider(),
                _ActionTile(icon: Icons.delete_sweep, label: 'Remove Expired Users', desc: 'Delete expired hotspot users', onTap: () {}),
                const Divider(),
                _ActionTile(icon: Icons.restart_alt, label: 'Rebuild User Manager DB', desc: 'Reset user manager database', onTap: () {}),
                const Divider(),
                _ActionTile(icon: Icons.restart_alt, label: 'Reboot Router', desc: 'Restart the router', onTap: () {}, isDestructive: true),
              ],
            ),
          )),
          const SizedBox(height: 20),
          const Text('Maintenance History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(8, (i) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.info.withOpacity(0.2), child: const Icon(Icons.build_circle, color: AppColors.info, size: 20)),
              title: Text(['Firmware Update','Database Optimization','Log Rotation','Backup Verification','Security Patch','DNS Update','Firewall Audit','Traffic Report'][i]),
              subtitle: Text('${DateTime.now().subtract(Duration(days: i * 3)).toString().substring(0, 10)} • Completed'),
              trailing: const Icon(Icons.check_circle, color: AppColors.success),
            ),
          )),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label; final String desc; final VoidCallback onTap; final bool isDestructive;
  const _ActionTile({required this.icon, required this.label, required this.desc, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
        title: Text(label),
        content: Text('Are you sure? $desc'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(context); onTap(); }, style: ElevatedButton.styleFrom(backgroundColor: isDestructive ? AppColors.error : AppColors.primary, foregroundColor: Colors.white), child: const Text('Confirm')),
        ],
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 15)), Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
            const Icon(Icons.chevron_left, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
