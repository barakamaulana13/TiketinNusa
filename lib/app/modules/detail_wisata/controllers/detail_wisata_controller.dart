import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/keranjang/controllers/keranjang_controller.dart';
import 'dart:ui';
import 'package:tiketinnusa/app/routes/app_routes.dart';

class DetailWisataController extends GetxController {
  late Map<String, dynamic> data;

  @override
  void onInit() {
    super.onInit();
    // Data sudah lengkap dari Firebase via argument
    data = Get.arguments as Map<String, dynamic>;
  }

  void toggleSave() {
    Get.find<KeranjangController>().toggleSave(data);
    final isSaved =
        Get.find<KeranjangController>().isSaved(data['nama']);
    Get.snackbar(
      isSaved ? '✅ Disimpan' : '🗑️ Dihapus',
      isSaved
          ? '${data['nama']} ditambahkan ke simpanan'
          : '${data['nama']} dihapus dari simpanan',
      duration: const Duration(seconds: 1),
      backgroundColor: const Color(0xFF1F4529),
      colorText: const Color(0xFFFFFFFF),
    );
  }

  void goToBooking() =>
      Get.toNamed(AppRoutes.BOOKING, arguments: data);
}