import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nsbm_student_academic_tracker/firebase_options.dart';
import 'package:nsbm_student_academic_tracker/pages/homescreen.dart';
import 'package:nsbm_student_academic_tracker/pages/welcomscreen.dart';
import 'package:nsbm_student_academic_tracker/pages/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:nsbm_student_academic_tracker/themes/themeprovider.dart';
import 'package:nsbm_student_academic_tracker/themes/darktheme.dart';
import 'package:nsbm_student_academic_tracker/themes/lighttheme.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  User? user = FirebaseAuth.instance.currentUser;

  if (isFirstTime) {
    await prefs.setBool('isFirstTime', false);
  }

  runApp(MyApp(user: user, isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  final User? user;

  const MyApp({super.key, required this.isFirstTime, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              final ColorScheme lightScheme =
                  lightDynamic ?? LightTheme.theme.colorScheme;
              final ColorScheme darkScheme =
                  darkDynamic ?? DarkTheme.theme.colorScheme;

              final ThemeData lightThemeData = LightTheme.theme.copyWith(
                colorScheme: lightScheme,
                drawerTheme: DrawerThemeData(
                  backgroundColor: lightScheme.surfaceContainerHighest,
                ),
              );
              final ThemeData darkThemeData = DarkTheme.theme.copyWith(
                colorScheme: darkScheme,
                drawerTheme: DrawerThemeData(
                  backgroundColor: darkScheme.surfaceContainerHighest,
                ),
              );

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'NSBM Student Academic Tracker',
                theme: lightThemeData,
                darkTheme: darkThemeData,
                home: _getInitialScreen(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getInitialScreen() {
    if (isFirstTime) {
      return const WelcomeScreen();
    } else if (user == null) {
      return const Signin();
    } else {
      return const HomeScreen();
    }
  }
}
