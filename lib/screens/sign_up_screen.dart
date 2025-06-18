import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';

import 'sign_in_screen.dart';
import '../theme_provider.dart';
import '../widgets/theme_switch_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Validation status
  bool _isFullNameValid = false;
  bool _isUsernameValid = false;
  bool _isPhoneValid= false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  // PocketBase instance
  final pb = PocketBase('https://pocketbase.evoptech.com');

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validation functions
  void _validateFullName(String value) {
    setState(() {
      _isFullNameValid = value.trim().length > 2;
    });
  }

  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
    });
  }

    void _validateUsername(String value) {
    setState(() {
      _isUsernameValid = value.trim().length > 2;
    });
  }

     void _validatePhone(String value) {
    setState(() {
      _isPhoneValid =  value.trim().length > 2;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _isPasswordValid = value.length >= 8; // PocketBase requires min 8 chars
    });
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_isFullNameValid || !_isEmailValid || !_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final body = <String, dynamic>{
        "email": _emailController.text.trim(),
        "name": _fullNameController.text.trim(),
        "username": _emailController.text.trim().split('@')[0], // Simple username from email
        "phone" : _phoneController.text.trim(),
        "emailVisibility": true,
        "password": _passwordController.text,
        "passwordConfirm": _passwordController.text,
      };

      await pb.collection('danusin_users').create(body: body);
      await pb.collection('danusin_users').requestVerification(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please verify your email')),
        );
        _navigateToSignIn();
      }
    } on ClientException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response['message'] ?? 'Failed to create account. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header image with logo
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage('../assets/images/donuts.png'),
                          fit: BoxFit.cover,
                          colorFilter: themeProvider.isDarkMode
                              ? ColorFilter.mode(
                                  Colors.black.withOpacity(0.5),
                                  BlendMode.darken,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      color: Colors.black.withOpacity(0.1),
                      child: Text(
                        'DANUSIN',
                        style: TextStyle(
                          color: themeProvider.getPrimaryColor(),
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                // Form container
                Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sign Up title
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getPrimaryColor(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Masukkan informasi anda, dan masuk untuk mendapatkan informasi menarik!',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.getSecondaryTextColor(),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Already have an account link
                      GestureDetector(
                        onTap: _navigateToSignIn,
                        child: Text(
                          'Sudah punya Akun?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: themeProvider.getPrimaryColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Full Name field
                      Text(
                        'FULL NAME',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.getSecondaryTextColor(),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _fullNameController,
                        onChanged: _validateFullName,
                        enabled: !_isLoading,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(color: themeProvider.getSecondaryTextColor()),
                          filled: true,
                          fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: _isFullNameValid
                              ? Icon(Icons.check_circle, color: themeProvider.getPrimaryColor())
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email field
                      Text(
                        'EMAIL ADDRESS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.getSecondaryTextColor(),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: _validateEmail,
                        enabled: !_isLoading,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: themeProvider.getSecondaryTextColor()),
                          filled: true,
                          fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: _isEmailValid
                              ? Icon(Icons.check_circle, color: themeProvider.getPrimaryColor())
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),

                        Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.getSecondaryTextColor(),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        onChanged: _validateUsername,
                        enabled: !_isLoading,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        decoration: InputDecoration(
                          hintText: 'Enter your username',
                          hintStyle: TextStyle(color: themeProvider.getSecondaryTextColor()),
                          filled: true,
                          fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: _isUsernameValid
                              ? Icon(Icons.check_circle, color: themeProvider.getPrimaryColor())
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                        Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.getSecondaryTextColor(),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        onChanged: _validatePhone,
                        enabled: !_isLoading,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        decoration: InputDecoration(
                          hintText: 'Enter your phone',
                          hintStyle: TextStyle(color: themeProvider.getSecondaryTextColor()),
                          filled: true,
                          fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: _isPhoneValid
                              ? Icon(Icons.check_circle, color: themeProvider.getPrimaryColor())
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Password field
                      Text(
                        'PASSWORD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.getSecondaryTextColor(),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: _validatePassword,
                        enabled: !_isLoading,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        decoration: InputDecoration(
                          hintText: 'Create a password',
                          hintStyle: TextStyle(color: themeProvider.getSecondaryTextColor()),
                          filled: true,
                          fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: themeProvider.getSecondaryTextColor(),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              if (_isPasswordValid)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: themeProvider.getPrimaryColor(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Sign Up button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.getPrimaryColor(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                ),
                              ),
                      ),
                      // Terms and conditions text
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'By Signing up you agree to our Terms Conditions & Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        ),
                      ),
                      // Or divider
                      Center(
                        child: Text(
                          'Or',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Facebook button
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                // Handle Facebook login
                              },
                        icon: const Icon(
                          Icons.facebook,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'CONNECT WITH FACEBOOK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF395998),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Google button
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                // Handle Google login
                              },
                        icon: Image.asset(
                          '../assets/images/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text(
                          'CONNECT WITH GOOGLE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Theme switcher button
          Positioned(
            top: 40,
            right: 16,
            child: const ThemeSwitchButton(),
          ),
        ],
      ),
    );
  }
}