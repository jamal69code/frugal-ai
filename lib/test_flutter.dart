import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class TestLoginScreen extends StatefulWidget {
  const TestLoginScreen({Key? key}) : super(key: key);

  @override
  State<TestLoginScreen> createState() => _TestLoginScreenState();
}

class _TestLoginScreenState extends State<TestLoginScreen> {
  final TextEditingController emailController = TextEditingController(
    text: "test@test.com",
  );
  final TextEditingController passwordController = TextEditingController(
    text: "123456",
  );

  bool isLoading = false;
  String result = "";

  Future<void> testLogin() async {
    setState(() {
      isLoading = true;
      result = "Logging in...";
    });

    try {
      final response = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      setState(() {
        result = "✅ SUCCESS:\n$response";
      });

      print("LOGIN SUCCESS: $response");
    } catch (e) {
      setState(() {
        result = "❌ ERROR:\n$e";
      });

      print("LOGIN ERROR: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backend Login Test")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : testLogin,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Test Login"),
            ),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(result))),
          ],
        ),
      ),
    );
  }
}
