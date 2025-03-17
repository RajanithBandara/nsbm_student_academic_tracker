import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServiceSignup {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<User?> createUserWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = userCredential.user;

      // Send email verification
      if (user != null) {
        await user.sendEmailVerification();
      }
      return user;
    } on FirebaseAuthException {

      rethrow;
    }
  }

  static Future<User?> signInWithGoogle() async {
    // Attempt to sign in the user with Google
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User cancelled Google sign-in
      return null;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      // Store (or update) the user's displayName and email in Firestore
      await FirebaseFirestore.instance.collection('student').doc(user.uid).collection('credentials').add({
        'displayName': user.displayName,
        'email': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }
}
