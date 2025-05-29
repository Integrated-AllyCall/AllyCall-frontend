import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:allycall/services/auth_service.dart';
import 'package:allycall/widgets/custom_button.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isSending = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();

    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final isVerified = user?.emailVerified ?? false;

    if (isVerified) {
      _timer.cancel();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isSending = true);
    await AuthService().sendVerificationEmail();
    if (!mounted) return;
    setState(() => _isSending = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification email resent')));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA587E7),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(30),
          width: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image.asset('assets/icon/icon.png', height: 50),
              const SizedBox(height: 10),
              Text(
                'Verify your email',
                style: GoogleFonts.livvic(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7C55D4),
                ),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.livvic(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  children: [
                    const TextSpan(text: 'We sent a verification link to\n'),
                    TextSpan(
                      text: AuthService().getUserEmail(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(text: '\nPlease verify to continue.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: 'Resend Email',
                icon: Icons.send,
                isLoading: _isSending,
                onPressed: _resendEmail,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  await AuthService().signOut();
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
