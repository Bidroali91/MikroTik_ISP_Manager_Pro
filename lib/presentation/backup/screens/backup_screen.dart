import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/router_connection_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _nameCtrl = TextEditingController();
  List<Map<String, String>> _backups = [];
  bool _isLoading = true;
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBackups() async {
    final conn = ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) {
      setState(() {
        _isLoading = false;
        _error = 'غير متصل بالراوتر';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final files = await conn.service!.system.listFiles(type: 'backup');
      setState(() {
        _backups = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'خطأ في جلب النسخ الاحتياطية: ${e.toString()}';
      });
    }
  }

  Future<void> _createBackup() async {
    final conn = ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) return;

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل اسم النسخة الاحتياطية'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final error = await conn.service!.system.createBackup(name);
      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $error'), backgroundColor: Colors.red),
          );
        }
      } else {
        _nameCtrl.clear();
        _loadBackups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء النسخة الاحتياطية بنجاح'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isCreating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBackups),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.backup, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Text('إنشاء نسخة احتياطية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم النسخة',
                      hintText: 'backup-2024-01-01',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCreating ? null : _createBackup,
                      icon: _isCreating
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.backup),
                      label: Text(_isCreating ? 'جاري الإنشاء...' : 'إنشاء الآن'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('النسخ الاحتياطية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: _loadBackups,
                label: const Text('تحديث'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBackups,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          else if (_backups.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.archive, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('لا توجد نسخ احتياطية', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ..._backups.map((b) {
              final name = b['name'] ?? '';
              final size = b['size'] ?? '0';
              final sizeKB = (int.tryParse(size) ?? 0) ~/ 1024;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.archive)),
                  title: Text(name),
                  subtitle: Text('$sizeKB KB'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('حذف النسخة'),
                              content: Text('هل أنت متأكد من حذف $name؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('إلغاء')),
                                TextButton(
                                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                                  child: const Text('حذف', style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            _loadBackups();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
