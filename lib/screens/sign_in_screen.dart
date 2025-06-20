import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_provider.dart';
import '../widgets/theme_switch_button.dart';
import '../services/pocketbase_service.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'first_page_screen.dart';

// Guest mode management
class GuestModeManager {
  static const String _guestModeKey = 'isGuestMode';
  
  static Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, isGuest);
  }
  
  static Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? false;
  }
  
  static Future<void> clearGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestModeKey);
  }
}

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

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await PocketBaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        await GuestModeManager.setGuestMode(false);
        
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
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: Failed to sign in: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      PocketBaseService.signOut();
      await GuestModeManager.setGuestMode(true);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FirstPageScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to enter guest mode: $e';
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
                        color: themeProvider.getPrimaryColor(),
                        image: const DecorationImage(
                          image: AssetImage('/images/donuts.png'),
                          fit: BoxFit.cover,
                          opacity: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      alignment: Alignment.center,
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
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        ),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        decoration: InputDecoration(
                          hintText: 'Email Address',
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
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: themeProvider.getTextColor()),
                        decoration: InputDecoration(
                          hintText: 'Password',
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
                          suffixIcon: IconButton(
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
                                ? CircularProgressIndicator(
                                    color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                  )
                                : Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.isDarkMode ? Colors.black : Colors.white,
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
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _signInAsGuest,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
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
                                'Continue as Guest',
                                style: TextStyle(
                                  color: themeProvider.getTextColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
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
