import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String task;

  @HiveField(1)
  DateTime dateTime;

  Todo({required this.task, required this.dateTime});
}
