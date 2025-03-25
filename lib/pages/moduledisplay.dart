import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/module_model.dart';

class ModulesPage extends StatefulWidget {
  const ModulesPage({super.key});

  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<Map<int, List<ModuleModel>>> futureModules;

  @override
  void initState() {
    super.initState();
    futureModules = fetchModules();
  }

  Future<Map<int, List<ModuleModel>>> fetchModules() async {
    if (user == null) {
      debugPrint("No user logged in.");
      return {};
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

      modules.sort((a, b) => a.moduleSemester.compareTo(b.moduleSemester));

      Map<int, List<ModuleModel>> groupedModules = {};
      for (var module in modules) {
        groupedModules.putIfAbsent(module.moduleSemester, () => []).add(module);
      }

      return groupedModules;
    } catch (e) {
      debugPrint("Error fetching modules: $e");
      return {};
    }
  }

  void refreshData() {
    setState(() {
      futureModules = fetchModules();
    });
  }

  Future<void> deleteModule(String moduleId) async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection("student")
          .doc(user!.uid)
          .collection("modules")
          .doc(moduleId)
          .delete();
      refreshData();
      HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint("Error deleting module: $e");
    }
  }

  Color _gradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
      case 'A-':
      case 'B+':
      case 'B':
      case 'B-':
        return Colors.green;
      case 'C+':
      case 'C':
      case 'C-':
        return Colors.amber;
      case 'D+':
      case 'D':
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSummaryCard(BuildContext context, List<ModuleModel> allModules) {
    final totalCredits =
    allModules.fold<int>(0, (sum, mod) => sum + mod.moduleCredit);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Total Modules: ${allModules.length}",
                style: Theme.of(context).textTheme.bodyLarge),
            Text("Total Credits: $totalCredits",
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile(BuildContext context, ModuleModel module, int index) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            elevation: 2,
            color: colorScheme.surface,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                module.moduleName,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Code: ${module.moduleCode}",
                        style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text("Grade: "),
                        Chip(
                          label: Text(module.moduleGrade),
                          backgroundColor: _gradeColor(module.moduleGrade)
                              .withOpacity(0.2),
                          labelStyle: textTheme.bodyMedium?.copyWith(
                            color: _gradeColor(module.moduleGrade),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text("Credits: ${module.moduleCredit}",
                        style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: colorScheme.error),
                onPressed: () {
                  deleteModule(module.moduleId);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onInverseSurface,
      body: FutureBuilder<Map<int, List<ModuleModel>>>(
        future: futureModules,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LinearProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No modules found."));
          }

          final Map<int, List<ModuleModel>> groupedModules = snapshot.data!;
          final allModules = groupedModules.values.expand((m) => m).toList();

          return AnimationLimiter(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildSummaryCard(context, allModules),
                ...groupedModules.entries.map((entry) {
                  return AnimationConfiguration.staggeredList(
                    position: entry.key,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(
                                'Semester ${entry.key}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              children: entry.value
                                  .asMap()
                                  .entries
                                  .map((e) =>
                                  _buildModuleTile(context, e.value, e.key))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
