import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/case_model.dart';
import '../../../data/models/expense_model.dart';
import 'add_expense_controller.dart';

class AddExpenseView extends StatelessWidget {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddExpenseController());
    final caseList = Hive.box<CaseModel>('cases').values.toList();
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedCaseId.value,
                decoration: const InputDecoration(labelText: "Select Case"),
                items: caseList.map((c) {
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
                controller: controller.titleController,
                decoration: const InputDecoration(
                  labelText: "Expense Title",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.amountController,
                decoration: const InputDecoration(
                  labelText: "Amount (\u20b9)",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) =>
                    val == null || double.tryParse(val) == null
                        ? "Enter valid amount"
                        : null,
              ),
              const SizedBox(height: 12),
              Obx(() => ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Date"),
                subtitle: Text(
                  "${controller.selectedDate.value.toLocal()}".split(" ")[0],
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
                  final expense = ExpenseModel(
                    id: const Uuid().v4(),
                    caseId: controller.selectedCaseId.value!,
                    title: controller.titleController.text.trim(),
                    amount: double.parse(controller.amountController.text),
                    date: controller.selectedDate.value,
                  );
                  await Hive.box<ExpenseModel>('expenses').add(expense);
                  Get.back();
                  Get.snackbar("Success", "Expense saved successfully");
                },
                icon: const Icon(Icons.save),
                label: const Text("Save Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
