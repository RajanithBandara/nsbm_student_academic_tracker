import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressionChart extends StatefulWidget {
  const ProgressionChart({super.key});

  @override
  State<ProgressionChart> createState() => _ProgressionChartState();
}

class _ProgressionChartState extends State<ProgressionChart> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<Map<String, double>> _semesterGPA;

  @override
  void initState() {
    super.initState();
    _semesterGPA = _fetchSemesterWiseGPA();
  }

  double _convertGradeToGPA(String grade) {
    const gradeMap = {
      "A+": 4.0,
      "A": 4.0,
      "A-": 3.7,
      "B+": 3.3,
      "B": 3.0,
      "B-": 2.7,
      "C+": 2.3,
      "C": 2.0,
      "C-": 1.7,
      "D+": 1.3,
      "D": 1.0,
      "F": 0.0,
    };
    return gradeMap[grade] ?? 0.0;
  }

  Future<Map<String, double>> _fetchSemesterWiseGPA() async {
    if (user == null) return {};

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("student")
          .doc(user!.uid)
          .collection("modules")
          .get();

      if (snapshot.docs.isEmpty) return {};

      Map<String, double> semesterTotalPoints = {};
      Map<String, int> semesterTotalCredits = {};

      for (var doc in snapshot.docs) {
        String semester = doc["moduleSemester"];
        int credits = int.tryParse(doc["moduleCredit"].toString()) ?? 0;
        double gpa = _convertGradeToGPA(doc["moduleGrade"]);

        semesterTotalPoints[semester] =
            (semesterTotalPoints[semester] ?? 0) + (gpa * credits);
        semesterTotalCredits[semester] =
            (semesterTotalCredits[semester] ?? 0) + credits;
      }

      return {
        for (var semester in semesterTotalPoints.keys)
          semester: semesterTotalPoints[semester]! /
              semesterTotalCredits[semester]!
      };
    } catch (e) {
      debugPrint("Error fetching GPA: $e");
      return {};
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _semesterGPA = _fetchSemesterWiseGPA();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onInverseSurface,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, double>>(
          future: _semesterGPA,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                  strokeWidth: 4,
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 200),
                  Center(
                    child: Text(
                      "No GPA data found.",
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              );
            }

            final semesterGPAData = snapshot.data!;
            final semesters = semesterGPAData.keys.toList()
              ..sort((a, b) => int.tryParse(a.replaceAll(RegExp(r'\D'), ''))!
                  .compareTo(
                  int.tryParse(b.replaceAll(RegExp(r'\D'), '')) ?? 0));

            final overallGPA = semesterGPAData.values.reduce((a, b) => a + b) /
                semesterGPAData.length;

            final List<FlSpot> spots = [
              for (var i = 0; i < semesters.length; i++)
                FlSpot(i.toDouble(), semesterGPAData[semesters[i]]!)
            ];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // Title for the chart.
                      Text(
                        "GPA Progression Chart",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Card containing the line chart.
                      Card.filled(
                        elevation: 0,
                        color: colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: AspectRatio(
                            aspectRatio: 1.6,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.easeInOut,
                              builder: (context, animationValue, child) {
                                final animatedSpots = spots
                                    .map((spot) => FlSpot(
                                    spot.x, spot.y * animationValue))
                                    .toList();
                                return LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) => Text(
                                            value.toInt().toString(),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        axisNameWidget: Padding(
                                          padding: const EdgeInsets.all(0),
                                          child: Text(
                                            "Semester",
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            int index = value.toInt();
                                            if (index >= 0 &&
                                                index < semesters.length) {
                                              String semesterNumber = semesters[index]
                                                  .replaceAll(RegExp(r'\D'), '');
                                              return Padding(
                                                padding:
                                                const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  semesterNumber,
                                                  style: theme.textTheme.bodySmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: colorScheme.onSurface,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                          reservedSize: 30,
                                          interval: 1,
                                        ),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                        color: colorScheme.outline,
                                        width: 2,
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: animatedSpots,
                                        isCurved: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            colorScheme.primary,
                                            colorScheme.secondary,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        barWidth: 4,
                                        isStrokeCapRound: true,
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              colorScheme.primary.withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                                radius: 6,
                                                color: colorScheme.primary,
                                                strokeWidth: 2,
                                                strokeColor: colorScheme.onPrimary,
                                              ),
                                        ),
                                      ),
                                    ],
                                    minX: 0,
                                    maxX: (semesters.length - 1).toDouble(),
                                    minY: 0,
                                    maxY: 4,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10,),
                      Card.outlined(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 3,
                        surfaceTintColor: colorScheme.onInverseSurface,
                        borderOnForeground: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "Overall GPA",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                overallGPA.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
