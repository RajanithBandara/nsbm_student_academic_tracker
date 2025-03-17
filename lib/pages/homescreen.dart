import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:nsbm_student_academic_tracker/pages/loginpage.dart'; // Make sure this import is correct
import 'package:nsbm_student_academic_tracker/functions/signinfunction.dart'; // Ensure this is correctly imported

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of widgets for different pages
  static const List<Widget> _pages = <Widget>[
    Center(child: Text("Home Page", style: TextStyle(fontSize: 18))),
    Center(child: Text("Search Page", style: TextStyle(fontSize: 18))),
    Center(child: Text("Profile Page", style: TextStyle(fontSize: 18))),
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
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // Sign Out function
  void _handleSignOut() async {
    await signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Signin()),  // Navigate to Login page after sign out
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(
        title: const Text(
          "Welcome",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        elevation: 0, // Material 3 elevation style
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
                  color: Theme.of(context).colorScheme.onSurface, // Text color
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              selected: _selectedIndex == 0,
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);  // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text("Search"),
              selected: _selectedIndex == 1,
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);  // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              selected: _selectedIndex == 2,
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);  // Close the drawer
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sign Out"),
              onTap: _handleSignOut,  // Sign out when tapped
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _pages.elementAt(_selectedIndex),
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
            icon: Icon(Icons.search),
            label: "Search",
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
