import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/tiket/controllers/tiket_controller.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';
import 'package:tiketinnusa/app/widgets/destinasi_search_delegate.dart';

class TiketView extends StatelessWidget {
  const TiketView({super.key});

  @override
  Widget build(BuildContext context) {
    final c    = Get.find<TiketController>();
    final lang = Get.find<PengaturanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFED),
      body: Column(
        children: [
          _buildHeader(context, lang),
          Expanded(
            child: Obx(
              () => c.tickets.isEmpty
                  ? _buildEmpty(lang)
                  : _buildList(c, lang),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PengaturanController lang) {
    return Container(
      height: 144,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      decoration: const BoxDecoration(color: Color(0xFF1F4529)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<PengaturanController>(
            builder: (_) => Text(
              lang.t('app_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
                onPressed: () => showSearch(
                  context: context,
                  delegate: DestinasiSearchDelegate(),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => Get.toNamed(AppRoutes.NOTIFIKASI),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(PengaturanController lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          GetBuilder<PengaturanController>(
            builder: (_) => Text(
              lang.t('no_ticket'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          GetBuilder<PengaturanController>(
            builder: (_) => ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.BERANDA),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F4529),
              ),
              child: Text(
                lang.t('start_order'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(TiketController c, PengaturanController lang) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: c.tickets.length,
      itemBuilder: (_, i) => _buildCard(c.tickets[i], c, lang),
    );
  }

  // ✅ Helper: warna & ikon berdasarkan status
  Color _statusColor(String? status) {
    switch (status) {
      case 'Lunas':
        return const Color(0xFF1F4529);
      case 'Menunggu Konfirmasi':
        return const Color(0xFFFF8F00);
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'Lunas':
        return Icons.check_circle_outline;
      case 'Menunggu Konfirmasi':
        return Icons.hourglass_top_rounded;
      case 'Ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _statusBgColor(String? status) {
    switch (status) {
      case 'Lunas':
        return const Color(0xFFE8F5E9);
      case 'Menunggu Konfirmasi':
        return const Color(0xFFFFF8E1);
      case 'Ditolak':
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey[100]!;
    }
  }

  Widget _buildCard(
    Map<String, dynamic> ticket,
    TiketController c,
    PengaturanController lang,
  ) {
    final status = ticket['status']?.toString();

    return Dismissible(
      key: Key(ticket['id'] ?? '$ticket'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => c.hapusTiket(ticket['id'] ?? ''),
      confirmDismiss: (_) async {
        return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Hapus Tiket'),
            content: const Text('Apakah Anda yakin ingin menghapus tiket ini?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: () => _showDetail(ticket, c, lang),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
            ],
            // ✅ Border kiri warna status
            border: Border(
              left: BorderSide(color: _statusColor(status), width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number, color: Color(0xFF1F4529), size: 40),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket['nama'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Kunjungan: ${ticket['tglMasuk'] ?? ''}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.formatCurrency(ticket['totalHarga'] ?? 0),
                        style: const TextStyle(
                          color: Color(0xFF1F4529),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // ✅ Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusBgColor(status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon(status), size: 12, color: _statusColor(status)),
                            const SizedBox(width: 4),
                            Text(
                              status ?? '-',
                              style: TextStyle(
                                fontSize: 11,
                                color: _statusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (status == 'Lunas')
                      const Icon(Icons.qr_code_2_rounded, color: Colors.black54, size: 30),
                    if (status == 'Menunggu Konfirmasi')
                      const Icon(Icons.pending_outlined, color: Color(0xFFFF8F00), size: 30),
                    if (status == 'Ditolak')
                      const Icon(Icons.error_outline, color: Colors.red, size: 30),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _konfirmasiHapus(ticket['id'] ?? '', c),
                      child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _konfirmasiHapus(String docId, TiketController c) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Tiket'),
        content: const Text('Apakah Anda yakin ingin menghapus tiket ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Get.back();
              c.hapusTiket(docId);
              Get.snackbar(
                'Berhasil',
                'Tiket berhasil dihapus',
                backgroundColor: const Color(0xFF1F4529),
                colorText: Colors.white,
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetail(
    Map<String, dynamic> ticket,
    TiketController c,
    PengaturanController lang,
  ) {
    final status = ticket['status']?.toString();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text(
              'E-STRUK PEMBAYARAN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2),
            ),
            const SizedBox(height: 16),

            // ✅ Status Banner
            _buildStatusBanner(status),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAF9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      // QR hanya tampil jika Lunas
                      if (status == 'Lunas') ...[
                        const Icon(Icons.qr_code_2_rounded, size: 140, color: Colors.black),
                        const SizedBox(height: 10),
                        Text(
                          'ID: TKN-${(ticket['id'] ?? '').toString().substring(0, 6).toUpperCase()}',
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ] else if (status == 'Menunggu Konfirmasi') ...[
                        Container(
                          width: 100, height: 100,
                          decoration: const BoxDecoration(color: Color(0xFFFFF8E1), shape: BoxShape.circle),
                          child: const Icon(Icons.hourglass_top_rounded, size: 55, color: Color(0xFFFF8F00)),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'QR tersedia setelah\nAdmin mengkonfirmasi',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFFFF8F00), fontSize: 12),
                        ),
                      ] else if (status == 'Ditolak') ...[
                        Container(
                          width: 100, height: 100,
                          decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                          child: const Icon(Icons.cancel_outlined, size: 55, color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Pembayaran ditolak admin.\nHubungi admin untuk info lebih lanjut.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                      const Divider(height: 30, thickness: 1),
                      _detailRow('Destinasi', ticket['nama'] ?? ''),
                      _detailRow('Tanggal', ticket['tglMasuk'] ?? ''),
                      _detailRow('Jumlah', '${ticket['jumlah'] ?? 1} orang'),
                      _detailRow('Kategori', ticket['kategori'] ?? ''),
                      _detailRow('Metode', ticket['metode'] ?? ''),
                      _detailRow(
                        'Status',
                        status ?? '-',
                        isSuccess: status == 'Lunas',
                        isPending: status == 'Menunggu Konfirmasi',
                        isRejected: status == 'Ditolak',
                      ),
                      const Divider(),
                      _detailRow(
                        'TOTAL BAYAR',
                        c.formatCurrency(ticket['totalHarga'] ?? 0),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Tombol Hapus
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _konfirmasiHapus(ticket['id'] ?? '', c);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Tutup
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F4529),
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Banner status di detail
  Widget _buildStatusBanner(String? status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    switch (status) {
      case 'Lunas':
        bgColor   = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF1F4529);
        icon      = Icons.check_circle_outline;
        message   = 'Pembayaran telah dikonfirmasi oleh admin';
        break;
      case 'Menunggu Konfirmasi':
        bgColor   = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFFF8F00);
        icon      = Icons.hourglass_top_rounded;
        message   = 'Menunggu verifikasi admin (maks. 1×24 jam)';
        break;
      case 'Ditolak':
        bgColor   = const Color(0xFFFFEBEE);
        textColor = Colors.red;
        icon      = Icons.cancel_outlined;
        message   = 'Pembayaran ditolak. Hubungi admin.';
        break;
      default:
        bgColor   = Colors.grey[100]!;
        textColor = Colors.grey;
        icon      = Icons.help_outline;
        message   = 'Status tidak diketahui';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool isSuccess  = false,
    bool isPending  = false,
    bool isRejected = false,
    bool isBold     = false,
  }) {
    Color valueColor = Colors.black;
    if (isSuccess)  valueColor = Colors.green;
    if (isPending)  valueColor = const Color(0xFFFF8F00);
    if (isRejected) valueColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold || isSuccess || isPending || isRejected
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: valueColor,
              fontSize: isBold ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}