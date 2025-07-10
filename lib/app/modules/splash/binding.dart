import 'package:get/get.dart';
import 'controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    print('SplashBinding: Registering SplashController');
    Get.lazyPut<SplashController>(() => SplashController());
    print('SplashBinding: SplashController registered');
  }
} 