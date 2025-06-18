

enum SafetyRating { safe, caution, harmful, unknown }

class Ingredient {
  final String name;
  final double safetyScore;
  final SafetyRating rating;
  final List<String> tags;
  final String description;

  Ingredient({
    required this.name,
    required this.safetyScore,
    required this.rating,
    this.tags = const [],
    required this.description,
  });
}

class ProductAnalysis {
  final String name;
  final String brand;
  final String imageUrl;
  final SafetyRating overallRating;
  final List<Ingredient> ingredients;

  ProductAnalysis({
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.overallRating,
    required this.ingredients,
  });
}