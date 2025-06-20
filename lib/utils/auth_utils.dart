import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../services/pocketbase_service.dart';

class AuthUtils {
  static const String _guestModeKey = 'isGuestMode';
  
  // Check if the user is in guest mode
  static Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? false;
  }
  
  // Set guest mode
  static Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, isGuest);
  }
  
  // Check if the user is authenticated
  static bool isAuthenticated() {
    return PocketBaseService.isAuthenticated;
  }
  
  // Check if the user has permission to access restricted features
  static Future<bool> canAccessRestrictedFeatures() async {
    // User must be authenticated and not in guest mode
    return isAuthenticated() && !(await isGuestMode());
  }
  
  // Show restricted access dialog
  static Future<void> showRestrictedAccessDialog(BuildContext context) async {
    final isGuest = await isGuestMode();
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              const Text('Sign In Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGuest 
                    ? 'You are currently browsing as a guest. To access this feature, please sign in or create an account.'
                    : 'You need to sign in to access this feature.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Guest users can browse danusers and products but cannot place orders or manage profiles.',
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Continue as Guest'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to sign in screen
                Navigator.pushNamed(context, '/signin');
              },
            ),
          ],
        );
      },
    );
  }
  
  // Use this method before accessing restricted features
  static Future<bool> checkAccess(BuildContext context) async {
    final hasAccess = await canAccessRestrictedFeatures();
    if (!hasAccess) {
      await showRestrictedAccessDialog(context);
    }
    return hasAccess;
  }
  
  // Sign out user
  static Future<void> signOut() async {
    PocketBaseService.signOut();
    await setGuestMode(true);
  }
  
  // Sign in user (call this after successful authentication)
  static Future<void> signIn() async {
    await setGuestMode(false);
  }
}
