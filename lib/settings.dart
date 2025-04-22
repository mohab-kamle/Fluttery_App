import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/signup_page.dart';
import 'package:flutter_at_akira_menai/widgets/auth_manager.dart';
import 'package:flutter_at_akira_menai/widgets/switch_mode.dart';
class SettingsPage extends StatefulWidget{
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              signOutUser().then((_) {
                if(context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
                }
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                    (route) => false,
                  );
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          :  SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('Settings Page', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              SwitchMode(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ), 
    );
  }
}
