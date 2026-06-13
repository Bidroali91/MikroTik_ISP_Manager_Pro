import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/packages_provider.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(packagesProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packagesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الباقات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(packagesProvider.notifier).load(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('باقة جديدة'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.packages.isEmpty
              ? _message(Icons.wifi_off, state.error!)
              : state.packages.isEmpty
                  ? _message(Icons.inventory_2, 'لا توجد باقات — أضف باقة جديدة')
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.packages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _packageCard(state.packages[i]),
                    ),
    );
  }

  Widget _packageCard(Map<String, String> p) {
    final rate = p['rate-limit'] ?? '';
    final timeout = p['session-timeout'] ?? '';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.inventory_2, color: Colors.blue),
        ),
        title: Text(p['name'] ?? '--',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rate.isNotEmpty) Text('السرعة: $rate'),
            if (timeout.isNotEmpty) Text('المدة: ${_fmtTimeout(timeout)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(p),
        ),
      ),
    );
  }

  String _fmtTimeout(String raw) {
    final secs = int.tryParse(raw.replaceAll('s', ''));
    if (secs == null) return raw;
    if (secs % 3600 == 0) return '${secs ~/ 3600} ساعة';
    return '${(secs / 60).round()} دقيقة';
  }

  void _showAddDialog() {
    final nameC = TextEditingController();
    final rateC = TextEditingController();
    final hoursC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('باقة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                    labelText: 'اسم الباقة', hintText: 'مثال: 1Mbps-Daily'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rateC,
                decoration: const InputDecoration(
                    labelText: 'السرعة (رفع/تنزيل)', hintText: 'مثال: 2M/2M'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hoursC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'المدة (ساعات)', hintText: 'مثال: 24'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final name = nameC.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final err = await ref.read(packagesProvider.notifier).addPackage(
                    name: name,
                    rateLimit: rateC.text.trim(),
                    sessionHours: int.tryParse(hoursC.text.trim()) ?? 0,
                  );
              _snack(err == null ? 'تمت إضافة الباقة' : 'خطأ: $err', err == null);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, String> p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الباقة'),
        content: Text('هل تريد حذف الباقة "${p['name']}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) {
      final err = await ref.read(packagesProvider.notifier).removePackage(p['.id'] ?? '');
      _snack(err == null ? 'تم حذف الباقة' : 'خطأ: $err', err == null);
    }
  }

  void _snack(String msg, bool ok) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : Colors.red),
    );
  }

  Widget _message(IconData icon, String text) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
}
