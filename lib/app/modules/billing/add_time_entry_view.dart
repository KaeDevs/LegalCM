import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:legalcm/app/data/models/time_entry_model.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/case_model.dart';
import 'add_time_entry_controller.dart';


class AddTimeEntryView extends StatelessWidget {
  const AddTimeEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddTimeEntryController());
    final caseBox = Hive.box<CaseModel>('cases');
    return Scaffold(
      appBar: AppBar(title: const Text("Add Time Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedCaseId.value,
                decoration: const InputDecoration(labelText: "Select Case"),
                items: caseBox.values.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.title),
                  );
                }).toList(),
                onChanged: (val) => controller.selectedCaseId.value = val,
                validator: (val) =>
                    val == null ? "Please select a case" : null,
              )),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.hoursController,
                decoration: const InputDecoration(
                  labelText: "Hours (e.g. 1.5)",
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) =>
                    val == null || double.tryParse(val) == null
                        ? "Enter valid number"
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.rateController,
                decoration: const InputDecoration(
                  labelText: "Rate (per hour)",
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) =>
                    val == null || double.tryParse(val) == null
                        ? "Enter valid rate"
                        : null,
              ),
              const SizedBox(height: 12),
              Obx(() => ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Date"),
                subtitle: Text(
                  "${controller.selectedDate.value.toLocal()}".split(' ')[0],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) controller.selectedDate.value = picked;
                  },
                ),
              )),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!controller.formKey.currentState!.validate()) return;
                  final timeEntry = TimeEntryModel(
                    id: const Uuid().v4(),
                    caseId: controller.selectedCaseId.value!,
                    date: controller.selectedDate.value,
                    description: controller.descController.text.trim(),
                    hours: double.parse(controller.hoursController.text),
                    rate: double.parse(controller.rateController.text),
                  );
                  await Hive.box<TimeEntryModel>('time_entries').add(timeEntry);
                  Get.back();
                  Get.snackbar("Success", "Time entry saved");
                },
                icon: const Icon(Icons.save),
                label: const Text("Save Time Entry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
