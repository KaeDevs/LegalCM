import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/time_entry_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/case_model.dart';
import 'package:collection/collection.dart';

class InvoiceDetailView extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoiceDetailView({super.key, required this.invoice});

  @override
  State<InvoiceDetailView> createState() => _InvoiceDetailViewState();
}

class _InvoiceDetailViewState extends State<InvoiceDetailView> {
  late Box<TimeEntryModel> timeBox;
  late Box<ExpenseModel> expenseBox;
  late Box<CaseModel> caseBox;

  @override
  void initState() {
    super.initState();
    timeBox = Hive.box<TimeEntryModel>('time_entries');
    expenseBox = Hive.box<ExpenseModel>('expenses');
    caseBox = Hive.box<CaseModel>('cases');
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final caseTitle =
        caseBox.values.firstWhereOrNull((c) => c.id == invoice.caseId)?.title ??
            "Unknown Case";

    final timeEntries = invoice.timeEntryIds
        .map((id) => timeBox.get(int.tryParse(id)))
        .whereType<TimeEntryModel>()
        .toList();

    final expenses = invoice.expenseIds
        .map((id) => expenseBox.get(int.tryParse(id)))
        .whereType<ExpenseModel>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Invoice #${invoice.id.substring(0, 8)}...",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: Text("Delete Invoice", style: GoogleFonts.poppins()),
                  content: Text(
                    "Are you sure you want to delete this invoice?",
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text("Cancel", style: GoogleFonts.poppins()),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: Text("Delete",
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await invoice.delete();
                Get.back();
                Get.snackbar("Deleted", "Invoice deleted successfully");
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Case: $caseTitle",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),

            /// Time Entries Section
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.blue),
                const SizedBox(width: 8),
                Text("Time Entries",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 17)),
              ],
            ),
            const SizedBox(height: 8),
            ...timeEntries.map(
              (t) => Card(
                child: ListTile(
                  title: Text(t.description,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    "${t.date.toLocal().toString().split(' ')[0]} • ${t.hours} hrs @ ₹${t.rate}/hr",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  trailing: Text("₹${t.total.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            if (timeEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("No time entries",
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey)),
              ),

            const SizedBox(height: 24),

            /// Expenses Section
            Row(
              children: [
                const Icon(Icons.money, color: Colors.green),
                const SizedBox(width: 8),
                Text("Expenses",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 17)),
              ],
            ),
            const SizedBox(height: 8),
            ...expenses.map(
              (e) => Card(
                child: ListTile(
                  title: Text(e.title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                      "${e.date.toLocal().toString().split(' ')[0]} • ₹${e.amount.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(fontSize: 13)),
                  trailing: const Icon(Icons.receipt_long),
                ),
              ),
            ),
            if (expenses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("No expenses",
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey)),
              ),

            const Divider(height: 32),

            /// Total
            ListTile(
              title: Text("Total Amount",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              trailing: Text("₹${invoice.totalAmount.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            /// Paid Switch
            SwitchListTile(
              title: Text("Mark as Paid",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              value: invoice.isPaid,
              onChanged: (val) {
                setState(() {
                  invoice.isPaid = val;
                  invoice.save();
                });
                Get.snackbar(
                  "Updated",
                  val ? "Invoice marked as paid" : "Invoice marked as unpaid",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
