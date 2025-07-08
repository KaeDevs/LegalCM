

import 'package:get/get.dart';

import 'controller.dart';

class CaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CasesController());
  }
}