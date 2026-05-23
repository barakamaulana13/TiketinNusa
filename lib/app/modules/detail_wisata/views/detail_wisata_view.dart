import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_wisata_controller.dart';

class DetailWisataView extends GetView<DetailWisataController> {
  const DetailWisataView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = controller.data;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F4529),
        toolbarHeight: 100,
        title: Text(data['nama'],
          style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(data['image'], width: double.infinity, height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey, height: 250,
                child: const Icon(Icons.image, size: 80))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['nama'],
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 18),
                    const SizedBox(width: 5),
                    Expanded(child: Text(data['lokasi'],
                      style: TextStyle(color: Colors.grey[700], fontSize: 16))),
                  ]),
                  const Divider(height: 40, thickness: 1),
                  _buildCategoryInfo(data),
                  const Divider(height: 40, thickness: 1),
                  const Text('Jalur Akses',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1F4529)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.alt_route, color: Color(0xFF1F4529)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(data['jalur'] ?? '-',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                    ]),
                  ),
                  const SizedBox(height: 30),
                  const Text('Informasi Tarif',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  _buildPriceItem('WNI - Hari Kerja', data['Tarif Hari Kerja (WNI)']),
                  _buildPriceItem('WNI - Akhir Pekan', data['Tarif Akhir Pekan (WNI)']),
                  _buildPriceItem('WNA - Hari Kerja', data['Tarif Hari Kerja (WNA)']),
                  _buildPriceItem('WNA - Akhir Pekan', data['Tarif Akhir Pekan (WNA)']),
                  const SizedBox(height: 40),
                  Row(children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: controller.toggleSave,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1F4529), width: 2),
                          minimumSize: const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Icon(Icons.shopping_basket,
                            color: Color(0xFF1F4529)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: controller.goToBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F4529),
                          minimumSize: const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Booking Sekarang',
                          style: TextStyle(color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInfo(Map<String, dynamic> data) {
    final k = data['kategori'];
    if (k == 'Gunung') {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _infoCol(Icons.terrain, 'Ketinggian', data['ketinggian'] ?? '-'),
        _infoCol(Icons.timer, 'Estimasi', data['estimasi'] ?? '-'),
        _infoCol(Icons.category, 'Kategori', k),
      ]);
    } else if (k == 'Pantai') {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _infoCol(Icons.beach_access, 'Tipe Pasir', data['tipe_pasir'] ?? '-'),
        _infoCol(Icons.thermostat, 'Suhu', data['suhu'] ?? '-'),
        _infoCol(Icons.category, 'Kategori', k),
      ]);
    } else if (k == 'Danau') {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _infoCol(Icons.straighten, 'Kedalaman', data['kedalaman'] ?? '-'),
        _infoCol(Icons.security, 'Status', data['status'] ?? '-'),
        _infoCol(Icons.category, 'Kategori', k),
      ]);
    } else if (k == 'Air Terjun') {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _infoCol(Icons.directions_walk, 'Jarak Trek', data['jarak_trek'] ?? '-'),
        _infoCol(Icons.timer, 'Durasi', data['durasi'] ?? '-'),
        _infoCol(Icons.category, 'Kategori', k),
      ]);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _infoCol(Icons.category, 'Kategori', k ?? '-'),
      _infoCol(Icons.place, 'Wilayah', data['wilayah'] ?? '-'),
    ]);
  }

  Widget _infoCol(IconData icon, String label, String value) {
    return Expanded(child: Column(children: [
      Icon(icon, color: const Color(0xFF1F4529), size: 28),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 4),
      Text(value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        textAlign: TextAlign.center, maxLines: 2,
        overflow: TextOverflow.ellipsis),
    ]));
  }

  Widget _buildPriceItem(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        Text(price == '0' ? 'Gratis' : 'Rp $price',
          style: const TextStyle(fontWeight: FontWeight.bold,
              color: Color(0xFF1F4529), fontSize: 15)),
      ]),
    );
  }
}