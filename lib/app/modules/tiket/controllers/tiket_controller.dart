import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../services/firebase_service.dart';

class TiketController extends GetxController {
  final tickets = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Stream real-time dari Firestore
    FirebaseService.to.streamTikets().listen((data) {
      tickets.value = data;
    });
  }

  Future<void> addTicket(Map<String, dynamic> ticket) async {
    await FirebaseService.to.simpanTiket(ticket);
    // List otomatis update via stream
  }

  String formatCurrency(dynamic amount) {
    int price = 0;
    if (amount is String) {
      price = int.tryParse(
              amount.replaceAll('.', '').replaceAll('Rp ', '')) ??
          0;
    } else if (amount is int) {
      price = amount;
    }
    return NumberFormat.currency(
            locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
  }
}