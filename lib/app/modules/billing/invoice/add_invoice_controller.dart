import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AddInvoiceController extends GetxController {
  final selectedCaseId = RxnString();
  final selectedTimeEntryIds = <String>[].obs;
  final selectedExpenseIds = <String>[].obs;
} 