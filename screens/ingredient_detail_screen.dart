import 'package:flutter/material.dart';
import 'package:skin_food_scanner/theme.dart'; // Make sure this path is correct
import 'package:skin_food_scanner/models/product_model.dart'; // Import the shared models

class IngredientDetailScreen extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientDetailScreen({super.key, required this.ingredient});

  // Helper functions for colors and icons
  // These are now more appropriate here as they use SafetyColors from theme.dart
  Color _getRatingColor(SafetyRating rating) {
    switch (rating) {
      case SafetyRating.safe:
        return SafetyColors.safe;
      case SafetyRating.caution:
        return SafetyColors.caution;
      case SafetyRating.harmful:
        return SafetyColors.harmful;
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
        return 'Unsafe';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    Color ratingColor = _getRatingColor(ingredient.rating);
    IconData ratingIcon = _getRatingIcon(ingredient.rating);
    String ratingText = _getRatingText(ingredient.rating);

    return Scaffold(
      appBar: AppBar(
        title: Text(ingredient.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating and Score
            Row(
              children: [
                Icon(ratingIcon, color: ratingColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  ratingText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ratingColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Safety Score: ${ingredient.safetyScore.toStringAsFixed(1)}/10',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.color
                        ?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              ingredient.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Tags
            if (ingredient.tags.isNotEmpty) ...[
              Text(
                'Key Properties',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, // Horizontal spacing
                runSpacing: 8, // Vertical spacing
                children: ingredient.tags
                    .map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                  labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.w500),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // More rounded chips
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),

            // More Info/Recommendations (Optional, add more content here)
            Text(
              'Considerations:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Always patch test new products. Consult a dermatologist for personalized advice regarding this ingredient and your specific skin concerns.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}