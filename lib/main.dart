import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/navigation_page.dart';
import 'package:flutter_at_akira_menai/providers/theme_provider.dart';
import 'package:flutter_at_akira_menai/signup_page.dart';
import 'package:flutter_at_akira_menai/widgets/themes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive box
  await Hive.initFlutter(); // Initialize Hive with directory
  await Hive.openBox('settings'); // Open the settings box
  await Hive.openBox('images');

  // Run the app
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Flutter at Akira Menai',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home:
          FirebaseAuth.instance.currentUser != null
              ? const NavigationPage()
              : const SignUpPage(),
    );
  }
}
