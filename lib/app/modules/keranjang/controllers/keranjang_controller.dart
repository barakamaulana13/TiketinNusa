import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';

class KeranjangController extends GetxController {
  final savedItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenSimpanan();
  }

  void _listenSimpanan() {
    FirebaseService.to.streamSimpanan().listen((data) {
      savedItems.value = data;
    });
  }

  Future<void> toggleSave(Map<String, dynamic> item) async {
    // Cek login
    if (FirebaseService.to.currentUser == null) {
      _showLoginDialog();
      return;
    }

    final isSaved = savedItems
        .any((e) => e['nama'] == item['nama']);
    if (isSaved) {
      await FirebaseService.to
          .hapusSimpanan(item['nama']);
      Get.snackbar(
        '🗑️ Dihapus dari Simpanan',
        '${item['nama']} dihapus dari daftar simpanan',
        backgroundColor: const Color(0xFF1F4529),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 2),
      );
    } else {
      await FirebaseService.to.simpanDestinasi(item);
      Get.snackbar(
        '✅ Tersimpan',
        '${item['nama']} ditambahkan ke simpanan',
        backgroundColor: const Color(0xFF1F4529),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 2),
      );
    }
  }

  bool isSaved(String nama) =>
      savedItems.any((e) => e['nama'] == nama);

  void _showLoginDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Login Diperlukan'),
        content: const Text(
          'Silahkan login atau daftar untuk menyimpan destinasi.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Nanti',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.LOGIN);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F4529),
            ),
            child: const Text('Login',
                style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.REGISTRASI);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F4529),
            ),
            child: const Text('Daftar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}