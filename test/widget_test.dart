import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nsbm_student_academic_tracker/main.dart';
import 'package:nsbm_student_academic_tracker/pages/homescreen.dart';
import 'package:nsbm_student_academic_tracker/pages/loginpage.dart';
import 'package:nsbm_student_academic_tracker/pages/welcomscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

// Mock FirebaseAuth and SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockUser extends Mock implements User {}

void main() {
  testWidgets('App starts with the correct screen based on authentication and preferences', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'isFirstTime': false});

    final mockUser = MockUser();

    await tester.pumpWidget(MyApp(isFirstTime: false, user: mockUser));

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('App starts with WelcomeScreen for first-time users', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'isFirstTime': true});

    await tester.pumpWidget(const MyApp(isFirstTime: true, user: null));

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('App starts with SignIn screen if user is signed out', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'isFirstTime': false});

    await tester.pumpWidget(const MyApp(isFirstTime: false, user: null));

    expect(find.byType(Signin), findsOneWidget);
  });
}
