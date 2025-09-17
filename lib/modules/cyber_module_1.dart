import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:lottie/lottie.dart';

class CyberModule1 extends StatefulWidget {
  final String role;
  const CyberModule1({super.key, required this.role});

  @override
  State<CyberModule1> createState() => _CyberModule1State();
}

class _CyberModule1State extends State<CyberModule1> {
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
      // 🔹 Reference to the role document
      final roleDocRef = FirebaseFirestore.instance.collection("roles").doc(widget.role);

      // 🔹 Check if role exists
      final roleDoc = await roleDocRef.get();
      if (!roleDoc.exists) {
        setState(() {
          errorMessage = "⚠️ Role '${widget.role}' not found in Firestore.";
          isLoading = false;
        });
        return;
      }

      // 🔹 Reference to modules collection
      final modulesCol = roleDocRef.collection("modules");
      final moduleDoc = await modulesCol.doc("module1").get();

      if (!moduleDoc.exists) {
        setState(() {
          errorMessage = "⚠️ Module 1 not found for role '${widget.role}'.";
          isLoading = false;
        });
        return;
      }

      // 🔹 Load introduction
      introduction = moduleDoc["introduction"] ?? "No introduction found";

      // 🔹 Load video: Storage path or YouTube link
      final videoPath = moduleDoc["videoUrl"] ?? "";
      if (videoPath.isNotEmpty) {
        if (videoPath.startsWith("https://") || videoPath.startsWith("http://")) {
          // YouTube or external link
          videoUrl = videoPath;
        } else {
          // Firebase Storage path
          videoUrl = await FirebaseStorage.instance.ref(videoPath).getDownloadURL();
        }

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
      }

      // 🔹 Check if the user already completed the module for this role
      final completionDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("roles")
          .doc(widget.role)                 // role ke hisaab se
          .collection("completedModules")
          .doc("module1")
          .get();

      if (completionDoc.exists && completionDoc["completed"] == true) {
        isCompleted = true;
      }

    } catch (e) {
      setState(() {
        errorMessage = "⚠️ Failed to load module: $e";
      });
    }

    setState(() {
      isLoading = false;
    });

    debugPrint("🔹 Loaded module1 for role: ${widget.role}, videoUrl: $videoUrl");
  }
  Future<void> _markCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final roleName = widget.role; // jo role screen me pass hua hai
    final moduleName = "module1"; // module ka naam

    try {
      // 🔹 Automatically create structure and set module as completed
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("roles")
          .doc(roleName)
          .collection("completedModules")
          .doc(moduleName)
          .set({
        "completed": true,
      }, SetOptions(merge: true));

      // 🔹 Update overall leaderboard score
      final leaderboardDoc = FirebaseFirestore.instance.collection("leaderboard").doc(user.uid);
      await leaderboardDoc.set({
        "uid": user.uid,
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "photoUrl": user.photoURL ?? "",
        "lastUpdate": FieldValue.serverTimestamp(),
        "score": FieldValue.increment(10), // increment score
      }, SetOptions(merge: true));

      setState(() {
        isCompleted = true;
      });

      debugPrint("✅ Module marked completed & leaderboard updated for ${user.displayName}");
    } catch (e) {
      debugPrint("❌ Error updating modules or leaderboard: $e");
    }
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
        title: Text("${widget.role} - Module 1"),
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
