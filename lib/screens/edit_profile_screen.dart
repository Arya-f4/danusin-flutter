import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../models/danusin_user.dart';
import '../services/pocketbase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final DanusinUser userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  
  bool _emailNotifications = false;
  bool _marketingEmails = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _usernameController = TextEditingController(text: widget.userData.username ?? '');
    _phoneController = TextEditingController(text: widget.userData.phone ?? '');
    _bioController = TextEditingController(text: widget.userData.bio ?? '');
    _locationController = TextEditingController(text: widget.userData.locationAddress ?? '');
    _emailNotifications = widget.userData.emailNotifications;
    _marketingEmails = widget.userData.marketingEmails;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        'location_address': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        'email_notifications': _emailNotifications,
        'marketing_emails': _marketingEmails,
      };

      await PocketBaseService.instance.collection('danusin_users').update(
        widget.userData.id,
        body: body,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF00704A),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeProvider.getBackgroundColor(),
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: themeProvider.getTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: themeProvider.getPrimaryColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: themeProvider.getPrimaryColor().withOpacity(0.2),
                          backgroundImage: widget.userData.avatar != null && widget.userData.avatar!.isNotEmpty
                              ? NetworkImage(widget.userData.getAvatarUrl(PocketBaseService.baseUrl))
                              : null,
                          child: widget.userData.avatar == null || widget.userData.avatar!.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: themeProvider.getPrimaryColor(),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeProvider.getPrimaryColor(),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                // TODO: Implement image picker
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image upload coming soon!')),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (widget.userData.isDanuser)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeProvider.getPrimaryColor(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Danuser',
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Form Fields
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
                themeProvider: themeProvider,
              ),

              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.alternate_email,
                themeProvider: themeProvider,
              ),

              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                themeProvider: themeProvider,
              ),

              _buildTextField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.info_outline,
                maxLines: 3,
                themeProvider: themeProvider,
              ),

              _buildTextField(
                controller: _locationController,
                label: 'Location Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                themeProvider: themeProvider,
              ),

              const SizedBox(height: 24),

              // Notification Settings
              Text(
                'Notification Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.getTextColor(),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Email Notifications',
                        style: TextStyle(color: themeProvider.getTextColor()),
                      ),
                      subtitle: Text(
                        'Receive notifications via email',
                        style: TextStyle(color: themeProvider.getSecondaryTextColor()),
                      ),
                      value: _emailNotifications,
                      activeColor: themeProvider.getPrimaryColor(),
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      },
                    ),
                    Divider(color: themeProvider.getDividerColor(), height: 1),
                    SwitchListTile(
                      title: Text(
                        'Marketing Emails',
                        style: TextStyle(color: themeProvider.getTextColor()),
                      ),
                      subtitle: Text(
                        'Receive promotional emails',
                        style: TextStyle(color: themeProvider.getSecondaryTextColor()),
                      ),
                      value: _marketingEmails,
                      activeColor: themeProvider.getPrimaryColor(),
                      onChanged: (value) {
                        setState(() {
                          _marketingEmails = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.getPrimaryColor(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeProvider themeProvider,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(color: themeProvider.getTextColor()),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: themeProvider.getSecondaryTextColor()),
          prefixIcon: Icon(icon, color: themeProvider.getSecondaryTextColor()),
          filled: true,
          fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: themeProvider.getPrimaryColor()),
          ),
        ),
      ),
    );
  }
}
