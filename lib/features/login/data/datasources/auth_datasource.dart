import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Raw Firebase Auth + Firestore calls.
/// Returns Firebase types; repository converts them to domain entities.
class AuthDatasource {
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get rawUserStream => _auth.authStateChanges();
  User?         get rawUser        => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) {
    return _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<bool> checkIsAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      return doc.data()?['isAdmin'] == true;
    } catch (e) {
      if (kDebugMode) debugPrint('AuthDatasource.checkIsAdmin error: $e');
      return false;
    }
  }
}
