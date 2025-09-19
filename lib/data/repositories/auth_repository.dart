import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthCancelledException implements Exception {
  const AuthCancelledException(this.provider);

  final String provider;

  @override
  String toString() => 'AuthCancelledException(provider: $provider)';
}

class AuthUnavailableException implements Exception {
  const AuthUnavailableException(this.provider);

  final String provider;

  @override
  String toString() => 'AuthUnavailableException(provider: $provider)';
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _googleInitialized = googleSignIn != null;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) {
      return;
    }
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }


  FirebaseAuth get auth => _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return _auth.signInWithPopup(provider);
    }

    await _ensureGoogleInitialized();

    try {
      final account = await _googleSignIn.authenticate();
      final auth = account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw const AuthUnavailableException('google');
      }
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );
      return _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException('google');
      }
      throw AuthUnavailableException('google');
    }

  }


  Future<UserCredential> signInWithApple() async {
    final provider = AppleAuthProvider();
    if (kIsWeb) {
      return _auth.signInWithPopup(provider);
    }
    final available = await SignInWithApple.isAvailable();
    if (!available) {
      throw const AuthUnavailableException('apple');
    }
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );
    return _auth.signInWithCredential(oauthCredential);
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();
}
