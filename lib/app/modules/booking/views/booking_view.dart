import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';

class BookingView extends GetView<BookingController> {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F4529),
        toolbarHeight: 78,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: controller.previousPage,
        ),
        title: Text(
          'Tiket ${controller.dataWisata['nama']}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => controller.currentStep.value = i,
        children: [
          _StepLokasi(),
          _StepBiodata(),
          _StepBayar(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 1 — Lokasi & Tanggal
// ─────────────────────────────────────────────
class _StepLokasi extends GetView<BookingController> {
  @override
  Widget build(BuildContext context) {
    final isGunung =
        controller.dataWisata['kategori'] == 'Gunung';
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Expanded(
          child: ListView(children: [
            if (isGunung) ...[
              _buildField('Pos Perizinan Masuk',
                  Icons.location_on_outlined),
              _buildField('Pos Perizinan Keluar',
                  Icons.location_on_outlined),
            ],
            _buildDateField(
              context, 'Tanggal Masuk',
              controller.tglMasukC,
              isMasuk: true,
            ),
            _buildDateField(
              context, 'Tanggal Keluar',
              controller.tglKeluarC,
            ),
            _buildField(
              'Jumlah Pemesanan',
              Icons.people_outline,
              ctrl: controller.jumlahC,
              keyboardType: TextInputType.number,
              onChanged: (_) => controller.refresh(),
            ),
          ]),
        ),
        _buildPrimaryBtn('Berikutnya', controller.nextPage),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 2 — Biodata
// ─────────────────────────────────────────────
class _StepBiodata extends GetView<BookingController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Expanded(
          child: ListView(children: [
            _buildField('Masukkan Nama', Icons.person_outline,
                ctrl: controller.namaC),
            _buildField(
              'Masukkan Nomor Handphone',
              Icons.phone_android,
              ctrl: controller.hpC,
            ),
            _buildField('Masukkan Alamat Rumah',
                Icons.home_outlined),
            _buildDropdown(
              context,
              'Negara',
              Icons.flag_outlined,
              controller.negaraList,
              controller.selectedNegara,
              (v) => controller.selectedNegara.value = v,
            ),
            _buildDropdown(
              context,
              'Gender',
              Icons.wc,
              controller.genderList,
              controller.selectedGender,
              (v) => controller.selectedGender.value = v,
            ),
          ]),
        ),
        _buildPrimaryBtn('Berikutnya', controller.nextPage),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 3 — Pembayaran (widget terpisah agar Obx terisolasi)
// ─────────────────────────────────────────────
class _StepBayar extends GetView<BookingController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Biaya :',
              style: TextStyle(fontSize: 16, color: Colors.grey)),

          // Obx 1: hanya untuk total biaya
          Obx(() => Text(
            controller.formatRupiah(controller.totalBiaya),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F4529),
            ),
          )),

          const Text('Includes Online Activations (2.0%)',
              style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 20),

          // Obx 2: hanya untuk toggle tab pembayaran
          _PaymentTabRow(),

          const SizedBox(height: 20),

          // Obx 3: hanya untuk konten metode pembayaran
          Expanded(child: _PaymentContent()),

          // Tombol konfirmasi — tidak reaktif
          _buildPrimaryBtn(
            'Konfirmasi Bayar',
            controller.konfirmasiBayar,
          ),
        ],
      ),
    );
  }
}

// Tab pilihan metode bayar — Obx terisolasi
class _PaymentTabRow extends GetView<BookingController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(children: [
      _tab('QRIS', Icons.qr_code_scanner),
      const SizedBox(width: 10),
      _tab('Kartu Kredit/Debit', Icons.credit_card),
    ]));
  }

  Widget _tab(String label, IconData icon) {
    // Tidak pakai Obx di sini karena sudah dalam Obx parent
    final isActive =
        controller.selectedPayment.value == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedPayment.value = label,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1F4529)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isActive
                      ? Colors.white
                      : Colors.black54,
                  size: 16),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Colors.black54,
                    fontSize: 10,
                    fontWeight: isActive
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Konten metode bayar — Obx terisolasi
class _PaymentContent extends GetView<BookingController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedPayment.value ==
          'Kartu Kredit/Debit') {
        return ListView(children: [
          _buildDropdown(
            context,
            'Pilih Bank / Jaringan',
            Icons.account_balance,
            controller.banks,
            controller.selectedBank,
            (v) => controller.selectedBank.value = v,
          ),
          _buildField('Nomor Kartu', Icons.credit_card),
          Row(children: [
            Expanded(
              child: _buildField(
                'Exp',
                Icons.calendar_month,
                ctrl: controller.expiredC,
                readOnly: true,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildField(
                'CVV',
                Icons.lock_outline,
                ctrl: controller.codeC,
                readOnly: true,
              ),
            ),
          ]),
        ]);
      }
      // QRIS
      return Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),
              Icon(Icons.qr_code_2, size: 180, color: Colors.black),
              SizedBox(height: 10),
              Text('TiketinNusa - QRIS Payment',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
              Text('TID: 0123456789',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey)),
              SizedBox(height: 15),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
// SHARED HELPER WIDGETS (fungsi bebas, bukan method class)
// ─────────────────────────────────────────────

Widget _buildField(
  String hint,
  IconData icon, {
  TextEditingController? ctrl,
  bool readOnly = false,
  TextInputType? keyboardType,
  ValueChanged<String>? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F4529))),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                readOnly ? Colors.grey[50] : Colors.white,
            prefixIcon: Icon(icon,
                size: 20, color: const Color(0xFF1F4529)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFF1F4529), width: 2),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDateField(
  BuildContext context,
  String label,
  TextEditingController ctrl, {
  bool isMasuk = false,
}) {
  // Ambil controller via Get.find karena ini fungsi bebas
  final c = Get.find<BookingController>();
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F4529))),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          readOnly: true,
          onTap: () =>
              c.selectDate(context, ctrl, isMasuk: isMasuk),
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            prefixIcon: const Icon(Icons.calendar_today,
                size: 20, color: Color(0xFF1F4529)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDropdown(
  BuildContext context,
  String label,
  IconData icon,
  List<String> items,
  RxnString selected,
  Function(String?) onChanged,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F4529))),
        const SizedBox(height: 5),
        // Obx di sini sudah aman karena ini scope baru
        Obx(() => DropdownButtonFormField<String>(
          value: selected.value,
          dropdownColor: Colors.white,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13)),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon,
                size: 20, color: const Color(0xFF1F4529)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        )),
      ],
    ),
  );
}

Widget _buildPrimaryBtn(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F4529),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}