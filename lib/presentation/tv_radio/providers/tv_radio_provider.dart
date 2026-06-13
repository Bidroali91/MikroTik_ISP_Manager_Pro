import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/channel_model.dart';

class TvRadioState {
  final List<ChannelModel> channels;
  final bool isLoading;
  final String? error;

  const TvRadioState({
    this.channels = const [],
    this.isLoading = false,
    this.error,
  });

  List<ChannelModel> get tvChannels =>
      channels.where((c) => c.type == 'tv').toList();
  List<ChannelModel> get radioChannels =>
      channels.where((c) => c.type == 'radio').toList();

  TvRadioState copyWith({
    List<ChannelModel>? channels,
    bool? isLoading,
    String? error,
  }) {
    return TvRadioState(
      channels: channels ?? this.channels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TvRadioNotifier extends StateNotifier<TvRadioState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TvRadioNotifier() : super(const TvRadioState());

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('channels');

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final snap = await _col.orderBy('order').get();
      final channels =
          snap.docs.map((d) => ChannelModel.fromMap(d.data())).toList();
      state = state.copyWith(channels: channels, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> addChannel({
    required String name,
    required String type,
    required String streamUrl,
    String category = '',
    String logoUrl = '',
  }) async {
    try {
      final id = _col.doc().id;
      final channel = ChannelModel(
        id: id,
        name: name,
        type: type,
        category: category,
        streamUrl: streamUrl,
        logoUrl: logoUrl,
        order: state.channels.length,
        createdAt: DateTime.now(),
      );
      await _col.doc(id).set(channel.toMap());
      state = state.copyWith(channels: [...state.channels, channel]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleActive(String id, bool active) async {
    try {
      await _col.doc(id).update({'isActive': active});
      state = state.copyWith(
        channels: state.channels
            .map((c) => c.id == id ? c.copyWith(isActive: active) : c)
            .toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteChannel(String id) async {
    try {
      await _col.doc(id).delete();
      state = state.copyWith(
        channels: state.channels.where((c) => c.id != id).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final tvRadioProvider =
    StateNotifierProvider<TvRadioNotifier, TvRadioState>((ref) {
  return TvRadioNotifier();
});
