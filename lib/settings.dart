import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/change_password_page.dart';
import 'package:flutter_at_akira_menai/signup_page.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_at_akira_menai/providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? _notificationsEnabled;
  final String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    try {
      final settingsBox = Hive.box('settings');
      setState(() {
        _notificationsEnabled =
            settingsBox.get('notificationsEnabled', defaultValue: true) as bool;
      });
    } catch (e) {
      setState(() {
        _notificationsEnabled = true;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading settings: $e')));
      }
    }
  }

  void _saveSettings({bool? notificationsEnabled, bool? darkMode}) {
    try {
      final settingsBox = Hive.box('settings');
      if (notificationsEnabled != null) {
        settingsBox.put('notificationsEnabled', notificationsEnabled);
      }
      if (darkMode != null) {
        settingsBox.put('darkMode', darkMode);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving settings: $e')));
      }
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out: $e')),
                      );
                    }
                  }
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dark Mode
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
              _saveSettings(darkMode: value);
            },
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Notifications'),
            value: _notificationsEnabled ?? true,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveSettings(notificationsEnabled: value);
            },
            secondary: Icon(
              Icons.notifications,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Change Password'),
            leading: Icon(
              Icons.lock_reset,
              color: Theme.of(context).colorScheme.primary,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('App Version'),
            subtitle: Text(_appVersion),
            leading: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Sign Out'),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: _signOut,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
