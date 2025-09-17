import 'package:cyber_education/modules/cyber_module_1.dart';
import 'package:cyber_education/modules/cyber_module_2.dart';
import 'package:cyber_education/modules/cyber_module_3.dart';
import 'package:cyber_education/modules/cyber_module_4.dart';
import 'package:cyber_education/modules/cyber_module_5.dart';
import 'package:cyber_education/screens/assesment_screen.dart';
import 'package:cyber_education/screens/module_screen.dart';
import 'package:cyber_education/screens/notification_screen.dart';
import 'package:cyber_education/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'leaderbord_screen.dart';
import 'login_screen.dart';

class MenuDashboardScreen extends StatelessWidget {
  final String role;
  final VoidCallback? onItemSelected;

  const MenuDashboardScreen({super.key, required this.role, this.onItemSelected});

  final List<_MenuItem> menuItems = const [
    _MenuItem("Cyber Module 1", Icons.security),
    _MenuItem("Cyber Module 2", Icons.security),
    _MenuItem("Cyber Module 3", Icons.security),
    _MenuItem("Cyber Module 4", Icons.security),
    _MenuItem("Cyber Module 5", Icons.security),
    _MenuItem("Quiz", Icons.video_library),
    _MenuItem("Assessments", Icons.assessment),
    _MenuItem("Leaderboard", Icons.leaderboard),
    _MenuItem("Notifications", Icons.notifications),
    _MenuItem("Settings", Icons.settings),
    _MenuItem("Logout", Icons.logout),
  ];

  void onMenuTap(BuildContext context, int index) async {
    onItemSelected?.call();

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => CyberModule1(role: role)));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => CyberModule2(role: role)));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => CyberModule3(role: role)));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => CyberModule4(role: role)));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => CyberModule5(role: role)));
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPage(role: role)));
        break;
      case 6:
        Navigator.push(context, MaterialPageRoute(builder: (_) => AssessmentPage(role: role)));
        break;
      case 7:
        Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardScreen(role: role)));
        break;
      case 8:
        Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen(role: role)));
        break;
      case 9:
        Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
        break;
      case 10: // Logout
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/icons/user.jpg"),
              ),
              const SizedBox(height: 12),
              Text(
                role,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return ListTile(
                      onTap: () => onMenuTap(context, index), // ✅ FIXED
                      leading: Icon(item.icon, color: Colors.white),
                      title: Text(
                        item.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  const _MenuItem(this.title, this.icon);
}
