import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/services/destinasi_service.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';
import 'package:tiketinnusa/app/widgets/firebase_image.dart';

class DestinasiSearchDelegate
    extends SearchDelegate<Map<String, dynamic>?> {

  final _historyStream =
      FirebaseService.to.streamRiwayatSearch();

  @override
  String get searchFieldLabel => 'Cari destinasi...';

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F4529),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              color: Colors.white, fontSize: 18)),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear,
                color: Colors.white),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back,
            color: Colors.white),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isNotEmpty) {
      FirebaseService.to.simpanRiwayatSearch(query.trim());
    }
    return _buildResultList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return _buildHistoryPage(context);
    return _buildResultList(context);
  }

  // ── HISTORY ──────────────────────────────────────────
  Widget _buildHistoryPage(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (_, snapshot) {
        final history = snapshot.data ?? [];
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada riwayat pencarian',
                  style: TextStyle(
                      color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 8),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Pencarian',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1F4529),
                    ),
                  ),
                  TextButton(
                    onPressed: () => FirebaseService.to
                        .hapusSemuaRiwayat(),
                    child: const Text(
                      'Hapus Semua',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (_, i) {
                  final item = history[i];
                  final q    = item['query'] ?? '';
                  return ListTile(
                    leading: const Icon(
                        Icons.history,
                        color: Color(0xFF1F4529)),
                    title: Text(q),
                    trailing: IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: Colors.grey),
                      onPressed: () =>
                          FirebaseService.to
                              .hapusRiwayatSearch(
                                  item['id']),
                    ),
                    onTap: () {
                      query = q;
                      showResults(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ── HASIL PENCARIAN ───────────────────────────────────
  Widget _buildResultList(BuildContext context) {
    final results = DestinasiService.to.search(query);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Destinasi tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final item = results[i];
        return Card(
          margin: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              FirebaseService.to
                  .simpanRiwayatSearch(query.trim());
              close(context, item);
              Get.toNamed(AppRoutes.DETAIL_WISATA,
                  arguments: item);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                FirebaseImage(
                  imageUrl : item['imageUrl'],
                  assetPath: item['image'] ?? '',
                  width    : 80,
                  height   : 80,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Expanded(child: Text(
                          item['lokasi'] ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ]),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F4529)
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['kategori'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1F4529),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF1F4529)),
              ]),
            ),
          ),
        );
      },
    );
  }
}