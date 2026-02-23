import 'package:flutter/material.dart';
import 'package:frugal_ai/backend/backend.dart';
import 'package:image_picker/image_picker.dart';

/// 👤 Enhanced Profile Screen with Bill Images
class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final AuthenticationService _authService = AuthenticationService();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _bills = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final profile = await _profileService.getUserProfile();
      final bills = await _profileService.getUserBills();

      if (mounted) {
        setState(() {
          if (profile != null) {
            _fullNameController.text = profile['fullName'] ?? '';
            _phoneController.text = profile['phone'] ?? '';
            _addressController.text = profile['address'] ?? '';
            _cityController.text = profile['city'] ?? '';
          }
          _bills = bills;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===== UPDATE PROFILE =====
  Future<void> _updateProfile() async {
    final success = await _profileService.updateUserProfile(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      city: _cityController.text,
      country: '',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✅ Profile updated' : '❌ Failed to update profile',
          ),
        ),
      );
      if (success) _loadProfileData();
    }
  }

  // ===== UPLOAD BILL =====
  Future<void> _uploadBill() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => _BillUploadDialog(
          imagePath: image.path,
          onSubmit: (category, description) async {
            Navigator.pop(context);

            final success = await _profileService.uploadBillImage(
              imagePath: image.path,
              billCategory: category,
              description: description,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '✅ Bill uploaded successfully'
                        : '❌ Failed to upload bill',
                  ),
                ),
              );
              if (success) _loadProfileData();
            }
          },
        ),
      );
    }
  }

  // ===== CHANGE PASSWORD =====
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔐 Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final validation = ValidationService.validatePasswordChange(
                currentPassword: currentPasswordController.text,
                newPassword: newPasswordController.text,
                confirmPassword: confirmPasswordController.text,
              );

              if (ValidationService.isFormValid(validation)) {
                final success = await _authService.changePassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '✅ Password changed successfully'
                            : '❌ Failed to change password',
                      ),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Password validation failed')),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 My Profile'),
        backgroundColor: const Color(0xFF0F9D58),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 👤 Profile Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF0F9D58),
                      child: const Text('👤', style: TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fullNameController.text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _authService.currentUser?.email ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 📝 Profile Form
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 💾 Save Profile Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _updateProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔐 Change Password Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock),
                  label: const Text('Change Password'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 📸 Captured Bills Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📸 Captured Bills',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _uploadBill,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 📸 Bills Grid
              if (_bills.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Text('📸', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        'No bills captured yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _bills.length,
                  itemBuilder: (context, index) {
                    final bill = _bills[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Image.network(bill['imageUrl']),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await _profileService.deleteBill(
                                    billId: bill['id'],
                                  );
                                  if (mounted) Navigator.pop(context);
                                  _loadProfileData();
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  bill['imageUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                bill['category'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// 🖼️ Bill Upload Dialog
class _BillUploadDialog extends StatefulWidget {
  final String imagePath;
  final Function(String category, String description) onSubmit;

  const _BillUploadDialog({required this.imagePath, required this.onSubmit});

  @override
  State<_BillUploadDialog> createState() => _BillUploadDialogState();
}

class _BillUploadDialogState extends State<_BillUploadDialog> {
  late String _selectedCategory;
  final _descriptionController = TextEditingController();

  final categories = [
    'Food',
    'Transport',
    'Shopping',
    'Utilities',
    'Healthcare',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = categories[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('📸 Upload Bill'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              widget.imagePath,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedCategory,
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategory = value ?? categories[0]),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () =>
              widget.onSubmit(_selectedCategory, _descriptionController.text),
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
