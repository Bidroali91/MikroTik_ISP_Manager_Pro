import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/channel_model.dart';
import '../providers/tv_radio_provider.dart';

class TvRadioScreen extends ConsumerStatefulWidget {
  const TvRadioScreen({super.key});

  @override
  ConsumerState<TvRadioScreen> createState() => _TvRadioScreenState();
}

class _TvRadioScreenState extends ConsumerState<TvRadioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tvRadioProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tvRadioProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV & Radio'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(tvRadioProvider.notifier).load(),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(icon: Icon(Icons.live_tv), text: 'التلفزيون'),
            Tab(icon: Icon(Icons.radio), text: 'الإذاعة'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(_tab.index == 0 ? 'tv' : 'radio'),
        icon: const Icon(Icons.add),
        label: const Text('قناة جديدة'),
      ),
      body: state.isLoading && state.channels.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [
                _list(state.tvChannels, Icons.live_tv, 'لا توجد قنوات تلفزيونية'),
                _list(state.radioChannels, Icons.radio, 'لا توجد محطات إذاعية'),
              ],
            ),
    );
  }

  Widget _list(List<ChannelModel> channels, IconData icon, String emptyMsg) {
    if (channels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(emptyMsg, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: channels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _channelCard(channels[i]),
    );
  }

  Widget _channelCard(ChannelModel c) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: c.isRadio ? Colors.deepPurple.shade50 : Colors.blue.shade50,
          backgroundImage: c.logoUrl.isNotEmpty ? NetworkImage(c.logoUrl) : null,
          child: c.logoUrl.isEmpty
              ? Icon(c.isRadio ? Icons.radio : Icons.live_tv,
                  color: c.isRadio ? Colors.deepPurple : Colors.blue)
              : null,
        ),
        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.category.isNotEmpty) Text(c.category),
            Text(c.streamUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        isThreeLine: c.category.isNotEmpty,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: c.isActive,
              onChanged: (v) async {
                final err = await ref.read(tvRadioProvider.notifier).toggleActive(c.id, v);
                _snack(err == null ? (v ? 'تم التفعيل' : 'تم الإيقاف') : 'خطأ: $err', err == null);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(c),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(String type) {
    final nameC = TextEditingController();
    final urlC = TextEditingController();
    final catC = TextEditingController();
    final logoC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == 'tv' ? 'قناة تلفزيونية جديدة' : 'محطة إذاعية جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'الاسم')),
              const SizedBox(height: 12),
              TextField(controller: urlC, decoration: const InputDecoration(labelText: 'رابط البث', hintText: 'http://...')),
              const SizedBox(height: 12),
              TextField(controller: catC, decoration: const InputDecoration(labelText: 'التصنيف (اختياري)', hintText: 'رياضة، أخبار...')),
              const SizedBox(height: 12),
              TextField(controller: logoC, decoration: const InputDecoration(labelText: 'رابط الشعار (اختياري)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final name = nameC.text.trim();
              final url = urlC.text.trim();
              if (name.isEmpty || url.isEmpty) return;
              Navigator.pop(ctx);
              final err = await ref.read(tvRadioProvider.notifier).addChannel(
                    name: name,
                    type: type,
                    streamUrl: url,
                    category: catC.text.trim(),
                    logoUrl: logoC.text.trim(),
                  );
              _snack(err == null ? 'تمت الإضافة' : 'خطأ: $err', err == null);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ChannelModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف القناة'),
        content: Text('هل تريد حذف "${c.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) {
      final err = await ref.read(tvRadioProvider.notifier).deleteChannel(c.id);
      _snack(err == null ? 'تم الحذف' : 'خطأ: $err', err == null);
    }
  }

  void _snack(String msg, bool ok) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : Colors.red),
    );
  }
}
