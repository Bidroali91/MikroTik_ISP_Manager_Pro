import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/router_connection_provider.dart';

class NetworkToolsState {
  final List<Map<String, String>> interfaces;
  final List<Map<String, String>> dhcpLeases;
  final List<Map<String, String>> logs;
  final List<Map<String, String>> firewallRules;
  final Map<String, String> resource; // CPU/RAM/uptime
  final Map<String, String> health;   // temperature/voltage
  final bool isLoading;
  final String? error;

  const NetworkToolsState({
    this.interfaces = const [],
    this.dhcpLeases = const [],
    this.logs = const [],
    this.firewallRules = const [],
    this.resource = const {},
    this.health = const {},
    this.isLoading = false,
    this.error,
  });

  NetworkToolsState copyWith({
    List<Map<String, String>>? interfaces,
    List<Map<String, String>>? dhcpLeases,
    List<Map<String, String>>? logs,
    List<Map<String, String>>? firewallRules,
    Map<String, String>? resource,
    Map<String, String>? health,
    bool? isLoading,
    String? error,
  }) {
    return NetworkToolsState(
      interfaces: interfaces ?? this.interfaces,
      dhcpLeases: dhcpLeases ?? this.dhcpLeases,
      logs: logs ?? this.logs,
      firewallRules: firewallRules ?? this.firewallRules,
      resource: resource ?? this.resource,
      health: health ?? this.health,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NetworkToolsNotifier extends StateNotifier<NetworkToolsState> {
  final RouterConnectionState _conn;
  NetworkToolsNotifier(this._conn) : super(const NetworkToolsState());

  Future<void> refresh() async {
    if (!_conn.isConnected || _conn.service == null) {
      state = state.copyWith(error: 'غير متصل بالراوتر');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    final s = _conn.service!;
    try {
      final interfaces = await _safe(() => s.system.getInterfaces());
      final leases = await _safe(() => s.hotspot.getDHCPLeases());
      final logs = await _safe(() => s.hotspot.getLogEntries());
      final firewall = await _safe(() => s.hotspot.getFirewallRules());
      final resource = await _safeMap(() => s.system.getResource());
      final health = await _safeMap(() => s.system.getHealth());
      state = state.copyWith(
        interfaces: interfaces,
        dhcpLeases: leases,
        logs: logs,
        firewallRules: firewall,
        resource: resource,
        health: health,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'خطأ في جلب البيانات: $e');
    }
  }

  /// تحديث بيانات المراقبة فقط (CPU/RAM) — للاستدعاء الدوري الخفيف.
  Future<void> refreshMonitor() async {
    if (!_conn.isConnected || _conn.service == null) return;
    final s = _conn.service!;
    final resource = await _safeMap(() => s.system.getResource());
    final health = await _safeMap(() => s.system.getHealth());
    if (mounted) state = state.copyWith(resource: resource, health: health);
  }

  Future<String?> toggleInterface(String id, bool enable) async {
    if (_conn.service == null) return 'غير متصل بالراوتر';
    final err = await _conn.service!.system.setInterfaceEnabled(id, enable);
    if (err == null) await refresh();
    return err;
  }

  Future<List<Map<String, String>>> _safe(
      Future<List<Map<String, String>>> Function() f) async {
    try {
      return await f();
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, String>> _safeMap(
      Future<Map<String, String>> Function() f) async {
    try {
      return await f();
    } catch (_) {
      return const {};
    }
  }
}

final networkToolsProvider =
    StateNotifierProvider<NetworkToolsNotifier, NetworkToolsState>((ref) {
  final conn = ref.watch(routerConnectionProvider);
  return NetworkToolsNotifier(conn);
});
