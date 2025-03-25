import 'package:flutter/material.dart';

 class DashboardScreen extends StatelessWidget {
 const DashboardScreen({super.key});

 @override

  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       backgroundColor: const Color(0xFF2C5F75),
       title: const Text(''),
       elevation: 0,
       leading: IconButton(
         icon: const Icon(Icons.menu),
         onPressed: () {},
       ),
     ),
   );
 }
 }
