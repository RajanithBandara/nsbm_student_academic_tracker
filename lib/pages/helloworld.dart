import 'package:flutter/material.dart';

class WelcomeToProject extends StatefulWidget{
  const WelcomeToProject({super.key});

  @override
  State<WelcomeToProject> createState() => _WelcomeToProjectState();

}

class _WelcomeToProjectState extends State<WelcomeToProject>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              "Welcome To Project",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            )
          ],
        ),
      ),
    );
  }
}