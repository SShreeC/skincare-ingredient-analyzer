import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFAQItem(
            context,
            question: 'How do I scan a product label?',
            answer:
            'Navigate to the "Scanner" tab. Position the product label, focusing on the ingredients list, within the frame. Tap the scan button. Ensure good lighting and a steady hand.',
          ),
          _buildFAQItem(
            context,
            question: 'What do the safety ratings mean?',
            answer:
            'Our safety ratings (Safe, Caution, Harmful) are based on a comprehensive analysis of ingredient data from trusted scientific sources and regulatory bodies. They indicate the general risk level of a product based on its ingredients.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I change my skin type?',
            answer:
            'On the "Analysis Results" screen, you can toggle between different skin types (Normal, Sensitive, Oily, Acne-prone) to see how ingredient safety changes for your specific needs.',
          ),
          _buildFAQItem(
            context,
            question: 'Can I save scanned products?',
            answer:
            'Yes, after a successful scan, you can tap the bookmark icon on the analysis results screen to save the product to your "History" tab for future reference.',
          ),
          _buildFAQItem(
            context,
            question: 'How accurate are the AI suggestions?',
            answer:
            'Our AI provides suggestions based on available data. While helpful, it should not replace professional advice. Always consult a dermatologist for personalized skincare recommendations.',
          ),
          const SizedBox(height: 20),
          Text(
            'Still have questions?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening contact support...')),
              );
              // TODO: Implement contact support feature (e.g., open email client)
            },
            icon: const Icon(Icons.email_rounded),
            label: const Text('Contact Support'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0, // Minimal shadow as per design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}