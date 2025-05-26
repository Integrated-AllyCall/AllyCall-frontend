import 'package:allycall/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:allycall/state/global_flags.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final api = ApiService();

  Future<Widget?> getProfileImage({double size = 100}) async {
    final user = await api.get('users/${_auth.currentUser?.uid}');
    final imageUrl = user['image_url'];
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }

    try {
      final response = await http.head(Uri.parse(imageUrl));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: size,
            width: size,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
          ),
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Image check failed: $e');
      return null;
    }
  }

  getUserId() {
    return _auth.currentUser?.uid;
  }

  getUserName() {
    return _auth.currentUser?.displayName ?? "Guest";
  }

  getUserEmail() {
    return _auth.currentUser?.email ?? "guest@example.com";
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // User cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      final isFirstTime = userCredential.additionalUserInfo?.isNewUser ?? false;

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
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register(String email, String password, String username) async {
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
  }

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload(); // Refresh user data
    return user?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
