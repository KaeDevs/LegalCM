import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/case_model.dart';
import 'invoiceDetailView.dart';
import 'package:collection/collection.dart';
class InvoiceListView extends StatelessWidget {
  const InvoiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceBox = Hive.box<InvoiceModel>('invoices');
    final caseBox = Hive.box<CaseModel>('cases');

    return Scaffold(
      appBar: AppBar(title: const Text("Invoices")),
      body: ValueListenableBuilder(
        valueListenable: invoiceBox.listenable(),
        builder: (context, Box<InvoiceModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No invoices created yet"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final invoice = box.getAt(index)!;
              final caseTitle = caseBox.values
    .firstWhereOrNull((c) => c.id == invoice.caseId)
    ?.title ?? "Unknown Case";


              return ListTile(
                title: Text("Invoice #${invoice.id}"),
                subtitle: Text(
                  "$caseTitle\nDate: ${invoice.invoiceDate.toLocal().toString().split(' ')[0]}\nTotal: ₹${invoice.totalAmount.toStringAsFixed(2)}",
                ),
                trailing: Icon(
                  invoice.isPaid ? Icons.check_circle : Icons.pending,
                  color: invoice.isPaid ? Colors.green : Colors.orange,
                ),
                isThreeLine: true,
                onTap: () {
  Get.to(() => InvoiceDetailView(invoice: invoice));
},

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
