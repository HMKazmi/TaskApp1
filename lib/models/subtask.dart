import 'package:hive/hive.dart';
part 'subtask.g.dart'; // Will be generated with Hive code generator

@HiveType(typeId: 2)
class Subtask extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  bool isCompleted;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}
