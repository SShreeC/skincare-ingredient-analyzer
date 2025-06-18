// lib/services/user_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String skinType;
  final String ageRange;
  final List<String> skinConcerns;
  final List<String> allergies;
  final String? profileImagePath;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.skinType,
    required this.ageRange,
    required this.skinConcerns,
    required this.allergies,
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'skinType': skinType,
      'ageRange': ageRange,
      'skinConcerns': skinConcerns,
      'allergies': allergies,
      'profileImagePath': profileImagePath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      skinType: json['skinType'] ?? 'Normal',
      ageRange: json['ageRange'] ?? '25-34',
      skinConcerns: List<String>.from(json['skinConcerns'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      profileImagePath: json['profileImagePath'],
    );
  }
}

class ScannedProduct {
  final String id;
  final String name;
  final String brand;
  final String overallRating;
  final String ratingColor; // Store as string for serialization
  final DateTime scannedAt;
  final List<String> keyIngredients;
  final String? productImagePath;
  final double safetyScore;

  ScannedProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.overallRating,
    required this.ratingColor,
    required this.scannedAt,
    required this.keyIngredients,
    this.productImagePath,
    required this.safetyScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'overallRating': overallRating,
      'ratingColor': ratingColor,
      'scannedAt': scannedAt.toIso8601String(),
      'keyIngredients': keyIngredients,
      'productImagePath': productImagePath,
      'safetyScore': safetyScore,
    };
  }

  factory ScannedProduct.fromJson(Map<String, dynamic> json) {
    return ScannedProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      overallRating: json['overallRating'] ?? 'Unknown',
      ratingColor: json['ratingColor'] ?? 'grey',
      scannedAt: DateTime.parse(json['scannedAt']),
      keyIngredients: List<String>.from(json['keyIngredients'] ?? []),
      productImagePath: json['productImagePath'],
      safetyScore: json['safetyScore']?.toDouble() ?? 0.0,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(scannedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class UserService {
  static const String _userProfileKey = 'user_profile';
  static const String _scannedProductsKey = 'scanned_products';

  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._internal();
  UserService._internal();

  // Save user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(_userProfileKey, profileJson);
  }

  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_userProfileKey);

    if (profileJson != null) {
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserProfile.fromJson(profileMap);
    }
    return null;
  }

  // Add scanned product
  Future<void> addScannedProduct(ScannedProduct product) async {
    final products = await getScannedProducts();

    // Remove if already exists (to avoid duplicates)
    products.removeWhere((p) => p.id == product.id);

    // Add to beginning of list (most recent first)
    products.insert(0, product);

    // Keep only last 50 products to avoid excessive storage
    if (products.length > 50) {
      products.removeRange(50, products.length);
    }

    await _saveScannedProducts(products);
  }

  // Get all scanned products
  Future<List<ScannedProduct>> getScannedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString(_scannedProductsKey);

    if (productsJson != null) {
      final productsList = jsonDecode(productsJson) as List<dynamic>;
      return productsList
          .map((json) => ScannedProduct.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Get recent scanned products (last 5)
  Future<List<ScannedProduct>> getRecentScannedProducts() async {
    final allProducts = await getScannedProducts();
    return allProducts.take(5).toList();
  }

  // Private method to save products
  Future<void> _saveScannedProducts(List<ScannedProduct> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString(_scannedProductsKey, productsJson);
  }

  // Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    await prefs.remove(_scannedProductsKey);
  }

  // Get user's preferred skin type colors
  Future<String> getUserSkinType() async {
    final profile = await getUserProfile();
    return profile?.skinType ?? 'Normal';
  }
}