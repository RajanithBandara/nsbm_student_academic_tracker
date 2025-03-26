import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';




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
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildModulesSection(context),
               const SizedBox(height: 24),
              _buildProgressionSection(),
              const SizedBox(height: 24),
              _buildTasksSection(context),
              const SizedBox(height: 24),
              _buildEventsSection(context),
              
            ],
          ),
        ),
      ),
    );
  }


    Widget _buildModulesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Modules', 'Your running modules', true),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildModuleCard(
                'Mathematics for Programming',
                Icons.calculate,
                const Color(0xFF2C5F75),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModuleCard(
                'HCI',
                Icons.desktop_windows,
                const Color(0xFF2C5F75),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModuleCard(
                'Object Oriented Programming (OOP)',
                Icons.code,
                const Color(0xFF2C5F75),
              ),
            ),
          ],
        ),
      ],
    );
  }


 Widget _buildModuleCard(String title, IconData icon, Color color) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


Widget _buildSectionHeader(String title, String subtitle, bool showMore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        if (showMore && title != 'Progression')
          TextButton(
            onPressed: () {},
            child: Row(
              children: const [
                Text(
                  'More',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
      ],
    );
  }



  Widget _buildProgressionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progression',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildProgressPieChart()),
            const SizedBox(width: 16),
            Expanded(child:_buildSimplifiedBarChart()),

          ],
        ),
      ],
    );
  }



   Widget _buildProgressPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 25, color: Colors.red, title: '25%'),
            PieChartSectionData(value: 50, color: Colors.yellow, title: '50%'),
            PieChartSectionData(value: 25, color: Colors.green, title: '25%'),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }



  Widget _buildSimplifiedBarChart() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBar('M1', 0.65, Colors.blue),
          _buildBar('M2', 0.4, Colors.green),
          _buildBar('M3', 0.5, Colors.yellow),
          _buildBar('M4', 0.85, Colors.orange),
          _buildBar('M5', 0.6, Colors.red),
          _buildBar('M6', 0.7, Colors.purple),
          _buildBar('M7', 0.55, Colors.teal),
        ],
      ),
    );
  }


  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 15,
          height: 100 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }




Widget _buildTasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tasks', '', true),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            4,
                (index) => _buildTaskCard(context, 'Marketing project at School'),
          ),
        ),
      ],
    );
  }








}





