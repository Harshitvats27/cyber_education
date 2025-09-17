import 'package:cyber_education/screens/settings_screen.dart';
import 'package:cyber_education/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart'; // Make sure path is correct

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? user;
  Map<String, dynamic>? leaderboardData;
  bool isDark = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("leaderboard")
          .doc(user!.uid)
          .get();
      leaderboardData = doc.data();
    }

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    isDark = themeProvider.themeMode == ThemeMode.dark;

    setState(() {
      isLoading = false;
    });
  }

  void _toggleTheme(bool value) {
    setState(() {
      isDark = value;
    });
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(isDark);
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();

    // 🔹 Redirect to login screen after sign out
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 User Info
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user?.photoURL ?? "https://i.pravatar.cc/150"),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? "No Name",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              user?.email ?? "No Email",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // 🔹 Leaderboard Score
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Lottie.asset(
                  "assets/animation/Checkanimation.json",
                  width: 50,
                  height: 50,
                ),
                title: const Text("Score"),
                subtitle: Text("${leaderboardData?['score'] ?? 0} points"),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Theme Switch
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text("Dark Mode"),
                value: isDark,
                onChanged: _toggleTheme,
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Logout Button
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
