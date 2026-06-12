import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/router_connection_provider.dart';

class DashboardState {
  final int activeUsers;
  final int onlineUsers;
  final int expiredUsers;
  final double todayRevenue;
  final double monthlyRevenue;
  final int connectedRouters;
  final int notifications;
  final int temperature;
  final int cpuUsage;
  final String internetSpeed;
  final String uptime;
  final String routerName;
  final String routerIp;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.activeUsers = 0,
    this.onlineUsers = 0,
    this.expiredUsers = 0,
    this.todayRevenue = 0,
    this.monthlyRevenue = 0,
    this.connectedRouters = 0,
    this.notifications = 0,
    this.temperature = 0,
    this.cpuUsage = 0,
    this.internetSpeed = '--',
    this.uptime = '--',
    this.routerName = '',
    this.routerIp = '',
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    int? activeUsers,
    int? onlineUsers,
    int? expiredUsers,
    double? todayRevenue,
    double? monthlyRevenue,
    int? connectedRouters,
    int? notifications,
    int? temperature,
    int? cpuUsage,
    String? internetSpeed,
    String? uptime,
    String? routerName,
    String? routerIp,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      activeUsers: activeUsers ?? this.activeUsers,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      expiredUsers: expiredUsers ?? this.expiredUsers,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      connectedRouters: connectedRouters ?? this.connectedRouters,
      notifications: notifications ?? this.notifications,
      temperature: temperature ?? this.temperature,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      internetSpeed: internetSpeed ?? this.internetSpeed,
      uptime: uptime ?? this.uptime,
      routerName: routerName ?? this.routerName,
      routerIp: routerIp ?? this.routerIp,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final RouterConnectionState _conn;
  DashboardNotifier(this._conn) : super(const DashboardState());

  Future<void> refresh() async {
    if (!_conn.isConnected || _conn.service == null) {
      state = state.copyWith(error: 'غير متصل بالراوتر');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = _conn.service!;

      // Fetch system resource (CPU, RAM, uptime)
      Map<String, String> resource = {};
      try {
        resource = await service.system.getResource();
      } catch (_) {}

      // Fetch system health (temperature)
      Map<String, String> health = {};
      try {
        health = await service.system.getHealth();
      } catch (_) {}

      // Fetch identity
      String identity = _conn.identity;
      if (identity.isEmpty) {
        try {
          identity = await service.system.getIdentity() ?? '';
        } catch (_) {}
      }

      // Fetch active hotspot sessions
      int activeHotspot = 0;
      try {
        final active = await service.hotspot.getActiveUsers();
        activeHotspot = active.length;
      } catch (_) {}

      // Fetch active PPPoE sessions
      int activePppoe = 0;
      try {
        final pppoeActive = await service.pppoe.getActiveSessions();
        activePppoe = pppoeActive.length;
      } catch (_) {}

      // Parse values
      final cpuLoad = int.tryParse(resource['cpu-load'] ?? '0') ?? 0;
      final temperature = int.tryParse(health['temperature'] ?? '0') ?? 0;
      final uptimeStr = resource['uptime'] ?? '--';
      final totalMemory = int.tryParse(resource['total-memory'] ?? '0') ?? 0;
      final freeMemory = int.tryParse(resource['free-memory'] ?? '0') ?? 0;
      final usedMemory = totalMemory - freeMemory;
      final memPercent = totalMemory > 0 ? ((usedMemory / totalMemory) * 100).round() : 0;

      state = state.copyWith(
        temperature: temperature,
        cpuUsage: cpuLoad,
        uptime: uptimeStr,
        internetSpeed: '$memPercent% RAM',
        activeUsers: activeHotspot + activePppoe,
        onlineUsers: activeHotspot,
        expiredUsers: activePppoe,
        routerName: identity,
        routerIp: _conn.ip,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'خطأ في جلب البيانات: ${e.toString()}',
      );
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final conn = ref.watch(routerConnectionProvider);
  return DashboardNotifier(conn);
});
