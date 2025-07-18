import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in anonymously
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register a new user
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } catch (e) {
      print("Error registering: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    username = 'Guest';
    useremail = 'guest@example.com';
    userId = '';
    quizzesCompleted = 0;
    totalCorrect = 0;
    totalAnswers = 0;
    averageScore = 0.0;
    isAdmin = false;
  }
}
