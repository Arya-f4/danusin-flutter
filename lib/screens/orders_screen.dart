import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../services/pocketbase_service.dart';
import '../models/danusin_user.dart';
import '../utils/auth_utils.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Mock data for active orders (in real app, fetch from PocketBase)
  final List<Map<String, dynamic>> _activeOrders = [];
  
  // Mock data for past orders (in real app, fetch from PocketBase)
  final List<Map<String, dynamic>> _pastOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAuthAndLoadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndLoadOrders() async {
    // Check if user has access
    final hasAccess = await AuthUtils.canAccessRestrictedFeatures();
    if (!hasAccess) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please sign in to view your orders';
      });
      return;
    }

    // Load orders from PocketBase
    await _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you would fetch orders from PocketBase
      // For now, we'll simulate loading
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load orders: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeProvider.getBackgroundColor(),
        elevation: 0,
        title: Text(
          'My Orders',
          style: TextStyle(
            color: themeProvider.getTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: _isLoading || _errorMessage != null ? null : TabBar(
          controller: _tabController,
          labelColor: themeProvider.getPrimaryColor(),
          unselectedLabelColor: themeProvider.getSecondaryTextColor(),
          indicatorColor: themeProvider.getPrimaryColor(),
          tabs: const [
            Tab(text: 'Active Orders'),
            Tab(text: 'Past Orders'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState(themeProvider)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Active Orders Tab
                    _activeOrders.isEmpty
                        ? _buildEmptyState('No active orders', 'Your active orders will appear here', themeProvider)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _activeOrders.length,
                            itemBuilder: (context, index) {
                              final order = _activeOrders[index];
                              return _buildActiveOrderCard(order, themeProvider);
                            },
                          ),
                    
                    // Past Orders Tab
                    _pastOrders.isEmpty
                        ? _buildEmptyState('No order history', 'Your past orders will appear here', themeProvider)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _pastOrders.length,
                            itemBuilder: (context, index) {
                              final order = _pastOrders[index];
                              return _buildPastOrderCard(order, themeProvider);
                            },
                          ),
                  ],
                ),
      bottomNavigationBar: DanusinBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) => navigateToMainScreen(context, index),
      ),
    );
  }

  Widget _buildErrorState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: themeProvider.getSecondaryTextColor().withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 18,
              color: themeProvider.getTextColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final hasAccess = await AuthUtils.checkAccess(context);
              if (hasAccess) {
                _loadOrders();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.getPrimaryColor(),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: themeProvider.getSecondaryTextColor().withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.getTextColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.getSecondaryTextColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => navigateToMainScreen(context, 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.getPrimaryColor(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Browse Danusers',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(Map<String, dynamic> order, ThemeProvider themeProvider) {
    // Implementation for active order card
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        'Active Order Card',
        style: TextStyle(color: themeProvider.getTextColor()),
      ),
    );
  }

  Widget _buildPastOrderCard(Map<String, dynamic> order, ThemeProvider themeProvider) {
    // Implementation for past order card
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        'Past Order Card',
        style: TextStyle(color: themeProvider.getTextColor()),
      ),
    );
  }
}
