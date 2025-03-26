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





  
}





