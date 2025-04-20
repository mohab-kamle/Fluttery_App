import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/home_page.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize firebase
  await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
  );
  //initilize Hivebox
  final dir = await getApplicationDocumentsDirectory(); // get directory path
  Hive.init(dir.path); // Initialize Hive with directory
  await Hive.openBox('myBox');
  //run the app
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Homepage(),
    );
  }
}
