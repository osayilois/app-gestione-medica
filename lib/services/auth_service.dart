// Logica di autenticazione (login, registrazione, logout)

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login
  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Errore di accesso";
    }
  }

  // Registrazione
  Future<User?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Errore nella registrazione";
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream per verificare login
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
