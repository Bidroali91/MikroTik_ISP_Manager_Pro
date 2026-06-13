import 'routeros_client.dart';

class VoucherApi {
  final RouterOSClient _client;

  VoucherApi(this._client);

  Future<List<Map<String, String>>> getVoucherProfiles() async {
    final reply = await _client.talk(['/ip/hotspot/user/profile/print']);
    final results = <Map<String, String>>[];
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!re') {
        final attrs = <String, String>{};
        i++;
        while (i < reply.length && reply[i].startsWith('=')) {
          final eq = reply[i].indexOf('=', 1);
          attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
          i++;
        }
        results.add(attrs);
      }
    }
    return results;
  }

  Future<String?> createVoucherUser({
    required String name,
    required String password,
    required String profile,
    String? comment,
  }) async {
    final cmd = <String>[
      '/ip/hotspot/user/add',
      '=name=$name',
      '=password=$password',
      '=profile=$profile',
    ];
    if (comment != null && comment.isNotEmpty) {
      cmd.add('=comment=$comment');
    }
    final reply = await _client.talk(cmd);
    return _client.getErrorMessage(reply);
  }

  Future<String?> removeVoucherUser(String id) async {
    final reply = await _client.talk([
      '/ip/hotspot/user/remove',
      '=.id=$id',
    ]);
    return _client.getErrorMessage(reply);
  }

  Future<String?> disableVoucherUser(String id) async {
    final reply = await _client.talk([
      '/ip/hotspot/user/disable',
      '=.id=$id',
    ]);
    return _client.getErrorMessage(reply);
  }

  Future<String?> enableVoucherUser(String id) async {
    final reply = await _client.talk([
      '/ip/hotspot/user/enable',
      '=.id=$id',
    ]);
    return _client.getErrorMessage(reply);
  }

  Future<List<Map<String, String>>> getActiveVoucherUsers() async {
    final reply = await _client.talk(['/ip/hotspot/active/print']);
    final results = <Map<String, String>>[];
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!re') {
        final attrs = <String, String>{};
        i++;
        while (i < reply.length && reply[i].startsWith('=')) {
          final eq = reply[i].indexOf('=', 1);
          attrs[reply[i].substring(1, eq)] = reply[i].substring(eq + 1);
          i++;
        }
        results.add(attrs);
      }
    }
    return results;
  }

  Future<String?> batchCreateVouchers({
    required int count,
    required String prefix,
    required String profile,
    required int passwordLength,
    String? comment,
  }) async {
    for (int i = 0; i < count; i++) {
      final username = '${prefix}${(i + 1).toString().padLeft(3, '0')}';
      final password = _generatePassword(passwordLength);
      final error = await createVoucherUser(
        name: username,
        password: password,
        profile: profile,
        comment: comment ?? 'Voucher ${i + 1}',
      );
      if (error != null) return error;
    }
    return null;
  }

  String _generatePassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final result = StringBuffer();
    for (int i = 0; i < length; i++) {
      result.write(chars[(random + i) % chars.length]);
    }
    return result.toString();
  }
}