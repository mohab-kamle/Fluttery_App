import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<String> saveImageToAppDirectory(XFile image) async {
  final appDir = await getApplicationDocumentsDirectory();
  final filename = p.basename(image.path); // keep original file name
  final savedImage = await File(image.path).copy('${appDir.path}/$filename');
  return savedImage.path; // now safe to store in Hive
}

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  User? user = FirebaseAuth.instance.currentUser;
  File? _avatarImage;
  File? _backgroundImage;
  final ImagePicker _picker = ImagePicker();

@override
void dispose() {
  Hive.box('images').close();
  super.dispose();
}

  // Load the image paths when the profile is loaded
  @override
  void initState() {
    super.initState();
    _loadProfileImages();
  }

  // Function to load images from Hive storage
  Future<void> _loadProfileImages() async {
    final avatarPath = Hive.box('images').get('AvatarPath');
    final backgroundPath = Hive.box('images').get('BackgroundPath');

    if (avatarPath != null) {
      final avatarFile = File(avatarPath);
      if (await avatarFile.exists()) {
        setState(() {
          _avatarImage = avatarFile;
        });
      }
    }

    if (backgroundPath != null) {
      final backgroundFile = File(backgroundPath);
      if (await backgroundFile.exists()) {
        setState(() {
          _backgroundImage = backgroundFile;
        });
      }
    }
  }
  Future<void> _pickImage(bool isAvatar) async {
  final status = Platform.isAndroid
      ? await Permission.storage.request()
      : await Permission.photos.request();

  if (!status.isGranted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied. Please enable media access.'),
        ),
      );
    }
    return;
    
  }

  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    // Get the current path from Hive
    String? currentPath;
    if (isAvatar) {
      currentPath = Hive.box('images').get('AvatarPath');
    } else {
      currentPath = Hive.box('images').get('BackgroundPath');
    }

    // If the path exists, delete the old file
    if (currentPath != null) {
      final oldImage = File(currentPath);
      if (await oldImage.exists()) {
        await oldImage.delete();
      }
    }

    // Save the new image
    String savedPath = await saveImageToAppDirectory(image);

    // Update the saved path in Hive
    if (isAvatar) {
      setState(() {
  _avatarImage = File(image.path);
});
      Hive.box('images').put('AvatarPath', savedPath);
    } else {
      setState(() {
  _backgroundImage = File(image.path);
});
      Hive.box('images').put('BackgroundPath', savedPath);
    }
  }
}


  Widget _buildUserInfo() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 30),
         // Space for avatar overflow
        Center(
          child: Text(
            user?.displayName ?? 'Anonymous User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            user?.email ?? 'No email provided',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard('Account Information', [
          InfoRow(
            'Email Verified',
            user?.emailVerified ?? false ? 'Yes' : 'No',
          ),
          InfoRow(
            'Created At',
            user?.metadata.creationTime?.toString() ?? 'Not available',
          ),
          InfoRow(
            'Last Sign In',
            user?.metadata.lastSignInTime?.toString() ?? 'Not available',
          ),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Authentication', [
          InfoRow(
            'Provider ID',
            user?.providerData.firstOrNull?.providerId ?? 'Not available',
          ),
          InfoRow(
            'Sign-in Method',
            user?.providerData.firstOrNull?.providerId ?? 'Not available',
          ),
        ]),
      ]),
    );
  }

  Widget _buildInfoCard(String title, List<InfoRow> rows) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(row.label), Text(row.value)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            user = FirebaseAuth.instance.currentUser;
          });
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: Colors.transparent,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return FlexibleSpaceBar(
                    background: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _pickImage(false),
                          child: _backgroundImage != null
                              ? Image.file(
                                _backgroundImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                              : Image.asset(
                                'assets/images/profile_background.png',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                        ),
                        Positioned(
                          bottom: -100,
                          child: Hero(
                            tag: 'profileAvatar',
                            child: CircleAvatar(
                              radius: 110,
                              backgroundColor: Colors.black,
                              child: GestureDetector(
                                onTap: () => _pickImage(true),
                                child: ClipOval(
                                  child:
                                      _avatarImage != null
                                          ? Image.file(
                                            _avatarImage!,
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          )
                                          : Image.asset(
                                            'assets/images/profile_avatar.jpeg',
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildUserInfo(),
          ],
        ),
      ),
    );
  }
}

class InfoRow {
  final String label;
  final String value;

  InfoRow(this.label, this.value);
}
