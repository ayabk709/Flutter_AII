import 'package:firebase_auth/firebase_auth.dart';
// Replace the AuthResult and FirebaseUser classes with UserCredential and User,
class AuthService {
  // Create an instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user; // Get the user from the result
      return user;
    } catch (e) {
      print(e.toString());
      return null; // Return null on error
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user; // Get the user from the result
      return user;
    } catch (error) {
      print(error.toString());
      return null; // Return null on error
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user; // Get the user from the result
      return user;
    } catch (error) {
      print(error.toString());
      return null; // Return null on error
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      print(error.toString());
    }
  }
}
