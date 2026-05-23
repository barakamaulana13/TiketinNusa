import 'package:get/get.dart';
import '../controllers/keranjang_controller.dart';

class KeranjangBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<KeranjangController>(KeranjangController(), permanent: true);
  }
}