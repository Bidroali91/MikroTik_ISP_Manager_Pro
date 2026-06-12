import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (s.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text('قراءة الكل'),
            ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'clear') ref.read(notificationsProvider.notifier).clearAll();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'clear', child: Text('حذف الكل')),
            ],
          ),
        ],
      ),
      body: s.isLoading
          ? const Center(child: CircularProgressIndicator())
          : s.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(s.error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(notificationsProvider.notifier).refresh(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : s.notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('لا توجد إشعارات', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
                      child: ListView.builder(
                        itemCount: s.notifications.length,
                        itemBuilder: (_, i) {
                          final n = s.notifications[i];
                          final icon = _getIcon(n.type);
                          final color = _getColor(n.type);

                          return Dismissible(
                            key: Key(n.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              ref.read(notificationsProvider.notifier).deleteNotification(n.id);
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              color: n.isRead ? null : AppColors.primary.withValues(alpha: 0.05),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.2),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                title: Text(
                                  n.title,
                                  style: TextStyle(
                                    fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!n.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(n.createdAt),
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  if (!n.isRead) {
                                    ref.read(notificationsProvider.notifier).markAsRead(n.id);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'warning': return Icons.warning;
      case 'error': return Icons.error;
      case 'success': return Icons.check_circle;
      case 'user': return Icons.person;
      case 'router': return Icons.router;
      default: return Icons.info;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'warning': return Colors.orange;
      case 'error': return Colors.red;
      case 'success': return Colors.green;
      case 'user': return AppColors.primary;
      case 'router': return AppColors.accent;
      default: return Colors.blue;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes}د';
    if (diff.inHours < 24) return '${diff.inHours}س';
    if (diff.inDays < 7) return '${diff.inDays}ي';
    return '${dt.day}/${dt.month}';
  }
}
