import 'package:flutter/material.dart';
import './dashboardhelper.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHelper.buildUserDataSection(context,),
              const SizedBox(height: 16),
              DashboardHelper.buildEventsSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}