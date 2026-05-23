import 'package:get/get.dart';
import '../controllers/notifikasi_controller.dart';

class NotifikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NotifikasiController>(NotifikasiController(), permanent: true);
  }
}