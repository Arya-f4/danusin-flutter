import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:pocketbase/pocketbase.dart';
import 'package:geolocator/geolocator.dart';
import '../theme_provider.dart';
import 'restaurant_detail_screen.dart';
import '../widgets/bottom_navigation_bar.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  String _selectedCategory = 'BURGERS';
  final List<String> _categories = ['BURGERS', 'BRUNCH', 'BREAKFAST'];

  // Map controller
  final MapController _mapController = MapController();

  // Default center (Perth, Australia)
  static const latlng.LatLng _perthLocation = latlng.LatLng(-31.9523, 115.8613);

  // Markers
  final List<Marker> _markers = [];

  // Selected restaurant ID
  String? _selectedRestaurantId;

  // PocketBase instance
  final pb = PocketBase('https://pocketbase.evoptech.com');

  // Mock restaurant data
  final List<Map<String, dynamic>> _restaurants = [
    {
      'id': 'r1',
      'name': 'Nethai Kitchen',
      'rating': 4.5,
      'deliveryTime': '30min',
      'freeDelivery': true,
      'cuisines': ['Thai', 'Asian'],
      'location': latlng.LatLng(-31.9513, 115.8573),
      'address': '123 Hay Street, Perth',
    },
    {
      'id': 'r2',
      'name': 'Lazy Bear',
      'image': 'assets/images/lazy_bear.jpg',
      'rating': 4.5,
      'deliveryTime': '25min',
      'freeDelivery': true,
      'cuisines': ['Cafe', 'Brunch'],
      'location': latlng.LatLng(-31.9533, 115.8633),
      'address': '456 Murray Street, Perth',
    },
    {
      'id': 'r3',
      'name': 'Burger Palace',
      'image': 'assets/images/mcdonalds.jpg',
      'rating': 4.2,
      'deliveryTime': '20min',
      'freeDelivery': true,
      'cuisines': ['Burgers', 'American'],
      'location': latlng.LatLng(-31.9553, 115.8593),
      'address': '789 Wellington Street, Perth',
    },
    {
      'id': 'r4',
      'name': 'Mario Italiano',
      'image': 'assets/images/cafe.jpg',
      'rating': 4.7,
      'deliveryTime': '35min',
      'freeDelivery': true,
      'cuisines': ['Italian', 'Pizza'],
      'location': latlng.LatLng(-31.9503, 115.8653),
      'address': '321 St Georges Terrace, Perth',
    },
  ];

  // User data from PocketBase
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _createMarkers();
    _updateUserLocation();
  }

  // Fetch users from PocketBase
  Future<void> _fetchUsers() async {
    try {
      final result = await pb.collection('danusin_users').getList(
        page: 1,
        perPage: 100,
        filter: 'location != null',
      );
      setState(() {
        _users = result.items.map((record) {
          final location = record.data['location'] as Map<String, dynamic>?;
          return {
            'id': record.id,
            'username': record.data['username'],
            'location': location != null
                ? latlng.LatLng(location['lat'] as double, location['lon'] as double)
                : null,
          };
        }) .where((user) => user['location'] != null)
            .toList();
        _createMarkers();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user locations: $e')),
        );
      }
    }
  }

  // Update current user's location in PocketBase
  Future<void> _updateUserLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update user location in PocketBase (assuming user is authenticated)
      if (pb.authStore.isValid) {
        final body = <String, dynamic>{
          'location': {
            'lat': position.latitude,
            'lon': position.longitude,
          },
        };
        await pb.collection('danusin_users').update(
          pb.authStore.model.id,
          body: body,
        );
        _fetchUsers(); // Refresh user markers
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update location: $e')),
        );
      }
    }
  }

  // Create markers for restaurants and users
  void _createMarkers() {
    _markers.clear();

    // Restaurant markers
    for (final restaurant in _restaurants) {
      final markerId = restaurant['id'] as String;
      final markerPosition = restaurant['location'] as latlng.LatLng;

      _markers.add(
        Marker(
          point: markerPosition,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _selectRestaurant(markerId),
            child: Icon(
              Icons.restaurant,
              color: _selectedRestaurantId == markerId ? Colors.green : Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    }

    // User markers
    for (final user in _users) {
      final markerId = user['id'] as String;
      final markerPosition = user['location'] as latlng.LatLng;

      _markers.add(
        Marker(
          point: markerPosition,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User: ${user['username']}')),
              );
            },
            child: const Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
              size: 40,
            ),
          ),
        ),
      );
    }
  }

  // Select a restaurant and update its marker
  void _selectRestaurant(String restaurantId) {
    setState(() {
      _selectedRestaurantId = restaurantId;

      final selectedRestaurantIndex = _restaurants.indexWhere(
        (restaurant) => restaurant['id'] == restaurantId,
      );

      if (selectedRestaurantIndex != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToRestaurant(selectedRestaurantIndex);
        });
      }

      _createMarkers();
    });
  }

  // Scroll to a restaurant in the list
  final ScrollController _scrollController = ScrollController();
  void _scrollToRestaurant(int index) {
    if (_scrollController.hasClients) {
      final itemHeight = 116.0;
      _scrollController.animateTo(
        index * itemHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Filter restaurants by category
  List<Map<String, dynamic>> get _filteredRestaurants {
    if (_selectedCategory == 'ALL') {
      return _restaurants;
    }

    switch (_selectedCategory) {
      case 'BURGERS':
        return _restaurants
            .where((r) => (r['cuisines'] as List<String>)
                .containsAny(['Burgers', 'American']))
            .toList();
      case 'BRUNCH':
        return _restaurants
            .where((r) =>
                (r['cuisines'] as List<String>).containsAny(['Cafe', 'Brunch']))
            .toList();
      case 'BREAKFAST':
        return _restaurants
            .where((r) =>
                (r['cuisines'] as List<String>).containsAny(['Cafe', 'Brunch']))
            .toList();
      default:
        return _restaurants;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: themeProvider.getBackgroundColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Top Pick Danuser',
          style: TextStyle(
            color: themeProvider.getTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // OpenStreetMap view
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _perthLocation,
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                      additionalOptions: themeProvider.isDarkMode
                          ? {
                              'tileProvider': 'CartoDB.DarkMatter',
                              'urlTemplate':
                                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                            }
                          : {},
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                // Back button
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Search button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.black),
                      onPressed: () {
                        // Show search dialog
                      },
                    ),
                  ),
                ),
                // My location button
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.black),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Category filters
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00704A).withOpacity(0.1)
                            : themeProvider.isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF00704A))
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF00704A)
                              : themeProvider.getSecondaryTextColor(),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Restaurant list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
              itemCount: _filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _filteredRestaurants[index];
                final isSelected = restaurant['id'] == _selectedRestaurantId;

                return GestureDetector(
                  onTap: () {
                    _selectRestaurant(restaurant['id'] as String);
                    _animateToLocation(restaurant['location'] as latlng.LatLng);
                  },
                  child: _buildRestaurantCard(restaurant, themeProvider, isSelected),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: DanusinBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) => navigateToMainScreen(context, index),
      ),
    );
  }

  // Animate map to a specific location
  void _animateToLocation(latlng.LatLng location) {
    _mapController.move(location, 15);
  }

  // Get current user location and animate map to it
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final location = latlng.LatLng(position.latitude, position.longitude);
      _animateToLocation(location);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  Widget _buildRestaurantCard(
      Map<String, dynamic> restaurant, ThemeProvider themeProvider, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: const Color(0xFF00704A), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    restaurant['image'] ?? 'assets/images/placeholder.jpg',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            restaurant['deliveryTime'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00704A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        restaurant['rating'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Restaurant details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    restaurant['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.getTextColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Restaurant address
                  Text(
                    restaurant['address'],
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Restaurant cuisines
                  Row(
                    children: [
                      ...List.generate(
                        restaurant['cuisines'].length > 2
                            ? 2
                            : restaurant['cuisines'].length,
                        (index) => Text(
                          '${index > 0 ? ' • ' : ''}${restaurant['cuisines'][index]}',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Free delivery
                  if (restaurant['freeDelivery'])
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on_outlined,
                          size: 16,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Free delivery',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // View button
          Padding(
            padding: const EdgeInsets.all(12),
            child: IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: themeProvider.getSecondaryTextColor(),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestaurantDetailScreen(restaurant: restaurant),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to check if any items exist in the list
extension ListFilterExtension<T> on List<T> {
  bool containsAny(List<T> items) {
    return any((element) => items.contains(element));
  }
}