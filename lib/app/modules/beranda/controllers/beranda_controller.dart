import 'package:get/get.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';
import 'package:tiketinnusa/app/services/destinasi_service.dart';

class BerandaController extends GetxController {
  final currentIndex      = 0.obs;
  final selectedDateIndex = 0.obs;
  late DateTime selectedDate;
  late List<Map<String, String>> calendarDates;

  final weekdays = ["SEN","SEL","RAB","KAM","JUM","SAB","MIN"];
  final months   = [
    "Januari","Februari","Maret","April","Mei","Juni",
    "Juli","Agustus","September","Oktober","November","Desember"
  ];

  // Ambil dari DestinasiService (sumber Firebase)
  List<Map<String, dynamic>> get popularDestinations =>
      DestinasiService.to.popular;

  @override
  void onInit() {
    super.onInit();
    selectedDate  = DateTime.now();
    calendarDates = _generateDates();
    // Rebuild otomatis saat Firebase update
    ever(DestinasiService.to.semuaDestinasi, (_) => update());
  }

  List<Map<String, String>> _generateDates() {
    final now = DateTime.now();
    return List.generate(14, (i) {
      final date = now.add(Duration(days: i));
      return {
        'day' : weekdays[date.weekday - 1],
        'date': date.day.toString(),
      };
    });
  }

  void changeTab(int index) {
    currentIndex.value = index;
    update();
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
    selectedDate = DateTime.now().add(Duration(days: index));
    update();
  }

  String get currentMonthYear =>
      '${months[selectedDate.month - 1]} ${selectedDate.year}';

  void goToDetail(Map<String, dynamic> data) =>
      Get.toNamed(AppRoutes.DETAIL_WISATA, arguments: data);

  void goToKategori(String kategori) =>
      Get.toNamed(AppRoutes.KATEGORI,
          arguments: {'kategori': kategori});
}