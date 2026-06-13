import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/telegram_provider.dart';

class TelegramScreen extends ConsumerStatefulWidget {
  const TelegramScreen({super.key});
  @override
  ConsumerState<TelegramScreen> createState() => _TelegramScreenState();
}

class _TelegramScreenState extends ConsumerState<TelegramScreen> {
  final _botTokenController = TextEditingController();
  final _chatIdController = TextEditingController();
  bool _obscureToken = true;

  @override
  void dispose() {
    _botTokenController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telegramState = ref.watch(telegramProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('بوت Telegram'),
        centerTitle: true,
        actions: [
          if (telegramState.isConfigured)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(telegramProvider.notifier).fetchMessages(),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!telegramState.isConfigured) ...[
            _buildConfigurationCard(telegramState),
          ] else ...[
            _buildStatusCard(telegramState),
            const SizedBox(height: 16),
            _buildCommandsCard(),
            const SizedBox(height: 16),
            _buildMessagesCard(telegramState),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigurationCard(TelegramState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.telegram, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'ربط بوت Telegram',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'قم بإعداد بوت Telegram للتحكم عن بعد',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _botTokenController,
              obscureText: _obscureToken,
              decoration: InputDecoration(
                labelText: 'Bot Token',
                hintText: 'أدخل توكن البوت',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureToken ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureToken = !_obscureToken),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _chatIdController,
              decoration: const InputDecoration(
                labelText: 'Chat ID',
                hintText: 'أدخل معرف المحادثة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (state.isLoading)
              const CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _configureBot,
                  icon: const Icon(Icons.link),
                  label: const Text('ربط البوت'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(TelegramState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                const Text(
                  'البوت متصل',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Bot Token', _maskToken(state.botToken)),
            _buildInfoRow('Chat ID', state.chatId),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sendTestMessage,
                    icon: const Icon(Icons.send),
                    label: const Text('إرسال رسالة اختبار'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sendRouterStatus,
                    icon: const Icon(Icons.router),
                    label: const Text('حالة الراوتر'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _disconnectBot,
                icon: const Icon(Icons.link_off),
                label: const Text('قطع الاتصال'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الأوامر المتاحة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _CommandTile(cmd: '/info', desc: 'معلومات النظام'),
            _CommandTile(cmd: '/active', desc: 'المستخدمين النشطين'),
            _CommandTile(cmd: '/users', desc: 'عدد المستخدمين'),
            _CommandTile(cmd: '/pppoe', desc: 'حالة PPPoE'),
            _CommandTile(cmd: '/sales', desc: 'تقرير المبيعات'),
            _CommandTile(cmd: '/backup', desc: 'إنشاء نسخة احتياطية'),
            _CommandTile(cmd: '/reboot', desc: 'إعادة تشغيل الراوتر'),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesCard(TelegramState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الرسائل المستلمة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (state.messages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'لا توجد رسائل',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...state.messages.take(10).map((msg) => _buildMessageTile(msg)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> msg) {
    final text = msg['text'] ?? '';
    final from = msg['from']?['first_name'] ?? 'غير معروف';
    final date = DateTime.fromMillisecondsSinceEpoch((msg['date'] ?? 0) * 1000);

    return ListTile(
      leading: CircleAvatar(
        child: Text(from[0]),
      ),
      title: Text(from, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(text),
      trailing: Text(
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _maskToken(String token) {
    if (token.length <= 8) return token;
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }

  Future<void> _configureBot() async {
    final botToken = _botTokenController.text.trim();
    final chatId = _chatIdController.text.trim();

    if (botToken.isEmpty || chatId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final error = await ref.read(telegramProvider.notifier).configure(
          botToken: botToken,
          chatId: chatId,
        );

    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الاتصال بالبوت بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendTestMessage() async {
    final error = await ref.read(telegramProvider.notifier).sendTestMessage();
    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال رسالة الاختبار'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendRouterStatus() async {
    final error = await ref.read(telegramProvider.notifier).sendRouterStatus();
    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال حالة الراوتر'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnectBot() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قطع الاتصال'),
        content: const Text('هل أنت متأكد من قطع اتصال البوت؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('قطع'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(telegramProvider.notifier).disconnect();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم قطع الاتصال'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class _CommandTile extends StatelessWidget {
  final String cmd;
  final String desc;
  const _CommandTile({required this.cmd, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            cmd,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: AppColors.info,
            ),
          ),
        ),
        title: Text(desc, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}