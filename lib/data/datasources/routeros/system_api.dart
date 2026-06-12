import 'routeros_client.dart';

class SystemApi {
  final RouterOSClient _client;
  SystemApi(this._client);

  Future<Map<String, String>> getResource() async {
    final reply = await _client.talk(['/system/resource/print']);
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!re') {
        final attrs = <String, String>{};
        i++;
        while (i < reply.length && reply[i].startsWith('=')) {
          final eq = reply[i].indexOf('=', 1);
          if (eq > 0) attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
          i++;
        }
        return attrs;
      }
    }
    return {};
  }

  Future<Map<String, String>> getHealth() async {
    try {
      final reply = await _client.talk(['/system/health/print']);
      for (int i = 0; i < reply.length; i++) {
        if (reply[i] == '!re') {
          final attrs = <String, String>{};
          i++;
          while (i < reply.length && reply[i].startsWith('=')) {
            final eq = reply[i].indexOf('=', 1);
            if (eq > 0) attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
            i++;
          }
          return attrs;
        }
      }
    } catch (_) {}
    return {};
  }

  Future<String?> getIdentity() async {
    final reply = await _client.talk(['/system/identity/print']);
    for (final w in reply) {
      if (w.startsWith('=name=')) return w.substring(6);
    }
    return null;
  }

  Future<String?> createBackup(String name) async {
    final reply = await _client.talk(['/system/backup/save', '=name=$name']);
    return _client.getErrorMessage(reply);
  }

  Future<List<Map<String, String>>> listFiles({String type = 'backup'}) async {
    final reply = await _client.talk(['/file/print', '?type=$type']);
    final files = <Map<String, String>>[];
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!re') {
        final attrs = <String, String>{};
        i++;
        while (i < reply.length && reply[i].startsWith('=')) {
          final eq = reply[i].indexOf('=', 1);
          if (eq > 0) attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
          i++;
        }
        files.add(attrs);
      }
    }
    return files;
  }

  Future<String?> reboot() async {
    final reply = await _client.talk(['/system/reboot']);
    return _client.getErrorMessage(reply);
  }

  Future<List<Map<String, String>>> getInterfaces() async {
    final reply = await _client.talk(['/interface/print']);
    final ifaces = <Map<String, String>>[];
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!re') {
        final attrs = <String, String>{};
        i++;
        while (i < reply.length && reply[i].startsWith('=')) {
          final eq = reply[i].indexOf('=', 1);
          if (eq > 0) attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
          i++;
        }
        ifaces.add(attrs);
      }
    }
    return ifaces;
  }

  Future<String?> setInterfaceEnabled(String id, bool enable) async {
    final cmd = enable ? '/interface/enable' : '/interface/disable';
    final reply = await _client.talk([cmd, '=.id=$id']);
    return _client.getErrorMessage(reply);
  }
}
