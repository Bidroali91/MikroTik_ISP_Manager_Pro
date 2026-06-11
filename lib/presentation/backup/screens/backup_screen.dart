import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup Manager'), actions: [
        IconButton(icon: const Icon(Icons.cloud_upload), onPressed: () {}),
        IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.backup, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text('Create Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(decoration: const InputDecoration(labelText: 'Backup Name', hintText: 'MikroTik-Backup-2024'), controller: TextEditingController()),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.backup),
                      label: const Text('Create Now'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Backup History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(icon: const Icon(Icons.refresh, size: 18), onPressed: () {}, label: const Text('Refresh')),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(5, (i) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.archive)),
              title: Text('backup-${DateTime.now().subtract(Duration(days: i)).toString().substring(0, 10)}.backup'),
              subtitle: Text('${(15 - i * 2)} MB • ${i == 0 ? "Just now" : "${i}d ago"}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.download, color: AppColors.primary), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete, color: AppColors.error), onPressed: () {}),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
