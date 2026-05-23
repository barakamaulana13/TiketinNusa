import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/beranda/controllers/beranda_controller.dart';
import 'package:tiketinnusa/app/modules/tiket/views/tiket_view.dart';
import 'package:tiketinnusa/app/modules/keranjang/views/keranjang_view.dart';
import 'package:tiketinnusa/app/modules/pengaturan/views/pengaturan_view.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/data/destinasi_data.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';
import 'package:tiketinnusa/app/services/destinasi_service.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/widgets/firebase_image.dart';
import 'package:tiketinnusa/app/widgets/destinasi_search_delegate.dart';

class BerandaView extends StatelessWidget {
  const BerandaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EFED),
      // GetBuilder TIDAK menyebabkan nested Obx conflict
      body: GetBuilder<BerandaController>(
        builder: (c) => IndexedStack(
          index: c.currentIndex.value,
          children: const [
            _HomeTab(),
            TiketView(),
            KeranjangView(),
            PengaturanView(),
          ],
        ),
      ),
      bottomNavigationBar: GetBuilder<BerandaController>(
        builder: (c) {
          final lang = Get.find<PengaturanController>();
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1F4529),
            unselectedItemColor: Colors.grey,
            currentIndex: c.currentIndex.value,
            onTap: c.changeTab,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: lang.t('nav_home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long_rounded),
                label: lang.t('nav_ticket'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_basket_rounded),
                label: lang.t('nav_saved'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                label: lang.t('nav_settings'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final c    = Get.find<BerandaController>();
    final lang = Get.find<PengaturanController>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, c, lang),
          const SizedBox(height: 90),
          GetBuilder<BerandaController>(
            builder: (_) => Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              child: Text(
                c.currentMonthYear,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1F4529),
                ),
              ),
            ),
          ),
          _buildCalendar(c),
          const SizedBox(height: 25),
          // Section title reaktif bahasa
          GetBuilder<PengaturanController>(
            builder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                lang.t('ticket_menu'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          _buildCategoryGrid(context, c, lang),
          const SizedBox(height: 10),
          GetBuilder<PengaturanController>(
            builder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                lang.t('popular'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          _buildWisataList(c),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context,
      BerandaController c, PengaturanController lang) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 144,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          decoration: const BoxDecoration(
              color: Color(0xFF1F4529)),
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
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.search,
                      color: Colors.white, size: 28),
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
                  onPressed: () =>
                      Get.toNamed(AppRoutes.NOTIFIKASI),
                ),
              ]),
            ],
          ),
        ),
        Positioned(
          top: 120, left: 20, right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              )],
            ),
            child: GetBuilder<PengaturanController>(
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang.t('home_greeting'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('home_subtitle'),
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(BerandaController c) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        height: 60,
        child: _CalendarList(c: c),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context,
      BerandaController c, PengaturanController lang) {
    return GetBuilder<PengaturanController>(
      builder: (_) {
        final categories = [
          {'icon': Icons.terrain,
           'label': lang.t('cat_mountain'),
           'kategori': 'Gunung'},
          {'icon': Icons.waterfall_chart,
           'label': lang.t('cat_waterfall'),
           'kategori': 'Air Terjun'},
          {'icon': Icons.beach_access,
           'label': lang.t('cat_beach'),
           'kategori': 'Pantai'},
          {'icon': Icons.water,
           'label': lang.t('cat_lake'),
           'kategori': 'Danau'},
        ];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 0.9,
            children: categories.map((cat) {
              return GestureDetector(
                onTap: () => c.goToKategori(
                    cat['kategori'] as String),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9E3D8),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Icon(cat['icon'] as IconData,
                        color: const Color(0xFF1F4529),
                        size: 24),
                  ),
                  const SizedBox(height: 5),
                  Text(cat['label'] as String,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ]),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildWisataList(BerandaController c) {
  return Obx(() {
    // Loading indicator saat pertama kali fetch Firebase
    if (DestinasiService.to.isLoading.value) {
      return const SizedBox(
        height: 210,
        child: Center(
          child: CircularProgressIndicator(
              color: Color(0xFF1F4529)),
        ),
      );
    }

    final list = DestinasiService.to.popular;

    if (list.isEmpty) {
      return const SizedBox(
        height: 210,
        child: Center(
          child: Text('Belum ada destinasi',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        itemBuilder: (_, index) {
          final item = list[index];
          return GestureDetector(
            onTap: () => c.goToDetail(item),
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(
                  right: 15, bottom: 5, top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15)),
                      child: FirebaseImage(
                        imageUrl : item['imageUrl'],
                        assetPath: item['image'] ?? '',
                        width    : double.infinity,
                        fit      : BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['wilayah'] ?? '',
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  });
}
}
  // ── HEADER ────────────────────────────────────────────
  Widget _buildHeader(BuildContext context,
      BerandaController c, PengaturanController lang) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 144,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          decoration:
              const BoxDecoration(color: Color(0xFF1F4529)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GetBuilder reaktif terhadap perubahan bahasa
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
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.search,
                      color: Colors.white, size: 28),
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
                  onPressed: () =>
                      Get.toNamed(AppRoutes.NOTIFIKASI),
                ),
              ]),
            ],
          ),
        ),
        Positioned(
          top: 120, left: 20, right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: GetBuilder<PengaturanController>(
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang.t('home_greeting'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('home_subtitle'),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── KALENDER ─────────────────────────────────────────
  // KUNCI: gunakan StatefulWidget kecil agar tidak ada
  // Obx/GetBuilder nested di dalam ListView.builder
  Widget _buildCalendar(BerandaController c) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        height: 60,
        child: _CalendarList(c: c),
      ),
    );
  }

  // ── KATEGORI GRID ─────────────────────────────────────
  Widget _buildCategoryGrid(BuildContext context,
      BerandaController c, PengaturanController lang) {
    return GetBuilder<PengaturanController>(
      builder: (_) {
        final categories = [
          {
            'icon': Icons.terrain,
            'label': lang.t('cat_mountain'),
            'kategori': 'Gunung',
          },
          {
            'icon': Icons.waterfall_chart,
            'label': lang.t('cat_waterfall'),
            'kategori': 'Air Terjun',
          },
          {
            'icon': Icons.beach_access,
            'label': lang.t('cat_beach'),
            'kategori': 'Pantai',
          },
          {
            'icon': Icons.water,
            'label': lang.t('cat_lake'),
            'kategori': 'Danau',
          },
        ];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 0.9,
            children: categories.map((cat) {
              return GestureDetector(
                onTap: () => c.goToKategori(
                    cat['kategori'] as String),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9E3D8),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: const Color(0xFF1F4529),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cat['label'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ]),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ── WISATA LIST ───────────────────────────────────────
  Widget _buildWisataList(BerandaController c) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: c.popularDestinations.length,
        itemBuilder: (_, index) {
          final item = c.popularDestinations[index];
          return GestureDetector(
            onTap: () => c.goToDetail(item),
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(
                  right: 15, bottom: 5, top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.asset(
                        item['image'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(
                          color: Colors.grey[200],
                          child: const Icon(
                              Icons.image, size: 40),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['wilayah'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

class _CalendarList extends StatefulWidget {
  final BerandaController c;
  const _CalendarList({required this.c});

  @override
  State<_CalendarList> createState() => _CalendarListState();
}

class _CalendarListState extends State<_CalendarList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.c.calendarDates.length,
      itemBuilder: (_, index) {
        final item = widget.c.calendarDates[index];
        // GetBuilder di level item — aman karena
        // tidak bersarang dengan Obx manapun
        return GetBuilder<BerandaController>(
          builder: (ctrl) {
            final isSelected =
                index == ctrl.selectedDateIndex.value;
            return GestureDetector(
              onTap: () {
                ctrl.selectDate(index);
                setState(() {}); // rebuild list
              },
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(
                    horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1F4529)
                      : const Color(0xFFE8EFED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      item['day']!,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item['date']!,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DestinasiSearchDelegate
    extends SearchDelegate<Map<String, dynamic>?> {

  // Stream history dari Firebase
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
    // Simpan ke Firebase saat user submit
    if (query.trim().isNotEmpty) {
      FirebaseService.to.simpanRiwayatSearch(query.trim());
    }
    return _buildResultList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildHistoryPage(context);
    }
    return _buildResultList(context);
  }

  // ── HALAMAN HISTORY ──────────────────────────────────
  Widget _buildHistoryPage(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        final history = snapshot.data ?? [];

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('Belum ada riwayat pencarian',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  )),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header riwayat
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 8),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Pencarian',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1F4529),
                    )),
                  TextButton(
                    onPressed: () =>
                        FirebaseService.to
                            .hapusSemuaRiwayat(),
                    child: const Text('Hapus Semua',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 12)),
                  ),
                ],
              ),
            ),
            // List riwayat
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (_, i) {
                  final item = history[i];
                  final q    = item['query'] ?? '';
                  return ListTile(
                    leading: const Icon(Icons.history,
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
    final results = DestinasiData.getAll().where((d) {
      final q = query.toLowerCase();
      return d['nama'].toLowerCase().contains(q)     ||
             d['lokasi'].toLowerCase().contains(q)   ||
             d['kategori'].toLowerCase().contains(q) ||
             d['wilayah'].toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Destinasi tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
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
              // Simpan ke history saat tap hasil
              FirebaseService.to
                  .simpanRiwayatSearch(query.trim());
              close(context, item);
              Get.toNamed(AppRoutes.DETAIL_WISATA,
                  arguments: item);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                // Gambar dengan FirebaseImage
                FirebaseImage(
                  imageUrl : item['imageUrl'],
                  assetPath: item['image'] ?? '',
                  width    : 80,
                  height   : 80,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(item['nama'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(child: Text(
                        item['lokasi'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
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
                      child: Text(item['kategori'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1F4529),
                          fontWeight: FontWeight.bold,
                        )),
                    ),
                  ],
                )),
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