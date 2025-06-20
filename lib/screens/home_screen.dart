import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/theme_switch_button.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../services/pocketbase_service.dart';
import '../models/danusin_user.dart';
import '../models/danusin_product.dart';
import '../models/danusin_banner.dart';
import 'featured_partners_screen.dart';
import 'danuser_detail_screen.dart';
import 'map_view_screen.dart';

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

  // Data lists
  List<DanusinBanner> _bannerImages = [];
  List<DanusinUser> _bestPicks = [];
  List<DanusinUser> _allDanusers = [];
  List<DanusinUser> _featuredPartners = [];
  List<DanusinProduct> _featuredProducts = [];

  // Loading and error states
  bool _isLoading = true;
  String? _errorMessage;

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
    });

    try {
      // Fetch banners (handle gracefully if collection doesn't exist)
      _bannerImages = await PocketBaseService.getBanners();

      // Fetch danusers (users who are danusers)
      final danusers = await PocketBaseService.getUsers(
        filter: 'isdanuser = true',
        sort: '-created',
      );

      // Filter danusers for different sections
      _bestPicks = danusers.take(2).toList();
      _featuredPartners = danusers.take(10).toList();
      _allDanusers = danusers;

      // Fetch featured products
      _featuredProducts = await PocketBaseService.getProducts(
        perPage: 10,
        sort: '-created',
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: $e';
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
                                          Icon(
                                            Icons.location_on,
                                            color: themeProvider.getPrimaryColor(),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
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
                                    child: _bannerImages.isEmpty
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.grey[800]
                                                  : Colors.grey[100],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image,
                                                    size: 50,
                                                    color: themeProvider.getSecondaryTextColor(),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'No banners available',
                                                    style: TextStyle(
                                                      color: themeProvider.getTextColor(),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
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
                                                    child: banner.image != null && banner.image!.isNotEmpty
                                                        ? Image.network(
                                                            banner.getImageUrl(PocketBaseService.baseUrl),
                                                            width: double.infinity,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return Container(
                                                                color: themeProvider.isDarkMode
                                                                    ? Colors.grey[800]
                                                                    : Colors.grey[200],
                                                                child: Center(
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons.image_not_supported,
                                                                        color: themeProvider.getSecondaryTextColor(),
                                                                        size: 50,
                                                                      ),
                                                                      if (banner.title != null) ...[
                                                                        const SizedBox(height: 8),
                                                                        Text(
                                                                          banner.title!,
                                                                          style: TextStyle(
                                                                            color: themeProvider.getTextColor(),
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : Container(
                                                            color: themeProvider.isDarkMode
                                                                ? Colors.grey[800]
                                                                : Colors.grey[200],
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Icon(
                                                                    Icons.image,
                                                                    color: themeProvider.getSecondaryTextColor(),
                                                                    size: 50,
                                                                  ),
                                                                  if (banner.title != null) ...[
                                                                    const SizedBox(height: 8),
                                                                    Text(
                                                                      banner.title!,
                                                                      style: TextStyle(
                                                                        color: themeProvider.getTextColor(),
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                  );
                                                },
                                              ),
                                              if (_bannerImages.length > 1)
                                                Positioned(
                                                  bottom: 12,
                                                  left: 0,
                                                  right: 0,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: List.generate(
                                                      _bannerImages.length,
                                                      (index) => Container(
                                                        margin: const EdgeInsets.symmetric(horizontal: 3),
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
                                        'Featured Danusers',
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
                                  child: _featuredPartners.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No featured danusers available',
                                            style: TextStyle(
                                              color: themeProvider.getSecondaryTextColor(),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
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
                                                        DanuserDetailScreen(danuser: partner),
                                                  ),
                                                );
                                              },
                                              child: _buildDanuserCard(partner, themeProvider),
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
                                  child: _bestPicks.isEmpty
                                      ? Container(
                                          height: 120,
                                          child: Center(
                                            child: Text(
                                              'No best picks available',
                                              style: TextStyle(
                                                color: themeProvider.getSecondaryTextColor(),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            if (_bestPicks.isNotEmpty)
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => DanuserDetailScreen(
                                                            danuser: _bestPicks[0]),
                                                      ),
                                                    );
                                                  },
                                                  child: _buildBestPickCard(_bestPicks[0], themeProvider),
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
                                                        builder: (context) => DanuserDetailScreen(
                                                            danuser: _bestPicks[1]),
                                                      ),
                                                    );
                                                  },
                                                  child: _buildBestPickCard(_bestPicks[1], themeProvider),
                                                ),
                                              ),
                                          ],
                                        ),
                                ),
                                // All Danusers section
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'All Danusers',
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
                          // All Danusers list
                          _allDanusers.isEmpty
                              ? SliverToBoxAdapter(
                                  child: Container(
                                    height: 200,
                                    child: Center(
                                      child: Text(
                                        'No danusers available',
                                        style: TextStyle(
                                          color: themeProvider.getSecondaryTextColor(),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final danuser = _allDanusers[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DanuserDetailScreen(danuser: danuser),
                                              ),
                                            );
                                          },
                                          child: _buildDanuserListItem(danuser, themeProvider),
                                        ),
                                      );
                                    },
                                    childCount: _allDanusers.length,
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

  Widget _buildDanuserCard(DanusinUser danuser, ThemeProvider themeProvider) {
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
                Container(
                  width: 140,
                  height: 100,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: danuser.avatar != null && danuser.avatar!.isNotEmpty
                      ? Image.network(
                          danuser.getAvatarUrl(PocketBaseService.baseUrl),
                          width: 140,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 50,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 50,
                          color: themeProvider.getSecondaryTextColor(),
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
                    child: const Text(
                      '4.5',
                      style: TextStyle(
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
                    child: const Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.white, size: 12),
                        SizedBox(width: 2),
                        Text(
                          'Online',
                          style: TextStyle(
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
            danuser.name,
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
            danuser.locationAddress ?? 'Location not set',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.getSecondaryTextColor(),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.verified,
                size: 14,
                color: themeProvider.getPrimaryColor(),
              ),
              const SizedBox(width: 4),
              Text(
                'Verified Danuser',
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

  Widget _buildBestPickCard(DanusinUser danuser, ThemeProvider themeProvider) {
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
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: danuser.avatar != null && danuser.avatar!.isNotEmpty
                      ? Image.network(
                          danuser.getAvatarUrl(PocketBaseService.baseUrl),
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 60,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: themeProvider.getSecondaryTextColor(),
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
                    child: const Text(
                      '4.5',
                      style: TextStyle(
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
                  danuser.name,
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
                        danuser.locationAddress ?? 'Location not set',
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
                      Icons.verified,
                      size: 14,
                      color: themeProvider.getPrimaryColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
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

  Widget _buildDanuserListItem(DanusinUser danuser, ThemeProvider themeProvider) {
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
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: danuser.avatar != null && danuser.avatar!.isNotEmpty
                      ? Image.network(
                          danuser.getAvatarUrl(PocketBaseService.baseUrl),
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 75,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 75,
                          color: themeProvider.getSecondaryTextColor(),
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
                    child: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.5',
                          style: TextStyle(
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
                        danuser.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getTextColor(),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeProvider.getPrimaryColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Danuser',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  danuser.bio ?? 'No bio available',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '100+ Reviews',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.getSecondaryTextColor(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          danuser.locationAddress ?? 'Location not set',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: themeProvider.getPrimaryColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.getPrimaryColor(),
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
