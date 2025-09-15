import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:lottie/lottie.dart';

class CyberModule3 extends StatefulWidget {
  final String role;
  const CyberModule3({super.key, required this.role});

  @override
  State<CyberModule3> createState() => _CyberModule3State();
}

class _CyberModule3State extends State<CyberModule3> {
  String introduction = "";
  String videoUrl = "";
  bool isCompleted = false;
  bool isLoading = true;
  String errorMessage = "";

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _loadModule();
  }

  Future<void> _loadModule() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        errorMessage = "⚠️ You must be signed in to access this module.";
        isLoading = false;
      });
      return;
    }

    try {
      // 🔹 Fetch module5 data dynamically
      final doc = await FirebaseFirestore.instance
          .collection("roles")
          .doc(widget.role) // dynamic role
          .collection("modules")
          .doc("module3")
          .get();

      if (!doc.exists) {
        setState(() {
          errorMessage = "⚠️ Module 3 data not found in Firestore.";
          isLoading = false;
        });
        return;
      }

      introduction = doc["introduction"] ?? "No introduction found";
      final storagePath = doc["videoUrl"] ?? "";

      // 🔹 Get video download URL
      if (storagePath.isNotEmpty) {
        videoUrl =
        await FirebaseStorage.instance.ref(storagePath).getDownloadURL();

        _videoController = VideoPlayerController.network(videoUrl);
        await _videoController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          allowPlaybackSpeedChanging: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.deepPurple,
            handleColor: Colors.deepPurpleAccent,
            bufferedColor: Colors.grey,
            backgroundColor: Colors.black26,
          ),
        );

        setState(() {});
      }

      // 🔹 Check if user completed module5
      final completionDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("completedModules")
          .doc("module3")
          .get();

      if (completionDoc.exists && completionDoc["completed"] == true) {
        isCompleted = true;
      }
    } catch (e) {
      errorMessage = "⚠️ Failed to load module: $e";
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _markCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("completedModules")
        .doc("module3")
        .set({"completed": true});

    setState(() {
      isCompleted = true;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.role} - Module 3"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage.isNotEmpty)
              Text(errorMessage,
                  style:
                  const TextStyle(color: Colors.red, fontSize: 16)),

            if (introduction.isNotEmpty)
              Text(
                introduction,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
            const SizedBox(height: 24),

            if (_chewieController != null &&
                _videoController != null &&
                _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            else if (videoUrl.isNotEmpty)
              const Text("⚠️ Video is loading..."),

            const SizedBox(height: 32),

            GestureDetector(
              onTap: () {
                if (!isCompleted) _markCompleted();
              },
              child: Row(
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: isCompleted
                        ? Lottie.asset("assets/animation/Checkanimation.json")
                        : Lottie.asset("assets/animation/Confetti.json"),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCompleted
                        ? "Module Completed 🎉"
                        : "Mark as Completed",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
