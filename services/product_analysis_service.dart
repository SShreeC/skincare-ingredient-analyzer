// // services/product_analysis_service.dart
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:skin_food_scanner/models/product_model.dart';
// class ProductAnalysisService {
//   static const String _geminiApiKey = 'AIzaSyDkuqHNn-_UoTt4tAYp2x83KDHPhIafF8M';
//   static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent';
//
//   // Extract text from image using Google ML Kit OCR
//   static Future<String> extractTextFromImage(String imagePath) async {
//     try {
//       final inputImage = InputImage.fromFilePath(imagePath);
//       final textRecognizer = GoogleMlKit.vision.textRecognizer();
//
//       final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
//
//       // Close the recognizer to free up resources
//       textRecognizer.close();
//
//       // Combine all recognized text
//       String extractedText = '';
//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           extractedText += '${line.text}\n';
//         }
//       }
//
//       return extractedText.trim();
//     } catch (e) {
//       print('Error extracting text: $e');
//       throw Exception('Failed to extract text from image: $e');
//     }
//   }
//
//   // Analyze ingredients using Gemini AI
//   static Future<ProductAnalysis> analyzeProduct(String extractedText, {String? productName, String? brand}) async {
//     try {
//       final prompt = _buildAnalysisPrompt(extractedText, productName, brand);
//
//       final response = await http.post(
//         Uri.parse('$_geminiBaseUrl?key=$_geminiApiKey'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'contents': [
//             {
//               'parts': [
//                 {'text': prompt}
//               ]
//             }
//           ],
//           'generationConfig': {
//             'temperature': 0.3,
//             'topK': 40,
//             'topP': 0.95,
//             'maxOutputTokens': 2048,
//           }
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
//
//         return _parseAIResponse(aiResponse, extractedText);
//       } else {
//         throw Exception('Failed to get AI analysis. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error analyzing product: $e');
//       throw Exception('Failed to analyze product: $e');
//     }
//   }
//
//   // Build the analysis prompt for Gemini
//   static String _buildAnalysisPrompt(String extractedText, String? productName, String? brand) {
//     return '''
// As a cosmetic chemistry expert, analyze the following product text extracted from a skincare/cosmetic product label:
//
// EXTRACTED TEXT:
// $extractedText
//
// Please provide a JSON response with the following structure:
// {
//   "product_name": "detected or provided product name",
//   "brand": "detected or provided brand name",
//   "overall_rating": "safe|caution|harmful",
//   "summary": "brief 2-3 sentence summary of the product safety",
//   "ingredients": [
//     {
//       "name": "ingredient name",
//       "safety_score": 0.0-10.0,
//       "rating": "safe|caution|harmful",
//       "tags": ["tag1", "tag2"],
//       "description": "detailed description including effects and safety info",
//       "concerns": "specific concerns for sensitive/acne-prone skin if any"
//     }
//   ]
// }
//
// Analysis Guidelines:
// - Focus on identifying individual ingredients from the ingredients list
// - Rate ingredients based on scientific evidence and common reactions
// - Safe (8-10): Generally well-tolerated, minimal side effects
// - Caution (4-7): May cause issues for some people, concentration-dependent
// - Harmful (0-3): Known irritants, allergens, or controversial ingredients
// - Include relevant tags like: "Humectant", "Emollient", "Preservative", "Fragrance", "Allergen", "Natural", "Synthetic", "Comedogenic", "Photosensitizing"
// - Provide practical descriptions focusing on benefits and potential concerns
// - Consider different skin types (normal, sensitive, oily, acne-prone)
//
// ${productName != null ? 'PRODUCT NAME: $productName' : ''}
// ${brand != null ? 'BRAND: $brand' : ''}
//
// Return only valid JSON without markdown formatting.
// ''';
//   }
//
//   // Parse AI response and convert to ProductAnalysis object
//   static ProductAnalysis _parseAIResponse(String aiResponse, String originalText) {
//     try {
//       // Clean the response in case it has markdown formatting
//       String cleanResponse = aiResponse.trim();
//       if (cleanResponse.startsWith('```json')) {
//         cleanResponse = cleanResponse.substring(7);
//       }
//       if (cleanResponse.endsWith('```')) {
//         cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
//       }
//
//       final Map<String, dynamic> data = jsonDecode(cleanResponse);
//
//       // Parse ingredients
//       List<Ingredient> ingredients = [];
//       if (data['ingredients'] != null) {
//         for (var ingredientData in data['ingredients']) {
//           ingredients.add(Ingredient(
//             name: ingredientData['name'] ?? 'Unknown Ingredient',
//             safetyScore: (ingredientData['safety_score'] ?? 5.0).toDouble(),
//             rating: _parseRating(ingredientData['rating']),
//             tags: List<String>.from(ingredientData['tags'] ?? []),
//             description: ingredientData['description'] ?? 'No description available',
//           ));
//         }
//       }
//
//       return ProductAnalysis(
//         name: data['product_name'] ?? 'Unknown Product',
//         brand: data['brand'] ?? 'Unknown Brand',
//         imageUrl: '', // Will be set separately when saving the image
//         overallRating: _parseRating(data['overall_rating']),
//         ingredients: ingredients,
//       );
//
//     } catch (e) {
//       print('Error parsing AI response: $e');
//       // Return a fallback analysis
//       return _createFallbackAnalysis(originalText);
//     }
//   }
//
//   // Helper method to parse safety rating from string
//   static SafetyRating _parseRating(String? rating) {
//     switch (rating?.toLowerCase()) {
//       case 'safe':
//         return SafetyRating.safe;
//       case 'caution':
//         return SafetyRating.caution;
//       case 'harmful':
//         return SafetyRating.harmful;
//       default:
//         return SafetyRating.unknown;
//     }
//   }
//
//   // Create a fallback analysis if AI parsing fails
//   static ProductAnalysis _createFallbackAnalysis(String extractedText) {
//     return ProductAnalysis(
//       name: 'Scanned Product',
//       brand: 'Unknown Brand',
//       imageUrl: '',
//       overallRating: SafetyRating.unknown,
//       ingredients: [
//         Ingredient(
//           name: 'Analysis Failed',
//           safetyScore: 5.0,
//           rating: SafetyRating.unknown,
//           tags: ['Error'],
//           description: 'Unable to analyze ingredients. Please try scanning again with better lighting and focus on the ingredients list.',
//         ),
//       ],
//     );
//   }
//
//   // Complete analysis pipeline
//   static Future<ProductAnalysis> analyzeProductFromImage(
//       String imagePath, {
//         String? productName,
//         String? brand,
//       }) async {
//     try {
//       // Step 1: Extract text using OCR
//       final extractedText = await extractTextFromImage(imagePath);
//
//       if (extractedText.isEmpty) {
//         throw Exception('No text could be extracted from the image');
//       }
//
//       // Step 2: Analyze with AI
//       final analysis = await analyzeProduct(
//           extractedText,
//           productName: productName,
//           brand: brand
//       );
//
//       return analysis;
//
//     } catch (e) {
//       print('Complete analysis failed: $e');
//       rethrow;
//     }
//   }}
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:skin_food_scanner/models/product_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ProductAnalysisService {
  // static const String _geminiApiKey = 'AIzaSyDkuqHNn-_UoTt4tAYp2x83KDHPhIafF8M';
  // static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent';
  static final String? _geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  static final String _geminiBaseUrl = dotenv.env['GEMINI_BASE_URL'] ?? 'https://api.generativeai.google.com/v1';

  static Future<String> _imageToBase64(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      throw Exception('Failed to process image: $e');
    }
  }

  // Get image MIME type based on file extension
  static String _getImageMimeType(String imagePath) {
    final String extension = imagePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  // Analyze product directly from image using Gemini Vision
  static Future<ProductAnalysis> analyzeProductFromImage(
      String imagePath, {
        String? productName,
        String? brand,
      }) async {
    try {
      // Convert image to base64
      final String base64Image = await _imageToBase64(imagePath);
      final String mimeType = _getImageMimeType(imagePath);

      // Build the analysis prompt
      final String prompt = _buildVisionAnalysisPrompt(productName, brand);

      // Make API call to Gemini Vision
      final response = await http.post(
        Uri.parse('$_geminiBaseUrl?key=$_geminiApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': base64Image
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 3000,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        return _parseAIResponse(aiResponse);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Gemini API Error: ${response.statusCode} - ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error analyzing product from image: $e');
      throw Exception('Failed to analyze product: $e');
    }
  }

  // Build the vision analysis prompt for Gemini
  static String _buildVisionAnalysisPrompt(String? productName, String? brand) {
    return '''
As a cosmetic chemistry expert, analyze this skincare/cosmetic product image. Focus on reading and analyzing the ingredients list visible in the image.

Please provide a JSON response with the following structure:
{
  "product_name": "detected or provided product name",
  "brand": "detected or provided brand name", 
  "overall_rating": "safe|caution|harmful",
  "summary": "brief 2-3 sentence summary of the product safety",
  "ingredients": [
    {
      "name": "ingredient name",
      "safety_score": 0.0-10.0,
      "rating": "safe|caution|harmful",
      "tags": ["tag1", "tag2"],
      "description": "detailed description including effects and safety info",
      "concerns": "specific concerns for sensitive/acne-prone skin if any"
    }
  ]
}

Analysis Guidelines:
- Carefully read the ingredients list from the product label in the image
- Identify and analyze each individual ingredient
- Rate ingredients based on scientific evidence and common reactions
- Safe (8-10): Generally well-tolerated, minimal side effects
- Caution (4-7): May cause issues for some people, concentration-dependent
- Harmful (0-3): Known irritants, allergens, or controversial ingredients
- Include relevant tags like: "Humectant", "Emollient", "Preservative", "Fragrance", "Allergen", "Natural", "Synthetic", "Comedogenic", "Photosensitizing"
- Provide practical descriptions focusing on benefits and potential concerns
- Consider different skin types (normal, sensitive, oily, acne-prone)
- If you cannot clearly read the ingredients list, mention this in the summary

${productName != null ? 'EXPECTED PRODUCT NAME: $productName' : ''}
${brand != null ? 'EXPECTED BRAND: $brand' : ''}

Important: Focus on the ingredients list section of the product label. Return only valid JSON without markdown formatting.
''';
  }

  // Parse AI response and convert to ProductAnalysis object
  static ProductAnalysis _parseAIResponse(String aiResponse) {
    try {
      // Clean the response in case it has markdown formatting
      String cleanResponse = aiResponse.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }

      final Map<String, dynamic> data = jsonDecode(cleanResponse);

      // Parse ingredients
      List<Ingredient> ingredients = [];
      if (data['ingredients'] != null) {
        for (var ingredientData in data['ingredients']) {
          ingredients.add(Ingredient(
            name: ingredientData['name'] ?? 'Unknown Ingredient',
            safetyScore: (ingredientData['safety_score'] ?? 5.0).toDouble(),
            rating: _parseRating(ingredientData['rating']),
            tags: List<String>.from(ingredientData['tags'] ?? []),
            description: ingredientData['description'] ?? 'No description available',
          ));
        }
      }

      return ProductAnalysis(
        name: data['product_name'] ?? 'Unknown Product',
        brand: data['brand'] ?? 'Unknown Brand',
        imageUrl: '', // Will be set separately when saving the image
        overallRating: _parseRating(data['overall_rating']),
        ingredients: ingredients,
      );

    } catch (e) {
      print('Error parsing AI response: $e');
      // Return a fallback analysis
      return _createFallbackAnalysis();
    }
  }

  // Helper method to parse safety rating from string
  static SafetyRating _parseRating(String? rating) {
    switch (rating?.toLowerCase()) {
      case 'safe':
        return SafetyRating.safe;
      case 'caution':
        return SafetyRating.caution;
      case 'harmful':
        return SafetyRating.harmful;
      default:
        return SafetyRating.unknown;
    }
  }

  // Create a fallback analysis if AI parsing fails
  static ProductAnalysis _createFallbackAnalysis() {
    return ProductAnalysis(
      name: 'Scanned Product',
      brand: 'Unknown Brand',
      imageUrl: '',
      overallRating: SafetyRating.unknown,
      ingredients: [
        Ingredient(
          name: 'Analysis Failed',
          safetyScore: 5.0,
          rating: SafetyRating.unknown,
          tags: ['Error'],
          description: 'Unable to analyze ingredients from image. Please ensure the ingredients list is clearly visible and try again with better lighting.',
        ),
      ],
    );
  }

  // Alternative method for analyzing from extracted text (keeping for backward compatibility)
  static Future<ProductAnalysis> analyzeFromText(
      String extractedText, {
        String? productName,
        String? brand,
      }) async {
    try {
      final prompt = _buildTextAnalysisPrompt(extractedText, productName, brand);

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl?key=$_geminiApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        return _parseAIResponse(aiResponse);
      } else {
        throw Exception('Failed to get AI analysis. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error analyzing from text: $e');
      throw Exception('Failed to analyze product: $e');
    }
  }

  // Build text analysis prompt (for backward compatibility)
  static String _buildTextAnalysisPrompt(String extractedText, String? productName, String? brand) {
    return '''
As a cosmetic chemistry expert, analyze the following product text extracted from a skincare/cosmetic product label:

EXTRACTED TEXT:
$extractedText

Please provide a JSON response with the following structure:
{
  "product_name": "detected or provided product name",
  "brand": "detected or provided brand name", 
  "overall_rating": "safe|caution|harmful",
  "summary": "brief 2-3 sentence summary of the product safety",
  "ingredients": [
    {
      "name": "ingredient name",
      "safety_score": 0.0-10.0,
      "rating": "safe|caution|harmful",
      "tags": ["tag1", "tag2"],
      "description": "detailed description including effects and safety info",
      "concerns": "specific concerns for sensitive/acne-prone skin if any"
    }
  ]
}

Analysis Guidelines:
- Focus on identifying individual ingredients from the ingredients list
- Rate ingredients based on scientific evidence and common reactions
- Safe (8-10): Generally well-tolerated, minimal side effects
- Caution (4-7): May cause issues for some people, concentration-dependent
- Harmful (0-3): Known irritants, allergens, or controversial ingredients
- Include relevant tags like: "Humectant", "Emollient", "Preservative", "Fragrance", "Allergen", "Natural", "Synthetic", "Comedogenic", "Photosensitizing"
- Provide practical descriptions focusing on benefits and potential concerns
- Consider different skin types (normal, sensitive, oily, acne-prone)

${productName != null ? 'PRODUCT NAME: $productName' : ''}
${brand != null ? 'BRAND: $brand' : ''}

Return only valid JSON without markdown formatting.
''';
  }
}