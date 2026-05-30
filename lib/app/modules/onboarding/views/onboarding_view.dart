import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (_, index) {
                  final page = controller.pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(page['image']!, height: 300,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, size: 100, color: Colors.grey)),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(children: [
                          Text(page['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                          if (page['brand']!.isNotEmpty)
                            Text(page['brand']!,
                              style: const TextStyle(fontSize: 32,
                                fontWeight: FontWeight.bold, color: Color(0xFF2D4B2D))),
                        ]),
                      ),
                    ],
                  );
                },
              ),
            ),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.all(4),
                  width: controller.currentPage.value == index ? 25 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: controller.currentPage.value == index
                        ? const Color(0xFF2D4B2D) : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D4B2D),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text(
                    controller.currentPage.value == controller.pages.length - 1
                        ? 'Mulai' : 'Selanjutnya',
                    style: const TextStyle(fontSize: 18, color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}