import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/beranda/controllers/beranda_controller.dart';
import 'package:tiketinnusa/app/modules/tiket/views/tiket_view.dart';
import 'package:tiketinnusa/app/modules/keranjang/views/keranjang_view.dart';
import 'package:tiketinnusa/app/modules/pengaturan/views/pengaturan_view.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';
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
          return GetBuilder<PengaturanController>(
            builder: (_) => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF1F4529),
              unselectedItemColor: Colors.grey,
              currentIndex: c.currentIndex.value,
              onTap: (index) {
                // Tab tiket & simpan butuh login
                if ((index == 1 || index == 2) &&
                    FirebaseService.to.currentUser == null) {
                  c.showLoginRequired();
                  return;
                }
                c.changeTab(index);
              },
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
            ),
          );
        },
      ),
    );
  }
}

// ── HOME TAB ─────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BerandaController>();
    final lang = Get.find<PengaturanController>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, c, lang),
          const SizedBox(height: 90),

          // Banner login jika belum login
          Obx(() {
            final user = FirebaseService.to.currentUser;
            if (user != null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F4529), Color(0xFF2D6B3A)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_open, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Masuk untuk fitur lengkap',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Pesan tiket, simpan wisata & riwayat perjalanan',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.LOGIN),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: Color(0xFF1F4529),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          GetBuilder<BerandaController>(
            builder: (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          GetBuilder<PengaturanController>(
            builder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                lang.t('ticket_menu'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          _buildCategoryGrid(context, c, lang),
          const SizedBox(height: 20),
          GetBuilder<PengaturanController>(
            builder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                lang.t('popular'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          _buildWisataList(c),
          const SizedBox(height: 20),

          // ── PROMO BANNER ──────────────────────────────
          _buildPromoBanner(),

          // ─────────────────────────────────────────────
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── PROMO BANNER WIDGET ───────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F4529),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Teks promosi
          const Text(
            'Ingin Mencari Informasi\nTerkait Wisata Alam Nusantara?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Garis pemisah dekoratif
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          // Kotak logo website
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 105, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Jelajahin Nusa
                Image.asset(
                  'assets/logo2.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JELAJAHIN\nNUSA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'jelajahinnusa.com',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ─────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    BerandaController c,
    PengaturanController lang,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 28,
                    ),
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
        ),
        Positioned(
          top: 120,
          left: 20,
          right: 20,
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
                ),
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

  Widget _buildCalendar(BerandaController c) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(height: 60, child: _CalendarList(c: c)),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    BerandaController c,
    PengaturanController lang,
  ) {
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
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
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
                onTap: () => c.goToKategori(cat['kategori'] as String),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9E3D8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        color: const Color(0xFF1F4529),
                        size: 35,
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
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildWisataList(BerandaController c) {
    return Obx(() {
      if (DestinasiService.to.isLoading.value) {
        return const SizedBox(
          height: 210,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF1F4529)),
          ),
        );
      }

      final list = c.popularDestinations;

      if (list.isEmpty) {
        return const SizedBox(
          height: 210,
          child: Center(
            child: Text(
              'Belum ada destinasi',
              style: TextStyle(color: Colors.grey),
            ),
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
                margin: const EdgeInsets.only(right: 15, bottom: 5, top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: FirebaseImage(
                          imageUrl: item['imageUrl'],
                          assetPath: item['image'] ?? '',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 10,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  item['wilayah'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
          },
        ),
      );
    });
  }
}

// ── CALENDAR LIST ─────────────────────────────────────────
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
        return GetBuilder<BerandaController>(
          builder: (ctrl) {
            final isSelected = index == ctrl.selectedDateIndex.value;
            return GestureDetector(
              onTap: () {
                ctrl.selectDate(index);
                setState(() {});
              },
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1F4529)
                      : const Color(0xFFE8EFED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['day']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item['date']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
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
