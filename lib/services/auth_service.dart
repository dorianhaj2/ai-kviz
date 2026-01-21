import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// Service for handling Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger? _logger;

  AuthService({Logger? logger}) : _logger = logger;

  /// Gets the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in a user with email and password
  /// 
  /// Throws [FirebaseAuthException] if authentication fails
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger?.d('Attempting sign in for email: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger?.i('Successfully signed in user: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger?.e('Sign in failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Registers a new user with email and password
  /// 
  /// Throws [FirebaseAuthException] if registration fails
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      _logger?.d('Attempting registration for email: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger?.i('Successfully registered user: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger?.e('Registration failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      _logger?.d('Signing out user: ${_auth.currentUser?.email}');
      await _auth.signOut();
      _logger?.i('Successfully signed out');
    } catch (e) {
      _logger?.e('Sign out failed: $e');
      rethrow;
    }
  }

  /// Checks if a user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;
}
