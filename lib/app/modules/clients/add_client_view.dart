import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/client_model.dart';

class AddClientView extends StatefulWidget {
  final ClientModel? existingClient;

  AddClientView({super.key}) : existingClient = Get.arguments;

  @override
  State<AddClientView> createState() => _AddClientViewState();
}


class _AddClientViewState extends State<AddClientView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  @override
void initState() {
  super.initState();
  if (widget.existingClient != null) {
    _nameController.text = widget.existingClient!.name;
    _contactController.text = widget.existingClient!.contactNumber;
    _emailController.text = widget.existingClient!.email;
  }
}


  void _saveClient() async {
    if (_formKey.currentState!.validate()) {
      if (widget.existingClient != null) {
        // Update existing client
        widget.existingClient!
          ..name = _nameController.text.trim()
          ..contactNumber = _contactController.text.trim()
          ..email = _emailController.text.trim();
        await widget.existingClient!.save();
        Get.back();
        Get.snackbar('Updated', 'Client updated successfully');
      } else {
        // Add new client
        final newClient = ClientModel(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          contactNumber: _contactController.text.trim(),
          email: _emailController.text.trim(),
        );
        final box = Hive.box<ClientModel>('clients');
        await box.add(newClient);
        Get.back();
        Get.snackbar('Success', 'Client added successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingClient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Client' : 'Add Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveClient,
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Update Client' : 'Save Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
