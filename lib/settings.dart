import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/change_password_page.dart';
import 'package:flutter_at_akira_menai/signup_page.dart';
import 'package:flutter_at_akira_menai/widgets/auth_manager.dart';
import 'package:flutter_at_akira_menai/widgets/awsome_material_banner.dart';
import 'package:flutter_at_akira_menai/widgets/notification_service.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_at_akira_menai/providers/theme_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? _notificationsEnabled;
  final String _appVersion = '1.0.0';
  late final NotificationService _notificationService;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService(
      _flutterLocalNotificationsPlugin,
    );
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
        awesomeMaterialBanner(
          context: context,
          title: 'Oh snap!',
          message: 'Error loading settings: $e',
          contentType: ContentType.failure,
        );
      }
    }
  }

  void _saveSettings({bool? notificationsEnabled, bool? darkMode}) {
    try {
      final settingsBox = Hive.box('settings');
      if (notificationsEnabled != null) {
        settingsBox.put('notificationsEnabled', notificationsEnabled);
        _notificationService.setNotificationsEnabled(notificationsEnabled);
      }
      if (darkMode != null) {
        settingsBox.put('darkMode', darkMode);
      }
    } catch (e) {
      if (context.mounted) {
        awesomeMaterialBanner(
          context: context,
          title: 'Oh snap!',
          message: 'Error saving settings: $e',
          contentType: ContentType.failure,
        );
      }
    }
  }

  void _showSnackBar(bool isEnabled) {
    final snackBar = SnackBar(
      content: Text(
        isEnabled ? 'Notifications enabled' : 'Notifications disabled',
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    signOutUser();
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
                      awesomeMaterialBanner(
                        context: context,
                        title: 'Oh snap!',
                        message: 'Error signing out: $e',
                        contentType: ContentType.failure,
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
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dark Mode Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
              _saveSettings(darkMode: value);
              // // test to notifications
              // _notificationService.showInstantNotification(
              //   101,
              //   'Theme Changed',
              //   value ? 'Dark Mode Enabled' : 'Light Mode Enabled',
              // );
              // // ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
            },
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),

          // Notifications Toggle
          SwitchListTile(
            title: const Text('Notifications'),
            value: _notificationsEnabled ?? true,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveSettings(notificationsEnabled: value);
              _showSnackBar(value); //
            },
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),

          // Change Password
          ListTile(
            title: const Text('Change Password'),
            leading: const Icon(Icons.lock_reset),
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

          // App Version
          ListTile(
            title: const Text('App Version'),
            subtitle: Text(_appVersion),
            leading: const Icon(Icons.info),
          ),
          const Divider(),

          // Sign Out
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
