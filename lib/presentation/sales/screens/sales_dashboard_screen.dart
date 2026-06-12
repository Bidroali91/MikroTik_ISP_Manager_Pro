import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class SalesDashboardScreen extends StatelessWidget {
  const SalesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.date_range), onPressed: () {}),
        IconButton(icon: const Icon(Icons.file_download), onPressed: () {}),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
            children: [
              _SalesCard(title: "Today's Sales", value: '\$1,250', change: '+12.5%', up: true),
              _SalesCard(title: 'This Month', value: '\$28,400', change: '+8.3%', up: true),
              _SalesCard(title: 'Vouchers Sold', value: '342', change: '+15.2%', up: true),
              _SalesCard(title: 'Pending', value: '\$2,100', change: '-3.1%', up: false),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weekly Revenue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: [200, 350, 280, 400, 320, 450, 380][i].toDouble(), color: AppColors.primary, width: 20)])),
                      titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][v.toInt()], style: const TextStyle(fontSize: 10))))),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    )),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Recent Sales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(10, (i) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.success.withOpacity(0.2), child: const Icon(Icons.check_circle, color: AppColors.success, size: 20)),
              title: Text('Voucher Sale #${1000 + i}'),
              subtitle: Text('${i + 1} x 1-Day • \$${((i + 1) * 5).toStringAsFixed(2)}'),
              trailing: Text(DateTime.now().subtract(Duration(hours: i)).toString().substring(11, 16), style: const TextStyle(color: Colors.grey)),
            ),
          )),
        ],
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  final String title; final String value; final String change; final bool up;
  const _SalesCard({required this.title, required this.value, required this.change, required this.up});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Icon(up ? Icons.trending_up : Icons.trending_down, color: up ? AppColors.success : AppColors.error, size: 16),
                const SizedBox(width: 4),
                Text(change, style: TextStyle(fontSize: 12, color: up ? AppColors.success : AppColors.error)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
