import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.teal,
      scaffoldBackgroundColor: Color.fromRGBO(62, 74, 54, 1.0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromRGBO(62, 74, 54, 1.0),
        foregroundColor: Colors.white,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color.fromRGBO(62, 74, 54, 1.0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromRGBO(98,111,71, 0.8),
      ),
      iconTheme: const IconThemeData(
        color: Colors.tealAccent,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white60, fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color.fromRGBO(62, 74, 54, 1.0),
        foregroundColor: Colors.white,
      ),
    );
  }
}
