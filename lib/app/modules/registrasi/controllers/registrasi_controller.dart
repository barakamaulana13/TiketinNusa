import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';

class RegistrasiController extends GetxController {
  final namaC      = TextEditingController();
  final emailC     = TextEditingController();
  final passwordC  = TextEditingController();
  final konfirmasiC= TextEditingController();
  final isLoading  = false.obs;

  @override
  void onClose() {
    namaC.dispose();
    emailC.dispose();
    passwordC.dispose();
    konfirmasiC.dispose();
    super.onClose();
  }

  Future<void> daftar() async {
    if (namaC.text.isEmpty || emailC.text.isEmpty ||
        passwordC.text.isEmpty || konfirmasiC.text.isEmpty) {
      Get.snackbar('Peringatan', 'Semua field wajib diisi.',
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    if (passwordC.text != konfirmasiC.text) {
      Get.snackbar('Peringatan', 'Kata sandi tidak cocok.',
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    final result = await FirebaseService.to.register(
      namaC.text.trim(),
      emailC.text.trim(),
      passwordC.text.trim(),
    );
    isLoading.value = false;

    if (result != null) {
      // Logout dulu agar user harus login manual
      await FirebaseService.to.logout();
      Get.snackbar(
        '✅ Registrasi Berhasil',
        'Silahkan masuk dengan akun Anda.',
        backgroundColor: const Color(0xFF1F4529),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      // Ke halaman Login, bukan Beranda
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  void keLogin() => Get.toNamed(AppRoutes.LOGIN);

  void handleSocialSignUp(String provider) {
    Get.snackbar('Info',
        'Daftar dengan $provider belum tersedia.',
        backgroundColor: const Color(0xFF1B3D26),
        colorText: Colors.white);
  }
}