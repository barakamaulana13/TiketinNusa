import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/destinasi_service.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';

class KategoriController extends GetxController {
  final destinations = <Map<String, dynamic>>[].obs;
  final isLoading    = true.obs;
  late String kategori;

  static const Map<String, String> kategoriIkon = {
    'Gunung'    : '⛰️',
    'Air Terjun': '💧',
    'Pantai'    : '🏖️',
    'Danau'     : '🌊',
  };

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    kategori   = args?['kategori'] ?? '';
    _load();
    // Auto update saat Firebase berubah
    ever(DestinasiService.to.semuaDestinasi, (_) => _load());
  }

  void _load() {
    isLoading.value    = true;
    destinations.value =
        DestinasiService.to.getByKategori(kategori);
    isLoading.value    = false;
    update();
  }

  void refresh() => _load();

  void goToDetail(Map<String, dynamic> data) =>
      Get.toNamed(AppRoutes.DETAIL_WISATA, arguments: data);

  String get judulHalaman =>
      '${kategoriIkon[kategori] ?? '📍'} $kategori';

  int get jumlahDestinasi => destinations.length;
}