import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nsbm_student_academic_tracker/firebase_options.dart';
import 'package:nsbm_student_academic_tracker/pages/componenttest.dart';
import 'package:nsbm_student_academic_tracker/pages/helloworld.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: 'NSBM Student Academic Tracker',
      home: const ComponentTest(),
    );
  }
}