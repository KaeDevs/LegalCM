import 'package:get/get.dart';
import 'controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionController>(() => SubscriptionController());
  }
} 