import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class LeaderboardPage extends StatefulWidget {
  final String role; // e.g., Software, Cybersecurity
  const LeaderboardPage({super.key, required this.role});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool isLoading = true;
  String errorMessage = "";
  List<Map<String, dynamic>> leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      isLoading = true;
      leaderboard.clear();
      errorMessage = "";
    });

    try {
      final usersSnapshot =
      await FirebaseFirestore.instance.collection("users").get();

      if (usersSnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = "No users found.";
          isLoading = false;
        });
        return;
      }

      for (var userDoc in usersSnapshot.docs) {
        final roleDoc = await userDoc.reference
            .collection("roles")
            .doc("Software")
            .get();

        if (roleDoc.exists) {
          leaderboard.add({
            "name": userDoc["name"] ?? "Unknown",
            "score": roleDoc["score"] ?? 0,
          });
        }
      }

      // Sort descending by score
      leaderboard.sort((a, b) => (b["score"] as int).compareTo(a["score"] as int));

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load leaderboard: $e";
        isLoading = false;
      });
    }
  }

  Widget _buildTopRankAnimation(int index) {
    // 🎖️ Display trophy/confetti animations for top 3
    if (index == 0) {
      return Lottie.asset("assets/animation/Technology.json", width: 60);
    } else if (index == 1) {
      return Lottie.asset("assets/animation/datasecurity.json", width: 60);
    } else if (index == 2) {
      return Lottie.asset("assets/animations/bronze_trophy.json", width: 60);
    } else {
      return CircleAvatar(
        backgroundColor: Colors.deepPurple,
        child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.role} Leaderboard"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(errorMessage,
            style: const TextStyle(color: Colors.red)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final user = leaderboard[index];
          return Card(
            elevation: 6,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: _buildTopRankAnimation(index),
              title: Text(
                user["name"],
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "${user["score"]} pts",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: index < 3
                        ? Colors.orange
                        : Colors.deepPurple),
              ),
            ),
          );
        },
      ),
    );
  }
}
