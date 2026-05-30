import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tiketinnusa/app/modules/booking/controllers/booking_controller.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F4529),
        toolbarHeight: 78,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: c.previousPage,
        ),
        title: Text(
          'Tiket ${c.dataWisata['nama'] ?? ''}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: PageView(
        controller: c.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => c.currentStep.value = i,
        children: [_StepLokasi(), _StepBiodata(), _StepBayar()],
      ),
    );
  }
}

// ── STEP 1: LOKASI ────────────────────────────────────
class _StepLokasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c    = Get.find<BookingController>();
    final lang = Get.find<PengaturanController>();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Expanded(
          child: ListView(children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F4529).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF1F4529), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${c.kategori} — ${c.dataWisata['lokasi'] ?? ''}',
                    style: const TextStyle(
                      color: Color(0xFF1F4529),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ]),
            ),
            if (c.kategori == 'Gunung') ...[
              _buildDropdownField(context,
                  label: 'Pos Perizinan Masuk',
                  icon: Icons.login,
                  items: c.jalurGunung,
                  selected: c.selectedPosMasuk,
                  onChanged: (v) => c.selectedPosMasuk.value = v),
              _buildDropdownField(context,
                  label: 'Pos Perizinan Keluar',
                  icon: Icons.logout,
                  items: c.jalurGunung,
                  selected: c.selectedPosKeluar,
                  onChanged: (v) => c.selectedPosKeluar.value = v),
            ],
            if (c.kategori == 'Pantai')
              _buildDropdownField(context,
                  label: 'Pilih Aktivitas',
                  icon: Icons.beach_access,
                  items: c.aktivitasPantai,
                  selected: c.selectedAktivitas,
                  onChanged: (v) => c.selectedAktivitas.value = v),
            if (c.kategori == 'Danau')
              _buildDropdownField(context,
                  label: 'Pilih Aktivitas',
                  icon: Icons.water,
                  items: c.aktivitasDanau,
                  selected: c.selectedAktivitasDanau,
                  onChanged: (v) => c.selectedAktivitasDanau.value = v),
            if (c.kategori == 'Air Terjun')
              _buildDropdownField(context,
                  label: 'Pilih Jalur Masuk',
                  icon: Icons.directions_walk,
                  items: c.jalurAirTerjun,
                  selected: c.selectedJalurAirTerjun,
                  onChanged: (v) => c.selectedJalurAirTerjun.value = v),
            _buildDateField(context,
                label: 'Tanggal Masuk',
                ctrl: c.tglMasukC,
                isMasuk: true),
            _buildDateField(context,
                label: 'Tanggal Keluar', ctrl: c.tglKeluarC),
            _buildTextField(
                label: 'Jumlah Pemesanan',
                icon: Icons.people_outline,
                ctrl: c.jumlahC,
                keyboardType: TextInputType.number),
          ]),
        ),
        GetBuilder<PengaturanController>(
          builder: (_) => _primaryBtn(lang.t('next'), c.nextPage),
        ),
      ]),
    );
  }
}

// ── STEP 2: BIODATA ───────────────────────────────────
class _StepBiodata extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c    = Get.find<BookingController>();
    final lang = Get.find<PengaturanController>();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Expanded(
          child: ListView(children: [
            _buildTextField(
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                ctrl: c.namaC),
            _buildTextField(
                label: 'Nomor Handphone',
                icon: Icons.phone_android,
                ctrl: c.hpC,
                keyboardType: TextInputType.phone),
            _buildTextField(
                label: 'Alamat Rumah',
                icon: Icons.home_outlined,
                ctrl: c.alamatC),
            _buildDropdownField(context,
                label: 'Negara',
                icon: Icons.flag_outlined,
                items: c.negaraList,
                selected: c.selectedNegara,
                onChanged: (v) => c.selectedNegara.value = v),
            _buildDropdownField(context,
                label: 'Gender',
                icon: Icons.wc,
                items: c.genderList,
                selected: c.selectedGender,
                onChanged: (v) => c.selectedGender.value = v),
          ]),
        ),
        GetBuilder<PengaturanController>(
          builder: (_) => _primaryBtn(lang.t('next'), c.nextPage),
        ),
      ]),
    );
  }
}

