import 'dart:math' as math;
import '../models/module_model.dart';

class GpaPredictionSystem {
  static double _gradeToPoints(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+': return 4.0;
      case 'A': return 4.0;
      case 'A-': return 3.7;
      case 'B+': return 3.3;
      case 'B': return 3.0;
      case 'B-': return 2.7;
      case 'C+': return 2.3;
      case 'C': return 2.0;
      case 'C-': return 1.7;
      case 'D+': return 1.3;
      case 'D': return 1.0;
      case 'F': return 0.0;
      default: return 0.0;
    }
  }

  static Map<int, List<ModuleModel>> groupModulesBySemester(List<ModuleModel> modules) {
    Map<int, List<ModuleModel>> groupedModules = {};
    for (var module in modules) {
      groupedModules.putIfAbsent(module.moduleSemester, () => []).add(module);
    }
    return groupedModules;
  }

  static Map<int, double> calculateSemesterGPA(Map<int, List<ModuleModel>> groupedModules) {
    Map<int, double> semesterGPA = {};

    groupedModules.forEach((semester, modules) {
      double totalPoints = 0;
      int totalCredits = 0;

      for (var module in modules) {
        double gradePoints = _gradeToPoints(module.moduleGrade);
        totalPoints += gradePoints * module.moduleCredit;
        totalCredits += module.moduleCredit;
      }

      semesterGPA[semester] = (totalCredits > 0) ? totalPoints / totalCredits : 0.0;
    });

    return semesterGPA;
  }

  /// Predicts the final GPA while considering gradually increasing difficulty per semester.
  static double predictFinalGPA(Map<int, double> semesterGPA, int totalSemesters) {
    if (semesterGPA.isEmpty) return 0.0;

    List<double> gpaValues = semesterGPA.values.toList();
    int completedSemesters = gpaValues.length;
    int remainingSemesters = totalSemesters - completedSemesters;
    if (remainingSemesters <= 0) return gpaValues.last;

    // Calculate average growth rate from past GPA trends
    double growthRate = 0.0;
    if (completedSemesters > 1) {
      for (int i = 1; i < completedSemesters; i++) {
        growthRate += (gpaValues[i] - gpaValues[i - 1]);
      }
      growthRate /= (completedSemesters - 1);
    }

    // **Gradually increasing difficulty factor** (quadratic growth)
    double difficultyFactor = 1.0 - math.pow(completedSemesters / totalSemesters, 2);
    difficultyFactor = difficultyFactor.clamp(0.3, 1.0); // Ensure valid range

    // Exponential decay to model increasing difficulty
    double decayFactor = math.exp(-0.1 * remainingSemesters); // Reduces growth rate

    // Adjusted GPA prediction
    double adjustedGrowth = growthRate * difficultyFactor * decayFactor;
    double predictedGPA = gpaValues.last + adjustedGrowth;

    return predictedGPA.clamp(0.0, 4.0);
  }
}
