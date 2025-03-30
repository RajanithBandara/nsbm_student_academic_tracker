import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:nsbm_student_academic_tracker/pages/calenderpin.dart';
import 'package:nsbm_student_academic_tracker/pages/datasendform.dart';
import 'package:nsbm_student_academic_tracker/pages/eventslatest.dart';
import 'package:nsbm_student_academic_tracker/pages/fetcheddata.dart';
import 'package:nsbm_student_academic_tracker/pages/gpapredictionpage.dart';
import 'package:nsbm_student_academic_tracker/pages/moduledisplay.dart';
import 'package:nsbm_student_academic_tracker/pages/progressionView.dart';
import 'package:nsbm_student_academic_tracker/pages/settings.dart';
import 'package:nsbm_student_academic_tracker/pages/loginpage.dart';
import 'package:nsbm_student_academic_tracker/pages/timer.dart';
import 'package:nsbm_student_academic_tracker/pages/todolist.dart';
import 'moduleaddition.dart';
import 'package:nsbm_student_academic_tracker/pages/dashboard.dart';

class HomeScreenUi extends StatefulWidget {
  const HomeScreenUi({super.key});

  @override
  State<HomeScreenUi> createState() => _HomeScreenUiState();
}

class _HomeScreenUiState extends State<HomeScreenUi> {
  String userName = "Loading...";
  String userid = "Loading...";
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    getUserName();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackGestureHandler.init(context);
    });
  }

  void getUserName() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userName = user?.displayName ?? "User Not Logged In";
    });
  }

  final List<String> _pageTitles = [
    "Dashboard",        // 0: Bottom nav
    "Add Modules",        // 1: Bottom nav
    "Your Data",          // 2: Bottom nav
    "Modules",            // 3: Bottom nav
    "Progression",        // 4: Bottom nav
    "Enter your Data",    // 5: Drawer
    "To Do List",       // 6: Drawer
    "Timer",
    "Calender",
    "Settings"         // 7: Drawer
  ];

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return DashboardScreen();
      case 1:
        return const ModuleAddition();
      case 2:
        return LatestEventsPage();
      case 3:
        return const ModulesPage();
      case 4:
        return const ProgressionPage();
      case 5:
        return const DataSendForm();
      case 6:
        return TodoPage();
      case 7:
        return TimerPage();
      case 8:
        return const CalenderPin();
      case 9:
        return const Settings();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> bottomNavTitles = _pageTitles.sublist(0, 5);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(
        automaticallyImplyLeading: true, // shows the drawer icon
        title: Text(
          _pageTitles[_selectedPageIndex],
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Signin()),
              );
              HapticFeedback.heavyImpact();
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      ),
      // Drawer navigation for extra pages.
      drawer: NavigationDrawer(
        selectedIndex: _selectedPageIndex >= 5 ? _selectedPageIndex - 5 : null,
        onDestinationSelected: (int index) {
          Navigator.pop(context);
          setState(() {
            _selectedPageIndex = index + 5;
          });
          HapticFeedback.lightImpact();
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Menu",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.add_box),
            label: Text("Enter your Data"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.list),
            label: Text("To Do List"),
          ),
          const NavigationDrawerDestination(
              icon: Icon(Icons.timer),
              label: Text("Timer")
          ),
          const NavigationDrawerDestination(
              icon: Icon(Icons.calendar_month_rounded),
              label: Text("Calender")
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.settings),
            label: Text("Settings"),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildPage(_selectedPageIndex),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPageIndex < 5 ? _selectedPageIndex : 0,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedPageIndex = index;
          });
          HapticFeedback.lightImpact();
        },
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        destinations: [
          NavigationDestination(
            icon: const Icon(CupertinoIcons.home),
            label: bottomNavTitles[0],
          ),
          NavigationDestination(
            icon: const Icon(CupertinoIcons.add),
            label: bottomNavTitles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.info),
            label: bottomNavTitles[2],
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_tree_outlined),
            label: bottomNavTitles[3],
          ),
          NavigationDestination(
            icon: const Icon(Icons.ssid_chart),
            label: bottomNavTitles[4],
          ),
        ],
      ),
    );
  }
}

class WelcomeHome extends StatelessWidget {
  final String userName;
  const WelcomeHome({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 100,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(height: 20),
          Text(
            "Welcome!",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          Text(
            userName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class BackGestureHandler {
  static const MethodChannel _channel = MethodChannel('predictive_back_channel');

  static Future<bool> _handleBackGesture(BuildContext context) async {
    final state = context.findAncestorStateOfType<_HomeScreenUiState>();
    if (state != null && state._selectedPageIndex != 0) {
      state.setState(() {
        state._selectedPageIndex = 0;
      });
      return true;
    }
    return false;
  }

  static void init(BuildContext context) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onPredictiveBack') {
        return _handleBackGesture(context);
      }
      return null;
    });
  }
}
