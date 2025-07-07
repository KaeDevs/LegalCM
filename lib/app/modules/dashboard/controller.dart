

import 'package:get/get.dart';

import '../tasks/task_controller.dart';

class DashBoardController extends GetxController{
  @override
  void onInit() {
    // TODO: implement onInit
    print("start dashboard");
    Get.put(TaskController());

    super.onInit();
  }
}