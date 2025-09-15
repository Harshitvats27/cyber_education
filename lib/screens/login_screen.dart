import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/firebase_auth_services.dart';
import '../widgets/google_sigin_button.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final user = await _authService.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      // Navigate to Home Screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show error or user cancelled login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Google Sign-In failed. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated cyber security illustration
                Lottie.asset(
                  'assets/animation/datasecurity.json',
                  height: 250,
                  repeat: true,
                ),

                const SizedBox(height: 20),

                Text(
                  "Welcome to SecureLearn",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Learn Cybersecurity with fun & gamification",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),

                // Show loading or Google Sign-In Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : GoogleSignInButton(onPressed: _handleGoogleSignIn),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
