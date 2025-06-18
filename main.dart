import 'package:flutter/material.dart';
import 'package:skin_food_scanner/screens/ProfileScreen.dart';
import 'package:skin_food_scanner/screens/helpScreen.dart';
import 'package:skin_food_scanner/screens/home_screen.dart';
import 'package:skin_food_scanner/screens/scanner_screen.dart';
import 'package:skin_food_scanner/screens/settingsScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main()  {
  WidgetsFlutterBinding.ensureInitialized();dotenv.load(fileName: ".env");
  runApp(const SkincareApp());
}
 ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
class SkincareApp extends StatefulWidget {
  const SkincareApp({super.key});

  @override
  State<SkincareApp> createState() => _SkincareAppState();
}

class _SkincareAppState extends State<SkincareApp> {


  @override
  void dispose() {
    themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          title: 'Skincare Safety Checker',
          themeMode: currentTheme,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          home: MainNavigationScreen(themeNotifier: themeNotifier),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const MainNavigationScreen({super.key, required this.themeNotifier});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
       HomeScreen(),
       ScannerScreen(),
      const HelpScreen(),
      const ProfileScreen(),
      SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.camera_alt, 'Scanner'),
                _buildNavItem(2, Icons.help_outline, 'Help'),
                _buildNavItem(3, Icons.person, 'Profile'),
                _buildNavItem(4, Icons.settings, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : theme.iconTheme.color?.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.primaryColor
                    : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

