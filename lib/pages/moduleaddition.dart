import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/module_model.dart';

class ModuleAddition extends StatefulWidget {
  const ModuleAddition({super.key});

  @override
  State<ModuleAddition> createState() => _ModuleAdditionState();
}

class _ModuleAdditionState extends State<ModuleAddition> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController moduleNameController = TextEditingController();
  final TextEditingController moduleCodeController = TextEditingController();
  final TextEditingController moduleCreditController = TextEditingController();
  final TextEditingController moduleGradeController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  bool isLoading = false;
  String? selectedSemester;

  final List<String> semesterList = [
    "Semester 1",
    "Semester 2",
    "Semester 3",
    "Semester 4",
    "Semester 5",
    "Semester 6",
    "Semester 7",
    "Semester 8",
  ];

  /// Converts the selected semester string (e.g., "Semester 1") into an integer.
  int parseSemester(String semesterStr) {
    final digits = RegExp(r'\d+').firstMatch(semesterStr)?.group(0);
    return digits != null ? int.parse(digits) : 0;
  }

  /// Sends module data to Firestore using ModuleModel.
  Future<void> sendModule() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedSemester == null) return;

    setState(() => isLoading = true);
    try {
      // Convert the input fields to the proper types.
      final moduleName = moduleNameController.text.trim();
      final moduleCode = moduleCodeController.text.trim();
      final moduleCredit = int.tryParse(moduleCreditController.text.trim()) ?? 0;
      final moduleGrade = moduleGradeController.text.trim();
      final moduleSemester = parseSemester(selectedSemester!);

      // Create a ModuleModel instance (moduleId will be set later)
      ModuleModel module = ModuleModel(
        moduleId: '',
        moduleCode: moduleCode,
        moduleName: moduleName,
        moduleCredit: moduleCredit,
        moduleGrade: moduleGrade,
        moduleSemester: moduleSemester,
      );

      DocumentReference docRef = FirebaseFirestore.instance
          .collection("student")
          .doc(user!.uid)
          .collection("modules")
          .doc(moduleCode);

      await docRef.set(module.toMap());

      // Update the moduleId field with the document id (if needed)
      module = module.copyWith(moduleId: docRef.id);

      // Optionally, you could show a success message.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Module added successfully")),
      );
      // Clear controllers after successful submission.
      moduleNameController.clear();
      moduleCodeController.clear();
      moduleCreditController.clear();
      moduleGradeController.clear();
      setState(() {
        selectedSemester = null;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Module addition failed")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Module addition failed: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    moduleNameController.dispose();
    moduleCodeController.dispose();
    moduleCreditController.dispose();
    moduleGradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onInverseSurface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      "Module Addition",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: moduleNameController,
                    decoration: const InputDecoration(
                      labelText: "Module Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Please enter module name"
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: moduleCodeController,
                    decoration: const InputDecoration(
                      labelText: "Module Code",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Please enter module code"
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: moduleCreditController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Module Credit",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Please enter module credit"
                        : (int.tryParse(value) == null
                        ? "Enter a valid number"
                        : null),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: moduleGradeController,
                    decoration: const InputDecoration(
                      labelText: "Module Grade",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Please enter module grade"
                        : null,
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Select Semester",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    value: selectedSemester,
                    items: semesterList.map((semester) {
                      return DropdownMenuItem<String>(
                        value: semester,
                        child: Text(semester),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSemester = newValue;
                      });
                    },
                    validator: (value) =>
                    value == null ? "Please select a semester" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : sendModule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Submit", style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
