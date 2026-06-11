import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardState {
  final int activeUsers;
  final int onlineUsers;
  final int expiredUsers;
  final double todayRevenue;
  final double monthlyRevenue;
  final int connectedRouters;
  final int notifications;
  final bool isLoading;

  const DashboardState({
    this.activeUsers = 0, this.onlineUsers = 0, this.expiredUsers = 0,
    this.todayRevenue = 0, this.monthlyRevenue = 0, this.connectedRouters = 0,
    this.notifications = 0, this.isLoading = false,
  });
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());

  Future<void> refresh() async {
    state = DashboardState(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = DashboardState(
      activeUsers: 156, onlineUsers: 42, expiredUsers: 12,
      todayRevenue: 1250.50, monthlyRevenue: 28400.75,
      connectedRouters: 3, notifications: 7,
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
