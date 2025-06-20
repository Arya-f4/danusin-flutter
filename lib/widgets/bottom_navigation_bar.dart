import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../screens/home_screen.dart';
import '../screens/map_view_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/first_page_screen.dart';
import '../utils/auth_utils.dart';

class DanusinBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DanusinBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      height: 64,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', themeProvider, context),
          _buildNavItem(1, Icons.search_outlined, Icons.search, 'Search', themeProvider, context),
          _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long, 'Orders', themeProvider, context),
          _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile', themeProvider, context),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index, 
    IconData outlinedIcon, 
    IconData filledIcon, 
    String label, 
    ThemeProvider themeProvider,
    BuildContext context,
  ) {
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => _handleNavTap(index, context),
        borderRadius: BorderRadius.circular(32),
        child: Container(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? themeProvider.getPrimaryColor().withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSelected ? filledIcon : outlinedIcon,
                  color: isSelected 
                      ? themeProvider.getPrimaryColor()
                      : themeProvider.getSecondaryTextColor(),
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected 
                      ? themeProvider.getPrimaryColor()
                      : themeProvider.getSecondaryTextColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNavTap(int index, BuildContext context) async {
    // Check if user needs authentication for certain features
    if (index == 2 || index == 3) { // Orders or Profile
      final hasAccess = await AuthUtils.checkAccess(context);
      if (!hasAccess) {
        return; // Don't navigate if access is denied
      }
    }

    // Call the provided onTap callback
    onTap(index);
  }
}

// Helper function to navigate between main screens
void navigateToMainScreen(BuildContext context, int index) async {
  // Get current route name to avoid unnecessary navigation
  final currentRoute = ModalRoute.of(context)?.settings.name;
  
  Widget targetScreen;
  String routeName;

  switch (index) {
    case 0:
      // Check if we need to go to FirstPageScreen for location selection
      if (currentRoute == '/first-page' || currentRoute == null) {
        targetScreen = const FirstPageScreen();
        routeName = '/first-page';
      } else {
        targetScreen = const HomeScreen(selectedLocation: 'Surabaya');
        routeName = '/home';
      }
      break;
    case 1:
      targetScreen = const MapViewScreen();
      routeName = '/map';
      break;
    case 2:
      // Check authentication for orders
      final hasAccess = await AuthUtils.checkAccess(context);
      if (!hasAccess) return;
      
      targetScreen = const OrdersScreen();
      routeName = '/orders';
      break;
    case 3:
      // Check authentication for profile
      final hasAccess = await AuthUtils.checkAccess(context);
      if (!hasAccess) return;
      
      targetScreen = const ProfileScreen();
      routeName = '/profile';
      break;
    default:
      targetScreen = const HomeScreen(selectedLocation: 'Surabaya');
      routeName = '/home';
  }

  // Only navigate if we're not already on the target screen
  if (currentRoute != routeName) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        settings: RouteSettings(name: routeName),
      ),
      (route) => false,
    );
  }
}
