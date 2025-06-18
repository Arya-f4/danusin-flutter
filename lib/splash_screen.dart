import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'theme_provider.dart';
import 'widgets/theme_switch_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to onboarding screen after a delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Your splash screen logo or image
             
                const SizedBox(height: 24),
                Text(
                  'DANUSIN',
                  style: TextStyle(
                    color: themeProvider.getPrimaryColor(),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Find Food Vendors Near You',
                  style: TextStyle(
                    color: themeProvider.getSecondaryTextColor(),
                    fontSize: 16,
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