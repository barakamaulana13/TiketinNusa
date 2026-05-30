import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/modules/notifikasi/controllers/notifikasi_controller.dart';

class BookingController extends GetxController {
  late Map<String, dynamic> dataWisata;

  final pageController  = PageController();
  final currentStep     = 0.obs;
  final selectedPayment = 'QRIS'.obs;
  final selectedBank    = RxnString();
  final selectedNegara  = RxnString();
  final selectedGender  = RxnString();

  final selectedPosMasuk       = RxnString();
  final selectedPosKeluar      = RxnString();
  final selectedAktivitas      = RxnString();
  final selectedAktivitasDanau = RxnString();
  final selectedJalurAirTerjun = RxnString();

  final namaC      = TextEditingController();
  final hpC        = TextEditingController();
  final tglMasukC  = TextEditingController();
  final tglKeluarC = TextEditingController();
  final expiredC   = TextEditingController();
  final codeC      = TextEditingController();
  final jumlahC    = TextEditingController(text: '1');
  final alamatC    = TextEditingController();

  final buktiBayar  = Rx<File?>(null);
  final isUploading = false.obs;
  final sudahUpload = false.obs;

  late String nomorTiket;
  String qrData = '';

  final banks = [
    'Visa', 'Mastercard', 'BCA', 'Mandiri',
    'BNI', 'BRI', 'JCB', 'American Express',
  ];
  final negaraList = [
    'Indonesia', 'Malaysia', 'Singapura', 'Thailand', 'Lainnya',
  ];
  final genderList = ['Laki-laki', 'Perempuan'];

  final aktivitasPantai = [
    'Berenang', 'Snorkeling', 'Surfing',
    'Berjemur', 'Fotografi', 'Lainnya',
  ];
  final aktivitasDanau = [
    'Wisata Perahu', 'Berenang', 'Memancing',
    'Berkemah', 'Fotografi', 'Lainnya',
  ];
  final jalurAirTerjun = [
    'Jalur Utama', 'Jalur Alternatif',
    'Jalur Trekking', 'Lainnya',
  ];

  List<String> get jalurGunung {
    final jalur = dataWisata['jalur']?.toString() ?? '';
    if (jalur.isEmpty) return ['Jalur Utama'];
    return jalur.split(',').map((e) => e.trim()).toList();
  }

  String get kategori => dataWisata['kategori']?.toString() ?? '';

  int get hargaSatuan {
    final isWNI = selectedNegara.value == 'Indonesia';
    final key   = isWNI
        ? 'Tarif Hari Kerja (WNI)'
        : 'Tarif Hari Kerja (WNA)';
    return int.tryParse(
            dataWisata[key].toString().replaceAll('.', '')) ?? 0;
  }

  int get subtotal      => hargaSatuan * (int.tryParse(jumlahC.text) ?? 0);
  int get biayaAktivasi => (subtotal * 0.02).round();
  int get totalBiaya    => subtotal + biayaAktivasi;

  String formatRupiah(int amount) =>
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
          .format(amount);

  String _generateNomorTiket() {
    final now    = DateTime.now();
    final tgl    = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final random = (Random().nextInt(900000) + 100000).toString();
    return 'TIN-$tgl-$random';
  }

  String _generateQrData() {
    return [
      'TIKET:$nomorTiket',
      'DESTINASI:${dataWisata['nama'] ?? ''}',
      'KATEGORI:$kategori',
      'PEMESAN:${namaC.text}',
      'TGL_MASUK:${tglMasukC.text}',
      'TGL_KELUAR:${tglKeluarC.text}',
      'JUMLAH:${jumlahC.text}',
      'TOTAL:$totalBiaya',
      'METODE:${selectedPayment.value}',
      // ✅ PERUBAHAN: status awal adalah Menunggu Konfirmasi
      'STATUS:Menunggu Konfirmasi',
    ].join('|');
  }

