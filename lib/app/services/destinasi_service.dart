import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';
import 'package:tiketinnusa/app/data/destinasi_data.dart';

class DestinasiService extends GetxService {
  static DestinasiService get to => Get.find();

  final semuaDestinasi = <Map<String, dynamic>>[].obs;
  final isLoading      = true.obs;
  final isOffline      = false.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _listen() {
    isLoading.value = true;
    _sub?.cancel();
    _sub = FirebaseService.to.streamDestinasi().listen(
      (data) {
        semuaDestinasi.value =
            data.isNotEmpty ? data : DestinasiData.getAll();
        isLoading.value = false;
        isOffline.value = false;
      },
      onError: (_) {
        semuaDestinasi.value = DestinasiData.getAll();
        isLoading.value = false;
        isOffline.value = true;
      },
    );
  }

  List<Map<String, dynamic>> getByKategori(String kategori) {
  if (kategori.isEmpty) return [];
  return semuaDestinasi
      .where((d) =>
          d['kategori']?.toString().trim() ==
          kategori.trim())
      .toList();
}

  List<Map<String, dynamic>> get popular =>
      semuaDestinasi.take(4).toList();

  List<Map<String, dynamic>> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return semuaDestinasi.where((d) {
      return d['nama'].toString().toLowerCase().contains(q)     ||
             d['lokasi'].toString().toLowerCase().contains(q)   ||
             d['kategori'].toString().toLowerCase().contains(q) ||
             d['wilayah'].toString().toLowerCase().contains(q);
    }).toList();
  }

  void refresh() => _listen();
}