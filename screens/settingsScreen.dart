import 'package:flutter/material.dart';
import 'package:skin_food_scanner/main.dart'; // Access global themeNotifier

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose Theme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, _) {
                return Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text("System Default"),
                      value: ThemeMode.system,
                      groupValue: currentMode,
                      onChanged: (mode) => themeNotifier.value = mode!,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text("Light"),
                      value: ThemeMode.light,
                      groupValue: currentMode,
                      onChanged: (mode) => themeNotifier.value = mode!,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text("Dark"),
                      value: ThemeMode.dark,
                      groupValue: currentMode,
                      onChanged: (mode) => themeNotifier.value = mode!,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