  @override
  void onInit() {
    super.onInit();

    final svc        = FirebaseService.to;
    final belumLogin = svc.currentUser == null || svc.isTamu;
    if (belumLogin) {
      final pesan = svc.isTamu
          ? 'Akun tamu tidak bisa memesan tiket. Silakan daftar atau login.'
          : 'Silakan login terlebih dahulu untuk melakukan pemesanan tiket.';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          'Login Diperlukan',
          pesan,
          backgroundColor: const Color(0xFF1F4529),
          colorText: Colors.white,
          icon: const Icon(Icons.lock_outline, color: Colors.white),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.toNamed('/login');
        });
      });
      return;
    }

    dataWisata = Get.arguments as Map<String, dynamic>;
    nomorTiket = _generateNomorTiket();
    codeC.text = (Random().nextInt(900) + 100).toString();
  }

  @override
  void onClose() {
    pageController.dispose();
    namaC.dispose(); hpC.dispose();
    tglMasukC.dispose(); tglKeluarC.dispose();
    expiredC.dispose(); codeC.dispose();
    jumlahC.dispose(); alamatC.dispose();
    super.onClose();
  }

  void nextPage() => pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut);

  void previousPage() {
    if (currentStep.value > 0) {
      pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    } else {
      Get.back();
    }
  }

  Future<void> selectDate(
    BuildContext context,
    TextEditingController ctrl, {
    bool isMasuk = false,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1F4529),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text = DateFormat('dd/MM/yyyy').format(picked);
      if (isMasuk) {
        expiredC.text = DateFormat('dd/MM/yyyy')
            .format(picked.add(const Duration(days: 1)));
      }
    }
  }

  Future<void> pilihBuktiBayar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
    );
    if (picked == null) return;
    isUploading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    buktiBayar.value  = File(picked.path);
    sudahUpload.value = true;
    isUploading.value = false;
  }

  void hapusBukti() {
    buktiBayar.value  = null;
    sudahUpload.value = false;
  }

  // ── Konfirmasi & simpan ───────────────────────────────
  Future<void> konfirmasiBayar() async {
    // Tampilkan loading
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1F4529)),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Generate qrData final
      qrData = _generateQrData();

      // Konversi bukti → base64
      String? buktiBayarBase64;
      if (buktiBayar.value != null) {
        buktiBayarBase64 =
            await FirebaseService.to.fileToBase64(buktiBayar.value!);
      }

      // ✅ PERUBAHAN: status awal 'Menunggu Konfirmasi', bukan 'Lunas'
      final tiket = <String, dynamic>{
        'nomorTiket'    : nomorTiket,
        'qrData'        : qrData,
        'nama'          : dataWisata['nama'] ?? '',
        'kategori'      : kategori,
        'lokasi'        : dataWisata['lokasi'] ?? '',
        'tglMasuk'      : tglMasukC.text,
        'tglKeluar'     : tglKeluarC.text,
        'jumlah'        : int.tryParse(jumlahC.text) ?? 1,
        'hargaSatuan'   : hargaSatuan,
        'subtotal'      : subtotal,
        'biayaAktivasi' : biayaAktivasi,
        'totalHarga'    : totalBiaya,
        'metode'        : selectedPayment.value,
        'negara'        : selectedNegara.value ?? '',
        'gender'        : selectedGender.value ?? '',
        'namaPemesan'   : namaC.text,
        'hp'            : hpC.text,
        'alamat'        : alamatC.text,
        'status'        : 'Menunggu Konfirmasi', // ✅ DIUBAH
        'createdAt'     : DateTime.now().millisecondsSinceEpoch,
        if (buktiBayarBase64 != null)
          'buktiBayar'  : buktiBayarBase64,
        if (kategori == 'Gunung') ...{
          'posMasuk' : selectedPosMasuk.value ?? '',
          'posKeluar': selectedPosKeluar.value ?? '',
        },
        if (kategori == 'Pantai') ...{
          'aktivitas': selectedAktivitas.value ?? '',
        },
        if (kategori == 'Danau') ...{
          'aktivitas': selectedAktivitasDanau.value ?? '',
        },
        if (kategori == 'Air Terjun') ...{
          'jalur': selectedJalurAirTerjun.value ?? '',
        },
      };

      // Simpan ke Firestore
      await FirebaseService.to.simpanTiket(tiket);

      // Notifikasi ke user: menunggu konfirmasi admin
      await FirebaseService.to.tambahNotifikasi(
        'Pembayaran Menunggu Konfirmasi ⏳',
        'Tiket $nomorTiket senilai ${formatRupiah(totalBiaya)} sedang menunggu konfirmasi admin.',
      );
      try {
        Get.find<NotifikasiController>().addNotification(
          'Pembayaran Menunggu Konfirmasi ⏳',
          'Tiket $nomorTiket senilai ${formatRupiah(totalBiaya)} sedang menunggu konfirmasi admin.',
        );
      } catch (_) {}

      // Tutup loading dialog
      Get.back();

      // Tampilkan dialog sukses (status menunggu)
      _showMenungguDialog();

    } catch (e) {
      Get.back();
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ✅ BARU: Dialog menunggu konfirmasi admin
  void _showMenungguDialog() {
    final _nomorTiket    = nomorTiket;
    final _namaDestinasi = dataWisata['nama'] ?? '';
    final _totalBiaya    = totalBiaya;
    final _tglMasuk      = tglMasukC.text;
    final _metode        = selectedPayment.value;

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.9,
            maxHeight: Get.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon status menunggu
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: Color(0xFFFF8F00),
                    size: 45,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Menunggu Konfirmasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1F4529),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bukti pembayaran Anda telah diterima.\nAdmin akan memverifikasi dalam 1×24 jam.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFB300)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pending_outlined, color: Color(0xFFFF8F00), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'MENUNGGU KONFIRMASI ADMIN',
                        style: TextStyle(
                          color: Color(0xFFFF8F00),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Info ringkas
                _infoRow(Icons.confirmation_number_outlined, 'No. Tiket', _nomorTiket),
                _infoRow(Icons.place_outlined, 'Destinasi', _namaDestinasi),
                _infoRow(Icons.calendar_today_outlined, 'Tgl Masuk', _tglMasuk),
                _infoRow(Icons.payment_outlined, 'Metode', _metode),
                _infoRow(Icons.attach_money_rounded, 'Total', formatRupiah(_totalBiaya)),

                const SizedBox(height: 20),

                // Info proses
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFB2DFDB)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.info_outline, color: Color(0xFF1F4529), size: 16),
                        SizedBox(width: 6),
                        Text('Alur Konfirmasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1F4529))),
                      ]),
                      SizedBox(height: 10),
                      _StepItem(step: '1', text: 'Bukti pembayaran Anda diterima', done: true),
                      _StepItem(step: '2', text: 'Admin memverifikasi pembayaran', done: false),
                      _StepItem(step: '3', text: 'Status berubah menjadi Lunas / Ditolak', done: false),
                      _StepItem(step: '4', text: 'Notifikasi dikirim ke akun Anda', done: false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.until((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home_outlined, color: Colors.white),
                    label: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F4529),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.until((route) => route.isFirst);
                    // Navigate ke tab tiket
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Get.toNamed('/tiket');
                    });
                  },
                  child: const Text(
                    'Pantau Status Tiket',
                    style: TextStyle(color: Color(0xFF1F4529)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const Text(' : ', style: TextStyle(color: Colors.grey, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Helper dialog section card (tetap ada untuk kompatibilitas)
  Widget _dialogSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: const Color(0xFF1F4529)),
            const SizedBox(width: 6),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1F4529))),
          ]),
          const Divider(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
          const Text(' : ', style: TextStyle(fontSize: 11, color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              softWrap: true,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Widget helper step konfirmasi
class _StepItem extends StatelessWidget {
  final String step;
  final String text;
  final bool done;

  const _StepItem({required this.step, required this.text, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF1F4529) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : Text(step, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 12, color: done ? Colors.black87 : Colors.grey)),
        ],
      ),
    );
  }
}