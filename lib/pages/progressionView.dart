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
  String selectedSemester = 'This Semester';

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
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSemesterSelector(),
              const SizedBox(height: 30),
              _buildModuleProgressChart(),
              const SizedBox(height: 30),
              _buildGpaProgressionChart(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSemesterSelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: DropdownButton<String>(
          value: selectedSemester,
          dropdownColor: Colors.deepPurple,
          onChanged: (String? newValue) {
            setState(() {
              selectedSemester = newValue!;
            });
          },
          items: ['Last Semester', 'This Semester']
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


  Widget _buildModuleProgressChart() {
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
              'Module Completion',
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
              child: BarChart(
                BarChartData(
                  barGroups: _getModuleProgressData(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
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
                          List<String> modules = _getModuleNames();
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                modules[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  gridData: const FlGridData(show: true),
                  barTouchData: BarTouchData(enabled: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  borderData: FlBorderData(show: true),
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
                    touchCallback: (FlTouchEvent event, LineTouchResponse? response) {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  List<BarChartGroupData> _getModuleProgressData() {
    if (selectedSemester == 'Last Semester') {
      return [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: Colors.orange, width: 16, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 70, color: Colors.red, width: 16, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 100, color: Colors.green, width: 16, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 90, color: Colors.purple, width: 16, borderRadius: BorderRadius.circular(4))]),
      ];
    } else {
      return [
        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 80, color: Colors.pink, width: 16, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: Colors.brown, width: 16, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 90, color: Colors.purple, width: 16, borderRadius: BorderRadius.circular(4))]),
        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 100, color: Colors.green, width: 16, borderRadius: BorderRadius.circular(4))]),
      ];
    }
  }

  List<String> _getModuleNames() {
    return selectedSemester == 'Last Semester'
        ? ['IOT', 'IMR', 'CGP', 'JAVA']
        : ['IOT', 'MAD', 'SDTP', 'CGP'];
  }
}