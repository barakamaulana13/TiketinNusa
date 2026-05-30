import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/destinasi_service.dart';
import 'package:tiketinnusa/app/data/destinasi_data.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';

class KategoriController extends GetxController {
  List<Map<String, dynamic>> destinations = [];
  late String kategori;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    kategori   = args?['kategori'] ?? '';
  }

  // Ambil data sekali, tidak ada listener apapun
  List<Map<String, dynamic>> getDestinasi() {
    // Coba dari service
    final fromService = DestinasiService.to
        .semuaDestinasi
        .where((d) =>
            d['kategori']?.toString().trim() ==
            kategori.trim())
        .toList();

    if (fromService.isNotEmpty) return fromService;

    // Fallback lokal
    return DestinasiData.getAll()
        .where((d) =>
            d['kategori']?.toString().trim() ==
            kategori.trim())
        .toList();
  }

  void goToDetail(Map<String, dynamic> data) =>
      Get.toNamed(AppRoutes.DETAIL_WISATA, arguments: data);

  String get judulHalaman => kategori;
}