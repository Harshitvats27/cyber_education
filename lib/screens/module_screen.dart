import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class QuizPage extends StatefulWidget {
  final String role; // e.g., Software, Cybersecurity
  const QuizPage({super.key, required this.role});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool isLoading = true;
  String errorMessage = "";
  List<Map<String, dynamic>> quizzes = [];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
      quizzes.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("roles")
          .doc(widget.role) // Hardcoded role
          .collection("quizzes")
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          errorMessage = "No quizzes found for this role.";
          isLoading = false;
        });
        return;
      }

      for (var doc in snapshot.docs) {
        quizzes.add({
          "title": doc["title"] ?? "Untitled Quiz",
          "link": doc["link"] ?? "",
          "animation": doc["animation"] ?? "assets/animation/quiz.json",
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load quizzes: $e";
        isLoading = false;
      });
    }
  }
  Future<void> _openQuizLink(String link) async {
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the quiz link.")),
      );
    }
  }



  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    return GestureDetector(
      onTap: () => _openQuizLink(quiz["link"]),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Animated icon using Lottie
              Lottie.asset(
                quiz["animation"],
                width: 80,
                height: 80,
                repeat: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  quiz["title"],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quizzes"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuizzes,
            tooltip: "Reload Quizzes",
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          return _buildQuizCard(quizzes[index]);
        },
      ),
    );
  }
}
