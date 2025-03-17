//add the which of the data you like to push for the module things
class ModuleModel {
  final String moduleCode;
  final String moduleName;
  final int moduleCredit;
  final String moduleGrade;
  final int moduleSemester;

  ModuleModel({
    required this.moduleCode,
    required this.moduleName,
    required this.moduleCredit,
    required this.moduleGrade,
    required this.moduleSemester,
  });
  Map<String, dynamic> toMap() {
    return {
      'moduleName': moduleCode,
      'moduleCode': moduleName,
      'moduleCredit': moduleCredit,
      'moduleGrade': moduleGrade,
      'moduleSemester': moduleSemester,
    };
  }
  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      moduleName: map['moduleCode'],
      moduleCode: map['moduleName'],
      moduleCredit: map['moduleCredit'],
      moduleGrade: map['moduleGrade'],
      moduleSemester: map['moduleSemester'],
    );
  }
}