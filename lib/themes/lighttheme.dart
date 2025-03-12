import 'package:flutter/material.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color.fromRGBO(72, 72, 44, 1.0),
      scaffoldBackgroundColor: Color.fromRGBO(217, 232, 203,1.0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromRGBO(217, 232, 203,1.0),
        foregroundColor: Colors.black,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color.fromRGBO(217, 232, 203,1.0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromRGBO(179,216,168, 0.8)
      ),
      iconTheme: const IconThemeData(
        color: Colors.green,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color.fromRGBO(72, 72, 44, 1.0),
        foregroundColor: Colors.black,
      ),
    );
  }
}
