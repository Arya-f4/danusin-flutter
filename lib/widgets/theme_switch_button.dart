import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class ThemeSwitchButton extends StatelessWidget {
  final bool isTransparent;
  
  const ThemeSwitchButton({
    Key? key,
    this.isTransparent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      decoration: isTransparent 
        ? null 
        : BoxDecoration(
            color: themeProvider.getCardColor(),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: IconButton(
        icon: Icon(
          themeProvider.isDarkMode 
            ? Icons.light_mode 
            : Icons.dark_mode,
          color: themeProvider.getPrimaryColor(),
        ),
        onPressed: () {
          themeProvider.toggleTheme();
        },
      ),
    );
  }
}