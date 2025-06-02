import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up method
  Future<String> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid ?? 'Signup failed';
    } on FirebaseAuthException catch (e) {
      print('firebase error');
      print(e);
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email already in use';
        case 'invalid-email':
          return 'Invalid email';
        case 'weak-password':
          return 'Weak password';
        default:
          return 'Signup error: ${e.code}';
      }
    } catch (e) {
      return 'Unexpected signup error';
    }
  }

  // Sign in method
  Future<String> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid ?? 'Login failed';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email';
        case 'user-disabled':
          return 'User is disabled';
        default:
          return 'Login error: ${e.code}';
      }
    } catch (e) {
      return 'Unexpected login error';
    }
  }

  // Logout method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get current user's UID
  String? getCurrentUserUid() {
    return _auth.currentUser?.uid;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      print('Failed to send password reset email: ${e.message}');
      rethrow; // Optional: rethrow for UI to handle
    }
  }
}
