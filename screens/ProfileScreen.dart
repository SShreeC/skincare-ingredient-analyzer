// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:skin_food_scanner/theme.dart';
import 'package:skin_food_scanner/services/user_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String selectedSkinType = 'Normal';
  String selectedAge = '25-34';
  List<String> selectedConcerns = [];
  List<String> selectedAllergies = [];
  bool isLoading = true;

  final List<String> skinTypes = ['Normal', 'Oily', 'Dry', 'Combination', 'Sensitive'];
  final List<String> ageRanges = ['18-24', '25-34', '35-44', '45-54', '55+'];
  final List<String> skinConcerns = [
    'Acne',
    'Aging',
    'Dark Spots',
    'Sensitivity',
    'Dryness',
    'Oiliness',
    'Wrinkles',
    'Rosacea'
  ];
  final List<String> commonAllergies = [
    'Fragrance',
    'Parabens',
    'Sulfates',
    'Alcohol',
    'Essential Oils',
    'Silicones',
    'Dyes',
    'Formaldehyde'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserService.instance.getUserProfile();

    if (profile != null) {
      setState(() {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
        _phoneController.text = profile.phone;
        selectedSkinType = profile.skinType;
        selectedAge = profile.ageRange;
        selectedConcerns = List.from(profile.skinConcerns);
        selectedAllergies = List.from(profile.allergies);
        isLoading = false;
      });
    } else {
      // Set default values for new users
      setState(() {
        _nameController.text = 'Sarah Johnson';
        _emailController.text = 'sarah.johnson@email.com';
        _phoneController.text = '+1 (555) 123-4567';
        selectedConcerns = ['Acne', 'Sensitivity'];
        selectedAllergies = ['Fragrance', 'Parabens'];
        isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final profile = UserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      skinType: selectedSkinType,
      ageRange: selectedAge,
      skinConcerns: selectedConcerns,
      allergies: selectedAllergies,
    );

    try {
      await UserService.instance.saveUserProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile saved successfully!'),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to previous screen
        Navigator.of(context).pop(true); // Return true to indicate profile was saved
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text.isNotEmpty ? _nameController.text : 'Your Name',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _emailController.text.isNotEmpty ? _emailController.text : 'your.email@example.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Basic Information
            _buildSectionTitle(context, 'Basic Information'),
            const SizedBox(height: 12),
            _buildTextField(context, 'Full Name', _nameController, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildTextField(context, 'Email', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(context, 'Phone Number', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 24),

            // Skin Profile
            _buildSectionTitle(context, 'Skin Profile'),
            const SizedBox(height: 12),
            _buildDropdownField(
              context,
              'Skin Type',
              selectedSkinType,
              skinTypes,
                  (newValue) {
                setState(() {
                  selectedSkinType = newValue!;
                });
              },
              Icons.palette_outlined,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              context,
              'Age Range',
              selectedAge,
              ageRanges,
                  (newValue) {
                setState(() {
                  selectedAge = newValue!;
                });
              },
              Icons.cake_outlined,
            ),
            const SizedBox(height: 24),

            // Skin Concerns
            _buildSectionTitle(context, 'Skin Concerns'),
            const SizedBox(height: 12),
            _buildMultiSelectChips(
              context,
              skinConcerns,
              selectedConcerns,
                  (tag) {
                setState(() {
                  if (selectedConcerns.contains(tag)) {
                    selectedConcerns.remove(tag);
                  } else {
                    selectedConcerns.add(tag);
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Allergies
            _buildSectionTitle(context, 'Known Allergies'),
            const SizedBox(height: 12),
            _buildMultiSelectChips(
              context,
              commonAllergies,
              selectedAllergies,
                  (tag) {
                setState(() {
                  if (selectedAllergies.contains(tag)) {
                    selectedAllergies.remove(tag);
                  } else {
                    selectedAllergies.add(tag);
                  }
                });
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String currentValue, List<String> items, ValueChanged<String?> onChanged, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).primaryColor),
          style: Theme.of(context).textTheme.bodyLarge,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          hint: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)),
              const SizedBox(width: 12),
              Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor)),
            ],
          ),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((String item) {
              return Row(
                children: [
                  Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                  const SizedBox(width: 12),
                  Text(item, style: Theme.of(context).textTheme.bodyLarge),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildMultiSelectChips(BuildContext context, List<String> allTags, List<String> selectedTags, Function(String) onToggle) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: allTags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        Color chipColor = Theme.of(context).primaryColor;
        if (tag == 'Sensitive' || tag == 'Acne') {
          chipColor = SkinTypeColors.sensitive;
        }

        return GestureDetector(
          onTap: () => onToggle(tag),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? chipColor : chipColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? chipColor : chipColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}