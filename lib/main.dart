
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/subtask.dart';
import 'package:task_manager/view_models/task_list_view_model.dart';
import 'package:task_manager/services/database_service.dart';
import 'package:task_manager/services/notification_service.dart';
import 'package:task_manager/views/HomeScreen.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(SubtaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>('tasks');
  
  // Initialize NotificationService
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize DatabaseService
  final databaseService = DatabaseService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskListViewModel(
            databaseService: databaseService,
            notificationService: notificationService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system, // Support system theme
      home: const HomeScreen(),
    );
  }
}

