import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TelegramScreen extends StatefulWidget {
  const TelegramScreen({super.key});
  @override
  State<TelegramScreen> createState() => _TelegramScreenState();
}

class _TelegramScreenState extends State<TelegramScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telegram Bot')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: AppColors.info, shape: BoxShape.circle), child: const Icon(Icons.telegram, size: 48, color: Colors.white)),
                  const SizedBox(height: 16),
                  const Text('Telegram Bot Integration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Monitor and manage your routers via Telegram', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextField(decoration: const InputDecoration(labelText: 'Bot Token', hintText: 'Enter your Telegram bot token'), controller: TextEditingController()),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.link), label: const Text('Connect Bot'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, foregroundColor: Colors.white))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Available Commands', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _CommandTile(cmd: '/info', desc: 'Router system information'),
          _CommandTile(cmd: '/active', desc: 'List active hotspot users'),
          _CommandTile(cmd: '/users', desc: 'Total users count'),
          _CommandTile(cmd: '/pppoe', desc: 'PPPoE session status'),
          _CommandTile(cmd: '/sales', desc: 'Today sales report'),
          _CommandTile(cmd: '/backup', desc: 'Create router backup'),
          _CommandTile(cmd: '/reboot', desc: 'Reboot router'),
        ],
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  final String cmd; final String desc;
  const _CommandTile({required this.cmd, required this.desc});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(cmd, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppColors.info))),
        title: Text(desc, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
