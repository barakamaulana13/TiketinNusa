import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';

class NotifikasiController extends GetxController {
  final notifications = <Map<String, dynamic>>[].obs;

  /// Jumlah notifikasi yang belum dibaca — berguna untuk badge di navbar
  int get unreadCount =>
      notifications.where((n) => n['dibaca'] == false).length;

  @override
  void onInit() {
    super.onInit();
    FirebaseService.to.streamNotifikasi().listen((data) {
      notifications.value = data;
    });
    _initDefaultNotif();
  }

  Future<void> _initDefaultNotif() async {
    await Future.delayed(const Duration(seconds: 2));
    if (notifications.isEmpty) {
      await addNotification(
        'Selamat Datang!',
        'Terimakasih sudah bergabung dengan TiketinNusa',
      );
    }
  }

  /// Tambah notifikasi & simpan ke Firestore.
  Future<void> addNotification(String judul, String isi) async {
    await FirebaseService.to.tambahNotifikasi(judul, isi);
  }

  /// Tandai satu notifikasi sebagai sudah dibaca.
  Future<void> tandaiBaca(String docId) async {
    // Update field 'dibaca' di Firestore — UI reaktif via stream
    await FirebaseService.to.tandaiNotifikasiBaca(docId);
  }

  /// Tandai semua notifikasi sebagai sudah dibaca.
  Future<void> tandaiSemuaBaca() async {
    await FirebaseService.to.tandaiSemuaNotifikasiBaca();
  }

  // ── HAPUS SATU NOTIFIKASI
  Future<void> hapusSatu(String docId) async {
    await FirebaseService.to.hapusNotifikasi(docId);
  }

  // ── HAPUS SEMUA NOTIFIKASI
  Future<void> hapusSemua() async {
    await FirebaseService.to.hapusSemuaNotifikasi();
  }
}