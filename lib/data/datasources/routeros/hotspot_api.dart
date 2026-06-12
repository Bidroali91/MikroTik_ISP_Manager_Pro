import 'routeros_client.dart';

class HotspotApi {
  final RouterOSClient _client;
  HotspotApi(this._client);

  Future<List<Map<String, String>>> getProfiles() async {
    final reply = await _client.talk(['/ip/hotspot/user/profile/print']);
    final profiles = <Map<String, String>>[];
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!re') {
        final attrs = <String, String>{};
        i++;
        while (i < reply.length && reply[i].startsWith('=')) {
          final eq = reply[i].indexOf('=', 1);
          if (eq > 0) attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
          i++;
        }
        profiles.add(attrs);
      }
    }
    return profiles;
  }

  Future<List<Map<String, String>>> listUsers() async {
    final reply = await _client.talk(['/ip/hotspot/user/print']);
    final users = <Map<String, String>>[];
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!re') {
        final attrs = <String, String>{};
        i++;
        while (i < reply.length && reply[i].startsWith('=')) {
          final eq = reply[i].indexOf('=', 1);
          if (eq > 0) attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
          i++;
        }
        users.add(attrs);
      }
    }
    return users;
  }

  Future<String?> addUser(String name, String password, String profile, {String? comment}) async {
    final cmd = ['/ip/hotspot/user/add', '=name=$name', '=password=$password', '=profile=$profile'];
    if (comment != null) cmd.add('=comment=$comment');
    final reply = await _client.talk(cmd);
    return _client.getErrorMessage(reply);
  }

  Future<String?> updateUser(String id, Map<String, String> fields) async {
    final cmd = ['/ip/hotspot/user/set', '=.id=$id'];
    fields.forEach((k, v) => cmd.add('=$k=$v'));
    final reply = await _client.talk(cmd);
    return _client.getErrorMessage(reply);
  }

  Future<String?> removeUser(String id) async {
    final reply = await _client.talk(['/ip/hotspot/user/remove', '=.id=$id']);
    return _client.getErrorMessage(reply);
  }

  Future<String?> enableUser(String id) async {
    final reply = await _client.talk(['/ip/hotspot/user/enable', '=.id=$id']);
    return _client.getErrorMessage(reply);
  }

  Future<String?> disableUser(String id) async {
    final reply = await _client.talk(['/ip/hotspot/user/disable', '=.id=$id']);
    return _client.getErrorMessage(reply);
  }

  Future<List<Map<String, String>>> getActiveUsers() async {
    final reply = await _client.talk(['/ip/hotspot/active/print']);
    final users = <Map<String, String>>[];
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!re') {
        final attrs = <String, String>{};
        i++;
        while (i < reply.length && reply[i].startsWith('=')) {
          final eq = reply[i].indexOf('=', 1);
          if (eq > 0) attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
          i++;
        }
        users.add(attrs);
      }
    }
    return users;
  }

  Future<String?> clearActiveSessions() async {
    final reply = await _client.talk(['/ip/hotspot/active/remove-all']);
    return _client.getErrorMessage(reply);
  }

  Future<int> getActiveUserCount() async {
    final reply = await _client.talk(['/ip/hotspot/active/print', '=count-only=']);
    for (final w in reply) {
      if (w.startsWith('=ret=')) return int.tryParse(w.substring(5)) ?? 0;
    }
    return 0;
  }
}
