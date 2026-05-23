import 'package:get/get.dart';
import '../../../services/firebase_service.dart';

class KeranjangController extends GetxController {
  final savedItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Stream real-time dari Firestore
    FirebaseService.to.streamSimpanan().listen((data) {
      savedItems.value = data;
    });
  }

  Future<void> toggleSave(Map<String, dynamic> item) async {
    final isSaved = savedItems.any((e) => e['nama'] == item['nama']);
    if (isSaved) {
      await FirebaseService.to.hapusSimpanan(item['nama']);
    } else {
      await FirebaseService.to.simpanDestinasi(item);
    }
  }

  bool isSaved(String nama) =>
      savedItems.any((e) => e['nama'] == nama);
}