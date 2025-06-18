import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get the base theme from the provider
        final baseTheme = themeProvider.getTheme();
        
        // Create a merged theme that includes your custom settings
        final mergedTheme = baseTheme.copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeProvider.getPrimaryColor(),
            primary: themeProvider.getPrimaryColor(),
            brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
          ),
        );
        
        return MaterialApp(
          title: 'Danusin',
          debugShowCheckedModeBanner: false,
          theme: mergedTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}