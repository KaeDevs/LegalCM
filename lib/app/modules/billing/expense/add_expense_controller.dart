import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AddExpenseController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final selectedCaseId = RxnString();
  final selectedDate = DateTime.now().obs;
} 