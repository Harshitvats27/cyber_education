import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final snapshot = await _db.collection('roles').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? 'Unknown',
          'animation': data['animation'] ?? 'assets/animation/default.json',
          'colorStart': data['colorStart'] ?? 0xFF2196F3,
          'colorEnd': data['colorEnd'] ?? 0xFF9C27B0,
        };
      }).toList();
    } catch (e) {
      print("Error fetching roles: $e");
      return []; // Return empty list on error
    }
  }
}
