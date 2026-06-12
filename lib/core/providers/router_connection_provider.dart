import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/routeros/routeros_service.dart';

class RouterConnectionState {
  final RouterOSService? service;
  final String ip;
  final String username;
  final String password;
  final int port;
  final bool isConnected;
  final bool isLoading;
  final String? error;
  final String identity;

  const RouterConnectionState({
    this.service,
    this.ip = '',
    this.username = '',
    this.password = '',
    this.port = 8728,
    this.isConnected = false,
    this.isLoading = false,
    this.error,
    this.identity = '',
  });

  RouterConnectionState copyWith({
    RouterOSService? service,
    String? ip,
    String? username,
    String? password,
    int? port,
    bool? isConnected,
    bool? isLoading,
    String? error,
    String? identity,
  }) {
    return RouterConnectionState(
      service: service ?? this.service,
      ip: ip ?? this.ip,
      username: username ?? this.username,
      password: password ?? this.password,
      port: port ?? this.port,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      identity: identity ?? this.identity,
    );
  }
}

class RouterConnectionNotifier extends StateNotifier<RouterConnectionState> {
  RouterConnectionNotifier() : super(const RouterConnectionState());

  Future<bool> connect(String ip, String username, String password, int port) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = await RouterOSService.connect(ip, port, username, password);
      String identity = '';
      try {
        identity = await service.system.getIdentity() ?? '';
      } catch (_) {}
      state = state.copyWith(
        service: service,
        ip: ip,
        username: username,
        password: password,
        port: port,
        isConnected: true,
        isLoading: false,
        identity: identity,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().contains('SocketException') ? 'فشل الاتصال بالراوتر - تحقق من IP والمنفذ' :
                e.toString().contains('login failed') ? 'اسم المستخدم أو كلمة المرور غير صحيحة' :
                'خطأ في الاتصال: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> disconnect() async {
    state.service?.disconnect();
    state = const RouterConnectionState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final routerConnectionProvider = StateNotifierProvider<RouterConnectionNotifier, RouterConnectionState>((ref) {
  return RouterConnectionNotifier();
});

final routerServiceProvider = Provider<RouterOSService?>((ref) {
  return ref.watch(routerConnectionProvider).service;
});
