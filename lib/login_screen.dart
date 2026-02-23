// import 'package:flutter/material.dart';
// import 'package:frugal_ai/app_storage.dart';
// import 'home_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green.shade50,
//       appBar: AppBar(
//         title: const Text("Login"),
//         backgroundColor: const Color(0xFF0F9D58),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(
//                 labelText: "Email",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: "Password",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0F9D58),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 40,
//                   vertical: 14,
//                 ),
//               ),
//               onPressed: () async {
//                 if (emailController.text.isNotEmpty &&
//                     passwordController.text.isNotEmpty) {
//                   await AppStorage.setLogin(true);

//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const HomeScreen()),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Enter email & password")),
//                   );
//                 }
//               },
//               child: const Text("Login"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:frugal_ai/app_storage.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Track if we are in Login or Sign Up mode
  bool isSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text(isSignUp ? "Create Account" : "Login"),
        backgroundColor: const Color(0xFF0F9D58),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // --- App Logo ---
            const Icon(Icons.eco_rounded, size: 80, color: Color(0xFF0F9D58)),
            const Text(
              "Frugal AI",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F9D58),
              ),
            ),

            const SizedBox(height: 40),

            // --- Input Fields ---
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Main Action Button (Login or Sign Up) ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D58),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (emailController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    if (isSignUp) {
                      // TODO: Add logic to save new user to your database (Firebase/Supabase/API)
                      debugPrint("Registering new user...");
                    }

                    await AppStorage.setLogin(true);
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill in all fields"),
                      ),
                    );
                  }
                },
                child: Text(isSignUp ? "Sign Up" : "Login"),
              ),
            ),

            const SizedBox(height: 20),

            // --- Toggle between Login and Sign Up ---
            TextButton(
              onPressed: () {
                setState(() {
                  isSignUp = !isSignUp;
                });
              },
              child: Text(
                isSignUp
                    ? "Already have an account? Login"
                    : "Don't have an account? Sign Up",
                style: const TextStyle(
                  color: Color(0xFF0F9D58),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("OR"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),

            // --- Google Sign-In ---
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                /* Google Auth Logic */
              },
              icon: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                height: 20,
              ),
              label: const Text(
                "Continue with Google",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
