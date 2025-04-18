import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baking_notes/theme/theme_provider.dart';
 
class ThemeSwitchWidget extends StatelessWidget {
  const ThemeSwitchWidget({super.key});
 
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode 
              ? Colors.grey.shade800 
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 16,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 4),
            Text(
              themeProvider.isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}