import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatefulWidget {
  final String role;
  const LeaderboardScreen({super.key, required this.role});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Future<void> _refreshLeaderboard() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {}); // Trigger rebuild
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "🏆 Leaderboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
        isDarkMode ? Colors.deepPurple[800] : Colors.deepPurple[400],
        centerTitle: true,
        elevation: 8,
        shadowColor: Colors.purpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: isDarkMode ? Colors.white : Colors.black,
            onPressed: _refreshLeaderboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLeaderboard,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('leaderboard')
              .orderBy('score', descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final rank = index + 1;
                final name = user['name'];
                final points = user['score'];

                // 🎖️ Different colors for top 3
                Color cardColor;
                if (rank == 1) {
                  cardColor = Colors.amber.shade400;
                } else if (rank == 2) {
                  cardColor = Colors.grey.shade400;
                } else if (rank == 3) {
                  cardColor = Colors.brown.shade400;
                } else {
                  cardColor = Colors.redAccent;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? cardColor.withOpacity(0.2)
                        : cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cardColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: cardColor,
                      child: Text(
                        "$rank",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: GoogleFonts.poppins(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      "⭐ ${points.toString()} points",
                      style: GoogleFonts.poppins(
                        color:
                        isDarkMode ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                    trailing: rank == 1
                        ? const Icon(Icons.emoji_events,
                        color: Colors.amber, size: 30)
                        : rank == 2
                        ? const Icon(Icons.emoji_events,
                        color: Colors.grey, size: 28)
                        : rank == 3
                        ? const Icon(Icons.emoji_events,
                        color: Colors.brown, size: 28)
                        : Icon(Icons.star,
                        color: isDarkMode
                            ? Colors.purpleAccent
                            : Colors.deepPurple),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
