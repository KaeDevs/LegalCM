import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/time_entry_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/case_model.dart';

class AddInvoiceView extends StatefulWidget {
  const AddInvoiceView({super.key});

  @override
  State<AddInvoiceView> createState() => _AddInvoiceViewState();
}

class _AddInvoiceViewState extends State<AddInvoiceView> {
  String? _selectedCaseId;
  List<String> _selectedTimeEntryIds = [];
  List<String> _selectedExpenseIds = [];

  @override
  Widget build(BuildContext context) {
    final caseBox = Hive.box<CaseModel>('cases');
    final timeBox = Hive.box<TimeEntryModel>('time_entries');
    final expenseBox = Hive.box<ExpenseModel>('expenses');

    return Scaffold(
      appBar: AppBar(title: const Text("Generate Invoice")),
      body: SingleChildScrollView(
        // physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCaseId,
                decoration: const InputDecoration(labelText: "Select Case"),
                items: caseBox.values.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.title));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCaseId = val),
              ),
              const SizedBox(height: 12),
        
              if (_selectedCaseId != null) ...[
                const Text("Time Entries", style: TextStyle(fontWeight: FontWeight.bold)),
                ...timeBox.values
                    .where((t) => t.caseId == _selectedCaseId)
                    .map((t) => CheckboxListTile(
                          title: Text("${t.description} - ₹${t.total}"),
                          value: _selectedTimeEntryIds.contains(t.key.toString()),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedTimeEntryIds.add(t.key.toString());
                              } else {
                                _selectedTimeEntryIds.remove(t.key.toString());
                              }
                            });
                          },
                        )),
                const SizedBox(height: 12),
                const Text("Expenses", style: TextStyle(fontWeight: FontWeight.bold)),
                ...expenseBox.values
                    .where((e) => e.caseId == _selectedCaseId)
                    .map((e) => CheckboxListTile(
                          title: Text("${e.title} - ₹${e.amount}"),
                          value: _selectedExpenseIds.contains(e.key.toString()),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedExpenseIds.add(e.key.toString());
                              } else {
                                _selectedExpenseIds.remove(e.key.toString());
                              }
                            });
                          },
                        )),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.receipt),
                  label: const Text("Generate Invoice"),
                  onPressed: _generateInvoice,
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _generateInvoice() async {
    final timeBox = Hive.box<TimeEntryModel>('time_entries');
    final expenseBox = Hive.box<ExpenseModel>('expenses');

    final selectedTimeEntries = _selectedTimeEntryIds.map((id) =>
        timeBox.get(int.parse(id))!).toList();
    final selectedExpenses = _selectedExpenseIds.map((id) =>
        expenseBox.get(int.parse(id))!).toList();

    final totalAmount = selectedTimeEntries.fold<double>(0, (s, e) => s + e.total) +
        selectedExpenses.fold<double>(0, (s, e) => s + e.amount);

    final invoice = InvoiceModel(
      id: const Uuid().v4(),
      caseId: _selectedCaseId!,
      invoiceDate: DateTime.now(),
      isPaid: false,
      timeEntryIds: _selectedTimeEntryIds,
      expenseIds: _selectedExpenseIds,
      totalAmount: totalAmount,
    );

    final invoiceBox = await Hive.openBox<InvoiceModel>('invoices');
    await invoiceBox.add(invoice);

    Get.back();
    Get.snackbar("Success", "Invoice generated");
  }
}
