class HotspotUserEntity {
  final String id;
  final String name;
  final String password;
  final String profile;
  final bool disabled;
  final String? uptime;

  const HotspotUserEntity({
    required this.id, required this.name, required this.password,
    this.profile = 'default', this.disabled = false, this.uptime,
  });
}
