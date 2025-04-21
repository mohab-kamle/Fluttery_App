import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/signup_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${auth.currentUser?.email}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await auth.signOut();
                if (!context.mounted) return;
                Navigator.push(context
                , MaterialPageRoute(
                  builder: (context) => SignUpPage(
                    isDarkMode: widget.isDarkMode,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ));
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
