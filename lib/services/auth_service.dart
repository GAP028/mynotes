import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();

  static String messageFromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return "L'adresse e-mail n'est pas valide.";
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cette adresse e-mail.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (6 caractères minimum).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou mot de passe incorrect.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Problème de connexion réseau.';
      case 'operation-not-allowed':
        return "La connexion par e-mail n'est pas activée dans Firebase.";
      default:
        return 'Une erreur est survenue ($code).';
    }
  }
}
