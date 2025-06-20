import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'sign_in_screen.dart';
import '../theme_provider.dart';
import '../widgets/theme_switch_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 3;

  List<String> titles = [
    'Apa itu Danusin?',
    'Banyak Pilihan makanan dan minuman!',
    'Banyak rekomendasi vendor di area surabaya!'
  ];

  List<String> descriptions = [
    'Danusin merupakan platform forum untuk membantu danusan anda dengan menemukan vendor vendor yang ada di area surabaya.',
    'Temukan banyak rekomendasi makanan dan minuman untuk danusan anda!',
    'Temukan banyak rekomendasi vendor yang berada di area surabaya, dan memiliki harga yang terjangkau!'
  ];

  List<String> buttonTexts = [
    'Continue',
    'Continue',
    'Get Started'
  ];

  List<String> images = [
    '../assets/images/logo-danusin-hijau.png',
    '../assets/images/burger.png',
    '../assets/images/logo-danusin-hijau.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Page indicator dots
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _numPages,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: i == _currentPage ? 24 : 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage 
                            ? themeProvider.getPrimaryColor() 
                            : themeProvider.getSecondaryTextColor().withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                // Main content with PageView for swiping
                Expanded(
                  child: PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _numPages,
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(index, themeProvider);
                    },
                  ),
                ),
              ],
            ),
            // Theme switcher button
            Positioned(
              top: 16,
              right: 16,
              child: const ThemeSwitchButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(int index, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with green blob background
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Small green blob in top left
                Positioned(
                  top: 20,
                  left: 40,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: themeProvider.getPrimaryColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                // Main green blob background
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: themeProvider.getPrimaryColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
                // Food image
                Image.asset(
                  images[index],
                  width: 250,
                  fit: BoxFit.contain,
                ),
                // Small green blob in bottom right
                Positioned(
                  bottom: 20,
                  right: 40,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: themeProvider.getPrimaryColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Title text
          Text(
            titles[index],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: themeProvider.getTextColor(),
            ),
          ),
          const SizedBox(height: 16),
          // Description text
          Text(
            descriptions[index],
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.getSecondaryTextColor(),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          // Continue/Get Started button
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _numPages - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              } else {
                _navigateToSignIn();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.getPrimaryColor(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonTexts[index],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Sign in text
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Sudah punya akun? ',
                style: TextStyle(
                  color: themeProvider.getSecondaryTextColor(),
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyle(
                      color: themeProvider.getPrimaryColor(),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _navigateToSignIn();
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}