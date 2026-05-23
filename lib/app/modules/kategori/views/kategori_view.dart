import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/kategori/controllers/kategori_controller.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/widgets/firebase_image.dart';

class KategoriView extends StatelessWidget {
  const KategoriView({super.key});

  @override
  Widget build(BuildContext context) {
    final c    = Get.find<KategoriController>();
    final lang = Get.find<PengaturanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFED),
      body: Column(children: [
        _buildHeader(c, lang),
        Expanded(
          child: Obx(() {
            // ── LOADING ──
            if (c.isLoading.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        color: Color(0xFF1F4529)),
                    SizedBox(height: 16),
                    Text('Memuat data...',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            // ── KOSONG ──
            if (c.destinations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore_off,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada destinasi ${c.kategori}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data akan muncul otomatis\nsaat admin menambahkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: c.refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1F4529),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── DAFTAR ──
            return RefreshIndicator(
              color: const Color(0xFF1F4529),
              onRefresh: () async => c.refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: c.destinations.length,
                itemBuilder: (_, i) =>
                    _buildCard(c.destinations[i], c, lang),
              ),
            );
          }),
        ),
      ]),
    );
  }

  // ── HEADER ──────────────────────────────────────────────
  Widget _buildHeader(KategoriController c,
      PengaturanController lang) {
    return Container(
      height: 144, width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 60, 20, 0),
      decoration:
          const BoxDecoration(color: Color(0xFF1F4529)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.judulHalaman,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Jumlah destinasi real-time
                  Obx(() => Text(
                    '${c.jumlahDestinasi} Destinasi',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  )),
                ],
              ),
            ),
          ),
          // Indikator live update
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text('Live',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
            ]),
          ),
        ],
      ),
    );
  }

  // ── CARD DESTINASI ───────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> item,
      KategoriController c, PengaturanController lang) {
    return GestureDetector(
      onTap: () => c.goToDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── GAMBAR ──
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              child: Stack(
                children: [
                  FirebaseImage(
                    imageUrl : item['imageUrl'],
                    assetPath: item['image'] ?? '',
                    width    : double.infinity,
                    height   : 180,
                    fit      : BoxFit.cover,
                  ),
                  // Badge kategori
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F4529)
                            .withOpacity(0.85),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['kategori'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── DETAIL ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama
                  Text(
                    item['nama'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Lokasi
                  Row(children: [
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(child: Text(
                      item['lokasi'] ?? '',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ]),
                  const SizedBox(height: 10),

                  // Info chips per kategori
                  _buildInfoChips(item),
                  const SizedBox(height: 12),

                  // Garis pemisah
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 8),

                  // Harga + tombol
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          GetBuilder<PengaturanController>(
                            builder: (_) => Text(
                              lang.t('weekday_wni'),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          Text(
                            _formatHarga(
                              item['Tarif Hari Kerja (WNI)']
                                      ?.toString() ?? '0',
                            ),
                            style: const TextStyle(
                              color: Color(0xFF1F4529),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => c.goToDetail(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F4529),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: GetBuilder<PengaturanController>(
                            builder: (_) => Text(
                              lang.t('book_now'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CHIPS INFO ───────────────────────────────────────────
  Widget _buildInfoChips(Map<String, dynamic> item) {
    final chips = <Map<String, dynamic>>[];
    final k     = item['kategori'];

    if (k == 'Gunung') {
      if ((item['ketinggian'] ?? '').isNotEmpty)
        chips.add({'icon': Icons.terrain,
            'label': item['ketinggian']});
      if ((item['estimasi'] ?? '').isNotEmpty)
        chips.add({'icon': Icons.timer,
            'label': item['estimasi']});
    } else if (k == 'Pantai') {
      if ((item['tipe_pasir'] ?? '').isNotEmpty)
        chips.add({'icon': Icons.beach_access,
            'label': item['tipe_pasir']});
      if ((item['suhu'] ?? '').isNotEmpty)
        chips.add({'icon': Icons.thermostat,
            'label': item['suhu']});
    } else if (k == 'Danau') {
      if ((item['kedalaman'] ?? '').isNotEmpty)
        chips.add({'icon': Icons.straighten,
            'label': item['kedalaman']});
      if ((item['status'] ?? '').isNotEmpty)
        chips.add({'icon': Icons.info_outline,
            'label': item['status']});
    } else if (k == 'Air Terjun') {
      if ((item['jarak_trek'] ?? '').isNotEmpty)
        chips.add({'icon': Icons.directions_walk,
            'label': item['jarak_trek']});
      if ((item['durasi'] ?? '').isNotEmpty)
        chips.add({'icon': Icons.timer,
            'label': item['durasi']});
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8, runSpacing: 6,
      children: chips.map((chip) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1F4529).withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min,
          children: [
            Icon(chip['icon'] as IconData,
                size: 13,
                color: const Color(0xFF1F4529)),
            const SizedBox(width: 4),
            Text(chip['label'] as String,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF1F4529),
                fontWeight: FontWeight.w600,
              )),
          ],
        ),
      )).toList(),
    );
  }

  String _formatHarga(String harga) {
    if (harga == '0' || harga.isEmpty) return 'Gratis';
    return 'Rp $harga';
  }
}