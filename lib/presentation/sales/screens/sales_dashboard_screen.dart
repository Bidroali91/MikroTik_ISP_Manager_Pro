import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/sales_provider.dart';

class SalesDashboardScreen extends ConsumerStatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  ConsumerState<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends ConsumerState<SalesDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(salesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(salesProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('المبيعات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildKPIRow(s),
            const SizedBox(height: 16),
            _buildWeeklyChart(s),
            const SizedBox(height: 16),
            _buildRecentSales(s),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIRow(SalesState s) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _KpiCard(
          title: 'مبيعات اليوم',
          value: '\$${s.todayRevenue.toStringAsFixed(0)}',
          icon: Icons.today,
          color: AppColors.primary,
        ),
        _KpiCard(
          title: 'مبيعات الشهر',
          value: '\$${s.monthlyRevenue.toStringAsFixed(0)}',
          icon: Icons.calendar_month,
          color: AppColors.success,
        ),
        _KpiCard(
          title: 'الكروت المباعة',
          value: '${s.totalVouchers}',
          icon: Icons.confirmation_number,
          color: AppColors.warning,
        ),
        _KpiCard(
          title: 'آخر 7 أيام',
          value: '\$${s.weeklyData.fold(0.0, (a, b) => a + b).toStringAsFixed(0)}',
          icon: Icons.bar_chart,
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(SalesState s) {
    final maxVal = s.weeklyData.reduce((a, b) => a > b ? a : b);
    final days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مبيعات آخر 7 أيام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final value = s.weeklyData[i];
                  final height = maxVal > 0 ? (value / maxVal) * 120 : 0.0;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (value > 0)
                          Text('\$${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10)),
                        const SizedBox(height: 4),
                        Container(
                          height: height + 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(days[i], style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSales(SalesState s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('آخر المبيعات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (s.recentSales.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('لا توجد مبيعات بعد', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...s.recentSales.map((sale) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Icon(
                        sale.type == 'voucher' ? Icons.confirmation_number : Icons.wifi,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(sale.customerName.isNotEmpty ? sale.customerName : sale.profile),
                    subtitle: Text('${sale.profile} × ${sale.quantity}'),
                    trailing: Text(
                      '\$${sale.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
