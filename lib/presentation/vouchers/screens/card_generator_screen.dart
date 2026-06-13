import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/voucher_provider.dart';

/// شاشة توليد الكروت بأسلوب "متروكيك": معاينة حيّة + خيارات متقدّمة.
class CardGeneratorScreen extends ConsumerStatefulWidget {
  const CardGeneratorScreen({super.key});

  @override
  ConsumerState<CardGeneratorScreen> createState() => _CardGeneratorScreenState();
}

class _CardGeneratorScreenState extends ConsumerState<CardGeneratorScreen> {
  final _networkC = TextEditingController(text: 'شبكة همم');
  final _prefixC = TextEditingController();
  final _notesC = TextEditingController();
  int _usernameDigits = 6;
  int _passwordDigits = 0;
  int _count = 5;
  int _durationHours = 24;
  final double _price = 0;
  bool _bindFirstUse = true;
  String? _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voucherProvider.notifier).loadVouchers();
    });
  }

  @override
  void dispose() {
    _networkC.dispose();
    _prefixC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(voucherProfilesProvider);
    final state = ref.watch(voucherProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('طباعة مجموعة بطاقات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _preview(),
          const SizedBox(height: 20),
          profilesAsync.when(
            data: (profiles) => _profileDropdown(profiles),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => _profileDropdown(const []),
          ),
          _numberRow('عدد أرقام اسم المستخدم', _usernameDigits, 3, 10,
              (v) => setState(() => _usernameDigits = v)),
          _numberRow('عدد أرقام كلمة السر (0=بدون)', _passwordDigits, 0, 10,
              (v) => setState(() => _passwordDigits = v)),
          _textField('بادئة الكرت', _prefixC, hint: 'لا يوجد'),
          _numberRow('عدد الكروت', _count, 1, 200,
              (v) => setState(() => _count = v), step: 1),
          _textField('اسم الشبكة', _networkC),
          _numberRow('مدة الكرت (ساعة)', _durationHours, 1, 720,
              (v) => setState(() => _durationHours = v), step: 1),
          SwitchListTile(
            title: const Text('ربط عند أول استخدام'),
            value: _bindFirstUse,
            activeThumbColor: AppColors.magenta,
            onChanged: (v) => setState(() => _bindFirstUse = v),
          ),
          _textField('ملاحظات (هاتف أو سعر)', _notesC),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: state.isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.add),
              label: Text(state.isLoading ? 'جارٍ التوليد...' : 'بدأ الإضافة'),
              onPressed: state.isLoading ? null : _generate,
            ),
          ),
        ],
      ),
    );
  }

  // معاينة حيّة للكرت
  Widget _preview() {
    final prefix = _prefixC.text.trim();
    final sampleUser = '$prefix${'1' * _usernameDigits}';
    final samplePass = _passwordDigits > 0 ? '2' * _passwordDigits : sampleUser;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 6)],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 10, color: AppColors.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_networkC.text.trim().isEmpty ? 'اسم الشبكة' : _networkC.text.trim(),
                        style: const TextStyle(
                            color: AppColors.cardRed,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _previewRow('اسم المستخدم', sampleUser),
                    _previewRow('كلمة السر', samplePass),
                    _previewRow('مدة الكرت', '$_durationHours ساعة'),
                    if (_notesC.text.trim().isNotEmpty)
                      _previewRow('', _notesC.text.trim()),
                  ],
                ),
              ),
            ),
            Container(
              width: 40,
              decoration: const BoxDecoration(color: AppColors.accent),
              child: const Icon(Icons.wifi, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (label.isNotEmpty)
            Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _profileDropdown(List<Map<String, String>> profiles) {
    final items = profiles.map((p) => p['name'] ?? '').where((e) => e.isNotEmpty).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(flex: 2, child: Text('اختر باقة يوزرمنجر')),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              initialValue: _profile,
              isExpanded: true,
              hint: const Text('الباقة'),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _profile = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberRow(String label, int value, int min, int max, ValueChanged<int> onCh,
      {int step = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > min ? () => onCh(value - step) : null,
          ),
          SizedBox(width: 44, child: Text('$value', textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < max ? () => onCh(value + step) : null,
          ),
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController c, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label, hintText: hint),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  void _generate() async {
    if (_profile == null) {
      _snack('اختر باقة يوزرمنجر أولًا', false);
      return;
    }
    final err = await ref.read(voucherProvider.notifier).generateCards(
          count: _count,
          prefix: _prefixC.text.trim(),
          usernameDigits: _usernameDigits,
          passwordDigits: _passwordDigits,
          profile: _profile!,
          profileName: _profile!,
          durationHours: _durationHours,
          price: _price,
          networkName: _networkC.text.trim(),
          bindFirstUse: _bindFirstUse,
          notes: _notesC.text.trim(),
        );
    _snack(err == null ? 'تم توليد $_count كرت بنجاح' : 'خطأ: $err', err == null);
  }

  void _snack(String msg, bool ok) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: ok ? AppColors.success : AppColors.error),
    );
  }
}
