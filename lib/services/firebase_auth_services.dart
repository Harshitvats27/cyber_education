import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 🔹 Sign in with Google and store user in Firestore
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled login

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final leaderboardDoc = _firestore.collection("leaderboard").doc(user.uid);
        final docSnapshot = await leaderboardDoc.get();

        if (!docSnapshot.exists) {
          // 🔹 First-time login: set score = 0
          await leaderboardDoc.set({
            "uid": user.uid,
            "name": user.displayName ?? "",
            "email": user.email ?? "",
            "photoUrl": user.photoURL ?? "",
            "score": 0, // first-time score
            "createdAt": FieldValue.serverTimestamp(),
            "lastLogin": FieldValue.serverTimestamp(),
          });
        } else {
          // 🔹 Subsequent logins: only update lastLogin
          await leaderboardDoc.update({
            "lastLogin": FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      return null;
    }
  }

  /// 🔹 Sign out (Google + Firebase)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("❌ Sign Out Error: $e");
    }
  }

  /// 🔹 Get current user
  User? getCurrentUser() => _auth.currentUser;
}
