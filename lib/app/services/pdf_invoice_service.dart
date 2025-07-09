import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:hive/hive.dart';
import '../data/models/case_model.dart';
import '../data/models/expense_model.dart';
import '../data/models/invoice_model.dart';
import '../data/models/time_entry_model.dart';

class PdfInvoiceService {
  static Future<Uint8List> generate(InvoiceModel invoice) async {
    final fontData = await rootBundle.load("fonts/poppins.ttf");
    final font = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    final caseBox = Hive.box<CaseModel>('cases');
    final timeBox = Hive.box<TimeEntryModel>('time_entries');
    final expenseBox = Hive.box<ExpenseModel>('expenses');

    final caseModel = caseBox.values.firstWhere((c) => c.id == invoice.caseId);
    final timeEntries = invoice.timeEntryIds
        .map((id) => timeBox.get(int.parse(id)))
        .whereType<TimeEntryModel>()
        .toList();
    final expenses = invoice.expenseIds
        .map((id) => expenseBox.get(int.parse(id)))
        .whereType<ExpenseModel>()
        .toList();

    final indigo = PdfColors.indigo;

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("LegalCM Invoice",
                style: pw.TextStyle(
                    font: font, fontSize: 26, fontWeight: pw.FontWeight.bold, color: indigo)),
            pw.SizedBox(height: 8),
            pw.Text("Invoice ID: ${invoice.id}",
                style: pw.TextStyle(font: font, fontSize: 14)),
            pw.Text("Date: ${invoice.invoiceDate.toLocal().toString().split(' ')[0]}",
                style: pw.TextStyle(font: font, fontSize: 14)),
            pw.SizedBox(height: 16),
            // pw.Text("Client: [Client Name Here]",
            //     style: pw.TextStyle(font: font, fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text("Case: ${caseModel.title}",
                style: pw.TextStyle(font: font, fontSize: 14)),
            pw.SizedBox(height: 24),

            pw.Text("Time Entries",
                style: pw.TextStyle(font: font, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            ...timeEntries.map((t) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text(t.description, style: pw.TextStyle(font: font))),
                pw.Text("${t.hours}h × ₹${t.rate} = ₹${t.total}", style: pw.TextStyle(font: font)),
              ],
            )),
            pw.SizedBox(height: 12),

            pw.Text("Expenses",
                style: pw.TextStyle(font: font, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            ...expenses.map((e) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text(e.title, style: pw.TextStyle(font: font))),
                pw.Text("₹${e.amount}", style: pw.TextStyle(font: font)),
              ],
            )),
            pw.SizedBox(height: 12),

            pw.Divider(),

           
            pw.SizedBox(height: 6),

            // Total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total", style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.Text("₹${invoice.totalAmount.toStringAsFixed(2)}",
                    style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, fontSize: 14)),
              ],
            ),

            pw.Spacer(),

            // Footer
            pw.Divider(),
            pw.Center(
              child: pw.Text("Generated using LegalCM App",
                  style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey)),
            )
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
