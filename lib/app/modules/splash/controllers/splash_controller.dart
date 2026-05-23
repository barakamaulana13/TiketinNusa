import 'package:flutter/widgets.dart';
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
      _cekStatusLogin();
    });
  }

  void _cekStatusLogin() {
    final user = FirebaseService.to.currentUser;
    if (user != null) {
      Get.offAllNamed(AppRoutes.BERANDA);
    } else {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
  }
}
