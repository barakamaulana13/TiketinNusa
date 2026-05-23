import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';
import '../controllers/tiket_controller.dart';
import '../../pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/widgets/destinasi_search_delegate.dart';

class TiketView extends StatelessWidget {
  const TiketView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TiketController>();
    final lang = Get.find<PengaturanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFED),
      body: Column(children: [
        _buildHeader(context, lang),
        Expanded(child: Obx(() => c.tickets.isEmpty
            ? _buildEmpty(lang)
            : _buildList(c, lang))),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context,
      PengaturanController lang) {
    return Container(
      height: 144, width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      decoration: const BoxDecoration(
          color: Color(0xFF1F4529)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(lang.t('app_title'),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold))),
          Row(children: [
            IconButton(
                icon: const Icon(Icons.search,
                    color: Colors.white, size: 28),
                onPressed: () => showSearch(
                    context: context,
                    delegate: DestinasiSearchDelegate())),
            IconButton(
                icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.white, size: 30),
                onPressed: () =>
                    Get.toNamed(AppRoutes.NOTIFIKASI)),
          ]),
        ],
      ),
    );
  }

  Widget _buildEmpty(PengaturanController lang) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.confirmation_number_outlined,
            size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        Obx(() => Text(lang.t('no_ticket'),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        Obx(() => ElevatedButton(
          onPressed: () =>
              Get.offAllNamed(AppRoutes.BERANDA),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F4529)),
          child: Text(lang.t('start_order'),
              style: const TextStyle(
                  color: Colors.white)),
        )),
      ],
    ));
  }

  Widget _buildList(TiketController c,
      PengaturanController lang) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: c.tickets.length,
      itemBuilder: (_, i) =>
          _buildCard(c.tickets[i], c, lang),
    );
  }

  Widget _buildCard(Map<String, dynamic> ticket,
      TiketController c, PengaturanController lang) {
    return GestureDetector(
      onTap: () => _showDetail(ticket, c, lang),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5))],
        ),
        child: Row(children: [
          const Icon(Icons.confirmation_number,
              color: Color(0xFF1F4529), size: 40),
          const SizedBox(width: 15),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticket['nama'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Obx(() => Text(
                '${lang.t('visit_date')}: ${ticket['tglMasuk']}',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13),
              )),
              const SizedBox(height: 4),
              Text(c.formatCurrency(ticket['totalHarga']),
                  style: const TextStyle(
                      color: Color(0xFF1F4529),
                      fontWeight: FontWeight.bold)),
            ],
          )),
          const Icon(Icons.qr_code_2_rounded,
              color: Colors.black54, size: 30),
        ]),
      ),
    );
  }

  void _showDetail(Map<String, dynamic> ticket,
      TiketController c, PengaturanController lang) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(children: [
          Container(
              width: 50, height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          Obx(() => Text(lang.t('receipt_title'),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2))),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(children: [
              const Icon(Icons.qr_code_2_rounded,
                  size: 140, color: Colors.black),
              const SizedBox(height: 10),
              Text('ID: TKN-${ticket['nama'].hashCode}',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 11)),
              const Divider(
                  height: 30, thickness: 1,
                  color: Colors.black12),
              _detailRow('Destinasi', ticket['nama']),
              _detailRow('Tanggal', ticket['tglMasuk']),
              _detailRow('Status', 'LUNAS',
                  isSuccess: true),
              const Divider(),
              _detailRow('TOTAL BAYAR',
                  c.formatCurrency(ticket['totalHarga']),
                  isBold: true),
            ]),
          ),
          const Spacer(),
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F4529),
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15)),
              ),
              child: Text(lang.t('close'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          )),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool isSuccess = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold || isSuccess
                      ? FontWeight.bold
                      : FontWeight.w600,
                  color: isSuccess
                      ? Colors.green
                      : Colors.black,
                  fontSize: isBold ? 16 : 13)),
        ],
      ),
    );
  }
}