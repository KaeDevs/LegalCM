import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:legalcm/app/data/models/user_model.dart';
import 'package:legalcm/app/utils/tools.dart';
import 'package:get/get.dart';
import 'package:legalcm/app/modules/login/controller.dart';
import 'package:legalcm/app/modules/dashboard/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final theme = Theme.of(context);
    final isUserPresent = controller.user.value != null;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Tools.oswaldValue(context).copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Obx(() => isUserPresent
            ? IconButton(
                icon: Icon(controller.isEditing.value ? Icons.close : Icons.edit),
                tooltip: controller.isEditing.value ? 'Cancel' : 'Edit',
                onPressed: controller.toggleEdit,
              )
            : SizedBox.shrink()),
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
                child: Obx(() => controller.isEditing.value || !isUserPresent
                    ? Column(
                        children: [
                          Text(
                            "Enter Your Details!",
                            style: Tools.oswaldValue(context).copyWith(
                                fontSize: 24, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 24),
                          Form(
                            key: controller.formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Obx(() => Text(
                                    controller.nameController.text.isNotEmpty
                                        ? controller.nameController.text[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                        fontSize: 36, color: Colors.white),
                                  )),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: controller.nameController,
                                  decoration: const InputDecoration(labelText: 'Name'),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: controller.emailController,
                                  decoration: const InputDecoration(labelText: 'Email'),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: controller.phoneController,
                                  decoration: const InputDecoration(labelText: 'Phone'),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: controller.cityController,
                                  decoration: const InputDecoration(labelText: 'City'),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: controller.stateController,
                                  decoration: const InputDecoration(labelText: 'State'),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: controller.saveProfile,
                                  icon: const Icon(Icons.save),
                                  label: Obx(() => Text(isUserPresent ? 'Update Profile' : 'Save Profile')),
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
                            child: Obx(() => Text(
                              controller.user.value!.name.isNotEmpty
                                  ? controller.user.value!.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  fontSize: 36, color: Colors.white),
                            )),
                          ),
                          const SizedBox(height: 20),
                          Obx(() => Text(
                            controller.user.value!.name,
                            style: Tools.oswaldValue(context).copyWith(fontSize: 22),
                          )),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            controller.user.value!.email,
                            style: Tools.oswaldValue(context).copyWith(fontSize: 16, color: Colors.grey),
                          )),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            controller.user.value!.phone ?? '',
                            style: Tools.oswaldValue(context).copyWith(fontSize: 16, color: Colors.grey),
                          )),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            controller.user.value!.city ?? '',
                            style: Tools.oswaldValue(context).copyWith(fontSize: 16, color: Colors.grey),
                          )),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            controller.user.value!.state ?? '',
                            style: Tools.oswaldValue(context).copyWith(fontSize: 16, color: Colors.grey),
                          )),
                        ],
                      )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearDataLoadingDialog extends StatelessWidget {
  const _ClearDataLoadingDialog();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Clearing all your data...',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
