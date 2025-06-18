import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for menu categories
  final List<String> _categories = [
    'Featured Items',
    'Beef & Lamb',
    'Seafood',
    'Appetizers',
    'Desserts',
  ];
  
  // Mock data for menu items
  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'Cookie Sanwich',
      'price': 'Rp 6000',
      'cuisine': 'Chinese',
      'image': 'assets/images/cookie.jpg',
    },
    {
      'name': 'Chow Fun',
      'price': 'Rp 7000',
      'cuisine': 'Chinese',
      'image': 'assets/images/chow_fun.jpg',
    },
    {
      'name': 'Dim Sum',
      'price': 'Rp 9000',
      'cuisine': 'Chinese',
      'image': 'assets/images/dim_sum.jpg',
    },
    {
      'name': 'Shortbread chocolate turtle cookies and toasted nut',
      'price': 'Rp 1000',
      'cuisine': 'Dessert',
      'image': 'assets/images/shortbread.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      body: CustomScrollView(
        slivers: [
          // App bar with restaurant image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: themeProvider.getBackgroundColor(),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.restaurant['image'],
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          
          // Restaurant info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    widget.restaurant['name'] ?? 'Mayfield Bakery & Cafe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.getTextColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price range and cuisines
                  Row(
                    children: [
                      Text(
                        widget.restaurant['priceRange'] ?? 'Rp 5000',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(
                        widget.restaurant['cuisines']?.length ?? 3,
                        (index) => Row(
                          children: [
                            Text(
                              ' • ',
                              style: TextStyle(
                                color: themeProvider.getSecondaryTextColor(),
                              ),
                            ),
                            Text(
                              widget.restaurant['cuisines']?[index] ?? 'Chinese',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.getSecondaryTextColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Rating and waiting time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00704A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.restaurant['rating']?.toString() ?? '4.3',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.restaurant['ratingCount'] ?? '200+ Ratings',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: themeProvider.getSecondaryTextColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.restaurant['waitingTime'] ?? '25 Minutes waiting time',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Find them button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: themeProvider.getPrimaryColor()),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'FIND THEM!',
                        style: TextStyle(
                          color: themeProvider.getPrimaryColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Featured Items heading
                  Text(
                    'Featured\nItems',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.getTextColor(),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Featured menu items
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return _buildMenuItem(item, themeProvider);
                },
              ),
            ),
          ),
          
          // Menu categories
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: themeProvider.getDividerColor(),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: themeProvider.getPrimaryColor(),
                unselectedLabelColor: themeProvider.getSecondaryTextColor(),
                indicatorColor: themeProvider.getPrimaryColor(),
                tabs: _categories.map((category) => Tab(text: category)).toList(),
              ),
            ),
          ),
          
          // Menu items for selected category
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300, // Fixed height for demo purposes
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return _buildMenuListItem(item, themeProvider);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(themeProvider),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, ThemeProvider themeProvider) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                item['image'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Item name
          Text(
            item['name'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: themeProvider.getTextColor(),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Price and cuisine
          Row(
            children: [
              Text(
                item['price'],
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.getSecondaryTextColor(),
                ),
              ),
              Text(
                ' • ${item['cuisine']}',
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

  Widget _buildMenuListItem(Map<String, dynamic> item, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                item['image'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item name
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.getTextColor(),
                  ),
                ),
                const SizedBox(height: 4),
                // Price and cuisine
                Text(
                  '${item['price']} • ${item['cuisine']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                ),
                const SizedBox(height: 8),
                // Description (mock)
                Text(
                  'Delicious ${item['name']} prepared with fresh ingredients.',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          _buildNavItem(Icons.search, 'Search', false, themeProvider),
          _buildNavItem(Icons.receipt_long_outlined, 'Orders', true, themeProvider),
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