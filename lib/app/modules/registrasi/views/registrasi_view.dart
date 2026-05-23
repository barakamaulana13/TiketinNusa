import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registrasi_controller.dart';

class RegistrasiView extends GetView<RegistrasiController> {
  const RegistrasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                      color: Color(0xFF1B3D26), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back()),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Selamat Datang!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                    color: Color(0xFF1B3D26))),
              const Text('Silahkan Daftar Akun Anda',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 30),
              _f('Nama Lengkap', controller.namaC),
              _f('E-Mail', controller.emailC),
              _f('Kata Sandi', controller.passwordC, isPassword: true),
              _f('Konfirmasi Kata Sandi', controller.konfirmasiC, isPassword: true),
              const SizedBox(height: 20),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.daftar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3D26),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Daftar',
                          style: TextStyle(color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 30),
              const Text('Atau Daftar Dengan',
                style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon('https://cdn-icons-png.flaticon.com/512/2991/2991148.png', 'Google'),
                  const SizedBox(width: 20),
                  _socialIcon('https://cdn-icons-png.flaticon.com/512/733/733547.png', 'Facebook'),
                  const SizedBox(width: 20),
                  _socialIcon('https://cdn-icons-png.flaticon.com/512/0/747.png', 'Apple'),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? '),
                  GestureDetector(
                    onTap: controller.keLogin,
                    child: const Text('Masuk',
                      style: TextStyle(color: Color(0xFF1B3D26),
                          fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _f(String hint, TextEditingController ctrl,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl, obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Colors.grey),
          filled: true, fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 25, vertical: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none)),
      ),
    );
  }

  Widget _socialIcon(String url, String label) {
    return InkWell(
      onTap: () => controller.handleSocialSignUp(label),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12), height: 60, width: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15)),
        child: Image.network(url, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, color: Colors.grey)),
      ),
    );
  }
}