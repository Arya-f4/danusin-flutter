import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/theme_switch_button.dart';
import '../services/pocketbase_service.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  bool _isDanuser = false;

  // Validation status
  bool _isFullNameValid = false;
  bool _isUsernameValid = false;
  bool _isPhoneValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

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
      _isPhoneValid = value.trim().length > 8;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _isPasswordValid = value.length >= 8;
    });
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the terms and conditions')),
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
        "username": _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        "phone": _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        "emailVisibility": true,
        "password": _passwordController.text,
        "passwordConfirm": _passwordController.text,
        "isdanuser": _isDanuser,
        "email_notifications": true,
        "marketing_emails": false,
      };

      await PocketBaseService.instance.collection('danusin_users').create(body: body);
      
      // Request email verification
      await PocketBaseService.instance.collection('danusin_users').requestVerification(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please check your email for verification'),
            backgroundColor: Color(0xFF00704A),
          ),
        );
        _navigateToSignIn();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: Failed to sign up: ', ''),
            ),
            backgroundColor: Colors.red,
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      body: Stack(
        children: [
          // Image Header
          Container(
            height: screenHeight * 0.25,
            decoration: BoxDecoration(
              color: themeProvider.getPrimaryColor(),
              image: const DecorationImage(
                image: AssetImage('assets/images/donuts.png'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Center(
              child: Text(
                'DANUSIN',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          
          // Form Container
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.22),
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.getBackgroundColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sign Up Title
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.getPrimaryColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Subtitle
                        Text(
                          'Create an account to enjoy all the features',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.getSecondaryTextColor(),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Sign In Link
                        GestureDetector(
                          onTap: _navigateToSignIn,
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: themeProvider.getPrimaryColor(),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Already have an account? Sign in',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: themeProvider.getPrimaryColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Form Fields
                        _buildInputField(
                          controller: _fullNameController,
                          label: 'FULL NAME',
                          hintText: 'Enter your full name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().length <= 2) {
                              return 'Full name is required (min 3 characters)';
                            }
                            return null;
                          },
                          onChanged: _validateFullName,
                          isValid: _isFullNameValid,
                          themeProvider: themeProvider,
                        ),
                        
                        _buildInputField(
                          controller: _emailController,
                          label: 'EMAIL ADDRESS',
                          hintText: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onChanged: _validateEmail,
                          isValid: _isEmailValid,
                          themeProvider: themeProvider,
                        ),
                        
                        _buildInputField(
                          controller: _usernameController,
                          label: 'USERNAME (Optional)',
                          hintText: 'Choose a username',
                          icon: Icons.account_circle_outlined,
                          onChanged: _validateUsername,
                          isValid: _isUsernameValid,
                          themeProvider: themeProvider,
                        ),
                        
                        _buildInputField(
                          controller: _phoneController,
                          label: 'PHONE NUMBER (Optional)',
                          hintText: 'Enter your phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          onChanged: _validatePhone,
                          isValid: _isPhoneValid,
                          themeProvider: themeProvider,
                        ),
                        
                        _buildInputField(
                          controller: _passwordController,
                          label: 'PASSWORD',
                          hintText: 'Create a password (min 8 characters)',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                          onChanged: _validatePassword,
                          isValid: _isPasswordValid,
                          themeProvider: themeProvider,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: themeProvider.getSecondaryTextColor(),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        
                        // Danuser Checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _isDanuser,
                                activeColor: themeProvider.getPrimaryColor(),
                                checkColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                side: BorderSide(
                                  color: themeProvider.getSecondaryTextColor(),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _isDanuser = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'I want to become a Danuser (seller)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: themeProvider.getTextColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Terms and Conditions Checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptedTerms,
                                activeColor: themeProvider.getPrimaryColor(),
                                checkColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                side: BorderSide(
                                  color: themeProvider.getSecondaryTextColor(),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedTerms = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'By signing up, you agree to our Terms of Service and Privacy Policy',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: themeProvider.getSecondaryTextColor(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.getPrimaryColor(),
                              foregroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'CREATE ACCOUNT',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Theme switcher
          Positioned(
            top: 40,
            right: 16,
            child: const ThemeSwitchButton(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required ThemeProvider themeProvider,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool isValid = false,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: themeProvider.getSecondaryTextColor(),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            validator: validator,
            style: TextStyle(
              color: themeProvider.getTextColor(),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: themeProvider.getSecondaryTextColor().withOpacity(0.6),
                fontSize: 15,
              ),
              filled: true,
              fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
              prefixIcon: icon != null
                  ? Icon(
                      icon,
                      color: themeProvider.getSecondaryTextColor(),
                      size: 20,
                    )
                  : null,
              suffixIcon: suffix ?? (isValid
                  ? Icon(
                      Icons.check_circle,
                      color: themeProvider.getPrimaryColor(),
                      size: 20,
                    )
                  : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.getPrimaryColor(),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
