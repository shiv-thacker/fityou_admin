import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Scopes must cover what `google_sign_in_web` / People API need; missing
  /// scopes or disabled People API → 403 on `people/me`.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const <String>[
      'openid',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return AuthResult.cancelled;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) return AuthResult.error;

      final isAdmin = await _checkIsAdmin(user.uid);
      if (!isAdmin) {
        await _auth.signOut();
        await _googleSignIn.signOut();
        return AuthResult.notAdmin;
      }

      return AuthResult.success;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('signInWithGoogle error: $e');
        debugPrint('$st');
      }
      // Popup closed by user, blocked by browser, or dismissed — not a server failure.
      final msg = e.toString().toLowerCase();
      if (msg.contains('popup_closed') ||
          msg.contains('popup blocked') ||
          msg.contains('popup_blocked') ||
          msg.contains('user_canceled') ||
          msg.contains('access_denied')) {
        return AuthResult.cancelled;
      }
      return AuthResult.error;
    }
  }

  Future<bool> _checkIsAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      return doc.data()?['isAdmin'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get isCurrentUserAdmin async {
    final user = _auth.currentUser;
    if (user == null) return false;
    return _checkIsAdmin(user.uid);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}

enum AuthResult { success, notAdmin, cancelled, error }
