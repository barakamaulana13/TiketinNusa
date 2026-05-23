import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final pages = [
    {'title': 'Selamat Datang Di', 'brand': 'TiketinNusa', 'image': 'assets/Group 18.png'},
    {'title': 'Kami Punya Banyak Tempat Menarik Yang Dapat Anda Kunjungi', 'brand': '', 'image': 'assets/gambar 2.png'},
    {'title': 'Ayo Mulai Perjalanan Anda Bersama Kami', 'brand': '', 'image': 'assets/gambar 3.png'},
  ];

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Get.toNamed(AppRoutes.REGISTRASI);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}