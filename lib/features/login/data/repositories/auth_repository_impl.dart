import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/app_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// Concrete auth repository — converts Firebase types to domain entities
/// and maps [FirebaseAuthException] codes to [SignInResult] values.
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _ds;

  AuthRepositoryImpl(this._ds);

  // ── Helpers ──────────────────────────────────────────────────────────────

  AppUserEntity _toEntity(User user, {bool isAdmin = false}) => AppUserEntity(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isAdmin: isAdmin,
      );

  // ── AuthRepository ───────────────────────────────────────────────────────

  @override
  Stream<AppUserEntity?> get userStream =>
      _ds.rawUserStream.map((u) => u == null ? null : _toEntity(u));

  @override
  AppUserEntity? get currentUser {
    final u = _ds.rawUser;
    return u == null ? null : _toEntity(u);
  }

  @override
  Future<SignInResult> signIn(String email, String password) async {
    try {
      final cred = await _ds.signInWithEmailAndPassword(email, password);
      final user = cred.user;
      if (user == null) return SignInResult.error;

      final isAdmin = await _ds.checkIsAdmin(user.uid);
      if (kDebugMode) {
        debugPrint(
            'Auth: uid=${user.uid}, isAdmin=$isAdmin '
            '(users/${user.uid}.isAdmin)');
      }
      if (!isAdmin) {
        await _ds.signOut();
        return SignInResult.notAdmin;
      }
      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) debugPrint('AuthRepositoryImpl.signIn: ${e.code}');
      const badCreds = {
        'user-not-found', 'wrong-password',
        'invalid-credential', 'invalid-email',
      };
      if (badCreds.contains(e.code)) return SignInResult.invalidCredentials;
      if (e.code == 'too-many-requests') return SignInResult.tooManyRequests;
      return SignInResult.error;
    } catch (e) {
      if (kDebugMode) debugPrint('AuthRepositoryImpl.signIn error: $e');
      return SignInResult.error;
    }
  }

  @override
  Future<void> signOut() => _ds.signOut();

  @override
  Future<bool> get isCurrentUserAdmin async {
    final u = _ds.rawUser;
    if (u == null) return false;
    return _ds.checkIsAdmin(u.uid);
  }
}
