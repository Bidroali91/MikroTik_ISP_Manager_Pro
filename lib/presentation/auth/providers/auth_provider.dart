import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/repositories/auth_repository.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? userId;
  final String? email;
  const AuthState({this.isAuthenticated = false, this.isLoading = false, this.error, this.userId, this.email});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthState()) {
    _repo.authState.listen((authed) {
      final user = fb.FirebaseAuth.instance.currentUser;
      state = AuthState(
        isAuthenticated: authed,
        userId: user?.uid,
        email: user?.email,
      );
    });
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.signIn(email, password);
      state = AuthState(isAuthenticated: true, isLoading: false, email: email, userId: fb.FirebaseAuth.instance.currentUser?.uid);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.signUp(email, password, fullName);
      state = AuthState(isAuthenticated: true, isLoading: false, email: email, userId: fb.FirebaseAuth.instance.currentUser?.uid);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.resetPassword(email);
      state = state.copyWith(isLoading: false, error: 'Password reset email sent');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }
}

extension AuthStateCopy on AuthState {
  AuthState copyWith({bool? isAuthenticated, bool? isLoading, String? error, String? userId, String? email}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      userId: userId ?? this.userId,
      email: email ?? this.email,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
