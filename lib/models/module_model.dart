class ModuleModel {
  final String moduleId;
  final String moduleCode;
  final String moduleName;
  final int moduleCredit;
  final String moduleGrade;
  final int moduleSemester;

  ModuleModel({
    required this.moduleId,
    required this.moduleCode,
    required this.moduleName,
    required this.moduleCredit,
    required this.moduleGrade,
    required this.moduleSemester,
  });

  // Add this method
  Map<String, dynamic> toMap() {
    return {
      'moduleId': moduleId,
      'moduleCode': moduleCode,
      'moduleName': moduleName,
      'moduleCredit': moduleCredit,
      'moduleGrade': moduleGrade,
      'moduleSemester': moduleSemester,
    };
  }

  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      moduleId: map['moduleId'],
      moduleName: map['moduleName'],
      moduleCode: map['moduleCode'],
      moduleGrade: map['moduleGrade'],
      moduleCredit: map['moduleCredit'],
      moduleSemester: map['moduleSemester'],
    );
  }

  // Add a copyWith method if needed
  ModuleModel copyWith({
    String? moduleId,
    String? moduleCode,
    String? moduleName,
    int? moduleCredit,
    String? moduleGrade,
    int? moduleSemester,
  }) {
    return ModuleModel(
      moduleId: moduleId ?? this.moduleId,
      moduleCode: moduleCode ?? this.moduleCode,
      moduleName: moduleName ?? this.moduleName,
      moduleCredit: moduleCredit ?? this.moduleCredit,
      moduleGrade: moduleGrade ?? this.moduleGrade,
      moduleSemester: moduleSemester ?? this.moduleSemester,
    );
  }
}