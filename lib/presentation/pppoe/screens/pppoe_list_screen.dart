import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PppoeListScreen extends StatefulWidget {
  const PppoeListScreen({super.key});
  @override
  State<PppoeListScreen> createState() => _PppoeListScreenState();
}

class _PppoeListScreenState extends State<PppoeListScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PPPoE Management'),
          actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Subscribers'),
              Tab(text: 'Active'),
              Tab(text: 'Profiles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSubscribersList(),
            _buildActiveSessions(),
            _buildProfilesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 10,
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.2), child: const Icon(Icons.person, color: AppColors.primary)),
          title: Text('subscriber${1000 + i}'),
          subtitle: const Text('profile: default • Active'),
          trailing: PopupMenuButton<String>(itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'disconnect', child: Text('Disconnect', style: TextStyle(color: AppColors.warning))),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
          ], onSelected: (v) {}),
        ),
      ),
    );
  }

  Widget _buildActiveSessions() {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lan, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('8 Active Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Total bandwidth: 125.4 Mbps', style: TextStyle(color: Colors.grey)),
      ],
    ));
  }

  Widget _buildProfilesList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ProfileCard(name: 'default', speed: '10M/10M', users: 45),
        _ProfileCard(name: 'Premium', speed: '50M/25M', users: 12),
        _ProfileCard(name: 'Business', speed: '100M/50M', users: 5),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name; final String speed; final int users;
  const _ProfileCard({required this.name, required this.speed, required this.users});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.speed)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$speed • $users subscribers'),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}
