import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';

class ProfilController extends GetxController {
  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController phoneC;

  PengaturanController get _pCtrl =>
      Get.find<PengaturanController>();

  @override
  void onInit() {
    super.onInit();
    nameC  = TextEditingController(text: _pCtrl.name.value);
    emailC = TextEditingController(text: _pCtrl.email.value);
    phoneC = TextEditingController(text: _pCtrl.phone.value);
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    phoneC.dispose();
    super.onClose();
  }

  Future<void> simpanPerubahan() async {
    await _pCtrl.updateProfile(
        nameC.text, emailC.text, phoneC.text);
    Get.snackbar(
      'Sukses',
      'Profil berhasil diperbarui!',
      backgroundColor: const Color(0xFF1F4529),
      colorText: Colors.white,
    );
    Get.back();
  }

  // ── LOGOUT — kembali ke splash, firebase sign out
  Future<void> keluar() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text(
            'Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await FirebaseService.to.logout();
              // Hapus semua state lalu ke onboarding
              Get.deleteAll(force: true);
              Get.offAllNamed(AppRoutes.ONBOARDING);
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ── HAPUS AKUN
  void hapusAkun() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
            'Akun Anda akan dihapus permanen dan tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: _konfirmasiHapus,
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _konfirmasiHapus() async {
    Get.back();
    try {
      await FirebaseService.to.deleteAccount();
      Get.deleteAll(force: true);
      Get.offAllNamed(AppRoutes.ONBOARDING);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menghapus akun. Coba login ulang terlebih dahulu.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}