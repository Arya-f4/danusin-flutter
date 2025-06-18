import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'first_page_screen.dart';
import '../theme_provider.dart';
import '../widgets/theme_switch_button.dart';

// Initialize PocketBase with your server URL
final pb = PocketBase('https://pocketbase.evoptech.com');

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle email/password login with PocketBase
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Authenticate with PocketBase
      final authData = await pb
          .collection('danusin_users')
          .authWithPassword(_emailController.text.trim(), _passwordController.text);

      // Store authentication data
      if (pb.authStore.isValid) {
        // Update user profile data
        await _updateUserProfile(authData.record);
        
        // Navigate to FirstPageScreen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FirstPageScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Please try again.';
        });
      }
    } on ClientException catch (e) {
      setState(() {
        _errorMessage = e.response['message']?.toString() ??
            'Invalid email or password.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle Google OAuth2 login
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Authenticate with Google OAuth2
      final authData = await pb.collection('danusin_users').authWithOAuth2(
        'google',
        (url) async {
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            throw 'Could not launch Google login page';
          }
        },
      );

      if (pb.authStore.isValid) {
        // Update user profile data
        await _updateUserProfile(authData.record);

        // Navigate to FirstPageScreen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FirstPageScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Google authentication failed.';
        });
      }
    } on ClientException catch (e) {
      setState(() {
        _errorMessage = e.response['message']?.toString() ??
            'Failed to sign in with Google.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update user profile data after authentication
  Future<void> _updateUserProfile(RecordModel? record) async {
    if (record == null) return;

    try {
      // Ensure the user record is up-to-date
      final user = await pb.collection('danusin_users').getOne(record.id);
      
      // Update auth store with the latest record
      pb.authStore.save(pb.authStore.token, user);
    } catch (e) {
      // Log error but don't block sign-in
      debugPrint('Failed to update user profile: $e');
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
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getPrimaryColor(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Masuk menggunakan akun anda!',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          hintStyle:
                              TextStyle(color: themeProvider.getSecondaryTextColor()),
                          filled: true,
                          fillColor: themeProvider.isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle:
                              TextStyle(color: themeProvider.getSecondaryTextColor()),
                          filled: true,
                          fillColor: themeProvider.isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: themeProvider.getSecondaryTextColor(),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                            'Lupa password?',
                            style: TextStyle(
                              color: themeProvider.getSecondaryTextColor(),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
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
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: themeProvider.getDividerColor()),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Atau login dengan',
                              style: TextStyle(
                                color: themeProvider.getSecondaryTextColor(),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: themeProvider.getDividerColor()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(
                                  color: themeProvider.isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    '../assets/images/google_logo.png',
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Google',
                                    style: TextStyle(
                                      color: themeProvider.getTextColor(),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _errorMessage = 'Guest login not implemented.';
                                      });
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(
                                  color: themeProvider.isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 24,
                                    color: themeProvider.getTextColor(),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Guest',
                                    style: TextStyle(
                                      color: themeProvider.getTextColor(),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Belum mempunyai akun? ',
                            style: TextStyle(
                              color: themeProvider.getSecondaryTextColor(),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign up',
                                style: TextStyle(
                                  color: themeProvider.getPrimaryColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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