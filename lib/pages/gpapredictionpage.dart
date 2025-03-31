import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../models/module_model.dart';
import '../functions/gpapredictionfunction.dart';
import './gpapredict_card.dart';

class GpaPredictionPage extends StatefulWidget {
  final int totalSemesters;
  const GpaPredictionPage({super.key, this.totalSemesters = 8});

  @override
  State<GpaPredictionPage> createState() => _GpaPredictionPageState();
}

class _GpaPredictionPageState extends State<GpaPredictionPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<List<ModuleModel>> futureModules;

  @override
  void initState() {
    super.initState();
    futureModules = fetchModules();
  }

  Future<List<ModuleModel>> fetchModules() async {
    if (user == null) {
      debugPrint("No user logged in.");
      return [];
    }
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("student")
          .doc(user!.uid)
          .collection("modules")
          .get();

      List<ModuleModel> modules = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ModuleModel.fromMap(data).copyWith(moduleId: doc.id);
      }).toList();

      return modules;
    } catch (e) {
      debugPrint("Error fetching modules: $e");
      return [];
    }
  }

  void refreshData() {
    setState(() {
      futureModules = fetchModules();
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      body: FutureBuilder<List<ModuleModel>>(
        future: futureModules,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No modules found."));
          }
          List<ModuleModel> modules = snapshot.data!;
          Map<int, List<ModuleModel>> groupedModules = GpaPredictionSystem.groupModulesBySemester(modules);
          Map<int, double> semesterGPA = GpaPredictionSystem.calculateSemesterGPA(groupedModules);
          double predictedGPA = GpaPredictionSystem.predictFinalGPA(semesterGPA, widget.totalSemesters);

          return RefreshIndicator(
            onRefresh: () async {
              refreshData();
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                GpaDetailsCard(
                  semesterGPA: semesterGPA,
                  predictedGPA: predictedGPA,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
