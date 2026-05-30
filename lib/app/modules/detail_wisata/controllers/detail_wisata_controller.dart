import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiketinnusa/app/modules/keranjang/controllers/keranjang_controller.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
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

  void goToBooking() {
    // Gunakan FirebaseService karena sudah reaktif & handle anonymous
    final svc  = FirebaseService.to;
    final user = svc.currentUser;

    // Blokir jika: belum login ATAU login sebagai tamu (anonymous)
    final belumLogin = user == null || svc.isTamu;

    if (belumLogin) {
      final pesan = svc.isTamu
          ? 'Akun tamu tidak bisa memesan tiket. Silakan daftar atau login terlebih dahulu.'
          : 'Silakan login terlebih dahulu untuk melakukan pemesanan tiket.';

      Get.snackbar(
        'Login Diperlukan',
        pesan,
        backgroundColor: const Color(0xFF1F4529),
        colorText: Colors.white,
        icon: const Icon(Icons.lock_outline, color: Colors.white),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
      Future.delayed(const Duration(milliseconds: 400), () {
        Get.toNamed(AppRoutes.LOGIN);
      });
      return;
    }

    // Sudah login dengan akun asli → lanjut ke halaman booking
    Get.toNamed(AppRoutes.BOOKING, arguments: data);
  }
}