

import 'package:get/get.dart';
import 'package:legalcm/app/modules/dashboard/controller.dart';

class dashBoardBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.put(DashBoardController());
  }
}
