import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../services/pocketbase_service.dart';
import '../models/danusin_user.dart';
import 'danuser_detail_screen.dart';
import '../widgets/bottom_navigation_bar.dart';

class FeaturedPartnersScreen extends StatefulWidget {
  const FeaturedPartnersScreen({Key? key}) : super(key: key);

  @override
  _FeaturedPartnersScreenState createState() => _FeaturedPartnersScreenState();
}

class _FeaturedPartnersScreenState extends State<FeaturedPartnersScreen> {
  List<DanusinUser> _featuredPartners = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFeaturedPartners();
  }

  Future<void> _fetchFeaturedPartners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final partners = await PocketBaseService.getUsers(
        filter: 'isdanuser = true',
        sort: '-created',
        perPage: 20,
      );
      
      setState(() {
        _featuredPartners = partners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load featured partners: $e';
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Featured Danusers',
          style: TextStyle(
            color: themeProvider.getTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
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
                        onPressed: _fetchFeaturedPartners,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _featuredPartners.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 64,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No featured danusers available',
                            style: TextStyle(
                              fontSize: 18,
                              color: themeProvider.getTextColor(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _featuredPartners.length,
                      itemBuilder: (context, index) {
                        final danuser = _featuredPartners[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DanuserDetailScreen(danuser: danuser),
                              ),
                            );
                          },
                          child: _buildDanuserCard(danuser, themeProvider),
                        );
                      },
                    ),
      bottomNavigationBar: DanusinBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) => navigateToMainScreen(context, index),
      ),
    );
  }

  Widget _buildDanuserCard(DanusinUser danuser, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Danuser image
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: danuser.avatar != null && danuser.avatar!.isNotEmpty
                      ? Image.network(
                          danuser.getAvatarUrl(PocketBaseService.baseUrl),
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
        ),
        const SizedBox(height: 8),
        // Danuser name
        Text(
          danuser.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: themeProvider.getTextColor(),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Location
        if (danuser.locationAddress != null)
          Text(
            danuser.locationAddress!,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.getSecondaryTextColor(),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
