import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/hive_constants.dart';
import 'core/di/injection_container.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApplication();

  runApp(const TaskManagerApp());
}

Future<void> _initializeApplication() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize Hive before opening any local database boxes.
  await Hive.initFlutter();

  await Hive.openBox<dynamic>(HiveConstants.authBox);
  await Hive.openBox<dynamic>(HiveConstants.taskBox);

  // Initialize GetIt dependency registrations.
  await initializeDependencies();

  // Support only portrait-up orientation.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  // Configure status bar and navigation bar.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
}
