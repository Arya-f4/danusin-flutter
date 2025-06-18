import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/theme_switch_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // PocketBase instance
  final pb = PocketBase('https://pocketbase.evoptech.com');

  // User data
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from PocketBase
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!pb.authStore.isValid) {
        throw Exception('User not authenticated. Please log in.');
      }

      // Fetch the authenticated user's record
      final user = await pb.collection('danusin_users').getOne(pb.authStore.model.id);
      setState(() {
        _userData = {
          'id': user.id,
          'name': user.data['name'] ?? 'Unknown User',
          'email': user.data['email'] ?? '',
          'avatar': user.data['avatar'] != null
              ? '${pb.baseUrl}/api/files/danusin_users/${user.id}/${user.data['avatar']}'
              : null,
          'language': user.data['language'] ?? 'English',
          'addresses': user.data['addresses'] ?? [],
          'payment_methods': user.data['payment_methods'] ?? [],
        };
        _isLoading = false;
      });
    } catch (e) {
      String errorDetail = e.toString();
      if (e is ClientException) {
        errorDetail = 'HTTP ${e.statusCode}: ${e.response['message'] ?? e.toString()}';
        if (e.statusCode == 403) {
          errorDetail += '\nCheck collection rules in PocketBase admin UI.';
        }
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile: $errorDetail';
      });
    }
  }

  // Sign out the user
  Future<void> _signOut() async {
    try {
      pb.authStore.clear();
      // Navigate to login screen
      // ignore: use_build_context_synchronously
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
                              backgroundColor:
                                  themeProvider.getPrimaryColor().withOpacity(0.2),
                              backgroundImage: _userData!['avatar'] != null
                                  ? NetworkImage(_userData!['avatar'])
                                  : null,
                              child: _userData!['avatar'] == null
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: themeProvider.getPrimaryColor(),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userData!['name'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.getTextColor(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData!['email'],
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.getSecondaryTextColor(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () {
                                // Navigate to EditProfileScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfileScreen(userData: _userData!),
                                  ),
                                ).then((_) => _fetchUserData()); // Refresh after edit
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
                            themeProvider: themeProvider,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfileScreen(userData: _userData!),
                                ),
                              ).then((_) => _fetchUserData());
                            },
                          ),
                          _buildDivider(themeProvider),
                          _buildSettingsItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            themeProvider: themeProvider,
                          ),
                          _buildDivider(themeProvider),
                          _buildSettingsItem(
                            icon: Icons.language_outlined,
                            title: 'Language',
                            subtitle: _userData!['language'],
                            themeProvider: themeProvider,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Payment methods section
                      _buildSectionTitle('Payment Methods', themeProvider),
                      const SizedBox(height: 8),
                      _buildSettingsCard(
                        themeProvider,
                        children: _userData!['payment_methods'].isNotEmpty
                            ? _userData!['payment_methods'].asMap().entries.map<Widget>(
                                (entry) {
                                  final method = entry.value;
                                  return Column(
                                    children: [
                                      _buildSettingsItem(
                                        icon: method['type'] == 'Credit Card'
                                            ? Icons.credit_card_outlined
                                            : Icons.account_balance_wallet_outlined,
                                        title:
                                            '${method['type']} ${method['last_four'] ?? method['name'] ?? ''}',
                                        themeProvider: themeProvider,
                                      ),
                                      if (entry.key <
                                          _userData!['payment_methods'].length - 1)
                                        _buildDivider(themeProvider),
                                    ],
                                  );
                                },
                              ).toList()
                            : [
                                _buildSettingsItem(
                                  icon: Icons.add_circle_outline,
                                  title: 'Add Payment Method',
                                  themeProvider: themeProvider,
                                ),
                              ],
                      ),
                      const SizedBox(height: 24),

                      // Addresses section
                      _buildSectionTitle('Addresses', themeProvider),
                      const SizedBox(height: 8),
                      _buildSettingsCard(
                        themeProvider,
                        children: _userData!['addresses'].isNotEmpty
                            ? _userData!['addresses'].asMap().entries.map<Widget>(
                                (entry) {
                                  final address = entry.value;
                                  return Column(
                                    children: [
                                      _buildSettingsItem(
                                        icon: address['type'] == 'Home'
                                            ? Icons.home_outlined
                                            : Icons.work_outline,
                                        title: address['type'],
                                        subtitle: address['address'],
                                        themeProvider: themeProvider,
                                      ),
                                      if (entry.key < _userData!['addresses'].length - 1)
                                        _buildDivider(themeProvider),
                                    ],
                                  );
                                },
                              ).toList()
                            : [
                                _buildSettingsItem(
                                  icon: Icons.add_circle_outline,
                                  title: 'Add New Address',
                                  themeProvider: themeProvider,
                                ),
                              ],
                      ),
                      const SizedBox(height: 24),

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

// Placeholder EditProfileScreen
class EditProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: Text('Edit Profile for ${userData['name']} (Placeholder)'),
      ),
    );
  }
}