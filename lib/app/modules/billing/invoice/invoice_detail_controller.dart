import 'package:get/get.dart';
import '../../../data/models/invoice_model.dart';

class InvoiceDetailController extends GetxController {
  late InvoiceModel invoice;
  final isPaid = false.obs;

  void setInvoice(InvoiceModel inv) {
    invoice = inv;
    isPaid.value = inv.isPaid;
  }

  void togglePaid() {
    isPaid.value = !isPaid.value;
    invoice.isPaid = isPaid.value;
    invoice.save();
  }
} 