import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  String role;
  SettingsScreen({super.key,required this.role});
 // const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,   // full screen width
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.black
        ),// full screen height
        child: const Center(
          child: Text(
            "Work in progress",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
          ),
        ),
      ),

    );
  }
}

