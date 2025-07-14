import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/time_entry_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/case_model.dart';
import 'add_invoice_controller.dart';

class AddInvoiceView extends StatelessWidget {
  const AddInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddInvoiceController());
    final caseBox = Hive.box<CaseModel>('cases');
    final timeBox = Hive.box<TimeEntryModel>('time_entries');
    final expenseBox = Hive.box<ExpenseModel>('expenses');

    return Scaffold(
      appBar: AppBar(title: const Text("Generate Invoice")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedCaseId.value,
                decoration: const InputDecoration(labelText: "Select Case"),
                items: caseBox.values.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.title));
                }).toList(),
                onChanged: (val) => controller.selectedCaseId.value = val,
              )),
              const SizedBox(height: 12),
              Obx(() => controller.selectedCaseId.value != null ? Column(
                children: [
                  const Text("Time Entries", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...timeBox.values
                      .where((t) => t.caseId == controller.selectedCaseId.value)
                      .map((t) => Obx(() => CheckboxListTile(
                            title: Text("${t.description} - 9${t.total}"),
                            value: controller.selectedTimeEntryIds.contains(t.key.toString()),
                            onChanged: (v) {
                              if (v == true) {
                                controller.selectedTimeEntryIds.add(t.key.toString());
                              } else {
                                controller.selectedTimeEntryIds.remove(t.key.toString());
                              }
                            },
                          ))),
                  const SizedBox(height: 12),
                  const Text("Expenses", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...expenseBox.values
                      .where((e) => e.caseId == controller.selectedCaseId.value)
                      .map((e) => Obx(() => CheckboxListTile(
                            title: Text("${e.title} - 9${e.amount}"),
                            value: controller.selectedExpenseIds.contains(e.key.toString()),
                            onChanged: (v) {
                              if (v == true) {
                                controller.selectedExpenseIds.add(e.key.toString());
                              } else {
                                controller.selectedExpenseIds.remove(e.key.toString());
                              }
                            },
                          ))),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.receipt),
                    label: const Text("Generate Invoice"),
                    onPressed: () => _generateInvoice(controller),
                  )
                ],
              ) : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  void _generateInvoice(AddInvoiceController controller) async {
    final timeBox = Hive.box<TimeEntryModel>('time_entries');
    final expenseBox = Hive.box<ExpenseModel>('expenses');

    final selectedTimeEntries = controller.selectedTimeEntryIds.map((id) =>
        timeBox.get(int.parse(id))!).toList();
    final selectedExpenses = controller.selectedExpenseIds.map((id) =>
        expenseBox.get(int.parse(id))!).toList();

    final totalAmount = selectedTimeEntries.fold<double>(0, (s, e) => s + e.total) +
        selectedExpenses.fold<double>(0, (s, e) => s + e.amount);

    final invoice = InvoiceModel(
      id: const Uuid().v4(),
      caseId: controller.selectedCaseId.value!,
      invoiceDate: DateTime.now(),
      isPaid: false,
      timeEntryIds: controller.selectedTimeEntryIds.toList(),
      expenseIds: controller.selectedExpenseIds.toList(),
      totalAmount: totalAmount,
    );

    final invoiceBox = await Hive.openBox<InvoiceModel>('invoices');
    await invoiceBox.add(invoice);

    Get.back();
    Get.snackbar("Success", "Invoice generated");
  }
}
