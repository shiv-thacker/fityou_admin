import '../entities/app_user_entity.dart';

/// Result codes returned by [AuthRepository.signIn].
enum SignInResult {
  success,
  notAdmin,
  invalidCredentials,
  tooManyRequests,
  error,
}

/// Auth repository contract — domain layer, no implementation details.
abstract interface class AuthRepository {
  Stream<AppUserEntity?> get userStream;
  AppUserEntity? get currentUser;

  Future<SignInResult> signIn(String email, String password);
  Future<void> signOut();
  Future<bool> get isCurrentUserAdmin;
}
