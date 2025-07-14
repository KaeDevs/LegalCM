import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/client_model.dart';
import 'controller.dart';

class AddClientView extends StatelessWidget {
  AddClientView({super.key});
  final controller = Get.put(ClientsController());

  @override
  Widget build(BuildContext context) {
    final isEditing = Get.arguments != null;
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _contactController = TextEditingController();
    final _emailController = TextEditingController();
    final _cityController = TextEditingController();
    final _stateController = TextEditingController();
    final existingClient = Get.arguments as ClientModel?;
    if (existingClient != null) {
      _nameController.text = existingClient.name;
      _contactController.text = existingClient.contactNumber;
      _emailController.text = existingClient.email;
      _cityController.text = existingClient.city;
      _stateController.text = existingClient.state;
    }
    void _saveClient() async {
      if (_formKey.currentState!.validate()) {
        if (existingClient != null) {
          existingClient
            ..name = _nameController.text.trim()
            ..contactNumber = _contactController.text.trim()
            ..email = _emailController.text.trim()
            ..city = _cityController.text.trim()
            ..state = _stateController.text.trim();
          await existingClient.save();
          Get.back();
          Get.snackbar('Updated', 'Client updated successfully');
        } else {
          final newClient = ClientModel(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
            contactNumber: _contactController.text.trim(),
            email: _emailController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
          );
          final box = Hive.box<ClientModel>('clients');
          await box.add(newClient);
          Get.back();
          Get.snackbar('Success', 'Client added successfully');
        }
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                keyboardType: TextInputType.numberWithOptions(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveClient,
                icon: Icon(Icons.save, color: Theme.of(context).colorScheme.onPrimary, size: 24, ),
                label: Text(isEditing ? 'Update Client' : 'Save Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
