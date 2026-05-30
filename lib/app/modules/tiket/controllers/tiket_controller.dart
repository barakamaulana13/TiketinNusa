import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/modules/notifikasi/controllers/notifikasi_controller.dart';

class TiketController extends GetxController {
  final tickets = <Map<String, dynamic>>[].obs;

  // ✅ Simpan status sebelumnya untuk deteksi perubahan
  final _prevStatusMap = <String, String>{};

  @override
  void onInit() {
    super.onInit();
    _listenTikets();
  }

  void _listenTikets() {
    FirebaseService.to.streamTikets().listen((data) {
      // ✅ Cek perubahan status → kirim notifikasi
      for (final tiket in data) {
        final id     = tiket['id']?.toString() ?? '';
        final status = tiket['status']?.toString() ?? '';
        final prev   = _prevStatusMap[id];

        if (prev != null && prev != status) {
          _onStatusChanged(tiket, prev, status);
        }
        _prevStatusMap[id] = status;
      }

      tickets.value = data;
    });
  }

  /// ✅ Dipanggil ketika status tiket berubah dari admin
  void _onStatusChanged(
    Map<String, dynamic> tiket,
    String oldStatus,
    String newStatus,
  ) {
    final nama  = tiket['nama']?.toString() ?? 'Destinasi';
    final nomor = tiket['nomorTiket']?.toString() ?? '';

    String judul;
    String pesan;

    if (newStatus == 'Lunas') {
      judul = 'Pembayaran Dikonfirmasi ✅';
      pesan = 'Tiket $nomor untuk $nama telah dikonfirmasi. E-Tiket Anda siap digunakan!';
    } else if (newStatus == 'Ditolak') {
      judul = 'Pembayaran Ditolak ❌';
      pesan = 'Tiket $nomor untuk $nama ditolak admin. Silakan hubungi admin untuk informasi lebih lanjut.';
    } else {
      return; // tidak perlu notifikasi untuk perubahan status lain
    }

    // Simpan ke Firestore notifikasi
    FirebaseService.to.tambahNotifikasi(judul, pesan).catchError((_) {});

    // Tampilkan in-app notification
    try {
      Get.find<NotifikasiController>().addNotification(judul, pesan);
    } catch (_) {}
  }

  Future<void> addTicket(Map<String, dynamic> tiket) async {
    await FirebaseService.to.simpanTiket(tiket);
  }

  Future<void> hapusTiket(String docId) async {
    _prevStatusMap.remove(docId);
    await FirebaseService.to.hapusTiket(docId);
  }

  String formatCurrency(dynamic amount) {
    int price = 0;
    if (amount is String) {
      price = int.tryParse(
              amount.replaceAll('.', '').replaceAll('Rp ', '')) ??
          0;
    } else if (amount is int) {
      price = amount;
    }
    return NumberFormat.currency(
            locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
  }

  int get countMenunggu =>
      tickets.where((t) => t['status'] == 'Menunggu Konfirmasi').length;

  int get countLunas =>
      tickets.where((t) => t['status'] == 'Lunas').length;

  int get countDitolak =>
      tickets.where((t) => t['status'] == 'Ditolak').length;
}