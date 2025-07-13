

import 'package:get/get.dart';
import 'package:legalcm/app/modules/dashboard/controller.dart';

class DashBoardBinding extends Bindings{
  @override
  void dependencies() {
    
    Get.put(DashBoardController());
  }
}
