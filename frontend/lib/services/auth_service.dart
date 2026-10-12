import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'api_service.dart';
import '../models/schedule.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: const String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
      defaultValue: '505052765177-jgrkglr7gl2iag31r7l62n3mukc255ct.apps.googleusercontent.com',
    ),
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Firestore user document sync
  // ---------------------------------------------------------------------------

  /// Upserts a user document in Firestore under `users/{uid}`.
  Future<void> syncUserToFirestore(User user) async {
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final snapshot = await docRef.get();

      final data = <String, dynamic>{
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'lastSignInAt': FieldValue.serverTimestamp(),
        'providers': user.providerData.map((p) => p.providerId).toList(),
      };

      if (!snapshot.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await docRef.set(data);
        debugPrint('AuthService: New user doc created in Firestore for ${user.uid}');
      } else {
        await docRef.update({
          'email': data['email'],
          'displayName': data['displayName'],
          'photoURL': data['photoURL'],
          'lastSignInAt': data['lastSignInAt'],
          'providers': data['providers'],
        });
        debugPrint('AuthService: User doc updated in Firestore for ${user.uid}');
      }
    } catch (e) {
      debugPrint('AuthService: Firestore sync error (non-blocking): $e');
    }
  }

  /// Syncs user profile to the backend via /api/auth/sync-user (fire-and-forget)
  Future<void> _syncToBackend(User user) async {
    try {
      final targetUrl = await ApiService.findReachableUrl() ?? 'http://127.0.0.1:8000';
      final idToken = await user.getIdToken();
      await http
          .post(
            Uri.parse('$targetUrl/api/auth/sync-user'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({
              'display_name': user.displayName ?? '',
              'email': user.email ?? '',
              'photo_url': user.photoURL ?? '',
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('AuthService: Backend sync non-blocking error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Sign in with Google
  // ---------------------------------------------------------------------------
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await syncUserToFirestore(user);
        _syncToBackend(user); // fire and forget
      }
      return userCredential;
    } catch (e) {
      debugPrint('AuthService: Google sign-in error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign in with Email & Password
  // ---------------------------------------------------------------------------
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = userCredential.user;
    if (user != null) {
      await syncUserToFirestore(user);
      _syncToBackend(user); // fire and forget
    }
    return userCredential;
  }

  // ---------------------------------------------------------------------------
  // Register with Email & Password
  // ---------------------------------------------------------------------------
  Future<UserCredential> registerWithEmailPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(displayName.trim());
      await user.reload();
      final refreshed = _auth.currentUser!;
      await syncUserToFirestore(refreshed);
      _syncToBackend(refreshed); // fire and forget
    }
    return userCredential;
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await clearUserTimetable();
    await _auth.signOut();
  }
}
