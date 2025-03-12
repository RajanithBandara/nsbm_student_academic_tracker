import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }
  static Future<UserCredential?> signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      final user = userCredential.user;
      if (user != null && user.emailVerified) {
        return userCredential;
      } else {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please verify your email before logging in."),
          ),
        );
        return null;
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = "The email address is not valid.";
          break;
        case 'user-disabled':
          message = "This user has been disabled.";
          break;
        case 'user-not-found':
          message = "No user found with this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        default:
          message = "An error occurred. Please try again.";
          break;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return null;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred.")),
      );
      return null;
    }
  }

  static Future<UserCredential?> signInWithGoogle(
      BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the sign-in.
        return null;
      }
      final googleAuth = await googleUser.authentication;

      // Check if ID token is available.
      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_ID_TOKEN',
          message: "Missing Google ID Token.",
        );
      }

      // Create a new credential using the tokens.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential.
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = "An account already exists with a different credential.";
          break;
        case 'invalid-credential':
          message = "The credential provided is invalid.";
          break;
        case 'operation-not-allowed':
          message = "Operation not allowed. Please contact support.";
          break;
        case 'user-disabled':
          message = "This user has been disabled.";
          break;
        case 'ERROR_MISSING_ID_TOKEN':
          message = "Missing Google ID Token.";
          break;
        default:
          message = "An error occurred. Please try again.";
          break;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return null;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An unexpected error occurred during Google Sign-In.")),
      );
      return null;
    }
  }
}
