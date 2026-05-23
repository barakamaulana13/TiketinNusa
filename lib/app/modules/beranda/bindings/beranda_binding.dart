import 'package:get/get.dart';
import '../controllers/beranda_controller.dart';
import '../../tiket/controllers/tiket_controller.dart';
import '../../keranjang/controllers/keranjang_controller.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';
import '../../pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/services/destinasi_service.dart';

class BerandaBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FirebaseService>()) {
      Get.put<FirebaseService>(FirebaseService(), permanent: true);
    }
    if (!Get.isRegistered<DestinasiService>()) {
      Get.put<DestinasiService>(DestinasiService(), permanent: true);
    }
    if (!Get.isRegistered<PengaturanController>()) {
      Get.put<PengaturanController>(PengaturanController(), permanent: true);
    }
    if (!Get.isRegistered<TiketController>()) {
      Get.put<TiketController>(TiketController(), permanent: true);
    }
    if (!Get.isRegistered<KeranjangController>()) {
      Get.put<KeranjangController>(KeranjangController(), permanent: true);
    }
    if (!Get.isRegistered<NotifikasiController>()) {
      Get.put<NotifikasiController>(NotifikasiController(), permanent: true);
    }
    Get.lazyPut<BerandaController>(() => BerandaController());
  }
}