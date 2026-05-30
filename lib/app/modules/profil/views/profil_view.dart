import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/profil/controllers/profil_controller.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';

class ProfilView extends StatelessWidget {
  const ProfilView({super.key});

void _showUpgradeDialog(BuildContext context,
    ProfilController c, PengaturanController lang) {
  final namaC  = TextEditingController();
  final emailC = TextEditingController();
  final passC  = TextEditingController();

  Get.dialog(
    AlertDialog(
      title: const Text('Buat Akun Permanen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Daftarkan diri Anda agar data tidak hilang.',
              style: TextStyle(
                  color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _dialogField('Nama Lengkap', namaC),
            _dialogField('E-Mail', emailC),
            _dialogField('Kata Sandi', passC,
                isPassword: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (namaC.text.isEmpty ||
                emailC.text.isEmpty ||
                passC.text.isEmpty) {
              Get.snackbar('Peringatan',
                  'Semua field wajib diisi.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white);
              return;
            }
            Get.back();
            final result = await FirebaseService.to
                .upgradeTamu(
              namaC.text.trim(),
              emailC.text.trim(),
              passC.text.trim(),
            );
            if (result != null) {
              await lang.loadProfil();
              Get.snackbar(
                '✅ Berhasil',
                'Akun berhasil dibuat!',
                backgroundColor: const Color(0xFF1F4529),
                colorText: Colors.white,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F4529),
          ),
          child: const Text('Daftar',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

Widget _dialogField(String hint,
    TextEditingController ctrl,
    {bool isPassword = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final c    = Get.find<ProfilController>();
    final lang = Get.find<PengaturanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE9EBEA),
      body: SingleChildScrollView(
        child: Column(children: [
          // ── HEADER ──
          Container(
            height: 144, width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 60, 20, 0),
            decoration:
                const BoxDecoration(color: Color(0xFF1F4529)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GetBuilder<PengaturanController>(
                    builder: (_) => Text(
                      lang.t('profile_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ── FOTO ──
          const CircleAvatar(
            radius: 82,
            backgroundColor: Color(0xFF1F4529),
            child: CircleAvatar(radius: 80,
              backgroundImage:
                  AssetImage('assets/favicon.png')),
          ),

          const SizedBox(height: 15),

          // ── NAMA reaktif ──
          GetBuilder<PengaturanController>(
            builder: (_) => Text(
              lang.name.value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),


// Banner upgrade akun tamu
if (lang.isTamu) ...[
  const SizedBox(height: 10),
  Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.orange[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange.shade200),
    ),
    child: Row(children: [
      const Icon(Icons.warning_amber_rounded,
          color: Colors.orange, size: 22),
      const SizedBox(width: 10),
      const Expanded(
        child: Text(
          'Anda masuk sebagai tamu.\nDaftar untuk menyimpan data Anda.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
          ),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () => _showUpgradeDialog(
            Get.context!, c, lang),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Daftar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ]),
  ),
],

          // ── TOMBOL EDIT ──
          GetBuilder<PengaturanController>(
            builder: (_) => TextButton.icon(
              onPressed: () => _showEditDialog(context, c, lang),
              icon: const Icon(Icons.edit,
                  size: 18, color: Colors.black54),
              label: Text(
                lang.t('edit_profile'),
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GetBuilder<PengaturanController>(
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── JUDUL TENTANG ──
                  Text(lang.t('about'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                    )),
                  const SizedBox(height: 10),

                  // ── CARD NAMA & EMAIL ──
                  _profileCard(children: [
                    _rowInfo(
                        lang.t('full_name'), lang.name.value),
                    const Divider(height: 1),
                    _rowInfo(
                        lang.t('email_label'), lang.email.value),
                  ]),
                  const SizedBox(height: 15),

                  // ── CARD TELEPON ──
                  _profileCard(children: [
                    _rowInfo(
                        lang.t('phone_label'), lang.phone.value),
                  ]),
                  const SizedBox(height: 25),

                  // ── TOMBOL KELUAR ──
                  GestureDetector(
                    onTap: c.keluar,
                    child: _actionCard(
                      icon: Icons.logout,
                      text: lang.t('logout'),
                      textColor: Colors.grey[700]!,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ── TOMBOL HAPUS AKUN ──
                  GestureDetector(
                    onTap: c.hapusAkun,
                    child: _actionCard(
                      icon: Icons.delete_outline,
                      text: lang.t('delete_account'),
                      textColor: Colors.red,
                      iconColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  // ── DIALOG EDIT ──────────────────────────────────────
  void _showEditDialog(BuildContext context,
      ProfilController c, PengaturanController lang) {
    // Sync nilai terkini sebelum buka dialog
    c.nameC.text  = lang.name.value;
    c.emailC.text = lang.email.value;
    c.phoneC.text = lang.phone.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              GetBuilder<PengaturanController>(
                builder: (_) => Text(
                  lang.t('edit_profile'),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              _editField(lang.t('full_name'),  c.nameC),
              _editField(lang.t('email_label'), c.emailC),
              _editField(lang.t('phone_label'), c.phoneC),
              const SizedBox(height: 20),
              GetBuilder<PengaturanController>(
                builder: (_) => ElevatedButton(
                  onPressed: c.simpanPerubahan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4529),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  child: Text(lang.t('save_changes'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
        ),
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────
  Widget _editField(String label,
      TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Color(0xFF1F4529)),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
                color: Color(0xFF1F4529)),
          ),
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 12, horizontal: 15),
      child: Row(children: [
        Expanded(flex: 3,
          child: Text(label,
              style: TextStyle(color: Colors.grey[600]))),
        const Text(' :  '),
        Expanded(flex: 5,
          child: Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold))),
      ]),
    );
  }

  Widget _profileCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )],
      ),
      child: Column(children: children),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String text,
    required Color textColor,
    Color iconColor = Colors.grey,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 15),
        Text(text, style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold)),
        const Spacer(),
        const Icon(Icons.chevron_right,
            color: Colors.grey, size: 20),
      ]),
    );
  }
}