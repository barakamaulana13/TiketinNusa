import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A24),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 180, height: 180,
              child: Image.asset(
                'assets/favicon.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.confirmation_number_outlined,
                  size: 80, color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: controller.animController,
                    builder: (_, __) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          double begin = index * 0.2;
                          double end = (begin + 0.6).clamp(0.0, 1.0);
                          double value = CurvedAnimation(
                            parent: controller.animController,
                            curve: Interval(begin, end),
                          ).value;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            transform: Matrix4.translationValues(0, -6 * value, 0),
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'TiketinNusa',
                    style: TextStyle(
                      color: Colors.white, fontSize: 30,
                      fontWeight: FontWeight.bold, letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}