import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/services/destinasi_service.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FirebaseService>(
      FirebaseService(),
      permanent: true,
    );
    Get.put<DestinasiService>(
      DestinasiService(),
      permanent: true,
    );
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
  }
}