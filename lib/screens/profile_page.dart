import 'package:flutter/material.dart';
import 'package:my_movie_recommender_app/userprofile.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const ProfilePage({Key? key, required this.userProfile}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.userProfile.name;
    print('userProfile: ${widget.userProfile}');
    print('_name: $_name');
    print('_name in initState: $_name');
  }

  void _navigateToEditProfile() async {
    final editedProfileData = await Navigator.pushNamed(
      context,
      '/editProfile',
      arguments: widget.userProfile,
    ) as Map<String, String>?;

    if (editedProfileData != null) {
      setState(() {
        _name = editedProfileData['name'] ??
            _name; // Use the edited name or keep the current name
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('userProfile: ${widget.userProfile}');
    print('_name in build: $_name');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
            ),
            const SizedBox(height: 16),
            Text(
              _name, // Display custom display name or placeholder
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String name;

  const EditProfilePage({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  bool _nameAlreadySet = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    // Check if the name is already set
    _nameAlreadySet = widget.name.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  void _saveChanges() {
    final name = _nameController.text;
    // Create a Map to send back the edited data
    final editedProfileData = {
      'name': name,
    };

    // Return the data back to the previous screen
    Navigator.pop(context, editedProfileData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                // Disable the text field if the name is already set
                enabled: !_nameAlreadySet,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _nameAlreadySet ? null : _saveChanges,
              child:
                  Text(_nameAlreadySet ? 'Name Already Set' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
