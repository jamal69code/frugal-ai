import 'package:flutter/material.dart';
import 'package:frugal_ai/app_storage.dart';
import 'login_screen.dart';

// Barrel imports to ensure screens, services and widgets are connected
import 'package:frugal_ai/widgets/enhanced_app_drawer.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    bool status = await AppStorage.getLogin();
    setState(() {
      isLoggedIn = status;
    });
  }

  Future<void> logoutUser() async {
    await AppStorage.logout();
    setState(() {
      isLoggedIn = false;
    });
    Navigator.pop(context); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F9D58),
        title: const Text("Frugal AI"),
        // 🔥 IMPORTANT: This ensures menu icon appears
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),

      // ✅ SIDEBAR: use EnhancedAppDrawer to expose all screens/features
      drawer: const EnhancedAppDrawer(),

      // ✅ BODY
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.green.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: isLoggedIn
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.trending_up, size: 80, color: Colors.green),
                    SizedBox(height: 20),
                    Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Track & Analyze Your Expenses Smartly",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline, size: 80, color: Colors.green),
                    SizedBox(height: 20),
                    Text(
                      "Please Login to Continue",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
        ),
      ),

      // 🔥 Floating Login Button when logged out
      floatingActionButton: !isLoggedIn
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF0F9D58),
              child: const Icon(Icons.login),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                ).then((_) => checkLoginStatus());
              },
            )
          : null,
    );
  }
}
