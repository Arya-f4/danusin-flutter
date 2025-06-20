import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme_provider.dart';
import '../models/danusin_user.dart';
import '../models/danusin_product.dart';
import '../models/danusin_review.dart';
import '../services/pocketbase_service.dart';

class DanuserDetailScreen extends StatefulWidget {
  final DanusinUser danuser;

  const DanuserDetailScreen({
    Key? key,
    required this.danuser,
  }) : super(key: key);

  @override
  _DanuserDetailScreenState createState() => _DanuserDetailScreenState();
}

class _DanuserDetailScreenState extends State<DanuserDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<DanusinProduct> _products = [];
  List<DanusinReview> _reviews = [];
  bool _isLoadingProducts = true;
  bool _isLoadingReviews = true;
  String? _productsError;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchDanuserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDanuserData() async {
    // Fetch products
    try {
      final products = await PocketBaseService.getProductsByUser(widget.danuser.id);
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
        _productsError = 'Failed to load products: $e';
      });
    }

    // Fetch reviews
    try {
      final reviews = await PocketBaseService.getReviewsForDanuser(widget.danuser.id);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
        _reviewsError = 'Failed to load reviews: $e';
      });
    }
  }

  Future<void> _contactDanuser() async {
    if (widget.danuser.phone != null && widget.danuser.phone!.isNotEmpty) {
      final phoneNumber = widget.danuser.phone!.replaceAll(RegExp(r'[^\d+]'), '');
      final whatsappUrl = 'https://wa.me/$phoneNumber?text=Hi ${widget.danuser.name}, I found you on Danusin app!';
      
      try {
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch WhatsApp';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open WhatsApp: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      body: CustomScrollView(
        slivers: [
          // App bar with danuser image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: themeProvider.getBackgroundColor(),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    ),
                    child: widget.danuser.avatar != null && widget.danuser.avatar!.isNotEmpty
                        ? Image.network(
                            widget.danuser.getAvatarUrl(PocketBaseService.baseUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 100,
                              color: themeProvider.getSecondaryTextColor(),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 100,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
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
            ],
          ),
          
          // Danuser info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danuser name and verification
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.danuser.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.getTextColor(),
                          ),
                        ),
                      ),
                      if (widget.danuser.verified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: themeProvider.getPrimaryColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 16,
                                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Bio
                  if (widget.danuser.bio != null && widget.danuser.bio!.isNotEmpty)
                    Text(
                      widget.danuser.bio!,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.getSecondaryTextColor(),
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Location and contact info
                  if (widget.danuser.locationAddress != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.danuser.locationAddress!,
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.getTextColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  if (widget.danuser.phone != null && widget.danuser.phone!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.danuser.phone!,
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.getTextColor(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Rating and stats
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00704A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '4.5',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_reviews.length} Reviews',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_products.length} Products',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Contact button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _contactDanuser,
                      icon: const Icon(Icons.chat, color: Colors.white),
                      label: const Text(
                        'Contact via WhatsApp',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tab bar
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
                labelColor: themeProvider.getPrimaryColor(),
                unselectedLabelColor: themeProvider.getSecondaryTextColor(),
                indicatorColor: themeProvider.getPrimaryColor(),
                tabs: const [
                  Tab(text: 'Products'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'About'),
                ],
              ),
            ),
          ),
          
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Products tab
                _buildProductsTab(themeProvider),
                // Reviews tab
                _buildReviewsTab(themeProvider),
                // About tab
                _buildAboutTab(themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(ThemeProvider themeProvider) {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_productsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _productsError!,
              style: TextStyle(color: themeProvider.getTextColor()),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDanuserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: themeProvider.getSecondaryTextColor(),
            ),
            const SizedBox(height: 16),
            Text(
              'No products available',
              style: TextStyle(
                fontSize: 18,
                color: themeProvider.getTextColor(),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(product, themeProvider);
      },
    );
  }

  Widget _buildProductCard(DanusinProduct product, ThemeProvider themeProvider) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
              ),
              child: product.productImage.isNotEmpty
                  ? Image.network(
                      product.getFirstImageUrl(PocketBaseService.baseUrl) ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image,
                        color: themeProvider.getSecondaryTextColor(),
                        size: 40,
                      ),
                    )
                  : Icon(
                      Icons.image,
                      color: themeProvider.getSecondaryTextColor(),
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Product details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.productName ?? 'Unnamed Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.getTextColor(),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  if (product.description != null && product.description!.isNotEmpty)
                    Text(
                      product.description!.replaceAll(RegExp(r'<[^>]*>'), ''), // Remove HTML tags
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.getSecondaryTextColor(),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Price
                  if (product.price != null)
                    Row(
                      children: [
                        if (product.discount != null && product.discount! > 0) ...[
                          Text(
                            'Rp ${product.price!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.getSecondaryTextColor(),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          'Rp ${product.finalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.getPrimaryColor(),
                          ),
                        ),
                        if (product.discount != null && product.discount! > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discount!.toInt()}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(ThemeProvider themeProvider) {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviewsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _reviewsError!,
              style: TextStyle(color: themeProvider.getTextColor()),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDanuserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: themeProvider.getSecondaryTextColor(),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                color: themeProvider.getTextColor(),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewCard(review, themeProvider);
      },
    );
  }

  Widget _buildReviewCard(DanusinReview review, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          // Rating and date
          Row(
            children: [
              if (review.rating != null) ...[
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating!.floor()
                          ? Icons.star
                          : index < review.rating!
                              ? Icons.star_half
                              : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  review.rating!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.getTextColor(),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '${review.created.day}/${review.created.month}/${review.created.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.getSecondaryTextColor(),
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.getTextColor(),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutTab(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic info
          _buildInfoSection(
            'Basic Information',
            [
              _buildInfoItem('Name', widget.danuser.name, themeProvider),
              if (widget.danuser.username != null)
                _buildInfoItem('Username', '@${widget.danuser.username}', themeProvider),
              _buildInfoItem('Email', widget.danuser.email, themeProvider),
              if (widget.danuser.phone != null)
                _buildInfoItem('Phone', widget.danuser.phone!, themeProvider),
              _buildInfoItem('Verified', widget.danuser.verified ? 'Yes' : 'No', themeProvider),
              _buildInfoItem('Danuser', widget.danuser.isDanuser ? 'Yes' : 'No', themeProvider),
            ],
            themeProvider,
          ),
          const SizedBox(height: 24),
          
          // Location info
          if (widget.danuser.locationAddress != null || widget.danuser.location != null)
            _buildInfoSection(
              'Location',
              [
                if (widget.danuser.locationAddress != null)
                  _buildInfoItem('Address', widget.danuser.locationAddress!, themeProvider),
                if (widget.danuser.location != null) ...[
                  _buildInfoItem('Latitude', widget.danuser.location!.lat.toStringAsFixed(6), themeProvider),
                  _buildInfoItem('Longitude', widget.danuser.location!.lon.toStringAsFixed(6), themeProvider),
                ],
              ],
              themeProvider,
            ),
          const SizedBox(height: 24),
          
          // Account info
          _buildInfoSection(
            'Account',
            [
              _buildInfoItem('Member since', '${widget.danuser.created.day}/${widget.danuser.created.month}/${widget.danuser.created.year}', themeProvider),
              _buildInfoItem('Last updated', '${widget.danuser.updated.day}/${widget.danuser.updated.month}/${widget.danuser.updated.year}', themeProvider),
              _buildInfoItem('Email notifications', widget.danuser.emailNotifications ? 'Enabled' : 'Disabled', themeProvider),
              _buildInfoItem('Marketing emails', widget.danuser.marketingEmails ? 'Enabled' : 'Disabled', themeProvider),
            ],
            themeProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.getTextColor(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.getSecondaryTextColor(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.getTextColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
