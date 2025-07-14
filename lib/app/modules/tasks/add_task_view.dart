import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../data/models/task_model.dart';
import '../../data/models/case_model.dart';
import 'task_controller.dart';

class AddTaskView extends StatelessWidget {
  const AddTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskController>();
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descController = TextEditingController();
    final _dueDate = Rx<DateTime>(DateTime.now());
    final _selectedCaseId = RxnString();
    final caseList = Hive.box<CaseModel>('cases').values.toList();

    Future<void> _pickDateTime() async {
      final date = await showDatePicker(
        context: context,
        initialDate: _dueDate.value,
        firstDate: DateTime.now().add(const Duration(minutes: 2)),
        lastDate: DateTime(2100),
      );
      if (date == null) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate.value),
      );
      if (time == null) return;
      _dueDate.value = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    void _saveTask() async {
      if (!_formKey.currentState!.validate()) return;
      final id = DateTime.now().millisecondsSinceEpoch.remainder(1000000000);
      final task = TaskModel(
        id: id.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _dueDate.value,
        hasReminder: false,
        linkedCaseId: _selectedCaseId.value,
        isCompleted: false,
      );
      await Hive.box<TaskModel>('tasks').add(task);
      Get.back();
      Get.snackbar("Success", "Task added successfully!");
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Obx(() => ListTile(
                title: const Text("Due Date"),
                subtitle: Text("${_dueDate.value.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              )),
              Obx(() => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Link to Case"),
                value: _selectedCaseId.value,
                items: caseList.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.title),
                  );
                }).toList(),
                onChanged: (val) => _selectedCaseId.value = val,
              )),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveTask,
                icon: const Icon(Icons.save),
                label: const Text("Save Task"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
