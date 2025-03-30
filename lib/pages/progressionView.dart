import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Module Progress',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProgressionPage(),
    );
  }
}

class ProgressionPage extends StatefulWidget {
  const ProgressionPage({super.key});

  @override
  State<ProgressionPage> createState() => _ProgressionPageState();
}

class _ProgressionPageState extends State<ProgressionPage> {
  String selectedYear = '1st Year';
  int? touchedIndex;

  final Map<String, int> grades = {
    'A+': 5,
    'A': 7,
    'A-': 4,
    'B+': 3,
    'B': 4,
    'B-': 3,
    'Others': 10,
  };

  final Map<String, int> othersGrades = {
    'C+': 2,
    'C': 3,
    'C-': 2,
    'D': 3,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'My Progression',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildYearSelector(),
              const SizedBox(height: 30),
              _buildGradeDistributionChart(),
              const SizedBox(height: 30),
              _buildGpaProgressionChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: DropdownButton<String>(
          value: selectedYear,
          dropdownColor: Colors.deepPurple,
          onChanged: (String? newValue) {
            setState(() {
              selectedYear = newValue!;
            });
          },
          items: ['1st Year', '2nd Year', '3rd Year', '4th Year']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGradeDistributionChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grade Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: PieChart(
                          PieChartData(
                            sections: _getGradeData(),
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null ||
                                      pieTouchResponse.touchedSection!.touchedSectionIndex < 0) {
                                    touchedIndex = null;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: _buildGradeLegend(),
                        ),
                      ),
                    ],
                  ),
                  if (touchedIndex != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.4,
                        ),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: _buildTouchedGradeInfo(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTouchedGradeInfo() {
    final gradeKeys = grades.keys.toList();
    if (touchedIndex == null || touchedIndex! >= gradeKeys.length) return const SizedBox();

    final grade = gradeKeys[touchedIndex!];
    final count = grades[grade]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _getGradeColor(grade),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$grade: $count',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (grade == 'Others')
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('C+: ${othersGrades['C+']}'),
                Text('C: ${othersGrades['C']}'),
                Text('C-: ${othersGrades['C-']}'),
                Text('D: ${othersGrades['D']}'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGradeLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grades.keys.map((grade) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _getGradeColor(grade),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                grade,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<PieChartSectionData> _getGradeData() {
    final gradeKeys = grades.keys.toList();

    return gradeKeys.asMap().entries.map((entry) {
      final index = entry.key;
      final grade = entry.value;
      final isTouched = index == touchedIndex && touchedIndex != null;
      final radius = isTouched ? 45.0 : 35.0;

      return PieChartSectionData(
        color: _getGradeColor(grade),
        value: grades[grade]!.toDouble(),
        radius: radius,
        showTitle: false, // This ensures no text appears on the pie sections
      );
    }).toList();
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return Colors.green[900]!;
      case 'A':
        return Colors.green[700]!;
      case 'A-':
        return Colors.green[500]!;
      case 'B+':
        return Colors.blue[700]!;
      case 'B':
        return Colors.blue[500]!;
      case 'B-':
        return Colors.blue[300]!;
      case 'Others':
        return Colors.orange[400]!;
      default:
        return Colors.grey;
    }
  }

  Widget _buildGpaProgressionChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GPA Trend Over Semesters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  minY: 0,
                  maxY: 4,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3.3),
                        FlSpot(1, 2.7),
                        FlSpot(2, 3.0),
                        FlSpot(3, 3.7),
                        FlSpot(4, 3.3),
                        FlSpot(5, 3.0),
                        FlSpot(6, 3.0),
                        FlSpot(7, 3.3),
                      ],
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(1));
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          List<String> semesters = [
                            'Y1S1', 'Y1S2', 'Y2S1', 'Y2S2',
                            'Y3S1', 'Y3S2', 'Y4S1', 'Y4S2'
                          ];
                          if (value.toInt() >= 0 && value.toInt() < semesters.length) {
                            return Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                semesters[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          } else {
                            return const Text("");
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (LineBarSpot touchedSpot) => Colors.deepPurple,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          double gpa = spot.y;
                          String gpaClass;
                          if (gpa >= 3.7) {
                            gpaClass = 'First Class';
                          } else if (gpa >= 3.3) {
                            gpaClass = 'Second Upper';
                          } else if (gpa >= 3.0) {
                            gpaClass = 'Second Lower';
                          } else {
                            gpaClass = 'General Pass';
                          }
                          return LineTooltipItem(
                            'GPA: ${gpa.toStringAsFixed(2)}\nClass: $gpaClass',
                            const TextStyle(color: Colors.white, fontSize: 14),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}