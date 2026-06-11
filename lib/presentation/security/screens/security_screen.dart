import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield, color: AppColors.primary, size: 24),
                      SizedBox(width: 8),
                      Text('Security Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SecurityTile(icon: Icons.check_circle, label: 'NetCut Protection', status: 'Protected', color: AppColors.success),
                  _SecurityTile(icon: Icons.warning, label: 'Rogue Devices', status: '2 Detected', color: AppColors.warning),
                  _SecurityTile(icon: Icons.check_circle, label: 'Firewall', status: 'Active', color: AppColors.success),
                  _SecurityTile(icon: Icons.check_circle, label: 'DoS Protection', status: 'Enabled', color: AppColors.success),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Security Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(8, (i) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(i % 2 == 0 ? Icons.warning_amber : Icons.info_outline, color: i % 2 == 0 ? AppColors.warning : AppColors.info),
              title: Text(['Unauthorized login attempt','New device connected','Firewall rule updated','Failed authentication','Port scan detected','MAC address changed','VPN connected','Admin login'][i]),
              subtitle: Text('${DateTime.now().subtract(Duration(hours: i)).toString().substring(11, 16)} • Router-${(i % 3) + 1}'),
              trailing: const Icon(Icons.chevron_left, color: Colors.grey),
            ),
          )),
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon; final String label; final String status; final Color color;
  const _SecurityTile({required this.icon, required this.label, required this.status, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
