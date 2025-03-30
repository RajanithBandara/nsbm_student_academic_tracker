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
              DashboardHelper.buildUserSection(context),
              const SizedBox(height: 16),
              DashboardHelper.buildSectionHeader(context, 'Tasks', true),
              const SizedBox(height: 16),
              DashboardHelper.buildTasksSection(context),
              const SizedBox(height: 24),
              DashboardHelper.buildSectionHeader(context, 'Upcoming Events', true ),
              const SizedBox(height: 16),
              DashboardHelper.buildEventsSection(context),
              const SizedBox(height: 24),
              DashboardHelper.buildSectionHeader(context, 'To-Do List', true),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}