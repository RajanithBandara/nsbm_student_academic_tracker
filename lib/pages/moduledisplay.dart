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
        return Colors.green.shade700;
      case 'B+':
      case 'B':
      case 'B-':
        return Colors.green.shade400;
      case 'C+':
      case 'C':
      case 'C-':
        return Colors.amber.shade600;
      case 'D+':
      case 'D':
        return Colors.deepOrange;
      case 'F':
        return Colors.red.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildSummaryCard(BuildContext context, List<ModuleModel> allModules) {
    final totalCredits =
    allModules.fold<int>(0, (sum, mod) => sum + mod.moduleCredit);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.primaryContainer.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Academic Progress",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _summaryItem(
                  context,
                  'Modules',
                  allModules.length.toString(),
                  Icons.book,
                  colorScheme,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                ),
                _summaryItem(
                  context,
                  'Credits',
                  totalCredits.toString(),
                  Icons.stars,
                  colorScheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(BuildContext context, String label, String value,
      IconData icon, ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleTile(BuildContext context, ModuleModel module, int index) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final gradeColor = _gradeColor(module.moduleGrade);

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 40.0,
        child: FadeInAnimation(
          child: Card(
            elevation: 2,
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.2),
                width: 1,
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grade indicator
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: gradeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        module.moduleGrade,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
                        ),
                      ),
                    ),
                  ),
                  // Module details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.moduleName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                module.moduleCode,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.credit_card,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${module.moduleCredit} Credits",
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => deleteModule(module.moduleId),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterHeader(BuildContext context, int semester) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Semester $semester',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant,
              thickness: 1,
            ),
          ),
        ],
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
            return Center(
              child: SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading modules",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    "${snapshot.error}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No modules found",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          final Map<int, List<ModuleModel>> groupedModules = snapshot.data!;
          final allModules = groupedModules.values.expand((m) => m).toList();

          return AnimationLimiter(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSummaryCard(context, allModules),
                ...groupedModules.entries.expand((entry) {
                  return [
                    _buildSemesterHeader(context, entry.key),
                    ...entry.value
                        .asMap()
                        .entries
                        .map((e) => _buildModuleTile(context, e.value, e.key))
                        .toList(),
                  ];
                }).toList(),
                const SizedBox(height: 24), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }
}