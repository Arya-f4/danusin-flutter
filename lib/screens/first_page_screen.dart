import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import '../theme_provider.dart';
import '../widgets/theme_switch_button.dart';

class FirstPageScreen extends StatefulWidget {
  const FirstPageScreen({Key? key}) : super(key: key);

  @override
  _FirstPageScreenState createState() => _FirstPageScreenState();
}

class _FirstPageScreenState extends State<FirstPageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;
  String _searchQuery = '';
  
  // Mock location data
  final List<Map<String, String>> _locationSuggestions = [
    {'name': 'St Georgese Terrace, Perth', 'region': 'Western Australia'},
    {'name': 'Murray street, Perth', 'region': 'Western Australia'},
    {'name': 'Kings Square, Perth', 'region': 'Western Australia'},
    {'name': 'San Francisco', 'region': 'California'},
    {'name': 'San Francisco', 'region': 'California'},
    {'name': 'Sydney CBD', 'region': 'New South Wales'},
    {'name': 'Melbourne Central', 'region': 'Victoria'},
  ];
  
  List<Map<String, String>> get filteredSuggestions {
    if (_searchQuery.isEmpty) {
      return _locationSuggestions;
    }
    
    return _locationSuggestions.where((location) {
      return location['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             location['region']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _selectLocation(Map<String, String> location) {
    setState(() {
      _searchController.text = location['name']!;
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();
    
    // Show a brief loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.getPrimaryColor()),
          ),
        );
      },
    );
    
    // Navigate to the home screen after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.of(context).pop(); // Dismiss the loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            selectedLocation: location['name']!,
          ),
        ),
      );
    });
  }

  void _requestLocationPermission() {
    // In a real app, you would request location permissions here
    
    // Show a brief loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeProvider.getPrimaryColor()),
          ),
        );
      },
    );
    
    // Navigate to the home screen after a short delay with a default location
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.of(context).pop(); // Dismiss the loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(
            selectedLocation: 'Current Location',
          ),
        ),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Heading
                  Text(
                    'Find Danuser near you',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.getPrimaryColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Text(
                    'Please enter your location or allow access to your location to find restaurants near you.',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.getSecondaryTextColor(),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Search input
                  Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(color: themeProvider.getTextColor()),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _showSuggestions = true;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your location',
                        hintStyle: TextStyle(color: themeProvider.getSecondaryTextColor()),
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear, 
                                  color: themeProvider.getSecondaryTextColor(),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location suggestions
                  if (_showSuggestions)
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredSuggestions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: themeProvider.getDividerColor(),
                        ),
                        itemBuilder: (context, index) {
                          final location = filteredSuggestions[index];
                          return ListTile(
                            leading: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: themeProvider.getSecondaryTextColor(),
                            ),
                            title: Text(
                              location['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: themeProvider.getTextColor(),
                              ),
                            ),
                            subtitle: Text(
                              location['region']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.getSecondaryTextColor(),
                              ),
                            ),
                            onTap: () => _selectLocation(location),
                          );
                        },
                      ),
                    ),
                  if (!_showSuggestions)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_searching,
                              size: 80,
                              color: themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Allow location access',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.getTextColor(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'For better restaurant recommendations',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.getSecondaryTextColor(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _requestLocationPermission,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeProvider.getPrimaryColor(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Allow Location Access',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
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