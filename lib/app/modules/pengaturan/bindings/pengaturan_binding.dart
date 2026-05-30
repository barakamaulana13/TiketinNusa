import 'package:get/get.dart';
import '../controllers/pengaturan_controller.dart';

class PengaturanBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PengaturanController>(PengaturanController(), permanent: true);
  }
}