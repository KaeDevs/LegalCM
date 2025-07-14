import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AddTimeEntryController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final descController = TextEditingController();
  final hoursController = TextEditingController();
  final rateController = TextEditingController();
  final selectedCaseId = RxnString();
  final selectedDate = DateTime.now().obs;
} 