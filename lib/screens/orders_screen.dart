import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/bottom_navigation_bar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for active orders
  final List<Map<String, dynamic>> _activeOrders = [
    {
      'id': 'OD-3479',
      'restaurant': 'McDonald\'s',
      'image': 'assets/images/mcdonalds.jpg',
      'status': 'On the way',
      'statusColor': Colors.orange,
      'items': ['Big Mac', 'French Fries', 'Coca Cola'],
      'total': '\$15.99',
      'date': 'Today, 12:30 PM',
      'estimatedDelivery': '15-20 min',
      'progress': 0.7,
    },
    {
      'id': 'OD-3478',
      'restaurant': 'Cafe MayField\'s',
      'image': 'assets/images/cafe.jpg',
      'status': 'Preparing',
      'statusColor': Colors.blue,
      'items': ['Chocolate Cake', 'Cappuccino'],
      'total': '\$12.50',
      'date': 'Today, 11:45 AM',
      'estimatedDelivery': '25-30 min',
      'progress': 0.4,
    },
  ];
  
  // Mock data for past orders
  final List<Map<String, dynamic>> _pastOrders = [
    {
      'id': 'OD-3477',
      'restaurant': 'Tacos Nanchas',
      'image': 'assets/images/tacos.jpg',
      'status': 'Delivered',
      'statusColor': Colors.green,
      'items': ['Beef Tacos (2)', 'Nachos', 'Guacamole'],
      'total': '\$22.75',
      'date': 'Yesterday, 7:30 PM',
    },
    {
      'id': 'OD-3476',
      'restaurant': 'KFC Foods',
      'image': 'assets/images/kfc.jpg',
      'status': 'Delivered',
      'statusColor': Colors.green,
      'items': ['Fried Chicken Bucket', 'Coleslaw', 'Mashed Potatoes'],
      'total': '\$28.99',
      'date': 'Yesterday, 1:15 PM',
    },
    {
      'id': 'OD-3475',
      'restaurant': 'Lazy Bear',
      'image': 'assets/images/lazy_bear.jpg',
      'status': 'Cancelled',
      'statusColor': Colors.red,
      'items': ['Grilled Salmon', 'Caesar Salad'],
      'total': '\$32.50',
      'date': '2 days ago, 8:00 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        bottom: TabBar(
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
      body: TabBarView(
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
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(Map<String, dynamic> order, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    order['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['restaurant'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getTextColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order ${order['id']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['date'],
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: order['statusColor'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      color: order['statusColor'],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Order items
            Text(
              'Items:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.getTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              order['items'].length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order['items'][index],
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.getTextColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Order progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Delivery:',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['estimatedDelivery'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  order['total'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.getPrimaryColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: order['progress'],
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(themeProvider.getPrimaryColor()),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
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
                      'TRACK ORDER',
                      style: TextStyle(
                        color: themeProvider.getPrimaryColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.getPrimaryColor(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'CONTACT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastOrderCard(Map<String, dynamic> order, ThemeProvider themeProvider) {
    final bool isDelivered = order['status'] == 'Delivered';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    order['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['restaurant'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getTextColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order ${order['id']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['date'],
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: order['statusColor'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      color: order['statusColor'],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Order items
            Text(
              'Items:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.getTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              order['items'].length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order['items'][index],
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.getTextColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Total and action buttons
            Row(
              children: [
                Text(
                  'Total: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.getTextColor(),
                  ),
                ),
                Text(
                  order['total'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.getPrimaryColor(),
                  ),
                ),
                const Spacer(),
                if (isDelivered)
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: themeProvider.getPrimaryColor()),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'REORDER',
                      style: TextStyle(
                        color: themeProvider.getPrimaryColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}