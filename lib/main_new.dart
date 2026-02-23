import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization warning: $e');
    // Continue with app even if Firebase fails (for demo mode)
  }

  runApp(const FrugalAI());
}

class FrugalAI extends StatelessWidget {
  const FrugalAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Frugal AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green.shade50,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
