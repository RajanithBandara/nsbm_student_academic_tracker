import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'firebase_options.dart';
import 'pages/homescreen.dart';
import 'pages/welcomscreen.dart';
import 'pages/loginpage.dart';
import 'pages/todo.dart';
import 'themes/themeprovider.dart';
import 'themes/darktheme.dart';
import 'themes/lighttheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
}

Future<void> initializeApp() async {
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todoBox');
  Hive.close();

  // Initialize Notifications
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        icon: 'resource://mipmap/ic_launcher',
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for task reminders',
        ledColor: Colors.white,
        enableVibration: true,
      ),
      NotificationChannel(
        icon: 'resource://mipmap/ic_launcher',
        channelKey: 'floating_channel',
        channelName: 'Floating Notifications',
        channelDescription: 'Channel for floating heads-up notifications',
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
        criticalAlerts: true,
      ),
    ],
  );

  // Fetch user authentication status
  User? user = FirebaseAuth.instance.currentUser;

  // Handle first-time app launch
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  if (isFirstTime) {
    await prefs.setBool('isFirstTime', false);
  }

  runApp(MyApp(isFirstTime: isFirstTime, user: user));
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
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'NSBM Student Academic Tracker',
                theme: LightTheme.theme.copyWith(
                  colorScheme: lightDynamic ?? LightTheme.theme.colorScheme,
                  drawerTheme: DrawerThemeData(
                    backgroundColor: (lightDynamic ?? LightTheme.theme.colorScheme).surfaceContainerHighest,
                  ),
                ),
                darkTheme: DarkTheme.theme.copyWith(
                  colorScheme: darkDynamic ?? DarkTheme.theme.colorScheme,
                  drawerTheme: DrawerThemeData(
                    backgroundColor: (darkDynamic ?? DarkTheme.theme.colorScheme).surfaceContainerHighest,
                  ),
                ),
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
    }
    return user == null ? const Signin() : const HomeScreenUi();
  }
}
