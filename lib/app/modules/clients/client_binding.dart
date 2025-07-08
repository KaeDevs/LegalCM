import 'package:get/get.dart';

import 'controller.dart';

class ClientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientsController());
  }
}