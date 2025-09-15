import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/firebase_auth_services.dart';
import '../services/firestore_services.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> roles = [];
  String userName = "User";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchRoles();
  }

  void _loadUser() {
    final user = _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        userName = user.displayName ?? "User";
      });
    }
  }

  Future<void> _fetchRoles() async {
    setState(() => _isLoading = true);
    try {
      final fetchedRoles = await _firestoreService.getRoles();
      setState(() {
        roles = fetchedRoles;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading roles: $e");
      setState(() => _isLoading = false);
    }
  }

  Color _parseColor(dynamic colorValue, int fallback) {
    if (colorValue is int) return Color(colorValue);
    if (colorValue is String) return Color(int.tryParse(colorValue) ?? fallback);
    return Color(fallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $userName"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fixed top banner animation
          Lottie.asset(
            'assets/animation/Technology.json',
            height: 180,
            repeat: true,
          ),
          const SizedBox(height: 10),

          // Grid with pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchRoles,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : roles.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text("No roles available")),
                ],
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: roles.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to your separate dashboard Dart file
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Dashboard(role: role['name']), // import your dashboard file
                        ),
                      );
                    },

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _parseColor(role['colorStart'], 0xFF2196F3),
                            _parseColor(role['colorEnd'], 0xFF9C27B0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Lottie.asset(
                              role['animation'] ??
                                  'assets/animation/default.json',
                              repeat: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            role['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}