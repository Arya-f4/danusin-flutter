import 'package:pocketbase/pocketbase.dart';
import 'dart:math';
import '../models/danusin_user.dart';
import '../models/danusin_product.dart';
import '../models/danusin_organization.dart';
import '../models/danusin_catalog.dart';
import '../models/danusin_review.dart';
import '../models/danusin_favorite.dart';
import '../models/danusin_banner.dart';
import '../models/danusin_comment.dart';

class PocketBaseService {
  static const String baseUrl = 'http://128.199.142.195:8090';
  static final PocketBase _pb = PocketBase(baseUrl);

  static PocketBase get instance => _pb;

  // User methods
  static Future<List<DanusinUser>> getUsers({
    int page = 1,
    int perPage = 50,
    String? filter,
    String? sort,
  }) async {
    try {
      final result = await _pb.collection('danusin_users').getList(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort,
      );
      
      return result.items.map((record) => DanusinUser.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  static Future<DanusinUser?> getUser(String id) async {
    try {
      final record = await _pb.collection('danusin_users').getOne(id);
      return DanusinUser.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  // Product methods
  static Future<List<DanusinProduct>> getProducts({
    int page = 1,
    int perPage = 50,
    String? filter,
    String? sort,
  }) async {
    try {
      final result = await _pb.collection('danusin_product').getList(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort,
      );
      
      return result.items.map((record) => DanusinProduct.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  static Future<DanusinProduct?> getProduct(String id) async {
    try {
      final record = await _pb.collection('danusin_product').getOne(id);
      return DanusinProduct.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Get products by user (danuser)
  static Future<List<DanusinProduct>> getProductsByUser(String userId) async {
    try {
      final result = await _pb.collection('danusin_product').getList(
        filter: 'added_by = "$userId"',
        sort: '-created',
      );
      
      return result.items.map((record) => DanusinProduct.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to fetch user products: $e');
    }
  }

  // Organization methods
  static Future<List<DanusinOrganization>> getOrganizations({
    int page = 1,
    int perPage = 50,
    String? filter,
    String? sort,
  }) async {
    try {
      final result = await _pb.collection('danusin_organization').getList(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort,
      );
      
      return result.items.map((record) => DanusinOrganization.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to fetch organizations: $e');
    }
  }

  // Banner methods - Updated to handle missing collection gracefully
  static Future<List<DanusinBanner>> getBanners({
    int page = 1,
    int perPage = 10,
    String? sort = 'order',
  }) async {
    try {
      // Check if banners collection exists by trying to get schema first
      final collections = await _pb.collections.getList();
      final bannerCollection = collections.items.where((c) => c.name == 'danusin_banners').firstOrNull;
      
      if (bannerCollection == null) {
        // Collection doesn't exist, return empty list
        return [];
      }

      final result = await _pb.collection('danusin_banners').getList(
        page: page,
        perPage: perPage,
        sort: sort,
      );
      
      return result.items.map((record) => DanusinBanner.fromJson(record.toJson())).toList();
    } catch (e) {
      // If collection doesn't exist or any other error, return empty list
      return [];
    }
  }

  // Review methods
  static Future<List<DanusinReview>> getReviews({
    int page = 1,
    int perPage = 50,
    String? filter,
    String? sort,
  }) async {
    try {
      final result = await _pb.collection('danusin_review').getList(
        page: page,
        perPage: perPage,
        filter: filter,
        sort: sort,
      );
      
      return result.items.map((record) => DanusinReview.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  // Get reviews for a specific danuser
  static Future<List<DanusinReview>> getReviewsForDanuser(String danuserId) async {
    try {
      final result = await _pb.collection('danusin_review').getList(
        filter: 'danuser = "$danuserId"',
        sort: '-created',
      );
      
      return result.items.map((record) => DanusinReview.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to fetch danuser reviews: $e');
    }
  }

  // Favorite methods
  static Future<List<DanusinFavorite>> getFavorites({
    int page = 1,
    int perPage = 50,
    String? filter,
  }) async {
    try {
      final result = await _pb.collection('danusin_favorite').getList(
        page: page,
        perPage: perPage,
        filter: filter,
      );
      
      return result.items.map((record) => DanusinFavorite.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  // Get user's favorite products
  static Future<List<DanusinFavorite>> getUserFavorites(String userId) async {
    try {
      final result = await _pb.collection('danusin_favorite').getList(
        filter: 'danusers_id = "$userId"',
      );
      
      return result.items.map((record) => DanusinFavorite.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to fetch user favorites: $e');
    }
  }

  // Search methods
  static Future<List<DanusinUser>> searchDanusers(String query) async {
    try {
      final result = await _pb.collection('danusin_users').getList(
        filter: 'isdanuser = true && (name ~ "$query" || bio ~ "$query" || location_address ~ "$query")',
        sort: '-created',
      );
      
      return result.items.map((record) => DanusinUser.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to search danusers: $e');
    }
  }

  static Future<List<DanusinProduct>> searchProducts(String query) async {
    try {
      final result = await _pb.collection('danusin_product').getList(
        filter: 'product_name ~ "$query" || description ~ "$query"',
        sort: '-created',
      );
      
      return result.items.map((record) => DanusinProduct.fromJson(record.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Location-based search
  static Future<List<DanusinUser>> getDanusersNearLocation({
    required double lat,
    required double lon,
    double radiusKm = 10.0,
  }) async {
    try {
      // For now, get all danusers with location and filter client-side
      // In production, you'd want to implement proper geo-spatial queries
      final result = await _pb.collection('danusin_users').getList(
        filter: 'isdanuser = true && location != null',
        sort: '-created',
      );
      
      final danusers = result.items.map((record) => DanusinUser.fromJson(record.toJson())).toList();
      
      // Filter by distance (simple implementation)
      return danusers.where((danuser) {
        if (danuser.location == null) return false;
        
        final distance = _calculateDistance(
          lat, lon,
          danuser.location!.lat, danuser.location!.lon,
        );
        
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby danusers: $e');
    }
  }

  // Helper method to calculate distance between two points
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = 
        pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        pow(sin(dLon / 2), 2);
    
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Authentication methods
  static Future<DanusinUser?> signIn(String email, String password) async {
    try {
      final authData = await _pb.collection('danusin_users').authWithPassword(email, password);
      return authData.record != null ? DanusinUser.fromJson(authData.record!.toJson()) : null;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  static Future<DanusinUser?> signUp({
    required String email,
    required String password,
    required String name,
    String? username,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': name,
        'username': username,
        'phone': phone,
        'emailVisibility': true,
      };

      final record = await _pb.collection('danusin_users').create(body: body);
      return DanusinUser.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Update user profile
  static Future<DanusinUser?> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final record = await _pb.collection('danusin_users').update(userId, body: data);
      return DanusinUser.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  static void signOut() {
    _pb.authStore.clear();
  }

  static bool get isAuthenticated => _pb.authStore.isValid;

  static DanusinUser? get currentUser {
    if (_pb.authStore.model != null) {
      return DanusinUser.fromJson(_pb.authStore.model!.toJson());
    }
    return null;
  }

  // Utility method to get file URL
  static String getFileUrl(String collectionName, String recordId, String fileName) {
    return '$baseUrl/api/files/$collectionName/$recordId/$fileName';
  }
}
