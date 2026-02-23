import 'package:flutter/material.dart';
import 'package:frugal_ai/app_storage.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "User";
  String userEmail = "user@example.com";
  String phoneNumber = "+1234567890";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    setState(() => isLoading = true);
    // Simulate loading user data
    await Future.delayed(const Duration(milliseconds: 500));

    String? name = await AppStorage.getStorageValue("userName");
    String? email = await AppStorage.getStorageValue("userEmail");

    setState(() {
      userName = name ?? "Guest User";
      userEmail = email ?? "user@frugal-ai.com";
      isLoading = false;
    });
  }

  Future<void> logoutUser() async {
    await AppStorage.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F9D58), Color(0xFF43A047)],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF0F9D58),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Account Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Email Card
                        Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(
                              Icons.email,
                              color: Colors.green,
                            ),
                            title: const Text("Email"),
                            subtitle: Text(userEmail),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Phone Card
                        Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(
                              Icons.phone,
                              color: Colors.green,
                            ),
                            title: const Text("Phone"),
                            subtitle: Text(phoneNumber),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Member Since Card
                        Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(
                              Icons.calendar_today,
                              color: Colors.green,
                            ),
                            title: const Text("Member Since"),
                            subtitle: Text(
                              DateTime.now().toString().split(' ')[0],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Settings Section
                        const Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Settings Options
                        Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(
                              Icons.lock,
                              color: Colors.green,
                            ),
                            title: const Text("Change Password"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password change feature coming soon",
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(
                              Icons.notifications,
                              color: Colors.green,
                            ),
                            title: const Text("Notifications"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: logoutUser,
                            icon: const Icon(Icons.logout),
                            label: const Text("Logout"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
