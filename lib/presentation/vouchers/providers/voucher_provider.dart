import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/router_connection_provider.dart';
import '../../../data/models/voucher_model.dart';

class VoucherState {
  final List<VoucherModel> vouchers;
  final bool isLoading;
  final String? error;

  VoucherState({
    this.vouchers = const [],
    this.isLoading = false,
    this.error,
  });

  VoucherState copyWith({
    List<VoucherModel>? vouchers,
    bool? isLoading,
    String? error,
  }) {
    return VoucherState(
      vouchers: vouchers ?? this.vouchers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class VoucherNotifier extends StateNotifier<VoucherState> {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VoucherNotifier(this._ref) : super(VoucherState());

  Future<void> loadVouchers() async {
    state = state.copyWith(isLoading: true);
    try {
      final snapshot = await _firestore
          .collection('vouchers')
          .orderBy('createdAt', descending: true)
          .get();
      final vouchers = snapshot.docs
          .map((doc) => VoucherModel.fromMap(doc.data()))
          .toList();
      state = state.copyWith(vouchers: vouchers, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<String?> createVoucher({
    required String username,
    required String password,
    required String profile,
    required String profileName,
    required int durationHours,
    required double price,
  }) async {
    final conn = _ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) {
      return 'الراوتر غير متصل';
    }

    try {
      final error = await conn.service!.voucher.createVoucherUser(
        name: username,
        password: password,
        profile: profile,
        comment: 'Voucher: $profileName',
      );

      if (error != null) return error;

      final voucher = VoucherModel(
        id: _firestore.collection('vouchers').doc().id,
        username: username,
        password: password,
        profile: profile,
        profileName: profileName,
        durationHours: durationHours,
        price: price,
        createdAt: DateTime.now(),
        routerId: conn.ip,
      );

      await _firestore.collection('vouchers').doc(voucher.id).set(voucher.toMap());

      state = state.copyWith(vouchers: [voucher, ...state.vouchers]);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> batchCreateVouchers({
    required int count,
    required String prefix,
    required String profile,
    required String profileName,
    required int durationHours,
    required double price,
    required int passwordLength,
  }) async {
    final conn = _ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) {
      return 'الراوتر غير متصل';
    }

    state = state.copyWith(isLoading: true);
    try {
      for (int i = 0; i < count; i++) {
        final username = '${prefix}${(i + 1).toString().padLeft(3, '0')}';
        final password = _generatePassword(passwordLength);

        final error = await conn.service!.voucher.createVoucherUser(
          name: username,
          password: password,
          profile: profile,
          comment: 'Voucher: $profileName',
        );

        if (error != null) {
          state = state.copyWith(isLoading: false);
          return error;
        }

        final voucher = VoucherModel(
          id: _firestore.collection('vouchers').doc().id,
          username: username,
          password: password,
          profile: profile,
          profileName: profileName,
          durationHours: durationHours,
          price: price,
          createdAt: DateTime.now(),
          routerId: conn.ip,
        );

        await _firestore.collection('vouchers').doc(voucher.id).set(voucher.toMap());
        state = state.copyWith(vouchers: [voucher, ...state.vouchers]);
      }

      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return e.toString();
    }
  }

  Future<String?> deleteVoucher(String id) async {
    final conn = _ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) {
      return 'الراوتر غير متصل';
    }

    try {
      final voucher = state.vouchers.firstWhere((v) => v.id == id);
      final users = await conn.service!.hotspot.listUsers();
      final routerUser = users.firstWhere(
        (u) => u['name'] == voucher.username,
        orElse: () => {},
      );

      if (routerUser.isNotEmpty) {
        final error = await conn.service!.voucher.removeVoucherUser(routerUser['.id']!);
        if (error != null) return error;
      }

      await _firestore.collection('vouchers').doc(id).delete();
      state = state.copyWith(
        vouchers: state.vouchers.where((v) => v.id != id).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> disableVoucher(String id) async {
    final conn = _ref.read(routerConnectionProvider);
    if (!conn.isConnected || conn.service == null) {
      return 'الراوتر غير متصل';
    }

    try {
      final voucher = state.vouchers.firstWhere((v) => v.id == id);
      final users = await conn.service!.hotspot.listUsers();
      final routerUser = users.firstWhere(
        (u) => u['name'] == voucher.username,
        orElse: () => {},
      );

      if (routerUser.isNotEmpty) {
        final error = await conn.service!.voucher.disableVoucherUser(routerUser['.id']!);
        if (error != null) return error;
      }

      await _firestore.collection('vouchers').doc(id).update({'isUsed': true});
      state = state.copyWith(
        vouchers: state.vouchers.map((v) {
          if (v.id == id) return v.copyWith(isUsed: true);
          return v;
        }).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String _generatePassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final now = DateTime.now().millisecondsSinceEpoch;
    final result = StringBuffer();
    for (int i = 0; i < length; i++) {
      result.write(chars[(now + i) % chars.length]);
    }
    return result.toString();
  }
}

final voucherProvider = StateNotifierProvider<VoucherNotifier, VoucherState>((ref) {
  return VoucherNotifier(ref);
});

final voucherProfilesProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final conn = ref.watch(routerConnectionProvider);
  if (!conn.isConnected || conn.service == null) {
    return [];
  }
  try {
    return await conn.service!.voucher.getVoucherProfiles();
  } catch (e) {
    return [];
  }
});