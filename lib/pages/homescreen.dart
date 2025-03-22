import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:nsbm_student_academic_tracker/pages/calenderpin.dart';
import 'package:nsbm_student_academic_tracker/pages/loginpage.dart';
import 'package:nsbm_student_academic_tracker/pages/homepage.dart';
import 'package:nsbm_student_academic_tracker/pages/profilepage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CalenderPin(),
    const ProfilePage(),
    const ProfilePage()
  ];

  void _onItemTapped(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Signin()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(
        title: const Text(
          "Welcome",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        child: Column(
          children: [
            DrawerHeader(
              child: Text(
                "Menu",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_rounded),
              title: const Text("Events"),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sign Out"),
              onTap: signOut,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // Change page dynamically
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            label: "Events",
          ),
          NavigationDestination(
            icon: Icon(Icons.view_module_rounded),
            label: "Modules",
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
