// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // For Clipboard
// import 'package:share_plus/share_plus.dart';
// import 'package:skin_food_scanner/screens/ingredient_detail_screen.dart';
// import 'package:skin_food_scanner/theme.dart';
// import 'package:skin_food_scanner/models/product_model.dart';
//
// class AnalysisResultScreen extends StatefulWidget {
//   const AnalysisResultScreen({super.key}); // Added const constructor
//
//   @override
//   _AnalysisResultScreenState createState() => _AnalysisResultScreenState();
// }
//
// class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
//   String selectedSkinType = 'Normal';
//   final List<String> skinTypes = ['Normal', 'Sensitive', 'Oily', 'Acne-prone'];
//   final TextEditingController _questionController = TextEditingController(); // Marked final
//   bool _showSuggestions = false;
//
//   // Mock data - Moved into the state class to be accessed by methods
//   final ProductAnalysis mockProduct = ProductAnalysis(
//     name: 'CeraVe Moisturizing Cream',
//     brand: 'CeraVe',
//     imageUrl: 'assets/product_image.jpg', // Placeholder, ensure this path exists or use NetworkImage
//     overallRating: SafetyRating.safe,
//     ingredients: [
//       Ingredient(
//         name: 'Aqua (Water)',
//         safetyScore: 9.2,
//         rating: SafetyRating.safe,
//         tags: ['Hydrating', 'Non-comedogenic'],
//         description: 'Water is the base of most cosmetic formulations and is completely safe.',
//       ),
//       Ingredient(
//         name: 'Glycerin',
//         safetyScore: 8.8,
//         rating: SafetyRating.safe,
//         tags: ['Humectant', 'Natural'],
//         description: 'A natural humectant that helps retain moisture in the skin.',
//       ),
//       Ingredient(
//         name: 'Cetearyl Alcohol',
//         safetyScore: 8.5,
//         rating: SafetyRating.safe,
//         tags: ['Emollient', 'Non-comedogenic'],
//         description: 'A fatty alcohol that acts as an emollient and emulsifier.',
//       ),
//       Ingredient(
//         name: 'Dimethicone',
//         safetyScore: 7.2,
//         rating: SafetyRating.safe,
//         tags: ['Silicone', 'Occlusive'],
//         description: 'A silicone that creates a protective barrier on the skin.',
//       ),
//       Ingredient(
//         name: 'Phenoxyethanol',
//         safetyScore: 6.5,
//         rating: SafetyRating.caution,
//         tags: ['Preservative', 'Allergen'],
//         description: 'A preservative that may cause irritation in sensitive individuals.',
//       ),
//       Ingredient(
//         name: 'Fragrance',
//         safetyScore: 4.2,
//         rating: SafetyRating.caution,
//         tags: ['Fragrance', 'Allergen', 'Risky'],
//         description: 'May cause allergic reactions and irritation, especially for sensitive skin.',
//       ),
//       Ingredient(
//         name: 'Salicylic Acid',
//         safetyScore: 5.5,
//         rating: SafetyRating.caution,
//         tags: ['Exfoliant', 'Acne Treatment'],
//         description: 'A BHA effective for acne, but can be irritating if overused or for sensitive skin.',
//       ),
//       Ingredient(
//         name: 'Parabens',
//         safetyScore: 2.0,
//         rating: SafetyRating.harmful,
//         tags: ['Preservative', 'Controversial'],
//         description: 'Common preservatives that have raised concerns about potential endocrine disruption.',
//       ),
//     ],
//   );
//
//   @override
//   void dispose() {
//     _questionController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Analysis Results'), // Added const
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share_rounded), // Added const
//             onPressed: _shareResults,
//           ),
//           IconButton(
//             icon: const Icon(Icons.bookmark_outline_rounded), // Added const
//             onPressed: _saveToHistory,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20), // Added const
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Product Summary Card
//             _buildProductSummaryCard(),
//             const SizedBox(height: 24), // Added const
//
//             // Skin Type Selector
//             _buildSkinTypeSelector(),
//             const SizedBox(height: 24), // Added const
//
//             // Ingredients List
//             _buildIngredientsSection(),
//             const SizedBox(height: 24), // Added const
//
//             // Ask Question Section
//             _buildAskQuestionSection(),
//             const SizedBox(height: 24), // Added const
//
//             // AI Suggestions
//             if (_showSuggestions) _buildSuggestionsSection(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   //region Helper Methods for Colors and Icons
//   Color _getRatingColor(SafetyRating rating) {
//     switch (rating) {
//       case SafetyRating.safe:
//         return SafetyColors.safe;
//       case SafetyRating.caution:
//         return SafetyColors.caution;
//       case SafetyRating.harmful:
//         return SafetyColors.harmful; // Fixed: was SafetyColors.safe
//       default:
//         return Colors.grey;
//     }
//   }
//
//   IconData _getRatingIcon(SafetyRating rating) {
//     switch (rating) {
//       case SafetyRating.safe:
//         return Icons.check_circle_rounded;
//       case SafetyRating.caution:
//         return Icons.warning_rounded;
//       case SafetyRating.harmful:
//         return Icons.dangerous_rounded;
//       default:
//         return Icons.info_outline_rounded;
//     }
//   }
//
//   String _getRatingText(SafetyRating rating) {
//     switch (rating) {
//       case SafetyRating.safe:
//         return 'Safe';
//       case SafetyRating.caution:
//         return 'Caution';
//       case SafetyRating.harmful:
//         return 'harmful ';
//       default:
//         return 'Unknown';
//     }
//   }
//   //endregion
//
//   Widget _buildProductSummaryCard() {
//     return Container(
//       padding: const EdgeInsets.all(20), // Added const
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4), // Added const
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               // Product Image
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   image: mockProduct.imageUrl.isNotEmpty
//                       ? DecorationImage(
//                     image: AssetImage(mockProduct.imageUrl), // Use AssetImage for local image
//                     fit: BoxFit.cover,
//                   )
//                       : null,
//                 ),
//                 child: mockProduct.imageUrl.isEmpty // Fallback icon if no image
//                     ? Icon(
//                   Icons.spa_rounded,
//                   color: Theme.of(context).primaryColor,
//                   size: 40,
//                 )
//                     : null,
//               ),
//               const SizedBox(width: 16), // Added const
//
//               // Product Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       mockProduct.name,
//                       style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 4), // Added const
//                     Text(
//                       mockProduct.brand,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: Theme.of(context)
//                             .textTheme
//                             .bodyMedium
//                             ?.color
//                             ?.withOpacity(0.7),
//                       ),
//                     ),
//                     const SizedBox(height: 12), // Added const
//
//                     // Safety Rating
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 6), // Added const
//                       decoration: BoxDecoration(
//                         color: _getRatingColor(mockProduct.overallRating)
//                             .withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             _getRatingIcon(mockProduct.overallRating),
//                             color: _getRatingColor(mockProduct.overallRating),
//                             size: 16,
//                           ),
//                           const SizedBox(width: 6), // Added const
//                           Text(
//                             _getRatingText(mockProduct.overallRating),
//                             style: TextStyle(
//                               color: _getRatingColor(mockProduct.overallRating),
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 16), // Added const
//
//           // Quick Stats
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround, // Added for better spacing
//             children: [
//               _buildQuickStat('Total Ingredients', '${mockProduct.ingredients.length}'),
//               _buildQuickStat('Safe Ingredients',
//                   '${mockProduct.ingredients.where((i) => i.rating == SafetyRating.safe).length}'),
//               _buildQuickStat('Caution Items',
//                   '${mockProduct.ingredients.where((i) => i.rating == SafetyRating.caution).length}'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickStat(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           value,
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.w700,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//         Text(
//           label,
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: Theme.of(context)
//                 .textTheme
//                 .bodySmall
//                 ?.color
//                 ?.withOpacity(0.7),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSkinTypeSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'View for your skin type',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         const SizedBox(height: 12), // Added const
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: skinTypes.map((type) => _buildSkinTypeChip(type)).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSkinTypeChip(String type) {
//     final isSelected = selectedSkinType == type;
//     Color chipColor;
//
//     switch (type) {
//       case 'Normal':
//         chipColor = SkinTypeColors.normal;
//         break;
//       case 'Sensitive':
//         chipColor = SkinTypeColors.sensitive;
//         break;
//       case 'Oily':
//         chipColor = SkinTypeColors.oily;
//         break;
//       case 'Acne-prone':
//         chipColor = SkinTypeColors.acneProne;
//         break;
//       default:
//         chipColor = Theme.of(context).primaryColor;
//     }
//
//     return Padding(
//       padding: const EdgeInsets.only(right: 12), // Added const
//       child: GestureDetector(
//         onTap: () => setState(() => selectedSkinType = type),
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//               horizontal: 16, vertical: 8), // Added const
//           decoration: BoxDecoration(
//             color: isSelected ? chipColor : chipColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: chipColor,
//               width: isSelected ? 0 : 1,
//             ),
//           ),
//           child: Text(
//             type,
//             style: TextStyle(
//               color: isSelected ? Colors.white : chipColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildIngredientsSection() {
//     // Filter ingredients based on selected skin type (example logic)
//     // This is a simplified example. A real app might have a more complex logic
//     // for how ingredients are 'safe' or 'caution' for different skin types.
//     final filteredIngredients = mockProduct.ingredients.where((ingredient) {
//       if (selectedSkinType == 'Sensitive' &&
//           ingredient.tags.contains('Allergen')) {
//         return false; // Hide allergens for sensitive skin
//       }
//       if (selectedSkinType == 'Acne-prone' &&
//           ingredient.tags.contains('Comedogenic')) {
//         return false; // Hide comedogenic for acne-prone skin (assuming a tag 'Comedogenic')
//       }
//       return true;
//     }).toList();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Ingredients Analysis',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         const SizedBox(height: 12), // Added const
//
//         // Filter summary
//         Container(
//           padding: const EdgeInsets.all(12), // Added const
//           decoration: BoxDecoration(
//             color: Theme.of(context).primaryColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.info_outline_rounded,
//                 color: Theme.of(context).primaryColor,
//                 size: 20,
//               ),
//               const SizedBox(width: 8), // Added const
//               Expanded(
//                 child: Text(
//                   'Showing analysis for $selectedSkinType skin',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Theme.of(context).primaryColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16), // Added const
//
//         // Ingredients List
//         ListView.builder(
//           shrinkWrap: true, // Important for nested list views
//           physics: const NeverScrollableScrollPhysics(), // Disable scrolling of inner list
//           itemCount: filteredIngredients.length,
//           itemBuilder: (context, index) {
//             final ingredient = filteredIngredients[index];
//             return _buildIngredientListItem(ingredient);
//           },
//         ),
//         if (filteredIngredients.isEmpty)
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 20.0),
//             child: Center(
//               child: Text(
//                 'No ingredients shown for "$selectedSkinType" skin type based on filters.',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Theme.of(context)
//                       .textTheme
//                       .bodyMedium
//                       ?.color
//                       ?.withOpacity(0.7),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildIngredientListItem(Ingredient ingredient) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => IngredientDetailScreen(ingredient: ingredient),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12), // Added const
//         padding: const EdgeInsets.all(16), // Added const
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: Theme.of(context).dividerColor.withOpacity(0.1),
//           ),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     ingredient.name,
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 4), // Added const
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 4,
//                     children: ingredient.tags
//                         .map((tag) => Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4), // Added const
//                       decoration: BoxDecoration(
//                         color: Theme.of(context)
//                             .colorScheme
//                             .tertiary
//                             .withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         tag,
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Theme.of(context).colorScheme.tertiary,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ))
//                         .toList(),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Added const
//               decoration: BoxDecoration(
//                 color: _getRatingColor(ingredient.rating).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 _getRatingText(ingredient.rating),
//                 style: TextStyle(
//                   color: _getRatingColor(ingredient.rating),
//                   fontWeight: FontWeight.w600,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//             const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey), // Added const
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAskQuestionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Ask AI Anything',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         const SizedBox(height: 12), // Added const
//         TextField(
//           controller: _questionController,
//           maxLines: 3,
//           decoration: InputDecoration(
//             hintText: 'e.g., "Is Glycerin good for oily skin?"',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: Theme.of(context).dividerColor.withOpacity(0.5),
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: Theme.of(context).dividerColor.withOpacity(0.5),
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: Theme.of(context).primaryColor,
//                 width: 2,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12), // Added const
//         Align(
//           alignment: Alignment.centerRight,
//           child: ElevatedButton.icon(
//             onPressed: () {
//               // TODO: Implement AI question logic here
//               _simulateAISuggestion();
//             },
//             icon: const Icon(Icons.send_rounded), // Added const
//             label: const Text('Ask AI'), // Added const
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Added const
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSuggestionsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'AI Suggestions',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         const SizedBox(height: 12), // Added const
//         Container(
//           padding: const EdgeInsets.all(16), // Added const
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.auto_awesome_rounded,
//                     color: Theme.of(context).colorScheme.secondary,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8), // Added const
//                   Text(
//                     'AI Response',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: Theme.of(context).colorScheme.secondary,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12), // Added const
//               Text(
//                 'Glycerin is generally excellent for all skin types, including oily skin. It is a humectant, meaning it draws moisture from the air into the skin, helping to keep it hydrated without adding oil. For oily skin, maintaining hydration is crucial as it can prevent the skin from overproducing sebum to compensate for dryness.',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Theme.of(context)
//                       .textTheme
//                       .bodyMedium
//                       ?.color
//                       ?.withOpacity(0.9),
//                   height: 1.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // region Action Methods
//   void _shareResults() {
//     // Example: Share product details as text
//     final String shareText =
//         'Check out ${mockProduct.name} by ${mockProduct.brand}!\n'
//         'Overall Safety: ${_getRatingText(mockProduct.overallRating)}\n'
//         'Ingredients analyzed: ${mockProduct.ingredients.length}\n'
//         '#SkincareSafety #ProductAnalysis';
//
//     Share.share(shareText); // Requires 'share_plus' package
//     _showSnackBar('Results shared!');
//   }
//
//   void _saveToHistory() {
//     // Implement saving to a local database or user preferences
//     _showSnackBar('Product saved to history!');
//     // Example: You might want to save mockProduct data to persistent storage
//   }
//
//   void _simulateAISuggestion() {
//     setState(() {
//       _showSuggestions = true;
//     });
//     // In a real app, you would send _questionController.text to an AI model
//     // and update _showSuggestions and the content based on the response.
//   }
//
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2), // Added const
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skin_food_scanner/screens/ingredient_detail_screen.dart';
import 'package:skin_food_scanner/theme.dart';
import 'package:skin_food_scanner/models/product_model.dart';

