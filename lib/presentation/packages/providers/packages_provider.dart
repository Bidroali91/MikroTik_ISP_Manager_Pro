import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/router_connection_provider.dart';

class PackagesState {
  final List<Map<String, String>> packages;
  final bool isLoading;
  final String? error;

  const PackagesState({
    this.packages = const [],
    this.isLoading = false,
    this.error,
  });

  PackagesState copyWith({
    List<Map<String, String>>? packages,
    bool? isLoading,
    String? error,
  }) {
    return PackagesState(
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PackagesNotifier extends StateNotifier<PackagesState> {
  final RouterConnectionState _conn;
  PackagesNotifier(this._conn) : super(const PackagesState());

  Future<void> load() async {
    if (!_conn.isConnected || _conn.service == null) {
      state = state.copyWith(error: 'غير متصل بالراوتر');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _conn.service!.voucher.getVoucherProfiles();
      // استبعاد البروفايل الافتراضي
      final filtered = list.where((p) => (p['name'] ?? '') != 'default').toList();
      state = state.copyWith(packages: filtered, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'خطأ في الجلب: $e');
    }
  }

  /// إضافة باقة: rateLimit مثل "2M/2M"، sessionTimeout بالساعات.
  Future<String?> addPackage({
    required String name,
    required String rateLimit,
    required int sessionHours,
  }) async {
    if (_conn.service == null) return 'غير متصل بالراوتر';
    final err = await _conn.service!.hotspot.addProfile(
      name,
      rateLimit: rateLimit.isEmpty ? null : 'rate-limit=$rateLimit',
      sessionTimeout: sessionHours > 0 ? sessionHours * 3600 : null,
    );
    if (err == null) await load();
    return err;
  }

  Future<String?> removePackage(String id) async {
    if (_conn.service == null) return 'غير متصل بالراوتر';
    final err = await _conn.service!.hotspot.removeProfile(id);
    if (err == null) await load();
    return err;
  }
}

final packagesProvider =
    StateNotifierProvider<PackagesNotifier, PackagesState>((ref) {
  final conn = ref.watch(routerConnectionProvider);
  return PackagesNotifier(conn);
});
