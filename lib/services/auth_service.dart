import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:allycall/state/global_flags.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/gg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Widget getProfileImage({
    double size = 100,
    bool isCircular = true,
    Color? fallbackColor,
  }) {
    Widget fallbackIcon() =>
        Iconify(Gg.profile, size: size, color: fallbackColor ?? Colors.grey);
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    if (photoUrl == null || photoUrl.isEmpty) {
      return fallbackIcon();
    }

    final image = CachedNetworkImage(
      imageUrl: photoUrl,
      height: size,
      width: size,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) {
        print(error);
        return fallbackIcon();
      },
      placeholder:
          (context, url) =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );

    return isCircular
        ? ClipOval(child: image)
        : ClipRRect(borderRadius: BorderRadius.circular(12), child: image);
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
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
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
