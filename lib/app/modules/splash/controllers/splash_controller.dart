import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animController;

  @override
  void onInit() {
    super.onInit();
    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      _cekStatus();
    });
  }

  void _cekStatus() {
    final user = FirebaseService.to.currentUser;
    if (user != null) {
      // Sudah login → langsung beranda
      Get.offAllNamed(AppRoutes.BERANDA);
    } else {
      // Belum login → onboarding
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}