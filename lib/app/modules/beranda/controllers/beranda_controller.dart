import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';
import 'package:tiketinnusa/app/services/destinasi_service.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';

class BerandaController extends GetxController {
  final currentIndex      = 0.obs;
  final selectedDateIndex = 0.obs;
  late DateTime selectedDate;
  late List<Map<String, String>> calendarDates;

  final weekdays = ["SEN","SEL","RAB","KAM","JUM","SAB","MIN"];
  final months   = [
    "Januari","Februari","Maret","April","Mei","Juni",
    "Juli","Agustus","September","Oktober","November","Desember"
  ];

  // 5 wisata populer — 1 dari tiap kategori
  List<Map<String, dynamic>> get popularDestinations {
    final semua = DestinasiService.to.semuaDestinasi;
    if (semua.isEmpty) return [];

    final kategoriList = ['Gunung','Pantai','Danau','Air Terjun'];
    final hasil = <Map<String, dynamic>>[];

    // Ambil 1 dari tiap kategori
    for (final k in kategoriList) {
      final found = semua.firstWhere(
        (d) => d['kategori']?.toString() == k,
        orElse: () => {},
      );
      if (found.isNotEmpty) hasil.add(found);
    }

    // Tambah 1 lagi dari kategori apapun jika kurang dari 5
    if (hasil.length < 5) {
      final sudahAda = hasil.map((e) => e['nama']).toSet();
      final tambahan = semua.firstWhere(
        (d) => !sudahAda.contains(d['nama']),
        orElse: () => {},
      );
      if (tambahan.isNotEmpty) hasil.add(tambahan);
    }

    return hasil.take(5).toList();
  }

  @override
  void onInit() {
    super.onInit();
    selectedDate  = DateTime.now();
    calendarDates = _generateDates();
  }

  List<Map<String, String>> _generateDates() {
    final now = DateTime.now();
    return List.generate(14, (i) {
      final date = now.add(Duration(days: i));
      return {
        'day' : weekdays[date.weekday - 1],
        'date': date.day.toString(),
      };
    });
  }

  void changeTab(int index) {
    currentIndex.value = index;
    update();
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
    selectedDate = DateTime.now().add(Duration(days: index));
    update();
  }

  String get currentMonthYear =>
      '${months[selectedDate.month - 1]} ${selectedDate.year}';

  void goToDetail(Map<String, dynamic> data) {
    // Cek login sebelum ke detail
    if (FirebaseService.to.currentUser == null) {
      _showLoginDialog();
      return;
    }
    Get.toNamed(AppRoutes.DETAIL_WISATA, arguments: data);
  }

  void goToKategori(String kategori) {
    // Kategori bisa dilihat tanpa login
    Get.toNamed(AppRoutes.KATEGORI,
        arguments: {'kategori': kategori});
  }

  // Dialog minta login jika fitur butuh auth
  void showLoginRequired() => _showLoginDialog();

  void _showLoginDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Login Diperlukan'),
        content: const Text(
          'Silahkan login atau daftar untuk menggunakan fitur ini.',
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