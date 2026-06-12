import 'routeros_client.dart';

class PppoeApi {
  final RouterOSClient _client;
  PppoeApi(this._client);

  Future<List<Map<String, String>>> listUsers() async {
    final reply = await _client.talk(['/ppp/secret/print']);
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

  Future<String?> addUser(String username, String password, String service, String profile, {String? comment}) async {
    final cmd = ['/ppp/secret/add', '=name=$username', '=password=$password', '=service=$service', '=profile=$profile'];
    if (comment != null) cmd.add('=comment=$comment');
    final reply = await _client.talk(cmd);
    return _client.getErrorMessage(reply);
  }

  Future<String?> updateUser(String id, Map<String, String> fields) async {
    final cmd = ['/ppp/secret/set', '=.id=$id'];
    fields.forEach((k, v) => cmd.add('=$k=$v'));
    final reply = await _client.talk(cmd);
    return _client.getErrorMessage(reply);
  }

  Future<String?> removeUser(String id) async {
    final reply = await _client.talk(['/ppp/secret/remove', '=.id=$id']);
    return _client.getErrorMessage(reply);
  }

  Future<String?> enableUser(String id) async {
    final reply = await _client.talk(['/ppp/secret/enable', '=.id=$id']);
    return _client.getErrorMessage(reply);
  }

  Future<String?> disableUser(String id) async {
    final reply = await _client.talk(['/ppp/secret/disable', '=.id=$id']);
    return _client.getErrorMessage(reply);
  }

  Future<List<Map<String, String>>> getActiveSessions() async {
    final reply = await _client.talk(['/ppp/active/print']);
    final sessions = <Map<String, String>>[];
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!re') {
        final attrs = <String, String>{};
        i++;
        while (i < reply.length && reply[i].startsWith('=')) {
          final eq = reply[i].indexOf('=', 1);
          if (eq > 0) attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
          i++;
        }
        sessions.add(attrs);
      }
    }
    return sessions;
  }

  Future<String?> disconnectSession(String id) async {
    final reply = await _client.talk(['/ppp/active/remove', '=.id=$id']);
    return _client.getErrorMessage(reply);
  }
}
