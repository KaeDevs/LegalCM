import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';

import '../../../data/models/invoice_model.dart';
import '../../../data/models/case_model.dart';
import 'invoiceDetailView.dart';

class InvoiceListView extends StatelessWidget {
  const InvoiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("📄 Invoices", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<InvoiceModel>('invoices').listenable(),
        builder: (context, Box<InvoiceModel> box, _) {
          final caseBox = Hive.box<CaseModel>('cases');

          if (box.isEmpty) {
            return Center(
              child: Text(
                "No invoices created yet",
                style: GoogleFonts.poppins(fontSize: 16, color: theme.hintColor),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final invoice = box.getAt(index)!;
              final caseTitle = caseBox.values
                      .firstWhereOrNull((c) => c.id == invoice.caseId)
                      ?.title ??
                  "Unknown Case";

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                color: theme.cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    "Invoice #${invoice.id}",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "$caseTitle\nDate: ${invoice.invoiceDate.toLocal().toString().split(' ')[0]}\nTotal: ₹${invoice.totalAmount.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(fontSize: 15, height: 1.4),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: Icon(
                    invoice.isPaid ? Icons.check_circle : Icons.pending,
                    color: invoice.isPaid ? Colors.green : Colors.orange,
                    size: 28,
                  ),
                  onTap: () => Get.to(() => InvoiceDetailView(invoice: invoice)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-invoice'),
        icon: const Icon(Icons.add),
        label: const Text("Create Invoice"),
      ),
    );
  }
}
