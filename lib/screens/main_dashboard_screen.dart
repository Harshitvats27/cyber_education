// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
// import 'package:intl/intl.dart';
//
// class MainDashboardScreen extends StatefulWidget {
//   final String role;
//   const MainDashboardScreen({super.key, required this.role});
//
//   @override
//   State<MainDashboardScreen> createState() => _MainDashboardScreenState();
// }
//
// class _MainDashboardScreenState extends State<MainDashboardScreen> {
//   int totalPoints = 0;
//   int dailyStreak = 0;
//   int completedModules = 0;
//   int newNotifications = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchRoleDashboard();
//   }
//
//   Future<void> fetchRoleDashboard() async {
//     try {
//       final roleDoc = await FirebaseFirestore.instance
//           .collection('roles')
//           .doc(widget.role)
//           .get();
//
//       if (roleDoc.exists) {
//         setState(() {
//           totalPoints = roleDoc.data()?['points'] ?? 0;
//           dailyStreak = roleDoc.data()?['daily_streak'] ?? 0;
//           completedModules = roleDoc.data()?['completed_modules'] ?? 0;
//           newNotifications = roleDoc.data()?['notifications'] ?? 0;
//         });
//       }
//     } catch (e) {
//       print("Error fetching role dashboard: $e");
//     }
//   }
//
//   Widget buildStatCard(String title, String value, Color color, IconData icon) {
//     return Animate(
//       effects: const [FadeEffect(duration: Duration(milliseconds: 500))],
//       child: Container(
//         width: 160,
//         padding: const EdgeInsets.all(16),
//         margin: const EdgeInsets.only(right: 16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.4),
//               blurRadius: 8,
//               offset: const Offset(2, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, size: 28, color: Colors.white),
//             const SizedBox(height: 12),
//             Text(
//               value,
//               style: const TextStyle(
//                   fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             const SizedBox(height: 4),
//             Text(title, style: const TextStyle(color: Colors.white70)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F6F6),
//       appBar: AppBar(
//         title: const Text("SecureLearn Dashboard"),
//         backgroundColor: Colors.deepPurple,
//         leading: IconButton(
//           icon: const Icon(Icons.menu),
//           onPressed: () => ZoomDrawer.of(context)!.toggle(),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(18.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Category: ${widget.role}",
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               const Text("Your Progress",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     buildStatCard("Total Points", "$totalPoints", Colors.deepPurple, Icons.star),
//                     buildStatCard("Daily Streak", "$dailyStreak", Colors.blue, Icons.whatshot),
//                     buildStatCard("Modules Done", "$completedModules", Colors.teal, Icons.check_circle),
//                     buildStatCard("Notifications", "$newNotifications", Colors.orange, Icons.notifications),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text("Recent Activities",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               ListTile(
//                 leading: const Icon(Icons.check_circle_outline, color: Colors.green),
//                 title: const Text("Completed Module: Introduction to Cybersecurity"),
//                 subtitle: Text(DateFormat('MMM dd, hh:mm a').format(DateTime.now())),
//               ).animate().fadeIn(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:intl/intl.dart';

class MainDashboardScreen extends StatefulWidget {
  final String role;
  const MainDashboardScreen({super.key, required this.role});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int totalPoints = 0;
  int dailyStreak = 0;
  int completedModules = 0;
  int newNotifications = 0;

  @override
  void initState() {
    super.initState();
    fetchRoleDashboard();
  }

  Future<void> fetchRoleDashboard() async {
    try {
      final roleDoc = await FirebaseFirestore.instance
          .collection('roles')
          .doc(widget.role)
          .get();

      if (roleDoc.exists) {
        setState(() {
          totalPoints = roleDoc.data()?['points'] ?? 0;
          dailyStreak = roleDoc.data()?['daily_streak'] ?? 0;
          completedModules = roleDoc.data()?['completed_modules'] ?? 0;
          newNotifications = roleDoc.data()?['notifications'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching role dashboard: $e");
    }
  }

  Widget buildStatCard(String title, String value, Color color, IconData icon) {
    return Animate(
      effects: const [FadeEffect(duration: Duration(milliseconds: 500))],
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          "SecureLearn Dashboard",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Category: ${widget.role}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Your Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildStatCard("Total Points", "$totalPoints", Colors.deepPurple, Icons.star),
                    buildStatCard("Daily Streak", "$dailyStreak", Colors.blue, Icons.whatshot),
                    buildStatCard("Modules Done", "$completedModules", Colors.teal, Icons.check_circle),
                    buildStatCard("Notifications", "$newNotifications", Colors.orange, Icons.notifications),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Recent Activities",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text(
                  "Completed Module: Introduction to Cybersecurity",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, hh:mm a').format(DateTime.now()),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ).animate().fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
