import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import '../../../core/utils/voucher_pdf.dart';
import '../../../data/models/voucher_model.dart';
import '../providers/voucher_provider.dart';

class VouchersScreen extends ConsumerStatefulWidget {
  const VouchersScreen({super.key});

  @override
  ConsumerState<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends ConsumerState<VouchersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VoucherCardOptions _cardOptions = const VoucherCardOptions();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voucherProvider.notifier).loadVouchers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voucherState = ref.watch(voucherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('القسائم'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'القسائم'),
            Tab(text: 'إنشاء قسائم'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printSelectedVouchers(voucherState.vouchers),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVoucherList(voucherState),
          _buildCreateVoucherTab(),
        ],
      ),
    );
  }

  Widget _buildVoucherList(VoucherState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.vouchers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vpn_key, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد قسائم', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.vouchers.length,
      itemBuilder: (context, index) {
        final voucher = state.vouchers[index];
        return _buildVoucherCard(voucher);
      },
    );
  }

  Widget _buildVoucherCard(VoucherModel voucher) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  voucher.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: voucher.isUsed ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    voucher.isUsed ? 'مستخدم' : 'متاح',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('كلمة المرور: ${voucher.password}'),
            Text('الملف الشخصي: ${voucher.profileName}'),
            Text('المدة: ${voucher.durationHours} ساعة'),
            Text('السعر: ${voucher.price} د.ل'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code),
                  onPressed: () => _showQRCode(voucher),
                ),
                IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () => _printVoucher(voucher),
                ),
                if (!voucher.isUsed)
                  IconButton(
                    icon: const Icon(Icons.block),
                    onPressed: () => _disableVoucher(voucher.id),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteVoucher(voucher.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateVoucherTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إنشاء قسائم جديدة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'الاسم المسبق',
                      hintText: ' voucher',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'عدد القسائم',
                      hintText: '10',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'طول كلمة المرور',
                      hintText: '8',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'السعر (د.ل)',
                      hintText: '5.0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _createVouchers,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('إنشاء القسائم'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRCode(VoucherModel voucher) {
    final qrData = 'SSID:${voucher.username}\nPASS:${voucher.password}\nPROFILE:${voucher.profileName}\nDURATION:${voucher.durationHours}h';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code - ${voucher.username}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
            ),
            const SizedBox(height: 16),
            Text('اسم المستخدم: ${voucher.username}'),
            Text('كلمة المرور: ${voucher.password}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _printVoucher(VoucherModel voucher) =>
      _openCardOptions([voucher]);

  Future<void> _printSelectedVouchers(List<VoucherModel> vouchers) {
    final available = vouchers.where((v) => !v.isUsed).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد قسائم متاحة للطباعة')),
      );
      return Future.value();
    }
    return _openCardOptions(available);
  }

  /// حوار تخصيص الكرت: إظهار/إخفاء الحقول واسم الشبكة قبل الطباعة.
  Future<void> _openCardOptions(List<VoucherModel> vouchers) async {
    var opts = _cardOptions;
    final networkC = TextEditingController(text: opts.networkName);
    final result = await showDialog<VoucherCardOptions>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          Widget toggle(String label, bool value, ValueChanged<bool> onCh) =>
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(label),
                value: value,
                onChanged: (v) => setLocal(() => onCh(v)),
              );
          return AlertDialog(
            title: const Text('تخصيص الكرت'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: networkC,
                    decoration: const InputDecoration(labelText: 'اسم الشبكة'),
                    onChanged: (v) => opts = opts.copyWith(networkName: v),
                  ),
                  const SizedBox(height: 8),
                  toggle('إظهار اسم الشبكة', opts.showNetwork,
                      (v) => opts = opts.copyWith(showNetwork: v)),
                  toggle('إظهار اسم المستخدم', opts.showUsername,
                      (v) => opts = opts.copyWith(showUsername: v)),
                  toggle('إظهار كلمة المرور', opts.showPassword,
                      (v) => opts = opts.copyWith(showPassword: v)),
                  toggle('إظهار نوع البروفايل', opts.showProfile,
                      (v) => opts = opts.copyWith(showProfile: v)),
                  toggle('إظهار السعر', opts.showPrice,
                      (v) => opts = opts.copyWith(showPrice: v)),
                  toggle('إظهار رمز QR', opts.showQr,
                      (v) => opts = opts.copyWith(showQr: v)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('طباعة'),
                onPressed: () => Navigator.pop(ctx, opts),
              ),
            ],
          );
        },
      ),
    );
    if (result != null) {
      _cardOptions = result; // حفظ الاختيار للمرة القادمة
      await _printPdf(vouchers, result);
    }
  }

  Future<void> _printPdf(List<VoucherModel> vouchers, VoucherCardOptions opts) async {
    try {
      await Printing.layoutPdf(
        name: 'vouchers_${DateTime.now().millisecondsSinceEpoch}',
        onLayout: (_) => VoucherPdf.build(vouchers, options: opts),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّرت الطباعة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _disableVoucher(String id) async {
    final error = await ref.read(voucherProvider.notifier).disableVoucher(id);
    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $error'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعطيل القسيمة'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _deleteVoucher(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف القسيمة'),
        content: const Text('هل أنت متأكد من حذف هذه القسيمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final error = await ref.read(voucherProvider.notifier).deleteVoucher(id);
      if (mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $error'), backgroundColor: Colors.red),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف القسيمة'), backgroundColor: Colors.green),
          );
        }
      }
    }
  }

  Future<void> _createVouchers() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري إنشاء القسائم...')),
    );
  }
}