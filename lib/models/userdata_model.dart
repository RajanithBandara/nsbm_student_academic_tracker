//add the data types which you wish to send as the student data
class UserDataModel {
  final String userName;
  final String courseName;
  final int age;
  final String idNumber;
  final String email;
  final double gpa;

  UserDataModel({
    required this.userName,
    required this.courseName,
    required this.age,
    required this.idNumber,
    required this.email,
    this.gpa = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'courseName': courseName,
      'age': age,
      'idNumber': idNumber,
      'email': email,
      'gpa': gpa,
    };
  }
}