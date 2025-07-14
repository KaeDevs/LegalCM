import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:legalcm/app/data/models/user_model.dart';

class ProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  final user = Rxn<UserModel>();
  final isEditing = false.obs;
  late Box<UserModel> userBox;

  @override
  void onInit() {
    super.onInit();
    userBox = Hive.box<UserModel>('user');
    if (userBox.isNotEmpty) {
      user.value = userBox.getAt(0);
      _setControllersFromUser();
    }
  }

  void _setControllersFromUser() {
    if (user.value != null) {
      nameController.text = user.value!.name;
      emailController.text = user.value!.email;
      phoneController.text = user.value!.phone ?? '';
      cityController.text = user.value!.city ?? '';
      stateController.text = user.value!.state ?? '';
    }
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) _setControllersFromUser();
  }

  void saveProfile() async {
    if (formKey.currentState!.validate()) {
      final newUser = UserModel(
        id: user.value?.id ?? '',
        createdAt: user.value?.createdAt ?? DateTime.now(),
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
      );
      if (userBox.isEmpty) {
        await userBox.add(newUser);
      } else {
        await userBox.putAt(0, newUser);
      }
      user.value = newUser;
      isEditing.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.onClose();
  }
} 