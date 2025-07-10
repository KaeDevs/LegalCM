import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:legalcm/app/data/models/user_model.dart';
import 'package:legalcm/app/utils/tools.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Box<UserModel> userBox;
  UserModel? user;
  bool isEditing = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<UserModel>('user');
    if (userBox.isNotEmpty) {
      user = userBox.getAt(0);
      _setControllersFromUser();
    }
  }

  void _setControllersFromUser() {
    if (user != null) {
      _nameController.text = user!.name;
      _emailController.text = user!.email;
      _phoneController.text = user!.phone ?? '';
      _cityController.text = user!.city ?? '';
      _stateController.text = user!.state ?? '';
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        id: user?.id ?? '',
        createdAt: user?.createdAt ?? DateTime.now(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
      );
      if (userBox.isEmpty) {
        await userBox.add(newUser);
      } else {
        await userBox.putAt(0, newUser);
      }
      setState(() {
        user = newUser;
        isEditing = false;
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Profile saved!')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserPresent = user != null;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Tools.oswaldValue(context).copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          if (isUserPresent)
            IconButton(
              icon: Icon(isEditing ? Icons.close : Icons.edit),
              tooltip: isEditing ? 'Cancel' : 'Edit',
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                  if (!isEditing) _setControllersFromUser();
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: isEditing || !isUserPresent
                    ? Column(
                      children: [
                        Text(
                          "Enter Your Details!",
                          style: Tools.oswaldValue(context).copyWith(fontSize: 24, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 24),
                        Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Text(
                                    _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U',
                                    style: const TextStyle(fontSize: 36, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(labelText: 'Name'),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(labelText: 'Email'),
                                  keyboardType: TextInputType.emailAddress,
                                  // validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(labelText: 'Phone'),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _cityController,
                                  decoration: const InputDecoration(labelText: 'City'),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _stateController,
                                  decoration: const InputDecoration(labelText: 'State'),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _saveProfile,
                                  icon: const Icon(Icons.save),
                                  label: Text(isUserPresent ? 'Update Profile' : 'Save Profile'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              user!.name.isNotEmpty ? user!.name[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 36, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user!.name,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user!.email,
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 16),
                          Divider(),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: Icon(Icons.phone, color: theme.colorScheme.primary),
                            title: const Text('Phone'),
                            subtitle: Text(user!.phone ?? ''),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_city, color: theme.colorScheme.primary),
                            title: const Text('City'),
                            subtitle: Text(user!.city ?? ''),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_on, color: theme.colorScheme.primary),
                            title: const Text('State'),
                            subtitle: Text(user!.state ?? ''),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 