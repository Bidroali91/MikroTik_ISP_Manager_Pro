import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(icon: const Icon(Icons.done_all), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 20,
        itemBuilder: (_, i) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: [AppColors.error, AppColors.warning, AppColors.info, AppColors.success][i % 4].withOpacity(0.2),
                  child: Icon([Icons.error, Icons.warning, Icons.info, Icons.check_circle][i % 4],
                    color: [AppColors.error, AppColors.warning, AppColors.info, AppColors.success][i % 4], size: 20),
                ),
                if (i < 3) Positioned(top: 0, right: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle))),
              ],
            ),
            title: Text(['Router Disconnected','User Expired','Payment Received','Backup Complete','Session Timeout','New Update Available','Security Alert','Low Disk Space'][i % 8]),
            subtitle: Text('${DateTime.now().subtract(Duration(minutes: i * 15)).toString().substring(11, 16)} • ${i < 3 ? "Just now" : "${i * 15}m ago"}'),
            trailing: i < 3 ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Text('NEW', style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold))) : null,
          ),
        ),
      ),
    );
  }
}
