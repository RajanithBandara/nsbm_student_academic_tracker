import 'package:cloud_firestore/cloud_firestore.dart';
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
          .signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      final user = userCredential.user;

      if (user != null && user.emailVerified) {
        await FirebaseFirestore.instance.collection('student').doc(user.uid).collection('credentials').doc('userInfo').set({
          'email': user.email,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return userCredential;
      } else {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please verify your email before logging in.")),
        );
        return null;
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
      return null;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred.")),
      );
      return null;
    }
  }

  static Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_ID_TOKEN',
          message: "Missing Google ID Token.",
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('student').doc(user.uid).collection('credentials').doc('userInfo').set({
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
      return null;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred during Google Sign-In.")),
      );
      return null;
    }
  }

  static void _handleAuthError(BuildContext context, FirebaseAuthException e) {
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
      case 'account-exists-with-different-credential':
        message = "An account already exists with a different credential.";
        break;
      case 'invalid-credential':
        message = "The credential provided is invalid.";
        break;
      case 'operation-not-allowed':
        message = "Operation not allowed. Please contact support.";
        break;
      case 'ERROR_MISSING_ID_TOKEN':
        message = "Missing Google ID Token.";
        break;
      default:
        message = "An error occurred. Please try again.";
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
