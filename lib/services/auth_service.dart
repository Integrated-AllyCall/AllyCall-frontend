import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:allycall/state/global_flags.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

// Image getProfileImage({double size = 100}) {
//   final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
//   final proxyUrl = "http://localhost:3000/api/proxy-image?url=${Uri.encodeComponent(photoUrl!)}";

//   return Image.network(
//     proxyUrl,
//     height: size,
//     width: size,
//     fit: BoxFit.cover,
//     errorBuilder: (context, error, stackTrace) {
//       print(error);
//       return Image.network(
//         "https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png",
//         height: size,
//         width: size,
//         fit: BoxFit.cover,
//       );
//     },
//     loadingBuilder: (context, child, loadingProgress) {
//       if (loadingProgress == null) return child;
//       return SizedBox(
//         height: size,
//         width: size,
//         child: const Center(
//           child: CircularProgressIndicator(strokeWidth: 2),
//         ),
//       );
//     },
//   );
// }

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
      //   await FirestoreService.createUser(
      //     user: user,
      //     username: user.displayName ?? 'Guest',
      //   );
      }
      // await FirestoreService.getUserPref(user.uid);
    }
  }

  Future<void> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    // if (user != null) {
    //   await FirestoreService.getUserPref(user.uid);
    // }
  }

  Future<void> register(String email, String password, String username) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(username);
      await user.updatePhotoURL(
        "https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_1280.png",
      );
      // await FirestoreService.createUser(
      //   user: user,
      //   username: username,
      // ); // Save user data to Firestore
      // await FirestoreService.getUserPref(user.uid);
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
    // await CacheService.clearUserPref();
  }
}
