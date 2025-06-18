import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'restaurant_detail_screen.dart';

class FeaturedPartnersScreen extends StatelessWidget {
  const FeaturedPartnersScreen({Key? key}) : super(key: key);

  // Mock data for featured partners
  final List<Map<String, dynamic>> _featuredPartners = const [
    {
      'name': 'Tacos Nanchas',
      'image': 'assets/images/tacos.jpg',
      'rating': 4.5,
      'deliveryTime': '25min',
      'freeDelivery': true,
      'cuisines': ['Chinese', 'American'],
    },
    {
      'name': 'McDonald\'s',
      'image': 'assets/images/mcdonalds.jpg',
      'rating': 4.5,
      'deliveryTime': '25min',
      'freeDelivery': true,
      'cuisines': ['Chinese', 'American'],
    },
    {
      'name': 'KFC Foods',
      'image': 'assets/images/kfc.jpg',
      'rating': 4.5,
      'deliveryTime': '30min',
      'freeDelivery': true,
      'cuisines': ['Chinese', 'American'],
    },
    {
      'name': 'Cafe MayField\'s',
      'image': 'assets/images/cafe.jpg',
      'rating': 4.5,
      'deliveryTime': '25min',
      'freeDelivery': true,
      'cuisines': ['Chinese', 'American'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeProvider.getBackgroundColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Featured Partners',
          style: TextStyle(
            color: themeProvider.getTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _featuredPartners.length,
        itemBuilder: (context, index) {
          final restaurant = _featuredPartners[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
                ),
              );
            },
            child: _buildRestaurantCard(restaurant, themeProvider),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(themeProvider),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant image
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  restaurant['image'],
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    children: [
                      Container(
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
                      const SizedBox(width: 4),
                      if (restaurant['freeDelivery'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Free',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
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
        const SizedBox(height: 8),
        // Restaurant name
        Text(
          restaurant['name'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: themeProvider.getTextColor(),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Restaurant cuisines
        Row(
          children: [
            ...List.generate(
              restaurant['cuisines'].length > 2 ? 2 : restaurant['cuisines'].length,
              (index) => Text(
                '${index > 0 ? ' • ' : ''}${restaurant['cuisines'][index]}',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.getSecondaryTextColor(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(ThemeProvider themeProvider) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false, themeProvider),
          _buildNavItem(Icons.search, 'Search', true, themeProvider),
          _buildNavItem(Icons.receipt_long_outlined, 'Orders', false, themeProvider),
          _buildNavItem(Icons.person_outline, 'Profile', false, themeProvider),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, ThemeProvider themeProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF00704A) : themeProvider.getSecondaryTextColor(),
          size: 24,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? const Color(0xFF00704A) : themeProvider.getSecondaryTextColor(),
          ),
        ),
      ],
    );
  }
}