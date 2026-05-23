import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
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
      Get.snackbar('Peringatan',
          'Email dan kata sandi wajib diisi.',
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    final result = await FirebaseService.to.login(
      emailC.text.trim(),
      passwordC.text.trim(),
    );
    isLoading.value = false;
    if (result != null) Get.offAllNamed(AppRoutes.BERANDA);
  }

  Future<void> masukTamu() async {
    isLoading.value = true;
    final result = await FirebaseService.to.loginTamu();
    isLoading.value = false;
    if (result != null) Get.offAllNamed(AppRoutes.BERANDA);
  }

  void keRegistrasi() => Get.toNamed(AppRoutes.REGISTRASI);
}