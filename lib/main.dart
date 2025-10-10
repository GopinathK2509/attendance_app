import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_attendance_application/data/local_storage/local_storage_impl.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';
import 'package:mobile_attendance_application/presentation/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(AttendanceModelAdapter());
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<AttendanceModel>('attendance');
  await Hive.openBox('app_data');
  final storage = LocalStorageImpl();
  await storage.init();
  final repository = AttendanceRepositoryImpl(localStorage: storage);
  runApp(MyApp(storage: storage, repository: repository));
}

class MyApp extends StatelessWidget {
  final LocalStorageImpl storage;
  final AttendanceRepositoryImpl repository;

  const MyApp({super.key, required this.storage, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(storage: storage),
    );
  }
}
