import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/homePage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
