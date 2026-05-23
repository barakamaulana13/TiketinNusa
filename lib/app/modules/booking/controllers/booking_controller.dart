import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../tiket/controllers/tiket_controller.dart';
import '../../notifikasi/controllers/notifikasi_controller.dart';

class BookingController extends GetxController {
  late Map<String, dynamic> dataWisata;

  final pageController = PageController();
  final currentStep = 0.obs;
  final selectedPayment = 'QRIS'.obs;
  final selectedBank = RxnString();
  final selectedNegara = RxnString();
  final selectedGender = RxnString();

  final namaC = TextEditingController();
  final hpC = TextEditingController();
  final tglMasukC = TextEditingController();
  final tglKeluarC = TextEditingController();
  final expiredC = TextEditingController();
  final codeC = TextEditingController();
  final jumlahC = TextEditingController(text: '1');

  final banks = ['Visa','Mastercard','BCA','Mandiri','BNI','BRI','JCB','American Express'];
  final negaraList = ['Indonesia','Malaysia','Singapura','Thailand','Lainnya'];
  final genderList = ['Laki-laki','Perempuan'];

  int get hargaSatuan {
    final isWNI = selectedNegara.value == 'Indonesia';
    final key = isWNI ? 'Tarif Hari Kerja (WNI)' : 'Tarif Hari Kerja (WNA)';
    return int.tryParse(
        dataWisata[key].toString().replaceAll('.', '')) ?? 0;
  }

  int get totalBiaya => hargaSatuan * (int.tryParse(jumlahC.text) ?? 0);

  String formatRupiah(int amount) =>
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
          .format(amount);

  @override
  void onInit() {
    super.onInit();
    dataWisata = Get.arguments as Map<String, dynamic>;
    codeC.text = (Random().nextInt(900) + 100).toString();
  }

  @override
  void onClose() {
    pageController.dispose();
    namaC.dispose(); hpC.dispose();
    tglMasukC.dispose(); tglKeluarC.dispose();
    expiredC.dispose(); codeC.dispose(); jumlahC.dispose();
    super.onClose();
  }

  void nextPage() => pageController.nextPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  void previousPage() {
    if (currentStep.value > 0) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Get.back();
    }
  }

  Future<void> selectDate(BuildContext context, TextEditingController c,
      {bool isMasuk = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1F4529), onPrimary: Colors.white, onSurface: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      c.text = DateFormat('dd/MM/yyyy').format(picked);
      if (isMasuk) {
        expiredC.text = DateFormat('dd/MM/yyyy')
            .format(picked.add(const Duration(days: 1)));
      }
    }
  }

  void konfirmasiBayar() {
    Get.dialog(
      _buildSuccessDialog(),
      barrierDismissible: false,
    );
  }

  Widget _buildSuccessDialog() {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1F4529), size: 60),
          const SizedBox(height: 10),
          const Text('Booking Berhasil!',
            style: TextStyle(fontWeight: FontWeight.bold)),
          Obx(() => Text(formatRupiah(totalBiaya),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                color: Color(0xFF1F4529)))),
          const Divider(),
          _receiptRow('Metode', selectedPayment.value),
          if (selectedPayment.value == 'Kartu Kredit/Debit')
            _receiptRow('Bank', selectedBank.value ?? 'Kartu'),
          _receiptRow('Tanggal',
              DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())),
          const SizedBox(height: 20),
          const Icon(Icons.qr_code_2, size: 80, color: Colors.black),
          const Text('Scan di pintu masuk',
            style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _selesai,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F4529),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
              child: const Text('Selesai',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _selesai() {
    Get.find<TiketController>().addTicket({
      'nama': dataWisata['nama'],
      'tglMasuk': tglMasukC.text,
      'totalHarga': totalBiaya,
      'status': 'Sudah Dibayar',
    });
    Get.find<NotifikasiController>().addNotification(
      'Booking Berhasil!',
      'E-Ticket untuk ${dataWisata['nama']} senilai ${formatRupiah(totalBiaya)} telah terbit.',
    );
    Get.until((route) => route.isFirst);
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}