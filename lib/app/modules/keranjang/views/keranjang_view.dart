import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';
import '../controllers/keranjang_controller.dart';
import '../../pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/widgets/destinasi_search_delegate.dart';

class KeranjangView extends StatelessWidget {
  const KeranjangView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<KeranjangController>();
    final lang = Get.find<PengaturanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFED),
      body: Column(children: [
        _buildHeader(context, lang),
        Expanded(child: Obx(() => c.savedItems.isEmpty
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
        const Icon(Icons.bookmark_border,
            size: 80, color: Colors.grey),
        const SizedBox(height: 20),
        Obx(() => Text(lang.t('no_saved'),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87))),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: Obx(() => ElevatedButton(
            onPressed: () =>
                Get.offAllNamed(AppRoutes.BERANDA),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F4529),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(30)),
            ),
            child: Text(lang.t('find_now'),
                style: const TextStyle(
                    color: Colors.white)),
          )),
        ),
      ],
    ));
  }

  Widget _buildList(KeranjangController c,
      PengaturanController lang) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 10),
      itemCount: c.savedItems.length,
      itemBuilder: (_, i) {
        final item = c.savedItems[i];
        return GestureDetector(
          onTap: () => Get.toNamed(
              AppRoutes.DETAIL_WISATA, arguments: item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5))],
            ),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                    item['image'] ?? '',
                    width: 60, height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(
                          width: 60, height: 60,
                          color: Colors.grey[300],
                          child: const Icon(
                              Icons.image_not_supported),
                        )),
              ),
              const SizedBox(width: 15),
              Expanded(child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(item['nama'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(item['kategori'] ?? '',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12)),
                ],
              )),
              IconButton(
                icon: const Icon(Icons.bookmark,
                    color: Color(0xFF1F4529)),
                onPressed: () => c.toggleSave(item)),
            ]),
          ),
        );
      },
    );
  }
}