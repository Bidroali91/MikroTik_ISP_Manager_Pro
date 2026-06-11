import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

class RouterOSClient {
  Socket? _socket;
  bool _connected = false;
  int _readIndex = 0;
  final List<int> _buffer = [];
  Completer<void> _onData = Completer<void>();
  StreamSubscription<Uint8List>? _subscription;

  bool get isConnected => _connected;

  Future<void> connect(String host, {int port = 8728, int timeout = 8000}) async {
    _socket = await Socket.connect(host, port, timeout: Duration(milliseconds: timeout));
    _socket!.setOption(SocketOption.tcpNoDelay, true);
    _connected = true;
    _subscription = _socket!.listen(
      (data) {
        _buffer.addAll(data);
        if (!_onData.isCompleted) _onData.complete();
      },
      onDone: () {
        _connected = false;
        if (!_onData.isCompleted) _onData.complete();
      },
      onError: (_) {
        _connected = false;
        if (!_onData.isCompleted) _onData.complete();
      },
    );
  }

  Future<bool> login(String username, String password) async {
    var reply = await talk(['/login', '=name=$username', '=password=$password']);
    if (reply.any((s) => s.startsWith('!done')) && reply.every((s) => !s.startsWith('!trap'))) {
      return true;
    }
    return false;
  }

  Future<List<String>> talk(List<String> words) async {
    writeSentence(words);
    return await readReply();
  }

  void writeSentence(List<String> words) {
    if (_socket == null || !_connected) {
      throw Exception('Not connected to router');
    }
    for (final word in words) {
      final bytes = utf8.encode(word);
      writeLength(bytes.length);
      _socket!.add(bytes);
    }
    writeLength(0);
  }

  void writeLength(int length) {
    if (length < 0x80) {
      _socket!.add(Uint8List.fromList([length]));
    } else if (length < 0x4000) {
      _socket!.add(Uint8List.fromList([(length >> 8) | 0x80, length & 0xFF]));
    } else if (length < 0x200000) {
      _socket!.add(Uint8List.fromList([(length >> 16) | 0xC0, (length >> 8) & 0xFF, length & 0xFF]));
    } else if (length < 0x10000000) {
      _socket!.add(Uint8List.fromList([(length >> 24) | 0xE0, (length >> 16) & 0xFF, (length >> 8) & 0xFF, length & 0xFF]));
    } else {
      _socket!.add(Uint8List.fromList([0xF0, (length >> 24) & 0xFF, (length >> 16) & 0xFF, (length >> 8) & 0xFF, length & 0xFF]));
    }
  }

  Future<void> _ensureData(int needed) async {
    while (_buffer.length - _readIndex < needed) {
      if (_onData.isCompleted) _onData = Completer<void>();
      await _onData.future;
    }
  }

  Future<int> _readByte() async {
    await _ensureData(1);
    return _buffer[_readIndex++];
  }

  Future<int> readLength() async {
    final c = await _readByte();
    if (c < 0) throw Exception('Connection closed');
    if (c & 0x80 == 0x00) return c;
    if (c & 0xC0 == 0x80) return ((c & 0x3F) << 8) + await _readByte();
    if (c & 0xE0 == 0xC0) return ((c & 0x1F) << 16) + (await _readByte() << 8) + await _readByte();
    if (c & 0xF0 == 0xE0) return ((c & 0x0F) << 24) + (await _readByte() << 16) + (await _readByte() << 8) + await _readByte();
    return (await _readByte() << 24) + (await _readByte() << 16) + (await _readByte() << 8) + await _readByte();
  }

  Future<List<String>> readReply() async {
    final sentences = <String>[];
    while (true) {
      final words = <String>[];
      while (true) {
        final len = await readLength();
        if (len == 0) break;
        await _ensureData(len);
        final wordBytes = _buffer.sublist(_readIndex, _readIndex + len);
        _readIndex += len;
        words.add(utf8.decode(wordBytes));
      }
      if (words.isEmpty) continue;
      sentences.addAll(words);
      if (words[0] == '!done' || words[0] == '!fatal') break;
    }
    return sentences;
  }

  Map<String, String> parseAttributes(List<String> words) {
    final attrs = <String, String>{};
    for (final w in words) {
      if (w.startsWith('=')) {
        final eq = w.indexOf('=', 1);
        if (eq > 0) {
          attrs[w.substring(1, eq)] = w.substring(eq + 1);
        } else {
          attrs[w.substring(1)] = '';
        }
      }
    }
    return attrs;
  }

  String? getErrorMessage(List<String> reply) {
    for (int i = 0; i < reply.length; i++) {
      if (reply[i] == '!trap' || reply[i] == '!fatal') {
        for (int j = i + 1; j < reply.length; j++) {
          if (reply[j].startsWith('=message=')) return reply[j].substring(9);
        }
      }
    }
    return null;
  }

  void close() {
    _subscription?.cancel();
    try { _socket?.destroy(); } catch (_) {}
    _socket = null;
    _connected = false;
    _buffer.clear();
    _readIndex = 0;
  }

  void disconnect() => close();
}
