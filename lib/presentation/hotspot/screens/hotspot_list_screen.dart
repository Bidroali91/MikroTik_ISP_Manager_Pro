import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HotspotListScreen extends StatefulWidget {
  const HotspotListScreen({super.key});
  @override
  State<HotspotListScreen> createState() => _HotspotListScreenState();
}

class _HotspotListScreenState extends State<HotspotListScreen> {
  final _searchCtrl = TextEditingController();
  final _users = List.generate(20, (i) => _HotspotUser(name: 'user${1000 + i}', profile: i % 2 == 0 ? '1-Day' : '1-Week', active: i % 3 != 0, uptime: '${i}h ${i * 5}m'));
  List<_HotspotUser> _filtered = [];

  @override
  void initState() { _filtered = _users; super.initState(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotspot Users'), actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog()),
        IconButton(icon: const Icon(Icons.print), onPressed: () {}),
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _filtered = _users); }) : null,
              ),
              onChanged: (v) => setState(() => _filtered = _users.where((u) => u.name.contains(v)).toList()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filtered.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_filtered.length} users', style: const TextStyle(color: AppColors.primary)),
                        const Spacer(),
                        FilterChip(label: const Text('All'), selected: true, onSelected: (_) {}),
                      ],
                    ),
                  );
                }
                final u = _filtered[i - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: u.active ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                      child: Icon(u.active ? Icons.wifi : Icons.wifi_off, color: u.active ? AppColors.success : AppColors.error, size: 20)),
                    title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${u.profile} • Uptime: ${u.uptime}'),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (_) => [
                        if (u.active) const PopupMenuItem(value: 'disable', child: Text('Disable'))
                        else const PopupMenuItem(value: 'enable', child: Text('Enable')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                      ],
                      onSelected: (v) {
                        if (v == 'delete') showDialog(context: context, builder: (_) => AlertDialog(
                          title: const Text('Delete User'), content: Text('Delete ${u.name}?'),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            TextButton(onPressed: () { Navigator.pop(context); setState(() => _users.remove(u)); }, child: const Text('Delete', style: TextStyle(color: AppColors.error))),
                          ],
                        ));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Add Hotspot User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(decoration: const InputDecoration(labelText: 'Username'), controller: TextEditingController()),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(labelText: 'Password'), controller: TextEditingController()),
          const SizedBox(height: 12),
          DropdownButtonFormField(items: const [DropdownMenuItem(value: '1-Day', child: Text('1-Day')), DropdownMenuItem(value: '1-Week', child: Text('1-Week'))], onChanged: (_) {}, decoration: const InputDecoration(labelText: 'Profile')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add')),
      ],
    ));
  }
}

class _HotspotUser {
  final String name; final String profile; final bool active; final String uptime;
  _HotspotUser({required this.name, required this.profile, required this.active, required this.uptime});
}
