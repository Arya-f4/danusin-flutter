import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../screens/home_screen.dart';
import '../screens/map_view_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profile_screen.dart';

// Update the DanusinBottomNavigationBar class to always use the floating style
class DanusinBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isFloating = true; // Always make it floating

  const DanusinBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Home', themeProvider),
            _buildNavItem(1, Icons.search, 'Search', themeProvider),
            _buildNavItem(2, Icons.receipt_long_outlined, 'Orders', themeProvider),
            _buildNavItem(3, Icons.person_outline, 'Profile', themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, ThemeProvider themeProvider) {
    final isSelected = currentIndex == index;
    
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected 
              ? themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100]
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected 
              ? const Color(0xFF00704A)
              : themeProvider.getSecondaryTextColor(),
          size: 24,
        ),
      ),
    );
  }
}

// Helper function to navigate between main screens
void navigateToMainScreen(BuildContext context, int index) {
  // Clear the navigation stack and go to the selected screen
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) {
        switch (index) {
          case 0:
            return HomeScreen(selectedLocation: 'Perth City');
          case 1:
            return const MapViewScreen();
          case 2:
            return const OrdersScreen();
          case 3:
            return const ProfileScreen();
          default:
            return HomeScreen(selectedLocation: 'Perth City');
        }
      },
    ),
    (route) => false, // Remove all previous routes
  );
}
