import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class ThemeSwitchButton extends StatelessWidget {
  final bool isTransparent;
  final bool isFloating;
  
  const ThemeSwitchButton({
    Key? key,
    this.isTransparent = false,
    this.isFloating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: isTransparent 
        ? null 
        : BoxDecoration(
            color: isFloating 
                ? themeProvider.getPrimaryColor().withOpacity(0.9)
                : themeProvider.getCardColor(),
            borderRadius: BorderRadius.circular(isFloating ? 25 : 20),
            boxShadow: isFloating ? [
              BoxShadow(
                color: themeProvider.getPrimaryColor().withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            themeProvider.isDarkMode 
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
            key: ValueKey(themeProvider.isDarkMode),
            color: isFloating 
                ? Colors.white
                : themeProvider.getPrimaryColor(),
            size: isFloating ? 20 : 24,
          ),
        ),
        onPressed: () {
          themeProvider.toggleTheme();
        },
        tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      ),
    );
  }
}
