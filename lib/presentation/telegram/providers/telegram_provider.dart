import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/datasources/telegram/telegram_bot_api.dart';
import '../../../core/providers/router_connection_provider.dart';

class TelegramState {
  final bool isConfigured;
  final bool isConnected;
  final String botToken;
  final String chatId;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> messages;

  TelegramState({
    this.isConfigured = false,
    this.isConnected = false,
    this.botToken = '',
    this.chatId = '',
    this.isLoading = false,
    this.error,
    this.messages = const [],
  });

  TelegramState copyWith({
    bool? isConfigured,
    bool? isConnected,
    String? botToken,
    String? chatId,
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? messages,
  }) {
    return TelegramState(
      isConfigured: isConfigured ?? this.isConfigured,
      isConnected: isConnected ?? this.isConnected,
      botToken: botToken ?? this.botToken,
      chatId: chatId ?? this.chatId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      messages: messages ?? this.messages,
    );
  }
}

class TelegramNotifier extends StateNotifier<TelegramState> {
  final Ref _ref;
  TelegramBotApi? _api;

  TelegramNotifier(this._ref) : super(TelegramState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final botToken = prefs.getString('telegram_bot_token') ?? '';
    final chatId = prefs.getString('telegram_chat_id') ?? '';

    if (botToken.isNotEmpty && chatId.isNotEmpty) {
      state = state.copyWith(
        botToken: botToken,
        chatId: chatId,
        isConfigured: true,
      );
      _api = TelegramBotApi(botToken: botToken, chatId: chatId);
    }
  }

  Future<String?> configure({
    required String botToken,
    required String chatId,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final api = TelegramBotApi(botToken: botToken, chatId: chatId);
      final result = await api.getMe();

      if (result['ok'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('telegram_bot_token', botToken);
        await prefs.setString('telegram_chat_id', chatId);

        _api = api;
        state = state.copyWith(
          botToken: botToken,
          chatId: chatId,
          isConfigured: true,
          isConnected: true,
          isLoading: false,
        );
        return null;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'فشل الاتصال بالبوت',
        );
        return 'فشل الاتصال بالبوت';
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return e.toString();
    }
  }

  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('telegram_bot_token');
    await prefs.remove('telegram_chat_id');

    _api = null;
    state = TelegramState();
  }

  Future<String?> sendTestMessage() async {
    if (_api == null) return 'البوت غير متصل';

    try {
      await _api!.sendMessage('تم الاتصال بنجاح! ✅');
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendRouterStatus() async {
    if (_api == null) return 'البوت غير متصل';

    final conn = _ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) {
      return 'الراوتر غير متصل';
    }

    try {
      final resource = await conn.service!.system.getResource();
      final cpuLoad = double.tryParse(resource['cpu-load'] ?? '0') ?? 0;
      final totalMemory = int.tryParse(resource['total-memory'] ?? '0') ?? 0;
      final freeMemory = int.tryParse(resource['free-memory'] ?? '0') ?? 0;
      final memoryUsage = totalMemory > 0 ? ((totalMemory - freeMemory) / totalMemory * 100) : 0;

      final activeUsers = await conn.service!.hotspot.getActiveUserCount();
      final identity = await conn.service!.system.getIdentity();

      await _api!.sendRouterStatus(
        routerIp: conn.ip,
        identity: identity ?? 'غير معروف',
        cpuLoad: cpuLoad,
        memoryUsage: memoryUsage.toDouble(),
        activeUsers: activeUsers,
        uptime: 0,
      );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendAlert(String title, String message) async {
    if (_api == null) return 'البوت غير متصل';

    try {
      await _api!.sendAlert(title, message);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> fetchMessages() async {
    if (_api == null) return;

    try {
      final result = await _api!.getUpdates();
      if (result['ok'] == true) {
        final updates = List<Map<String, dynamic>>.from(result['result'] ?? []);
        final messages = updates
            .where((u) => u.containsKey('message'))
            .map((u) => u['message'] as Map<String, dynamic>)
            .toList();
        state = state.copyWith(messages: messages);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final telegramProvider = StateNotifierProvider<TelegramNotifier, TelegramState>((ref) {
  return TelegramNotifier(ref);
});