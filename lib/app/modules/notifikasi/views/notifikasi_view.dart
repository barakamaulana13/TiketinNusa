import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/notifikasi/controllers/notifikasi_controller.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';

class NotifikasiView extends StatelessWidget {
  const NotifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final c    = Get.find<NotifikasiController>();
    final lang = Get.find<PengaturanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFED),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F4529),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: GetBuilder<PengaturanController>(
          builder: (_) => Text(
            lang.t('notif_title'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        // Tombol hapus semua di kanan atas
        actions: [
          Obx(() => c.notifications.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep,
                      color: Colors.white),
                  tooltip: 'Hapus Semua',
                  onPressed: () => _konfirmasiHapusSemua(
                      context, c, lang),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (c.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined,
                    size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                GetBuilder<PengaturanController>(
                  builder: (_) => Text(
                    lang.t('no_notif'),
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: c.notifications.length,
          itemBuilder: (_, i) {
            final item = c.notifications[i];
            return _buildCard(item, c);
          },
        );
      }),
    );
  }

  Widget _buildCard(
      Map<String, dynamic> item, NotifikasiController c) {
    return Dismissible(
      // Swipe kiri untuk hapus
      key: Key(item['id'] ?? item['judul'] ?? '$item'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => c.hapusSatu(item['id'] ?? ''),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete,
            color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon notifikasi
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F4529)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                color: Color(0xFF1F4529),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['judul']?.toString() ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        item['waktu']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['isi']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol hapus
            IconButton(
              icon: Icon(Icons.close,
                  size: 18, color: Colors.grey[400]),
              onPressed: () =>
                  c.hapusSatu(item['id'] ?? ''),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  void _konfirmasiHapusSemua(
    BuildContext context,
    NotifikasiController c,
    PengaturanController lang,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Semua Notifikasi'),
        content: const Text(
            'Semua notifikasi akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              c.hapusSemua();
            },
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}