import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/login/controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tombol back
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B3D26),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Logo
              Image.asset(
                'assets/favicon.png',
                height: 80,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.confirmation_number,
                  size: 80,
                  color: Color(0xFF1B3D26),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B3D26),
                ),
              ),
              const Text(
                'Silahkan Masuk Ke Akun Anda',
                style: TextStyle(
                    color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Input Email
              _buildTextField(
                hint: 'E-Mail',
                ctrl: controller.emailC,
                icon: Icons.email_outlined,
              ),

              // Input Password
              _buildTextField(
                hint: 'Kata Sandi',
                ctrl: controller.passwordC,
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Lupa Kata Sandi?',
                    style: TextStyle(
                        color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Tombol Masuk
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.masuk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1B3D26),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )),

              const SizedBox(height: 16),

              // Tombol Masuk Sebagai Tamu
              Obx(() => SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.masukTamu,
                  icon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF1B3D26),
                  ),
                  label: const Text(
                    'Masuk Sebagai Tamu',
                    style: TextStyle(
                      color: Color(0xFF1B3D26),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15),
                    side: const BorderSide(
                      color: Color(0xFF1B3D26),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),
                ),
              )),

              const SizedBox(height: 8),
              Text(
                'Sebagai tamu, beberapa fitur mungkin terbatas',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  GestureDetector(
                    onTap: controller.keRegistrasi,
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                        color: Color(0xFF1B3D26),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController ctrl,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: Colors.grey, fontSize: 15),
          prefixIcon: Icon(icon,
              color: const Color(0xFF1B3D26)),
          filled: true,
          fillColor: const Color(0xFFE0E0E0),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 25, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}