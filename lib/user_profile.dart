import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/settings.dart';
import 'package:flutter_at_akira_menai/signup_page.dart';
import 'package:flutter_at_akira_menai/widgets/auth_manager.dart';
import 'package:flutter_at_akira_menai/widgets/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

Future<String> saveImageToAppDirectory(XFile image) async {
  final appDir = await getApplicationDocumentsDirectory();
  final filename = p.basename(image.path);
  final savedImage = await File(image.path).copy('${appDir.path}/$filename');
  return savedImage.path;
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  User? user = FirebaseAuth.instance.currentUser;
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAvatarImage();
  }

  Future<void> _loadAvatarImage() async {
    final avatarPath = Hive.box('images').get('AvatarPath');
    if (avatarPath != null) {
      final avatarFile = File(avatarPath);
      if (await avatarFile.exists()) {
        setState(() {
          _avatarImage = avatarFile;
        });
      }
    }
  }

  Future<void> _pickAvatarImage() async {
    final status =
        Platform.isAndroid
            ? await Permission.storage.request()
            : await Permission.photos.request();

    if (!status.isGranted) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final savedPath = await saveImageToAppDirectory(image);
      Hive.box('images').put('AvatarPath', savedPath);
      setState(() {
        _avatarImage = File(savedPath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {

          await user?.reload();
          final refreshedUser = FirebaseAuth.instance.currentUser;

          setState(() {
            user = refreshedUser;
          });
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SafeArea(
                  child: const Text(
                    "User Profile",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
            
                // Avatar Image
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight,
                        border: Border.all(
                          color: AppColors.primaryLight,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 90,
            
                        backgroundImage:
                            _avatarImage != null
                                ? FileImage(_avatarImage!)
                                : null,
                        backgroundColor: Colors.grey[800],
                        child:
                            _avatarImage == null
                                ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 70,
                                )
                                : null,
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: GestureDetector(
                        onTap: _pickAvatarImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryLight,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // User Name and Email
                Text(
                  (user?.displayName?.isNotEmpty ?? false)
                      ? user!.displayName!
                      : 'Anynomous',
                ),
                Text(
                  user?.email ?? 'No email provided',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                // List of Tiles
                ListTile(
                  leading: const Icon(Icons.settings, size: 30),
                  title: const Text('Settings'),
                  onTap: () {
                    // Navigate to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, size: 30),
                  title: const Text('About Us'),
                  onTap: () {
                    //To Do : Handle About Us action
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_mail, size: 30),
                  title: const Text('Contact Us'),
                  onTap: () {
                    //To Do : Handle Contact Us action
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 30,
                  ),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    signOutUser();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
