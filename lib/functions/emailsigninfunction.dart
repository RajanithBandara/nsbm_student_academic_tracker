import 'package:firebase_auth/firebase_auth.dart';

// Email/Password sign-in method
Future<User?> signInWithEmailPassword(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user; // Return the user if successful
  } catch (e) {
    print("Error during Email/Password Sign-In: $e");
    return null; // Return null if there was an error
  }
}
