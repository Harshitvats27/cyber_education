import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';

class AssessmentPage extends StatefulWidget {
  final String role; // Software, Cybersecurity, etc.
  const AssessmentPage({super.key, required this.role});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  Map<String, TextEditingController> textControllers = {};
  Map<String, File?> pickedFiles = {}; // Key: moduleId_questionId
  Map<String, String> questionTypes = {};
  Map<String, List<Map<String, dynamic>>> moduleQuestions = {};
  Map<String, bool> moduleCompleted = {};
  Map<String, bool> questionSubmitted = {}; // Key: moduleId_questionId

  bool isLoading = true;
  String errorMessage = "";
  String submittingKey = "";

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
      textControllers.clear();
      pickedFiles.clear();
      questionTypes.clear();
      moduleQuestions.clear();
      moduleCompleted.clear();
      questionSubmitted.clear();
    });

    try {
      final modulesSnap = await FirebaseFirestore.instance
          .collection("roles")
          .doc(widget.role) // Hardcoded role
          .collection("modules")
          .get();

      if (modulesSnap.docs.isEmpty) {
        setState(() {
          errorMessage = "No modules found for this role.";
          isLoading = false;
        });
        return;
      }

      final user = FirebaseAuth.instance.currentUser;

      for (var moduleDoc in modulesSnap.docs) {
        final questionsSnap =
        await moduleDoc.reference.collection("questions").get();

        if (questionsSnap.docs.isNotEmpty) {
          moduleQuestions[moduleDoc.id] = [];
          moduleCompleted[moduleDoc.id] = false;

          for (var qDoc in questionsSnap.docs) {
            final qId = qDoc.id;
            final qText = qDoc["question"] ?? "";
            final qType = qDoc["type"] ?? "text";

            final key = "${moduleDoc.id}_$qId"; // Unique key per module+question
            questionTypes[key] = qType;
            textControllers[key] = TextEditingController();
            pickedFiles[key] = null;

            // Check if question already submitted
            if (user != null) {
              final doc = await FirebaseFirestore.instance
                  .collection("submissions")
                  .doc(user.uid)
                  .collection(widget.role) // Hardcoded role
                  .doc(moduleDoc.id)
                  .collection("questions")
                  .doc(qId)
                  .get();
              questionSubmitted[key] = doc.exists;

              if (doc.exists) {
                textControllers[key]?.text = doc["text"] ?? "";
              }
            } else {
              questionSubmitted[key] = false;
            }

            moduleQuestions[moduleDoc.id]!.add({
              "id": qId,
              "text": qText,
              "type": qType,
            });
          }

          // Mark module completed if all questions submitted
          final allSubmitted = moduleQuestions[moduleDoc.id]!.every((q) {
            final key = "${moduleDoc.id}_${q["id"]}";
            return questionSubmitted[key] == true;
          });
          moduleCompleted[moduleDoc.id] = allSubmitted;
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load modules: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _pickFile(String moduleId, String questionId) async {
    final key = "${moduleId}_$questionId";
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        pickedFiles[key] = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitAnswer(String moduleId, String questionId) async {
    final key = "${moduleId}_$questionId";
    if (questionSubmitted[key] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already submitted this question.")),
      );
      return;
    }

    setState(() {
      submittingKey = key;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? downloadUrl;
      final file = pickedFiles[key];

      if (file != null) {
        final ref = FirebaseStorage.instance
            .ref("submissions/${widget.role}/$moduleId/${questionId}_${file.path.split('/').last}");
        await ref.putFile(file);
        downloadUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection("submissions")
          .doc(user.uid)
          .collection(widget.role) // Hardcoded role
          .doc(moduleId)
          .collection("questions")
          .doc(questionId)
          .set({
        "text": (questionTypes[key] != "file") ? textControllers[key]?.text ?? "" : "",
        "fileUrl": downloadUrl ?? "",
        "submittedAt": FieldValue.serverTimestamp(),
      });

      questionSubmitted[key] = true;

      // Check if all questions submitted for module
      final allSubmitted = moduleQuestions[moduleId]!.every((q) {
        final qKey = "${moduleId}_${q["id"]}";
        return questionSubmitted[qKey] == true;
      });
      if (allSubmitted) moduleCompleted[moduleId] = true;

      setState(() {
        submittingKey = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Answer submitted successfully!")),
      );
    } catch (e) {
      setState(() {
        submittingKey = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    }
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question, String moduleId) {
    final qId = question["id"];
    final key = "${moduleId}_$qId";
    final qType = question["type"];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question["text"], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            if (qType == "text" || qType == "both")
              TextField(
                controller: textControllers[key],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Your Answer",
                ),
                maxLines: null,
                enabled: !(questionSubmitted[key] ?? false),
              ),
            const SizedBox(height: 8),
            if (qType == "file" || qType == "both")
              Row(
                children: [
                  ElevatedButton(
                    onPressed: (questionSubmitted[key] ?? false)
                        ? null
                        : () => _pickFile(moduleId, qId),
                    child: const Text("Upload File"),
                  ),
                  const SizedBox(width: 12),
                  if (pickedFiles[key] != null)
                    Expanded(
                      child: Text(
                        pickedFiles[key]!.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: submittingKey == key || (questionSubmitted[key] ?? false)
                  ? null
                  : () => _submitAnswer(moduleId, qId),
              child: submittingKey == key
                  ? Lottie.asset(
                "assets/animation/Confetti.json",
                width: 50,
                height: 50,
                repeat: true,
              )
                  : Text((questionSubmitted[key] ?? false) ? "Already Submitted" : "Submit Answer"),
            ),
          ],
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
        title: Text("${widget.role} - Assessment"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadModules,
            tooltip: "Reload Modules",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: moduleQuestions.entries.map((moduleEntry) {
            final moduleId = moduleEntry.key;
            final questions = moduleEntry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(moduleId.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    if (moduleCompleted[moduleId] == true)
                      Lottie.asset(
                        "assets/animation/Checkanimation.json",
                        width: 40,
                        height: 40,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ...questions.map((q) => _buildQuestionWidget(q, moduleId)).toList(),
                const Divider(thickness: 2),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
