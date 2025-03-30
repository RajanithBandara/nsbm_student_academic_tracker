import 'package:flutter/material.dart';

class GpaDetailsCard extends StatelessWidget {
  final Map<int, double> semesterGPA;
  final double predictedGPA;

  const GpaDetailsCard({
    super.key,
    required this.semesterGPA,
    required this.predictedGPA,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current Semester GPAs:", style: Theme.of(context).textTheme.titleLarge),
            ...semesterGPA.entries.map((e) =>
                Text("Semester ${e.key}: ${e.value.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.bodyLarge)),
            const SizedBox(height: 16),
            Text("Predicted Final GPA: ${predictedGPA.toStringAsFixed(2)}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
