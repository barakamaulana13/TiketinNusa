import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/modules/tiket/controllers/tiket_controller.dart';
import 'package:tiketinnusa/app/modules/keranjang/controllers/keranjang_controller.dart';
import 'package:tiketinnusa/app/modules/notifikasi/controllers/notifikasi_controller.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';

class LoginController extends GetxController {
  final emailC    = TextEditingController();
  final passwordC = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  Future<void> masuk() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Email dan kata sandi wajib diisi.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    isLoading.value = true;
    try {
      final result = await FirebaseService.to
          .login(emailC.text.trim(), passwordC.text.trim())
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          Get.snackbar('Timeout', 'Koneksi lambat. Coba lagi.',
              backgroundColor: Colors.orange,
              colorText: Colors.white);
          return null;
        },
      );
      if (result != null) {
        await _reloadSemua();
        // Jika sudah ada beranda di stack, back saja
        // Jika belum, navigate ke beranda
        if (Get.previousRoute == AppRoutes.BERANDA ||
            Get.currentRoute == AppRoutes.BERANDA) {
          Get.back(); // kembali ke beranda
        } else {
          Get.offAllNamed(AppRoutes.BERANDA);
        }
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan. Coba lagi.',
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _reloadSemua() async {
    // Reload profil
    if (Get.isRegistered<PengaturanController>()) {
      await Get.find<PengaturanController>().reloadAfterLogin();
    }
    // Reload tiket stream
    if (Get.isRegistered<TiketController>()) {
      Get.find<TiketController>().onInit();
    }
    // Reload keranjang stream
    if (Get.isRegistered<KeranjangController>()) {
      Get.find<KeranjangController>().onInit();
    }
    // Reload notifikasi stream
    if (Get.isRegistered<NotifikasiController>()) {
      Get.find<NotifikasiController>().onInit();
    }
  }

  void keRegistrasi() => Get.toNamed(AppRoutes.REGISTRASI);
}