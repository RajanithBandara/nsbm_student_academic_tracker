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
    _semesterGPA = _fetchSemesterWiseGPA().then((value) => value.map((key, val) => MapEntry(key.toString(), val)));
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

  Future<Map<int, double>> _fetchSemesterWiseGPA() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return {};

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("student")
          .doc(currentUser.uid)
          .collection("modules")
          .get();

      if (snapshot.docs.isEmpty) return {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onInverseSurface,
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, double>>(
          future: _semesterGPA,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Loading your GPA data...",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No GPA data found",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            "Complete your course modules to see your GPA progression here.",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _refreshData,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh Data"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: colorScheme.onPrimary,
                            backgroundColor: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final semesterGPAData = snapshot.data!;
            final semesters = semesterGPAData.keys.toList()
              ..sort((a, b) => int.tryParse(a.replaceAll(RegExp(r'\D'), ''))!
                  .compareTo(int.tryParse(b.replaceAll(RegExp(r'\D'), '')) ?? 0));

            final overallGPA = semesterGPAData.values.reduce((a, b) => a + b) / semesterGPAData.length;
            final overallGradeLabel = _getGradeFromGPA(overallGPA);
            final gpaColor = _getGPAColor(overallGPA, colorScheme);

            final List<FlSpot> spots = [
              for (var i = 0; i < semesters.length; i++) FlSpot(i.toDouble(), semesterGPAData[semesters[i]]!)
            ];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GPA Summary Card
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Cumulative GPA",
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onPrimary.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          overallGPA.toStringAsFixed(2),
                                          style: theme.textTheme.displaySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "/ 4.0",
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: colorScheme.onPrimary.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimary,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      overallGradeLabel,
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: gpaColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildGPAStat(
                                  context,
                                  "Total Semesters",
                                  semesterGPAData.length.toString(),
                                ),
                                _buildGPAStat(
                                  context,
                                  "Best Semester",
                                  "${semesters[semesterGPAData.values.toList().indexOf(semesterGPAData.values.reduce((a, b) => a > b ? a : b))].replaceAll(RegExp(r'\D'), '')}",
                                ),
                                _buildGPAStat(
                                  context,
                                  "Highest GPA",
                                  semesterGPAData.values.reduce((a, b) => a > b ? a : b).toStringAsFixed(2),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Chart title with additional info
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "GPA Progression",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${semesterGPAData.length} Semesters",
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chart card with enhanced styling
                    Card(
                      elevation: 4,
                      shadowColor: colorScheme.shadow.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 1.6,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeInOut,
                                builder: (context, animationValue, child) {
                                  final animatedSpots = spots
                                      .map((spot) => FlSpot(spot.x, spot.y * animationValue))
                                      .toList();
                                  return LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: true,
                                        drawHorizontalLine: true,
                                        horizontalInterval: 1,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: colorScheme.outline.withOpacity(0.2),
                                            strokeWidth: 1,
                                            dashArray: [5, 5],
                                          );
                                        },
                                        getDrawingVerticalLine: (value) {
                                          return FlLine(
                                            color: colorScheme.outline.withOpacity(0.1),
                                            strokeWidth: 1,
                                            dashArray: [5, 5],
                                          );
                                        },
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            interval: 1,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onSurface.withOpacity(0.7),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          axisNameWidget: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              "Semester",
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              int index = value.toInt();
                                              if (index >= 0 && index < semesters.length) {
                                                String semesterNumber = semesters[index].replaceAll(RegExp(r'\D'), '');
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      semesterNumber,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: colorScheme.primary,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                            reservedSize: 40,
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
                                          color: colorScheme.outline.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: animatedSpots,
                                          isCurved: true,
                                          curveSmoothness: 0.3,
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
                                                colorScheme.primary.withOpacity(0.4),
                                                colorScheme.primary.withOpacity(0.05),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                              radius: 6,
                                              color: colorScheme.primary,
                                              strokeWidth: 3,
                                              strokeColor: colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                      minX: 0,
                                      maxX: (semesters.length - 1).toDouble(),
                                      minY: 0,
                                      maxY: 4,
                                      lineTouchData: LineTouchData(
                                        touchTooltipData: LineTouchTooltipData(
                                          tooltipRoundedRadius: 8,
                                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                            return touchedBarSpots.map((barSpot) {
                                              final semIndex = barSpot.x.toInt();
                                              final gpa = barSpot.y;
                                              return LineTooltipItem(
                                                'Sem ${semesters[semIndex].replaceAll(RegExp(r'\D'), '')}: ${gpa.toStringAsFixed(2)}',
                                                TextStyle(
                                                  color: colorScheme.onPrimaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: '\nGrade: ${_getGradeFromGPA(gpa)}',
                                                    style: TextStyle(
                                                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList();
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
=======
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
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Semester detail cards
                    Text(
                      "Semester GPA Details",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: semesters.length,
                      itemBuilder: (context, index) {
                        final semester = semesters[index];
                        final gpa = semesterGPAData[semester]!;
                        final grade = _getGradeFromGPA(gpa);

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Sem ${semester.replaceAll(RegExp(r'\D'), '')}",
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: _getGPAColor(gpa, colorScheme).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          grade,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _getGPAColor(gpa, colorScheme),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  gpa.toStringAsFixed(2),
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  "GPA Score",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

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
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGPAStat(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}