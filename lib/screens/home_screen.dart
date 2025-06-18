import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';
import '../theme_provider.dart';
import '../widgets/theme_switch_button.dart';
import 'featured_partners_screen.dart';
import 'restaurant_detail_screen.dart';
import 'map_view_screen.dart';
import '../widgets/bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  final String selectedLocation;

  const HomeScreen({
    Key? key,
    required this.selectedLocation,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBannerIndex = 0;
  int _selectedNavIndex = 0;
  final PageController _bannerController = PageController();

  // PocketBase instance
  final pb = PocketBase('https://pocketbase.evoptech.com');

  // Data lists
  List<Map<String, dynamic>> _bannerImages = [];
  List<Map<String, dynamic>> _bestPicks = [];
  List<Map<String, dynamic>> _allRestaurants = [];
  List<Map<String, dynamic>> _featuredPartners = [];

  // Loading and error states
  bool _isLoading = true;
  String? _errorMessage;
  String? _bannerErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _bannerController.addListener(() {
      if (_bannerController.page?.round() != _currentBannerIndex) {
        setState(() {
          _currentBannerIndex = _bannerController.page?.round() ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  // Fetch all data from PocketBase
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _bannerErrorMessage = null;
    });

    try {
      // Fetch banners
      try {
        final bannerResult = await pb.collection('danusin_banners').getList(
          page: 1,
          perPage: 10,
          sort: 'order',
        );
        _bannerImages = bannerResult.items.map((record) {
          final imageUrl = record.data['image_url']?.toString() ?? '';
          // Validate image_url
          if (imageUrl.isEmpty) {
            debugPrint('Warning: Empty image_url for banner ID: ${record.id}');
          }
          return {
            'id': record.id,
            'image_url': imageUrl,
            'title': record.data['title']?.toString() ?? '',
          };
        }).toList();
        if (_bannerImages.isEmpty) {
          setState(() {
            _bannerErrorMessage = 'No banners available.';
          });
        }
      } catch (e) {
        String bannerError = 'Failed to load banners: $e';
        if (e is ClientException) {
          bannerError = 'HTTP ${e.statusCode}: ${e.response['message'] ?? e.toString()}';
          if (e.statusCode == 403) {
            bannerError +=
                '\nCheck danusin_banners collection rules in PocketBase admin UI.';
          }
        }
        debugPrint(bannerError);
        setState(() {
          _bannerErrorMessage = bannerError;
        });
      }

      // Fetch restaurants
      final restaurantResult = await pb.collection('danusin_users').getList(
        page: 1,
        perPage: 50,
      );
      final restaurants = restaurantResult.items.map((record) {
        return {
          'id': record.id,
          'name': record.data['name']?.toString() ?? '',
          'image': record.data['image'] != null
              ? '${pb.baseUrl}/api/files/danusin_users/${record.id}/${record.data['image']}'
              : 'assets/images/placeholder.jpg',
          'location': record.data['location']?.toString() ?? '',
          'rating': record.data['rating']?.toDouble() ?? 0.0,
          'delivery_time': record.data['delivery_time']?.toString() ?? '',
          'free_delivery': record.data['free_delivery'] ?? false,
          'cuisines': record.data['cuisines'] ?? [],
          'price_range': record.data['price_range']?.toString() ?? '',
          'rating_count': record.data['rating_count']?.toString() ?? '',
          'is_best_pick': record.data['is_best_pick'] ?? false,
          'is_featured': record.data['is_featured'] ?? false,
        };
      }).toList();

      // Filter restaurants for different sections
      _bestPicks = restaurants.where((r) => r['is_best_pick'] == true).take(2).toList();
      _featuredPartners = restaurants.where((r) => r['is_featured'] == true).toList();
      _allRestaurants = restaurants;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      String errorDetail = e.toString();
      if (e is ClientException) {
        errorDetail = 'HTTP ${e.statusCode}: ${e.response['message'] ?? e.toString()}';
        if (e.statusCode == 403) {
          errorDetail +=
              '\nCheck danusin_users collection rules in PocketBase admin UI or log in to access data.';
        }
      }
      debugPrint(errorDetail);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $errorDetail';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: themeProvider.getTextColor()),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchData,
                              child: const Text('Retry'),
                            ),
                            if (_errorMessage!.contains('403'))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  child: const Text('Log in'),
                                ),
                              ),
                          ],
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Location header
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            widget.selectedLocation,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: themeProvider.getTextColor(),
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: themeProvider.getTextColor(),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const MapViewScreen()),
                                          );
                                        },
                                        child: Text(
                                          'Filter',
                                          style: TextStyle(
                                            color: themeProvider.getTextColor(),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Banner carousel
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: _bannerErrorMessage != null
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.grey[800]
                                                  : Colors.grey[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _bannerErrorMessage!,
                                                style: TextStyle(
                                                  color: themeProvider.getTextColor(),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          )
                                        : _bannerImages.isEmpty
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: themeProvider.isDarkMode
                                                      ? Colors.grey[800]
                                                      : Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'No banners available.',
                                                    style: TextStyle(
                                                      color: themeProvider.getTextColor(),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Stack(
                                                children: [
                                                  PageView.builder(
                                                    controller: _bannerController,
                                                    itemCount: _bannerImages.length,
                                                    onPageChanged: (index) {
                                                      setState(() {
                                                        _currentBannerIndex = index;
                                                      });
                                                    },
                                                    itemBuilder: (context, index) {
                                                      final banner = _bannerImages[index];
                                                      return ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: Image.network(
                                                          banner['image_url'],
                                                          width: double.infinity,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error, stackTrace) {
                                                            debugPrint(
                                                                'Failed to load banner image: ${banner['image_url']}');
                                                            return Image.asset(
                                                              'assets/images/placeholder.jpg',
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Positioned(
                                                    bottom: 12,
                                                    left: 0,
                                                    right: 0,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                      children: List.generate(
                                                        _bannerImages.length,
                                                        (index) => Container(
                                                          margin: const EdgeInsets.symmetric(
                                                              horizontal: 3),
                                                          width: 8,
                                                          height: 8,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: index == _currentBannerIndex
                                                                ? Colors.white
                                                                : Colors.white.withOpacity(0.5),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Featured Partners section
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Featured Partners',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: themeProvider.getTextColor(),
                                          height: 1.2,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const FeaturedPartnersScreen()),
                                          );
                                        },
                                        child: const Text(
                                          'See all',
                                          style: TextStyle(
                                            color: Color(0xFF00704A),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Featured Partners horizontal list
                                SizedBox(
                                  height: 180,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _featuredPartners.length,
                                    itemBuilder: (context, index) {
                                      final partner = _featuredPartners[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RestaurantDetailScreen(restaurant: partner),
                                            ),
                                          );
                                        },
                                        child: _buildRestaurantCard(partner, themeProvider),
                                      );
                                    },
                                  ),
                                ),
                                // Best Picks section
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Best Picks Danuser\nby team',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: themeProvider.getTextColor(),
                                          height: 1.2,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const MapViewScreen()),
                                          );
                                        },
                                        child: const Text(
                                          'See all',
                                          style: TextStyle(
                                            color: Color(0xFF00704A),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Best Picks cards
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      if (_bestPicks.isNotEmpty)
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => RestaurantDetailScreen(
                                                      restaurant: _bestPicks[0]),
                                                ),
                                              );
                                            },
                                            child:
                                                _buildBestPickCard(_bestPicks[0], themeProvider),
                                          ),
                                        ),
                                      if (_bestPicks.length > 1) const SizedBox(width: 12),
                                      if (_bestPicks.length > 1)
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => RestaurantDetailScreen(
                                                      restaurant: _bestPicks[1]),
                                                ),
                                              );
                                            },
                                            child:
                                                _buildBestPickCard(_bestPicks[1], themeProvider),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // All Restaurants section
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'All Restaurants',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: themeProvider.getTextColor(),
                                        ),
                                      ),
                                      const Text(
                                        'See all',
                                        style: TextStyle(
                                          color: Color(0xFF00704A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // All Restaurants list
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final restaurant = _allRestaurants[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RestaurantDetailScreen(restaurant: restaurant),
                                        ),
                                      );
                                    },
                                    child: _buildRestaurantListItem(restaurant, themeProvider),
                                  ),
                                );
                              },
                              childCount: _allRestaurants.length,
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 80),
                          ),
                        ],
                      ),
            // Theme switcher button
            Positioned(
              top: 8,
              right: 8,
              child: ThemeSwitchButton(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DanusinBottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => navigateToMainScreen(context, index),
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant, ThemeProvider themeProvider) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Image.network(
                  restaurant['image'],
                  width: 140,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.jpg',
                    width: 140,
                    height: 100,
                    fit: BoxFit.cover,
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
                          restaurant['delivery_time'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            restaurant['name'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.getTextColor(),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            restaurant['cuisines'].join(' • '),
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.getSecondaryTextColor(),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (restaurant['free_delivery'])
            Row(
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  size: 14,
                  color: themeProvider.getSecondaryTextColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  'Free delivery',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBestPickCard(Map<String, dynamic> restaurant, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.network(
                  restaurant['image'],
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.jpg',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.getTextColor(),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        restaurant['location'],
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      restaurant['delivery_time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.getSecondaryTextColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantListItem(
      Map<String, dynamic> restaurant, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.network(
                  restaurant['image'],
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.jpg',
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00704A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          restaurant['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        restaurant['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getTextColor(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      restaurant['price_range'],
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.getSecondaryTextColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant['cuisines'].join(' • '),
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      restaurant['rating_count'],
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.getSecondaryTextColor(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant['delivery_time'],
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    if (restaurant['free_delivery'])
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 16,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Free',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.getSecondaryTextColor(),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}