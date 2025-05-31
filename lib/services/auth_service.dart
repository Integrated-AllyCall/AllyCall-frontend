import 'package:allycall/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:allycall/state/global_flags.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final api = ApiService();

  Future<Widget?> getProfileImage({double size = 100}) async {
    try {
      final response = await api.getImage(
        'users/${_auth.currentUser?.uid}/image',
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        return ClipOval(
          child: Image.memory(
            bytes,
            height: size,
            width: size,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: frame != null
                    ? child
                    : SizedBox(
                        height: size,
                        width: size,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
              );
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to load profile image: $e');
    }

    return null;
  }

  getUserId() => _auth.currentUser?.uid;

  getUserName() => _auth.currentUser?.displayName ?? "Guest";

  getUserEmail() => _auth.currentUser?.email ?? "guest@example.com";

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final isFirstTime =
            userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isFirstTime) {
          GlobalFlags.isNewUser = true;
          await api.post("users", {
            'id': user.uid,
            'email': user.email,
            'username': user.displayName,
            'image_url': user.photoURL,
          });
        }
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Email/password sign-in error: $e');
      rethrow;
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(username);
        await sendVerificationEmail();
        GlobalFlags.isNewUser = true;

        await api.post("users", {
          'id': user.uid,
          'email': user.email,
          'username': username,
        });
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      debugPrint('Email verification error: $e');
      rethrow;
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      await user?.reload();
      return user?.emailVerified ?? false;
    } catch (e) {
      debugPrint('Check email verification error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }
}
