import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _nameController = TextEditingController();
  bool _notificationsEnabled = true;
  ImageProvider? _profileImage;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? "Your Name";
    if (user?.photoURL != null) {
      _profileImage = NetworkImage(user!.photoURL!);
    } else {
      _profileImage = const AssetImage('assets/profile_placeholder.png');
    }
  }

  // Simulate picking a new profile picture.
  Future<void> _pickProfilePicture() async {

    setState(() {
      _profileImage = const AssetImage('assets/new_profile.png');
    });
  }

  Future<void> _saveSettings() async {
    // Here you would save the settings to your backend or local storage.
    debugPrint(
        "Saving settings: Name: ${_nameController.text}, Notifications: $_notificationsEnabled");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: _pickProfilePicture,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Change Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              "Notifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
