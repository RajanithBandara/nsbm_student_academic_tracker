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

  // Controllers for user input
  final TextEditingController aController = TextEditingController();
  final TextEditingController bController = TextEditingController();
  final TextEditingController cController = TextEditingController();
  final TextEditingController dController = TextEditingController();
  final TextEditingController fController = TextEditingController();

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
              _buildGradeInputFields(),
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

  Widget _buildGradeInputFields() {
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
              'Enter Your Grades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField('A\'s:', aController),
            _buildTextField('B\'s:', bController),
            _buildTextField('C\'s:', cController),
            _buildTextField('D\'s:', dController),
            _buildTextField('F\'s:', fController),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text('Update Chart'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
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
              child: PieChart(
                PieChartData(
                  sections: _getGradeData(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getGradeData() {
    final grades = {
      'A': int.tryParse(aController.text) ?? 0,
      'B': int.tryParse(bController.text) ?? 0,
      'C': int.tryParse(cController.text) ?? 0,
      'D': int.tryParse(dController.text) ?? 0,
      'F': int.tryParse(fController.text) ?? 0,
    };

    return grades.entries.map((entry) {
      return PieChartSectionData(
        title: '${entry.key}: ${entry.value}',
        value: entry.value.toDouble(),
        color: _getGradeColor(entry.key),
        radius: 50,
      );
    }).toList();
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      case 'F':
        return Colors.black;
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3.3),
                        FlSpot(1, 2.7),
                        FlSpot(2, 3.0),
                        FlSpot(3, 3.7),
                        FlSpot(4, 3.3),
                      ],
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
