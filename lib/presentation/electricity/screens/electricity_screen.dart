import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});
  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Power Monitoring')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _PowerCard(title: 'Main Power', status: 'ON', icon: Icons.bolt, color: AppColors.powerOn, subtitle: '220V')),
              const SizedBox(width: 12),
              Expanded(child: _PowerCard(title: 'Generator', status: 'STANDBY', icon: Icons.local_gas_station, color: AppColors.generatorOn, subtitle: 'Ready')),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Voltage Monitor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: 0.92, backgroundColor: Colors.grey[300], color: AppColors.success),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('220V', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Normal Range', style: TextStyle(color: Colors.grey)),
                      Text('240V', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Power Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(6, (i) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(i % 2 == 0 ? Icons.bolt : Icons.power_off, color: i % 2 == 0 ? AppColors.powerOn : AppColors.powerOff),
              title: Text(i % 2 == 0 ? 'Power Restored' : 'Power Outage'),
              subtitle: Text('${DateTime.now().subtract(Duration(days: i * 2)).toString().substring(0, 10)} • ${i * 5}min duration'),
              trailing: Text(i % 2 == 0 ? 'Auto' : 'Manual', style: TextStyle(color: Colors.grey[500])),
            ),
          )),
        ],
      ),
    );
  }
}

class _PowerCard extends StatelessWidget {
  final String title; final String status; final IconData icon; final Color color; final String subtitle;
  const _PowerCard({required this.title, required this.status, required this.icon, required this.color, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(status, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
