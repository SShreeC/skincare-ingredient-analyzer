


// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:skin_food_scanner/theme.dart';
import 'package:skin_food_scanner/services/user_services.dart';
import 'dart:io';
import'package:skin_food_scanner/screens/ProfileScreen.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  UserProfile? userProfile;
  List<ScannedProduct> recentScans = [];
  bool isLoading = true;
  String selectedSkinType = 'Normal';

  final List<String> skinTypes = ['Normal', 'Sensitive', 'Oily', 'Acne-prone'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app becomes active (user returns from another screen)
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await UserService.instance.getUserProfile();
      final scans = await UserService.instance.getRecentScannedProducts();

      setState(() {
        userProfile = profile;
        recentScans = scans;
        selectedSkinType = profile?.skinType ?? 'Normal';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _loadUserData();
  }

  void _navigateToProfile() async {
    // Navigate to profile screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );

    // Refresh data if profile was updated
    if (result == true) {
      _loadUserData();
    }
  }

  Color _getSafetyColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'safe':
        return SafetyColors.safe;
      case 'caution':
        return SafetyColors.caution;
      case 'harmful':
      case 'unsafe':
        return SafetyColors.harmful;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skincare Safety'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Handle notification icon press
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              // Skin Type Selector
              _buildSkinTypeSelector(),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Recent Scans
              _buildRecentScans(),
              const SizedBox(height: 24),

              // Tips Section
              _buildTipsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final userName = userProfile?.name ?? 'there';
    final firstName = userName.split(' ').first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $firstName! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userProfile != null
                      ? 'Ready to check your skincare products for ${userProfile!.skinType.toLowerCase()} skin?'
                      : 'Ready to check your skincare products for safety?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.8),
                  ),
                ),
                if (userProfile?.skinConcerns.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Focus areas: ${userProfile!.skinConcerns.take(2).join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.spa_rounded,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Skin Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (userProfile == null)
              TextButton(
                onPressed: _navigateToProfile,
                child: Text(
                  'Set Profile',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: skinTypes.map((type) => _buildSkinTypeChip(type)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkinTypeChip(String type) {
    final isSelected = selectedSkinType == type;
    Color chipColor;

    switch (type) {
      case 'Normal':
        chipColor = SkinTypeColors.normal;
        break;
      case 'Sensitive':
        chipColor = SkinTypeColors.sensitive;
        break;
      case 'Oily':
        chipColor = SkinTypeColors.oily;
        break;
      case 'Acne-prone':
        chipColor = SkinTypeColors.acneProne;
        break;
      default:
        chipColor = Theme.of(context).primaryColor;
    }

    return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
        onTap: () {
      setState(() => selectedSkinType = type);
      // Optionally update user profile automatically
      if (userProfile != null) {
        final updatedProfile = UserProfile(
          name: userProfile!.name,
          email: userProfile!.email,
          phone: userProfile!.phone,
          skinType: type,
          ageRange: userProfile!.ageRange,
          skinConcerns: userProfile!.skinConcerns,
          allergies: userProfile!.allergies,
        );
        UserService.instance.saveUserProfile(updatedProfile);
      }
    },
    child: Container(
      // Complete remaining part of home_screen.dart

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? chipColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: chipColor,
          width: 1.5,
        ),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: isSelected ? Colors.white : chipColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
        ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.camera_alt_rounded,
                title: 'Scan Product',
                subtitle: 'Check ingredients',
                color: Theme.of(context).primaryColor,
                onTap: () {
                  Navigator.pushNamed(context, '/scan');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.search_rounded,
                title: 'Search',
                subtitle: 'Find products',
                color: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  Navigator.pushNamed(context, '/search');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.favorite_rounded,
                title: 'Favorites',
                subtitle: 'Saved products',
                color: Colors.pink,
                onTap: () {
                  Navigator.pushNamed(context, '/favorites');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history_rounded,
                title: 'History',
                subtitle: 'View all scans',
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, '/history');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Scans',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (recentScans.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: Text(
                  'View All',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (recentScans.isEmpty)
          _buildEmptyState()
        else
          Column(
            children: recentScans
                .map((product) => _buildRecentScanCard(product))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No scans yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by scanning your first product to see safety analysis',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/scan');
            },
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Scan Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScanCard(ScannedProduct product) {
    final safetyColor = _getSafetyColor(product.overallRating);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: safetyColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: product.productImagePath != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(product.productImagePath!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.spa_rounded,
                  color: safetyColor,
                  size: 30,
                );
              },
            ),
          )
              : Icon(
            Icons.spa_rounded,
            color: safetyColor,
            size: 30,
          ),
        ),
        title: Text(
          product.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              product.brand,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: safetyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    product.overallRating.toUpperCase(),
                    style: TextStyle(
                      color: safetyColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  product.timeAgo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${product.safetyScore.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: safetyColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/10',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.5),
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to product details
          Navigator.pushNamed(
            context,
            '/product-details',
            arguments: product,
          );
        },
      ),
    );
  }

  Widget _buildTipsSection() {
    final tips = _getTipsForSkinType(selectedSkinType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips for ${selectedSkinType} Skin',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...tips.map((tip) => _buildTipCard(tip)),
      ],
    );
  }

  Widget _buildTipCard(String tip) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTipsForSkinType(String skinType) {
    switch (skinType) {
      case 'Sensitive':
        return [
          'Look for fragrance-free and hypoallergenic products',
          'Avoid products with high concentrations of acids or retinoids',
          'Always patch test new products before full application',
          'Choose products with minimal ingredient lists',
        ];
      case 'Oily':
        return [
          'Look for non-comedogenic and oil-free formulations',
          'Salicylic acid can help control excess oil production',
          'Avoid over-cleansing which can trigger more oil production',
          'Use lightweight, gel-based moisturizers',
        ];
      case 'Acne-prone':
        return [
          'Avoid comedogenic ingredients like coconut oil',
          'Look for products with salicylic acid or benzoyl peroxide',
          'Choose non-comedogenic makeup and skincare',
          'Be gentle - avoid harsh scrubbing or over-washing',
        ];
      default: // Normal
        return [
          'Maintain a consistent skincare routine',
          'Use sunscreen daily to prevent premature aging',
          'Incorporate antioxidants like vitamin C in your routine',
          'Listen to your skin and adjust products seasonally',
        ];
    }
  }
}

// Add these imports at the top of your file if not already present:
// import 'package:skin_food_scanner/screens/profile_screen.dart';
// import 'package:skin_food_scanner/models/product_model.dart';