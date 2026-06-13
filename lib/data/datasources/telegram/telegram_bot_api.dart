import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramBotApi {
  final String botToken;
  final String chatId;

  TelegramBotApi({
    required this.botToken,
    required this.chatId,
  });

  String get _baseUrl => 'https://api.telegram.org/bot$botToken';

  Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(Uri.parse('$_baseUrl/getMe'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> sendMessage(String text, {String? parseMode}) async {
    final body = {
      'chat_id': chatId,
      'text': text,
    };
    if (parseMode != null) {
      body['parse_mode'] = parseMode;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/sendMessage'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> sendPhoto(String photoUrl, {String? caption}) async {
    final body = {
      'chat_id': chatId,
      'photo': photoUrl,
    };
    if (caption != null) {
      body['caption'] = caption;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/sendPhoto'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getUpdates({int? offset}) async {
    final params = <String, String>{};
    if (offset != null) {
      params['offset'] = offset.toString();
    }

    final uri = Uri.parse('$_baseUrl/getUpdates').replace(queryParameters: params);
    final response = await http.get(uri);
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> setWebhook(String url) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/setWebhook'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'url': url}),
    );
    return json.decode(response.body);
  }

  Future<void> sendRouterStatus({
    required String routerIp,
    required String identity,
    required double cpuLoad,
    required double memoryUsage,
    required int activeUsers,
    required int uptime,
  }) async {
    final message = '''
*status الراوتر* 📊

*الهوية:* $identity
*العنوان:* $routerIp

*حالة النظام:*
- حمل CPU: ${cpuLoad.toStringAsFixed(1)}%
- استخدام الذاكرة: ${memoryUsage.toStringAsFixed(1)}%
- المستخدمين النشطين: $activeUsers
- مدة التشغيل: ${_formatUptime(uptime)}
''';

    await sendMessage(message, parseMode: 'Markdown');
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (days > 0) return '$days يوم $hours ساعة $minutes دقيقة';
    if (hours > 0) return '$hours ساعة $minutes دقيقة';
    return '$minutes دقيقة';
  }

  Future<void> sendAlert(String title, String message) async {
    final text = '''
*⚠️ تنبيه: $title*

$message
''';

    await sendMessage(text, parseMode: 'Markdown');
  }

  Future<void> sendNewUserNotification(String username, String profile) async {
    final text = '''
*مستخدم جديد* 👤

*الاسم:* $username
*الملف الشخصي:* $profile
''';

    await sendMessage(text, parseMode: 'Markdown');
  }

  Future<void> sendComplaintNotification(String subject, String message) async {
    final text = '''
*شكوى جديدة* 📝

*الموضوع:* $subject
*الرسالة:* $message
''';

    await sendMessage(text, parseMode: 'Markdown');
  }
}