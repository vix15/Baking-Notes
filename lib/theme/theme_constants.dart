import 'package:flutter/material.dart';
 
// Colores para el tema claro
const Color primaryColor = Color(0xFFFF5A8C);
const Color secondaryColor = Color(0xFFFFB6C1);
const Color tertiaryColor = Color(0xFFFFC0CB);
const Color backgroundColor = Color(0xFFFFF0F5);
const Color textColor = Color(0xFF4A2040);
 
// Colores para el tema oscuro
const Color darkPrimaryColor = Color(0xFFFF5A8C);
const Color darkSecondaryColor = Color(0xFFFF8AAD);
const Color darkTertiaryColor = Color(0xFFFF9DBD);
const Color darkBackgroundColor = Color(0xFF121212);
const Color darkCardColor = Color(0xFF1E1E1E);
const Color darkTextColor = Colors.white;
 
final ThemeData lightTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    tertiary: tertiaryColor,
    surface: backgroundColor,
    onPrimary: Colors.white,
    onSecondary: textColor,
    onSurface: textColor,
  ),
  fontFamily: 'Montserrat',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: textColor,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: textColor,
      fontWeight: FontWeight.w500,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: primaryColor.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: secondaryColor, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    labelStyle: const TextStyle(color: textColor),
    floatingLabelStyle: const TextStyle(color: primaryColor),
  ),
  cardTheme: CardTheme(
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: primaryColor,
    unselectedItemColor: textColor,
    type: BottomNavigationBarType.fixed,
    elevation: 16,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
  ),
);
 
final ThemeData darkTheme = ThemeData(
  primaryColor: darkPrimaryColor,
  scaffoldBackgroundColor: darkBackgroundColor,
  colorScheme: ColorScheme.dark(
    primary: darkPrimaryColor,
    secondary: darkSecondaryColor,
    tertiary: darkTertiaryColor,
    surface: darkCardColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: darkTextColor,
  ),
  fontFamily: 'Montserrat',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: darkTextColor,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: darkTextColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: darkTextColor,
      fontWeight: FontWeight.w500,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: darkPrimaryColor.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: darkCardColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: darkSecondaryColor, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    labelStyle: const TextStyle(color: Colors.white70),
    floatingLabelStyle: const TextStyle(color: darkPrimaryColor),
  ),
  cardTheme: CardTheme(
    color: darkCardColor,
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: darkPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: darkPrimaryColor,
    unselectedItemColor: Colors.white70,
    type: BottomNavigationBarType.fixed,
    elevation: 16,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
  ),
  dialogTheme: const DialogTheme(
    backgroundColor: darkCardColor,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    contentTextStyle: TextStyle(color: Colors.white70),
  ),
);