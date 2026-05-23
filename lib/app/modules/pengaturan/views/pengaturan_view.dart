import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/pengaturan/controllers/pengaturan_controller.dart';
import 'package:tiketinnusa/app/routes/app_routes.dart';
import 'package:tiketinnusa/app/widgets/destinasi_search_delegate.dart';

class PengaturanView extends StatelessWidget {
  const PengaturanView({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<PengaturanController>();
    return Scaffold(
      backgroundColor: const Color(0xFFE8EFED),
      body: SingleChildScrollView(
        child: Column(children: [
          _buildHeader(context, lang),
          // Seluruh konten dibungkus 1 GetBuilder
          GetBuilder<PengaturanController>(
            builder: (_) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── PROFIL ──
                  Center(child: Column(children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF1F4529),
                      child: CircleAvatar(radius: 47,
                        backgroundImage:
                            AssetImage('assets/favicon.png')),
                    ),
                    const SizedBox(height: 12),
                    Text(lang.name.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F4529),
                      )),
                    Text(lang.email.value,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey)),
                  ])),
                  const SizedBox(height: 30),

                  // ── JUDUL ──
                  Text(lang.t('settings'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F4529),
                    )),
                  const SizedBox(height: 15),

                  // ── MENU AKUN ──
                  _menuCard(
                    icon: Icons.person_outline,
                    title: lang.t('acc_info'),
                    onTap: () =>
                        Get.toNamed(AppRoutes.PROFIL),
                  ),

                  // ── NOTIFIKASI ──
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF1F4529)),
                      title: Text(lang.t('notif')),
                      trailing: Switch(
                        value: lang.isNotificationOn.value,
                        activeColor: const Color(0xFF1F4529),
                        onChanged: (v) {
                          lang.isNotificationOn.value = v;
                          lang.update();
                        },
                      ),
                    ),
                  ),

                  // ── BAHASA ──
                  _menuCard(
                    icon: Icons.language,
                    title: lang.t('lang'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(lang.selectedLanguage.value,
                          style: const TextStyle(
                              color: Colors.grey)),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey),
                      ],
                    ),
                    onTap: () =>
                        _showLanguagePicker(context, lang),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context,
      PengaturanController lang) {
    return Container(
      height: 144, width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      decoration:
          const BoxDecoration(color: Color(0xFF1F4529)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<PengaturanController>(
            builder: (_) => Text(
              lang.t('app_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(children: [
            IconButton(
              icon: const Icon(Icons.search,
                  color: Colors.white, size: 28),
              onPressed: () => showSearch(
                context: context,
                delegate: DestinasiSearchDelegate(),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.white, size: 30,
              ),
              onPressed: () =>
                  Get.toNamed(AppRoutes.NOTIFIKASI),
            ),
          ]),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context,
      PengaturanController lang) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)),
        ),
        child: GetBuilder<PengaturanController>(
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(lang.t('choose_lang'),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Indonesia'),
                trailing: lang.selectedLanguage.value ==
                        'Indonesia'
                    ? const Icon(Icons.check,
                        color: Color(0xFF1F4529))
                    : null,
                onTap: () {
                  lang.setLanguage('Indonesia');
                  Get.back();
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: lang.selectedLanguage.value ==
                        'English'
                    ? const Icon(Icons.check,
                        color: Color(0xFF1F4529))
                    : null,
                onTap: () {
                  lang.setLanguage('English');
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1F4529)),
        title: Text(title),
        trailing: trailing ??
            const Icon(Icons.chevron_right,
                color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}