class AnalysisResultScreen extends StatefulWidget {
  final ProductAnalysis analysis;
  final String? imagePath;

  const AnalysisResultScreen({
    super.key,
    required this.analysis,
    this.imagePath,
  });

  @override
  _AnalysisResultScreenState createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  String selectedSkinType = 'Normal';
  final List<String> skinTypes = ['Normal', 'Sensitive', 'Oily', 'Acne-prone'];
  final TextEditingController _questionController = TextEditingController();
  bool _showSuggestions = false;
  String _aiResponse = '';
  bool _isLoadingAI = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareResults,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            onPressed: _saveToHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Summary Card
            _buildProductSummaryCard(),
            const SizedBox(height: 24),

            // Overall Analysis Summary
            _buildAnalysisSummary(),
            const SizedBox(height: 24),

            // Skin Type Selector
            _buildSkinTypeSelector(),
            const SizedBox(height: 24),

            // Ingredients List
            _buildIngredientsSection(),
            const SizedBox(height: 24),

            // Ask Question Section
            _buildAskQuestionSection(),
            const SizedBox(height: 24),

            // AI Suggestions
            if (_showSuggestions) _buildSuggestionsSection(),
          ],
        ),
      ),
    );
  }

  //region Helper Methods for Colors and Icons
  Color _getRatingColor(SafetyRating rating) {
    switch (rating) {
      case SafetyRating.safe:
        return SafetyColors.safe;
      case SafetyRating.caution:
        return SafetyColors.caution;
      case SafetyRating.harmful:
        return SafetyColors.harmful;
      case SafetyRating.unknown:
      default:
        return Colors.grey;
    }
  }

  IconData _getRatingIcon(SafetyRating rating) {
    switch (rating) {
      case SafetyRating.safe:
        return Icons.check_circle_rounded;
      case SafetyRating.caution:
        return Icons.warning_rounded;
      case SafetyRating.harmful:
        return Icons.dangerous_rounded;
      case SafetyRating.unknown:
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getRatingText(SafetyRating rating) {
    switch (rating) {
      case SafetyRating.safe:
        return 'Safe';
      case SafetyRating.caution:
        return 'Caution';
      case SafetyRating.harmful:
        return 'Harmful';
      case SafetyRating.unknown:
      default:
        return 'Unknown';
    }
  }
  //endregion

  Widget _buildProductSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: widget.imagePath != null && widget.imagePath!.isNotEmpty
                      ? DecorationImage(
                    image: FileImage(File(widget.imagePath!)),
                    fit: BoxFit.cover,
                  )
                      : widget.analysis.imageUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(widget.analysis.imageUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: (widget.imagePath == null || widget.imagePath!.isEmpty) &&
                    widget.analysis.imageUrl.isEmpty
                    ? Icon(
                  Icons.spa_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 40,
                )
                    : null,
              ),
              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.analysis.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.analysis.brand,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Safety Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRatingColor(widget.analysis.overallRating)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRatingIcon(widget.analysis.overallRating),
                            color: _getRatingColor(widget.analysis.overallRating),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getRatingText(widget.analysis.overallRating),
                            style: TextStyle(
                              color: _getRatingColor(widget.analysis.overallRating),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat('Total Ingredients', '${widget.analysis.ingredients.length}'),
              _buildQuickStat(
                  'Safe Ingredients',
                  '${widget.analysis.ingredients.where((i) => i.rating == SafetyRating.safe).length}'),
              _buildQuickStat(
                  'Caution Items',
                  '${widget.analysis.ingredients.where((i) => i.rating == SafetyRating.caution).length}'),
              _buildQuickStat(
                  'Harmful Items',
                  '${widget.analysis.ingredients.where((i) => i.rating == SafetyRating.harmful).length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSummary() {
    // Get counts for different safety ratings
    final safeCount = widget.analysis.ingredients.where((i) => i.rating == SafetyRating.safe).length;
    final cautionCount = widget.analysis.ingredients.where((i) => i.rating == SafetyRating.caution).length;
    final harmfulCount = widget.analysis.ingredients.where((i) => i.rating == SafetyRating.harmful).length;

    String summaryText;
    Color summaryColor;
    IconData summaryIcon;

    if (harmfulCount > 0) {
      summaryText = "This product contains $harmfulCount harmful ingredient(s). Consider alternatives if you have sensitive skin.";
      summaryColor = SafetyColors.harmful;
      summaryIcon = Icons.warning_rounded;
    } else if (cautionCount > 0) {
      summaryText = "This product has $cautionCount ingredient(s) that may cause reactions in some people. Patch test recommended.";
      summaryColor = SafetyColors.caution;
      summaryIcon = Icons.info_rounded;
    } else {
      summaryText = "This product appears to be generally safe with $safeCount well-tolerated ingredients.";
      summaryColor = SafetyColors.safe;
      summaryIcon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: summaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: summaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            summaryIcon,
            color: summaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              summaryText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: summaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSkinTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'View for your skin type',
          style: Theme.of(context).textTheme.titleLarge,
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
        onTap: () => setState(() => selectedSkinType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : chipColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: chipColor,
              width: isSelected ? 0 : 1,
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

  Widget _buildIngredientsSection() {
    // Filter ingredients based on selected skin type
    final filteredIngredients = _getFilteredIngredients();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients Analysis',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),

        // Filter summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Showing ${filteredIngredients.length} ingredients analyzed for $selectedSkinType skin',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Ingredients List
        if (filteredIngredients.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredIngredients.length,
            itemBuilder: (context, index) {
              final ingredient = filteredIngredients[index];
              return _buildIngredientListItem(ingredient);
            },
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 48,
                    color: Theme.of(context).dividerColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ingredients to show for "$selectedSkinType" skin type',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Ingredient> _getFilteredIngredients() {
    // Enhanced filtering logic based on skin type
    return widget.analysis.ingredients.where((ingredient) {
      switch (selectedSkinType) {
        case 'Sensitive':
        // Hide known allergens and harsh ingredients for sensitive skin
          return !ingredient.tags.any((tag) =>
          tag.toLowerCase().contains('allergen') ||
              tag.toLowerCase().contains('fragrance') ||
              tag.toLowerCase().contains('harsh'));

        case 'Acne-prone':
        // Hide comedogenic ingredients for acne-prone skin
          return !ingredient.tags.any((tag) =>
          tag.toLowerCase().contains('comedogenic') ||
              tag.toLowerCase().contains('pore-clogging'));

        case 'Oily':
        // Show all ingredients but highlight oil-control ones
          return true;

        case 'Normal':
        default:
        // Show all ingredients for normal skin
          return true;
      }
    }).toList();
  }

  Widget _buildIngredientListItem(Ingredient ingredient) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IngredientDetailScreen(ingredient: ingredient),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Safety Score: ${ingredient.safetyScore.toStringAsFixed(1)}/10',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getRatingColor(ingredient.rating).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getRatingText(ingredient.rating),
                              style: TextStyle(
                                color: _getRatingColor(ingredient.rating),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
            if (ingredient.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ingredient.tags
                    .map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 10,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ],
            if (ingredient.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                ingredient.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAskQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ask AI Anything',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _questionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g., "Is this product safe for daily use?" or "What ingredients should I avoid?"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _isLoadingAI ? null : _askAI,
            icon: _isLoadingAI
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.send_rounded),
            label: Text(_isLoadingAI ? 'Asking...' : 'Ask AI'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Response',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Analysis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _aiResponse.isNotEmpty ? _aiResponse : 'Ask a question to get AI insights about this product and its ingredients.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // region Action Methods
  void _shareResults() {
    final safeCount = widget.analysis.ingredients.where((i) => i.rating == SafetyRating.safe).length;
    final cautionCount = widget.analysis.ingredients.where((i) => i.rating == SafetyRating.caution).length;
    final harmfulCount = widget.analysis.ingredients.where((i) => i.rating == SafetyRating.harmful).length;

    final String shareText = '''
🧴 Product Analysis: ${widget.analysis.name}
🏷️ Brand: ${widget.analysis.brand}
📊 Overall Safety: ${_getRatingText(widget.analysis.overallRating)}

📈 Ingredient Breakdown:
✅ Safe: $safeCount ingredients
⚠️ Caution: $cautionCount ingredients
❌ Harmful: $harmfulCount ingredients

Total ingredients analyzed: ${widget.analysis.ingredients.length}

#SkincareSafety #ProductAnalysis #IngredientCheck
    ''';

    Share.share(shareText);
    _showSnackBar('Results shared!');
  }

  void _saveToHistory() {
    // TODO: Implement saving to local database/preferences
    // You might want to use SharedPreferences, Hive, or SQLite here
    _showSnackBar('Product saved to history!');
  }

  Future<void> _askAI() async {
    if (_questionController.text.trim().isEmpty) {
      _showSnackBar('Please enter a question first');
      return;
    }

    setState(() {
      _isLoadingAI = true;
      _showSuggestions = true;
    });

    try {
      // TODO: In a real implementation, you would call your AI service here
      // For now, we'll simulate with a delay and provide a contextual response
      await Future.delayed(const Duration(seconds: 2));

      // Generate a contextual response based on the analysis
      _aiResponse = _generateContextualResponse(_questionController.text);

    } catch (e) {
      _aiResponse = 'Sorry, I encountered an error while processing your question. Please try again.';
      _showSnackBar('Error getting AI response');
    } finally {
      setState(() {
        _isLoadingAI = false;
      });
    }
  }

  String _generateContextualResponse(String question) {
    // Simple contextual response generation based on the actual analysis
    final harmfulIngredients = widget.analysis.ingredients.where((i) => i.rating == SafetyRating.harmful).toList();
    final cautionIngredients = widget.analysis.ingredients.where((i) => i.rating == SafetyRating.caution).toList();

    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('safe') || lowerQuestion.contains('safety')) {
      if (harmfulIngredients.isNotEmpty) {
        return 'Based on the analysis, this product contains ${harmfulIngredients.length} potentially harmful ingredient(s): ${harmfulIngredients.map((i) => i.name).join(', ')}. I recommend being cautious, especially if you have sensitive skin.';
      } else if (cautionIngredients.isNotEmpty) {
        return 'This product is generally safe but contains ${cautionIngredients.length} ingredient(s) that may cause reactions in some people: ${cautionIngredients.map((i) => i.name).join(', ')}. Consider doing a patch test first.';
      } else {
        return 'Based on the analysis, this product appears to be safe for most skin types with well-tolerated ingredients.';
      }
    } else if (lowerQuestion.contains('daily use') || lowerQuestion.contains('every day')) {
      return 'For daily use, ${harmfulIngredients.isEmpty ? 'this product should be fine' : 'be cautious due to potentially irritating ingredients'}. Start with every other day to see how your skin reacts.';
    } else if (lowerQuestion.contains('sensitive skin')) {
      final problematicIngredients = widget.analysis.ingredients.where((i) =>
          i.tags.any((tag) => tag.toLowerCase().contains('allergen') || tag.toLowerCase().contains('fragrance'))
      ).toList();

      if (problematicIngredients.isNotEmpty) {
        return 'For sensitive skin, I recommend caution with this product as it contains: ${problematicIngredients.map((i) => i.name).join(', ')}. These ingredients may cause irritation.';
      } else {
        return 'This product appears to be relatively gentle and may be suitable for sensitive skin, but always patch test first.';
      }
    } else {
      return 'Based on the ingredient analysis of ${widget.analysis.name}, the product has an overall safety rating of "${_getRatingText(widget.analysis.overallRating)}". The analysis shows ${widget.analysis.ingredients.length} ingredients with varying safety profiles. Would you like to know more about any specific ingredient?';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
//endregion
}