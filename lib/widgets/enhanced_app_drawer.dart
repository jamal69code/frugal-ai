import 'package:flutter/material.dart';
import 'package:frugal_ai/backend/backend.dart';
import 'package:frugal_ai/screens/feedback_suggestions_screen.dart';
import 'package:frugal_ai/screens/investment_screen.dart';
import 'package:frugal_ai/screens/enhanced_profile_screen.dart';
import 'package:frugal_ai/screens/enhanced_login_screen.dart';
import 'package:frugal_ai/screens/enhanced_signup_screen.dart';

/// 🎯 Enhanced App Drawer with All Features
class EnhancedAppDrawer extends StatefulWidget {
  const EnhancedAppDrawer({Key? key}) : super(key: key);

  @override
  State<EnhancedAppDrawer> createState() => _EnhancedAppDrawerState();
}

class _EnhancedAppDrawerState extends State<EnhancedAppDrawer> {
  final AuthenticationService _authService = AuthenticationService();
  final NotificationPermissionService _permissionService =
      NotificationPermissionService();

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final prefs = await _permissionService.getNotificationPreferences();
    if (mounted) {
      setState(() => _notificationsEnabled = prefs['enabled'] ?? true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 👤 User Profile Header
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : '👤',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(user?.displayName ?? 'Frugal User'),
            accountEmail: Text(user?.email ?? ''),
            decoration: const BoxDecoration(color: Color(0xFF0F9D58)),
          ),

          // If not logged in, show Login / Sign Up quick actions
          if (user == null) ...[
            _DrawerTile(
              icon: Icons.login,
              title: 'Login',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedLoginScreen(),
                  ),
                );
              },
            ),
            _DrawerTile(
              icon: Icons.person_add,
              title: 'Sign Up',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnhancedSignupScreen(),
                  ),
                );
              },
            ),
            const Divider(),
          ],

          // 👤 Profile & Settings
          _DrawerTile(
            icon: Icons.person,
            title: 'My Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EnhancedProfileScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // 📈 Investment Features
          _DrawerSectionHeader('📊 INVESTMENTS'),

          _DrawerTile(
            icon: Icons.trending_up,
            title: 'Investment Tracker',
            subtitle: 'Track your portfolio & stocks',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvestmentScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // 💬 Feedback & Suggestions
          _DrawerSectionHeader('💬 FEEDBACK'),

          _DrawerTile(
            icon: Icons.feedback,
            title: 'Send Feedback',
            subtitle: 'Help us improve the app',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackSuggestionsScreen(),
                ),
              );
            },
          ),

          _DrawerTile(
            icon: Icons.lightbulb,
            title: 'Suggest Features',
            subtitle: 'Share your ideas',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackSuggestionsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // 🔔 Notification Settings
          _DrawerSectionHeader('🔔 NOTIFICATIONS'),

          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() => _notificationsEnabled = value);
                if (value) {
                  await _permissionService.enableNotifications();
                } else {
                  await _permissionService.disableNotifications();
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? '✅ Notifications enabled'
                            : '✅ Notifications disabled',
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: const Text('Manage Permissions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPermissionDialog(context),
          ),

          const Divider(),

          // ⚙️ App Settings
          _DrawerSectionHeader('⚙️ SETTINGS'),

          _DrawerTile(
            icon: Icons.security,
            title: 'Security Settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security settings coming soon')),
              );
            },
          ),

          _DrawerTile(
            icon: Icons.language,
            title: 'Language',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings coming soon')),
              );
            },
          ),

          _DrawerTile(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support coming soon')),
              );
            },
          ),

          const Divider(),

          // 🚪 Logout
          _DrawerTile(
            icon: Icons.logout,
            title: 'Logout',
            titleColor: Colors.red[700],
            onTap: () async {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),

          const SizedBox(height: 20),

          // 📱 App Version
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Frugal AI v1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ===== SHOW PERMISSION DIALOG =====
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔐 Manage Permissions'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PermissionTile(
                title: 'Camera Access',
                description: 'For capturing bill images',
                icon: Icons.camera,
                onTap: () async {
                  await _permissionService.grantPermission(
                    permissionType: 'camera',
                    resource: 'bill_images',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Camera access granted')),
                    );
                  }
                },
              ),
              const Divider(),
              _PermissionTile(
                title: 'Microphone Access',
                description: 'For voice expense entry',
                icon: Icons.mic,
                onTap: () async {
                  await _permissionService.grantPermission(
                    permissionType: 'microphone',
                    resource: 'voice_input',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Microphone access granted'),
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              _PermissionTile(
                title: 'Location Access',
                description: 'For location-based suggestions',
                icon: Icons.location_on,
                onTap: () async {
                  await _permissionService.grantPermission(
                    permissionType: 'location',
                    resource: 'location_services',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Location access granted'),
                      ),
                    );
                  }
                },
              ),
              const Divider(),
              _PermissionTile(
                title: 'Calendar Access',
                description: 'For bill reminders',
                icon: Icons.calendar_today,
                onTap: () async {
                  await _permissionService.grantPermission(
                    permissionType: 'calendar',
                    resource: 'bill_reminders',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Calendar access granted'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ===== LOGOUT CONFIRMATION =====
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ===== DRAWER TILE WIDGET =====
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: titleColor),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: subtitle != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: onTap,
    );
  }
}

// ===== DRAWER SECTION HEADER =====
class _DrawerSectionHeader extends StatelessWidget {
  final String title;

  const _DrawerSectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ===== PERMISSION TILE =====
class _PermissionTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(title),
      subtitle: Text(description, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
      onTap: onTap,
    );
  }
}
