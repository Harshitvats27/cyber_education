import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  String role;
  NotificationScreen({super.key,required this.role});
 // const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,   // full screen width
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            color: Colors.black,
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
