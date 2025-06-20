import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/theme_switch_button.dart';
import '../services/pocketbase_service.dart';
import '../models/danusin_user.dart';
import 'edit_profile_screen.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DanusinUser? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!PocketBaseService.isAuthenticated) {
        throw Exception('User not authenticated. Please log in.');
      }

      final user = PocketBaseService.currentUser;
      if (user != null) {
        // Fetch fresh user data
        final freshUser = await PocketBaseService.getUser(user.id);
        setState(() {
          _userData = freshUser;
          _isLoading = false;
        });
      } else {
        throw Exception('No user data available');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile: $e';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      PocketBaseService.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign out: $e';
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
          'My Profile',
          style: TextStyle(
            color: themeProvider.getTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ThemeSwitchButton(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUserData,
                        child: const Text('Retry'),
                      ),
                      if (_errorMessage!.contains('not authenticated'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text('Log in'),
                          ),
                        ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User profile header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: themeProvider.getPrimaryColor().withOpacity(0.2),
                              backgroundImage: _userData!.avatar != null && _userData!.avatar!.isNotEmpty
                                  ? NetworkImage(_userData!.getAvatarUrl(PocketBaseService.baseUrl))
                                  : null,
                              child: _userData!.avatar == null || _userData!.avatar!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: themeProvider.getPrimaryColor(),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userData!.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.getTextColor(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData!.email,
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.getSecondaryTextColor(),
                              ),
                            ),
                            if (_userData!.username != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '@${_userData!.username}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeProvider.getSecondaryTextColor(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (_userData!.isDanuser)
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
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(userData: _userData!),
                                  ),
                                ).then((_) => _fetchUserData());
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: themeProvider.getPrimaryColor()),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: themeProvider.getPrimaryColor(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Account settings section
                      _buildSectionTitle('Account Settings', themeProvider),
                      const SizedBox(height: 8),
                      _buildSettingsCard(
                        themeProvider,
                        children: [
                          _buildSettingsItem(
                            icon: Icons.person_outline,
                            title: 'Personal Information',
                            subtitle: _userData!.bio ?? 'Add your bio',
                            themeProvider: themeProvider,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(userData: _userData!),
                                ),
                              ).then((_) => _fetchUserData());
                            },
                          ),
                          _buildDivider(themeProvider),
                          _buildSettingsItem(
                            icon: Icons.notifications_outlined,
                            title: 'Email Notifications',
                            subtitle: _userData!.emailNotifications ? 'Enabled' : 'Disabled',
                            themeProvider: themeProvider,
                          ),
                          _buildDivider(themeProvider),
                          _buildSettingsItem(
                            icon: Icons.email_outlined,
                            title: 'Marketing Emails',
                            subtitle: _userData!.marketingEmails ? 'Enabled' : 'Disabled',
                            themeProvider: themeProvider,
                          ),
                          _buildDivider(themeProvider),
                          _buildSettingsItem(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            subtitle: _userData!.locationAddress ?? 'Add your location',
                            themeProvider: themeProvider,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Danuser section (if user is a danuser)
                      if (_userData!.isDanuser) ...[
                        _buildSectionTitle('Danuser Settings', themeProvider),
                        const SizedBox(height: 8),
                        _buildSettingsCard(
                          themeProvider,
                          children: [
                            _buildSettingsItem(
                              icon: Icons.store_outlined,
                              title: 'My Products',
                              subtitle: 'Manage your products',
                              themeProvider: themeProvider,
                            ),
                            _buildDivider(themeProvider),
                            _buildSettingsItem(
                              icon: Icons.analytics_outlined,
                              title: 'Analytics',
                              subtitle: 'View your performance',
                              themeProvider: themeProvider,
                            ),
                            _buildDivider(themeProvider),
                            _buildSettingsItem(
                              icon: Icons.phone_outlined,
                              title: 'Contact Number',
                              subtitle: _userData!.phone ?? 'Add phone number',
                              themeProvider: themeProvider,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Support section
                      _buildSectionTitle('Support', themeProvider),
                      const SizedBox(height: 8),
                      _buildSettingsCard(
                        themeProvider,
                        children: [
                          _buildSettingsItem(
                            icon: Icons.help_outline,
                            title: 'Help Center',
                            themeProvider: themeProvider,
                          ),
                          _buildDivider(themeProvider),
                          _buildSettingsItem(
                            icon: Icons.chat_bubble_outline,
                            title: 'Contact Us',
                            themeProvider: themeProvider,
                          ),
                          _buildDivider(themeProvider),
                          _buildSettingsItem(
                            icon: Icons.info_outline,
                            title: 'About Danusin',
                            themeProvider: themeProvider,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sign out button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signOut,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App version
                      Center(
                        child: Text(
                          'Danusin App v1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
      bottomNavigationBar: DanusinBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) => navigateToMainScreen(context, index),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: themeProvider.getTextColor(),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeProvider themeProvider, {required List<Widget> children}) {
    return Card(
      elevation: 2,
      color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required ThemeProvider themeProvider,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: themeProvider.getPrimaryColor(),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: themeProvider.getTextColor(),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.getSecondaryTextColor(),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: themeProvider.getSecondaryTextColor(),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeProvider themeProvider) {
    return Divider(
      color: themeProvider.getDividerColor(),
      height: 1,
      indent: 56,
      endIndent: 16,
    );
  }
}