// ── STEP 3: PEMBAYARAN ────────────────────────────────
class _StepBayar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c    = Get.find<BookingController>();
    final lang = Get.find<PengaturanController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ringkasan biaya di atas ──
          Obx(() {
            c.selectedNegara.value;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F4529).withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _biayaCol('Subtotal', c.formatRupiah(c.subtotal)),
                  _biayaCol('Aktivasi (2%)',
                      c.formatRupiah(c.biayaAktivasi)),
                  _biayaCol('Total', c.formatRupiah(c.totalBiaya),
                      isTotal: true),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Detail Pesanan
                  _sectionCard(
                    title: 'Detail Pesanan',
                    icon: Icons.receipt_long,
                    children: [
                      _detailRow('Destinasi',
                          c.dataWisata['nama'] ?? '-'),
                      _detailRow('Kategori', c.kategori),
                      _detailRow(
                          'Lokasi', c.dataWisata['lokasi'] ?? '-'),
                      if (c.kategori == 'Gunung') ...[
                        Obx(() => _detailRow('Pos Masuk',
                            c.selectedPosMasuk.value ?? '-')),
                        Obx(() => _detailRow('Pos Keluar',
                            c.selectedPosKeluar.value ?? '-')),
                      ],
                      if (c.kategori == 'Pantai')
                        Obx(() => _detailRow('Aktivitas',
                            c.selectedAktivitas.value ?? '-')),
                      if (c.kategori == 'Danau')
                        Obx(() => _detailRow('Aktivitas',
                            c.selectedAktivitasDanau.value ?? '-')),
                      if (c.kategori == 'Air Terjun')
                        Obx(() => _detailRow('Jalur Masuk',
                            c.selectedJalurAirTerjun.value ?? '-')),
                      _detailRow(
                          'Tanggal Masuk',
                          c.tglMasukC.text.isEmpty
                              ? '-'
                              : c.tglMasukC.text),
                      _detailRow(
                          'Tanggal Keluar',
                          c.tglKeluarC.text.isEmpty
                              ? '-'
                              : c.tglKeluarC.text),
                      _detailRow(
                          'Jumlah Orang',
                          c.jumlahC.text.isEmpty
                              ? '-'
                              : '${c.jumlahC.text} orang'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Data Pemesan
                  _sectionCard(
                    title: 'Data Pemesan',
                    icon: Icons.person_outline,
                    children: [
                      _detailRow('Nama',
                          c.namaC.text.isEmpty ? '-' : c.namaC.text),
                      _detailRow('No. HP',
                          c.hpC.text.isEmpty ? '-' : c.hpC.text),
                      _detailRow('Alamat',
                          c.alamatC.text.isEmpty ? '-' : c.alamatC.text),
                      Obx(() => _detailRow(
                          'Negara', c.selectedNegara.value ?? '-')),
                      Obx(() => _detailRow(
                          'Gender', c.selectedGender.value ?? '-')),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Rincian Biaya
                  _sectionCard(
                    title: 'Rincian Biaya',
                    icon: Icons.payments_outlined,
                    children: [
                      Obx(() {
                        c.selectedNegara.value;
                        final jumlah =
                            int.tryParse(c.jumlahC.text) ?? 0;
                        return Column(children: [
                          _detailRow(
                            'Harga Tiket',
                            '${c.formatRupiah(c.hargaSatuan)} × $jumlah',
                          ),
                          _detailRow('Subtotal',
                              c.formatRupiah(c.subtotal)),
                          _detailRow('Biaya Aktivasi (2%)',
                              c.formatRupiah(c.biayaAktivasi)),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Pembayaran',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1F4529))),
                              Text(c.formatRupiah(c.totalBiaya),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF1F4529))),
                            ],
                          ),
                        ]);
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Tab Metode Bayar
                  _PaymentTabRow(),
                  const SizedBox(height: 12),

                  // 5. Konten QRIS / Kartu
                  SizedBox(
                    height: 520,
                    child: _PaymentContent(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Tombol Konfirmasi (tetap di bawah) ──
          Obx(() {
            final bisa = c.sudahUpload.value;
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: bisa ? c.konfirmasiBayar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bisa
                      ? const Color(0xFF1F4529)
                      : Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      bisa
                          ? Icons.check_circle_outline
                          : Icons.lock_outline,
                      size: 18,
                      color: bisa ? Colors.white : Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    GetBuilder<PengaturanController>(
                      builder: (_) => Text(
                        bisa
                            ? lang.t('confirm_pay')
                            : 'Upload Bukti Terlebih Dahulu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                              bisa ? Colors.white : Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _biayaCol(String label, String value,
      {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: isTotal
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal
                  ? const Color(0xFF1F4529)
                  : Colors.black87,
            )),
      ],
    );
  }
}

// ── PAYMENT TAB ROW ───────────────────────────────────
class _PaymentTabRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();
    return Obx(() => Row(children: [
          _tab(c, 'QRIS', Icons.qr_code_scanner),
          const SizedBox(width: 10),
          _tab(c, 'Kartu Kredit/Debit', Icons.credit_card),
        ]));
  }

  Widget _tab(BookingController c, String label, IconData icon) {
    final isActive = c.selectedPayment.value == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.selectedPayment.value = label,
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
                  color: isActive ? Colors.white : Colors.black54,
                  size: 16),
              const SizedBox(width: 5),
              Flexible(
                child: Text(label,
                    style: TextStyle(
                      color:
                          isActive ? Colors.white : Colors.black54,
                      fontSize: 10,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PAYMENT CONTENT ───────────────────────────────────
class _PaymentContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();
    return Obx(() {
      if (c.selectedPayment.value == 'Kartu Kredit/Debit') {
        return ListView(children: [
          _buildDropdownField(context,
              label: 'Pilih Bank / Jaringan',
              icon: Icons.account_balance,
              items: c.banks,
              selected: c.selectedBank,
              onChanged: (v) => c.selectedBank.value = v),
          _buildTextField(
              label: 'Nomor Kartu', icon: Icons.credit_card),
          Row(children: [
            Expanded(child: _buildTextField(
                label: 'Exp',
                icon: Icons.calendar_month,
                ctrl: c.expiredC,
                readOnly: true)),
            const SizedBox(width: 15),
            Expanded(child: _buildTextField(
                label: 'CVV',
                icon: Icons.lock_outline,
                ctrl: c.codeC,
                readOnly: true)),
          ]),
          const SizedBox(height: 10),
          _UploadBukti(),
        ]);
      }

      // ── QRIS ──
      final previewData = [
        'TIKET:${c.nomorTiket}',
        'DESTINASI:${c.dataWisata['nama'] ?? ''}',
        'KATEGORI:${c.kategori}',
        'PEMESAN:${c.namaC.text.isEmpty ? '-' : c.namaC.text}',
        'TGL_MASUK:${c.tglMasukC.text.isEmpty ? '-' : c.tglMasukC.text}',
        'TGL_KELUAR:${c.tglKeluarC.text.isEmpty ? '-' : c.tglKeluarC.text}',
        'JUMLAH:${c.jumlahC.text}',
        'TOTAL:${c.totalBiaya}',
        'METODE:QRIS',
        'STATUS:PENDING',
      ].join('|');

      return SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(children: [
              // Header total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1F4529),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                child: Column(children: [
                  const Text('Total Pembayaran',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Obx(() {
                    c.selectedNegara.value;
                    return Text(
                      c.formatRupiah(c.totalBiaya),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                  const SizedBox(height: 2),
                  Text(
                    'a.n. ${c.namaC.text.isEmpty ? 'Pemesan' : c.namaC.text}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ]),
              ),

              // QR dari qr_flutter
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(children: [
                    QrImageView(
                      data: previewData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.nomorTiket,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('TiketinNusa — QRIS Payment',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey)),
                  ]),
                ),
              ),

              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scan QR di atas lalu upload '
                        'bukti pembayaran sebelum konfirmasi.',
                        style: TextStyle(
                            fontSize: 11, color: Colors.blue),
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _UploadBukti(),
          const SizedBox(height: 16),
        ]),
      );
    });
  }
}

// ── UPLOAD BUKTI ──────────────────────────────────────
class _UploadBukti extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<BookingController>();
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bukti Pembayaran',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F4529))),
            const SizedBox(height: 4),
            const Text('Upload foto/screenshot bukti transfer Anda',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 10),
            if (c.buktiBayar.value != null) ...[
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    c.buktiBayar.value!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: c.hapusBukti,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F4529),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Bukti Terunggah',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: c.pilihBuktiBayar,
                icon: const Icon(Icons.refresh,
                    size: 16, color: Color(0xFF1F4529)),
                label: const Text('Ganti Foto',
                    style: TextStyle(
                        color: Color(0xFF1F4529), fontSize: 12)),
              ),
            ] else ...[
              GestureDetector(
                onTap: c.isUploading.value ? null : c.pilihBuktiBayar,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: c.isUploading.value
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF1F4529)))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Ketuk untuk upload bukti',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('JPG, PNG (maks. 5MB)',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[400])),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text('Wajib upload bukti untuk konfirmasi',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500)),
              ]),
            ],
          ],
        ));
  }
}

// ── SHARED HELPERS ────────────────────────────────────

Widget _sectionCard({
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 16, color: const Color(0xFF1F4529)),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1F4529))),
        ]),
        const Divider(height: 16),
        ...children,
      ],
    ),
  );
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey)),
        ),
        const Text(' : ',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ),
      ],
    ),
  );
}

Widget _buildTextField({
  required String label,
  required IconData icon,
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
        Text(label,
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
            fillColor: readOnly ? Colors.grey[50] : Colors.white,
            prefixIcon:
                Icon(icon, size: 20, color: const Color(0xFF1F4529)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF1F4529), width: 2),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDateField(
  BuildContext context, {
  required String label,
  required TextEditingController ctrl,
  bool isMasuk = false,
}) {
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

Widget _buildDropdownField(
  BuildContext context, {
  required String label,
  required IconData icon,
  required List<String> items,
  required RxnString selected,
  required Function(String?) onChanged,
}) {
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
        Obx(() => DropdownButtonFormField<String>(
              value: selected.value,
              dropdownColor: Colors.white,
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: const TextStyle(fontSize: 13))))
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

Widget _primaryBtn(String text, VoidCallback onPressed) {
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