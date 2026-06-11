abstract class AuthRepository {
  Stream<bool> get authState;
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String fullName);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}
