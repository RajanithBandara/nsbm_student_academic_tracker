import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _photoURL;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (userId == null) return;

    DocumentSnapshot userDoc = await _firestore.collection('student').doc(userId).collection('credentials').doc('userinfo').get();
    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      setState(() {
        _nameController.text = userData?["name"] ?? "Your Name";
        _notificationsEnabled = userData?["notificationsEnabled"] ?? true;
        _photoURL = userData?["photoURL"];
        _profileImage = _photoURL != null ? NetworkImage(_photoURL!) : const AssetImage('assets/profile_placeholder.png');
      });
    }
  }

  Future<void> _saveSettings() async {
    if (userId == null) return;

    await _firestore.collection('student').doc(userId).collection('credentials').doc('userInfo').set({
      "name": _nameController.text,
      "notificationsEnabled": _notificationsEnabled,
    }, SetOptions(merge: true));

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

  Future<void> _pickProfilePicture() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile picture update feature coming soon!")),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
