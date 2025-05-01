import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/navigation_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_at_akira_menai/providers/theme_provider.dart';
import 'package:flutter_at_akira_menai/widgets/themes.dart';
import 'package:flutter_at_akira_menai/on_boarding.dart';
import 'package:flutter_at_akira_menai/models/task_model.dart';
import 'package:flutter_at_akira_menai/models/habit_model.dart';
import 'package:flutter_at_akira_menai/widgets/notification_service.dart';
import 'firebase_options.dart';

/// Global instance of the NotificationService
late NotificationService notificationService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // 3. Initialize Hive
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox('images');
  await Hive.openBox('settings');
  await Hive.openBox('themeBox');
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<Task>('tasks');
  await Hive.openBox("pomodoro");
  
  // 1. Initialize time zone database once
  tz.initializeTimeZones();

  // 2. Initialize NotificationService
  notificationService = NotificationService(FlutterLocalNotificationsPlugin());
  await notificationService.initialize();

  
  // 4. Load env vars & Firebase
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 5. Run the app
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Temply',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home:
          FirebaseAuth.instance.currentUser != null
              ? const NavigationPage()
              : const OnBoarding(),
    );
  }
}
