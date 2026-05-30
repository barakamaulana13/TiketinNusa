import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  static FirebaseService get to => Get.find();

  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  // ── REACTIVE USER ─────────────────────────────────────
  final Rxn<User> _currentUser = Rxn<User>();

  User? get currentUser => _currentUser.value;
  String get uid => currentUser?.uid ?? '';
  bool get isTamu => currentUser?.isAnonymous ?? false;

  @override
  void onInit() {
    super.onInit();
    // Sinkron pertama kali (pakai currentUser dari FirebaseAuth langsung)
    _currentUser.value = _auth.currentUser;

    // Listen perubahan auth state secara reaktif
    _auth.authStateChanges().listen((user) {
      _currentUser.value = user;
    });
  }

  // ── AUTH EMAIL ────────────────────────────────────────

  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Gagal', _authError(e.code),
          backgroundColor: const Color(0xFF1F4529),
          colorText: Colors.white);
      return null;
    }
  }

  Future<UserCredential?> register(
      String nama, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _simpanProfilBaru(cred.user!.uid, nama, email);
      return cred;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registrasi Gagal', _authError(e.code),
          backgroundColor: const Color(0xFF1F4529),
          colorText: Colors.white);
      return null;
    }
  }

  // ── TAMU ──────────────────────────────────────────────

  Future<UserCredential?> loginTamu() async {
    try {
      final cred = await _auth.signInAnonymously();
      await _db.collection('users').doc(cred.user!.uid).set({
        'nama': 'Tamu',
        'email': '',
        'phone': '',
        'isTamu': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return cred;
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal masuk sebagai tamu. Coba lagi.',
          backgroundColor: const Color(0xFF1F4529),
          colorText: Colors.white);
      return null;
    }
  }

  Future<UserCredential?> upgradeTamu(
      String nama, String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
          email: email, password: password);
      final cred =
          await currentUser!.linkWithCredential(credential);
      await _db.collection('users').doc(cred.user!.uid).update({
        'nama': nama,
        'email': email,
        'isTamu': false,
      });
      return cred;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Gagal', _authError(e.code),
          backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  // ── LOGOUT ────────────────────────────────────────────

  Future<void> logout() async => await _auth.signOut();

  // ── PROFIL ────────────────────────────────────────────

  Future<void> _simpanProfilBaru(
      String uid, String nama, String email) async {
    await _db.collection('users').doc(uid).set({
      'nama': nama,
      'email': email,
      'phone': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getProfil() async {
    if (uid.isEmpty) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateProfil(
      String nama, String email, String phone) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).update({
      'nama': nama,
      'email': email,
      'phone': phone,
    });
  }

  Future<void> deleteAccount() async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).delete();
    await currentUser?.delete();
  }

  // ── DESTINASI ─────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> streamDestinasi() {
  return _db
      .collection('destinasi')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) {
            final data = d.data();
            // Ambil imageUrl dari field manapun yang tersedia
            final imgUrl = data['imageUrl']?.toString() ??
                           data['image']?.toString() ??
                           data['gambar']?.toString() ?? '';
            return {
              'id'        : d.id,
              'nama'      : data['nama']       ?? '',
              'kategori'  : data['kategori']   ?? '',
              'lokasi'    : data['lokasi']      ?? '',
              'wilayah'   : data['wilayah']     ?? '',
              'imageUrl'  : imgUrl,   // ← selalu ada
              'image'     : imgUrl,   // ← alias
              'jalur'     : data['jalur']       ?? '',
              'ketinggian': data['ketinggian']  ?? '',
              'estimasi'  : data['estimasi']    ?? '',
              'tipe_pasir': data['tipe_pasir']  ?? '',
              'suhu'      : data['suhu']        ?? '',
              'kedalaman' : data['kedalaman']   ?? '',
              'status'    : data['status']      ?? '',
              'jarak_trek': data['jarak_trek']  ?? '',
              'durasi'    : data['durasi']      ?? '',
              'Tarif Hari Kerja (WNI)'  : data['Tarif Hari Kerja (WNI)']  ?? '0',
              'Tarif Akhir Pekan (WNI)' : data['Tarif Akhir Pekan (WNI)'] ?? '0',
              'Tarif Hari Kerja (WNA)'  : data['Tarif Hari Kerja (WNA)']  ?? '0',
              'Tarif Akhir Pekan (WNA)' : data['Tarif Akhir Pekan (WNA)'] ?? '0',
            };
          }).toList());
}

  Stream<List<Map<String, dynamic>>> streamDestinasiByKategori(
      String kategori) {
    return _db
        .collection('destinasi')
        .where('kategori', isEqualTo: kategori)
        .snapshots()
        .map((s) => s.docs.map((d) => _mapDestinasi(d)).toList());
  }

  Map<String, dynamic> _mapDestinasi(
    QueryDocumentSnapshot<Map<String, dynamic>> d) {
  final data = d.data();

  return {
    'id': d.id,
    'nama': data['nama'] ?? '',
    'kategori': data['kategori'] ?? '',
    'lokasi': data['lokasi'] ?? '',
    'wilayah': data['wilayah'] ?? '',

    'imageUrl': data['imageUrl'] ?? data['image'] ?? '',
    'image': data['imageUrl'] ?? data['image'] ?? '',

    'jalur': data['jalur'] ?? '',
    'ketinggian': data['ketinggian'] ?? '',
    'estimasi': data['estimasi'] ?? '',
    'tipe_pasir': data['tipe_pasir'] ?? '',
    'suhu': data['suhu'] ?? '',
    'kedalaman': data['kedalaman'] ?? '',
    'status': data['status'] ?? '',
    'jarak_trek': data['jarak_trek'] ?? '',
    'durasi': data['durasi'] ?? '',
    'Tarif Hari Kerja (WNI)': data['Tarif Hari Kerja (WNI)'] ?? '0',
    'Tarif Akhir Pekan (WNI)': data['Tarif Akhir Pekan (WNI)'] ?? '0',
    'Tarif Hari Kerja (WNA)': data['Tarif Hari Kerja (WNA)'] ?? '0',
    'Tarif Akhir Pekan (WNA)': data['Tarif Akhir Pekan (WNA)'] ?? '0',
  };
}

  // ── TIKET ─────────────────────────────────────────────

  Future<String?> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<void> simpanTiket(Map<String, dynamic> tiket) async {
    if (uid.isEmpty) return;
    final docRef = _db
        .collection('users')
        .doc(uid)
        .collection('tikets')
        .doc(tiket['nomorTiket'] as String);

    await docRef.set({
      ...tiket,
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> hapusTiket(String docId) async {
    if (uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('tikets')
        .doc(docId)
        .delete();
  }

  /// Stream real-time tiket milik user yang sedang login.
  /// Menggunakan snapshots() sehingga perubahan status dari admin
  /// (Menunggu Konfirmasi → Lunas / Ditolak) langsung terefleksi.
  Stream<List<Map<String, dynamic>>> streamTikets() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('tikets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ── SIMPANAN ──────────────────────────────────────────

  Future<void> simpanDestinasi(Map<String, dynamic> item) async {
    if (uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('simpanan')
        .doc(item['nama'])
        .set(item);
  }

  Future<void> hapusSimpanan(String nama) async {
    if (uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('simpanan')
        .doc(nama)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> streamSimpanan() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('simpanan')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ── NOTIFIKASI ────────────────────────────────────────

  /// Tambah notifikasi untuk user yang sedang login.
  /// Menyimpan field 'isi' DAN 'pesan' agar kompatibel dengan
  /// admin dashboard yang menulis field 'pesan'.
  Future<void> tambahNotifikasi(String judul, String isi) async {
    if (uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifikasi')
        .add({
      'judul'    : judul,
      'isi'      : isi,   // field lama — tetap disimpan
      'pesan'    : isi,   // field baru — dipakai admin dashboard
      'waktu'    : 'Baru saja',
      'dibaca'   : false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Tambah notifikasi ke user LAIN berdasarkan userId-nya.
  /// Digunakan oleh fitur internal (misalnya push dari sisi server/admin Flutter).
  /// Admin dashboard (HTML) menulis langsung ke Firestore,
  /// sehingga method ini hanya diperlukan jika ada logika admin di Flutter.
  Future<void> tambahNotifikasiKeUser(
      String targetUid, String judul, String isi) async {
    if (targetUid.isEmpty) return;
    await _db
        .collection('users')
        .doc(targetUid)
        .collection('notifikasi')
        .add({
      'judul'    : judul,
      'isi'      : isi,
      'pesan'    : isi,
      'waktu'    : 'Baru saja',
      'dibaca'   : false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> hapusNotifikasi(String docId) async {
    if (uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifikasi')
        .doc(docId)
        .delete();
  }

  /// Tandai satu notifikasi sebagai sudah dibaca.
  Future<void> tandaiNotifikasiBaca(String docId) async {
    if (uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifikasi')
        .doc(docId)
        .update({'dibaca': true});
  }

  /// Tandai semua notifikasi sebagai sudah dibaca sekaligus (batch write).
  Future<void> tandaiSemuaNotifikasiBaca() async {
    if (uid.isEmpty) return;
    final docs = await _db
        .collection('users')
        .doc(uid)
        .collection('notifikasi')
        .where('dibaca', isEqualTo: false)
        .get();
    if (docs.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in docs.docs) {
      batch.update(d.reference, {'dibaca': true});
    }
    await batch.commit();
  }

  Future<void> hapusSemuaNotifikasi() async {
    if (uid.isEmpty) return;
    final batch = _db.batch();
    final docs  = await _db
        .collection('users')
        .doc(uid)
        .collection('notifikasi')
        .get();
    for (final d in docs.docs) batch.delete(d.reference);
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> streamNotifikasi() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifikasi')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = d.data();
              // Kompatibel dengan field 'isi' (lama) & 'pesan' (dari admin dashboard)
              final teks = data['isi']?.toString().isNotEmpty == true
                  ? data['isi']
                  : data['pesan'] ?? '';
              return {
                'id'   : d.id,
                ...data,
                'isi'  : teks,
                'pesan': teks,
              };
            }).toList());
  }

  // ── RIWAYAT SEARCH ────────────────────────────────────

  Future<void> simpanRiwayatSearch(String query) async {
    if (uid.isEmpty || query.trim().isEmpty) return;
    final existing = await _db
        .collection('users')
        .doc(uid)
        .collection('riwayat_search')
        .where('query', isEqualTo: query.trim())
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference
          .update({'createdAt': FieldValue.serverTimestamp()});
    } else {
      await _db
          .collection('users')
          .doc(uid)
          .collection('riwayat_search')
          .add({
        'query': query.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<Map<String, dynamic>>> streamRiwayatSearch() {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('riwayat_search')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> hapusRiwayatSearch(String docId) async {
    if (uid.isEmpty) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('riwayat_search')
        .doc(docId)
        .delete();
  }

  Future<void> hapusSemuaRiwayat() async {
    if (uid.isEmpty) return;
    final batch = _db.batch();
    final docs  = await _db
        .collection('users')
        .doc(uid)
        .collection('riwayat_search')
        .get();
    for (final d in docs.docs) batch.delete(d.reference);
    await batch.commit();
  }

  // ── AUTH ERROR ────────────────────────────────────────

  String _authError(String code) {
    switch (code) {
      case 'user-not-found':        return 'Email tidak terdaftar.';
      case 'wrong-password':        return 'Kata sandi salah.';
      case 'email-already-in-use':  return 'Email sudah digunakan.';
      case 'weak-password':         return 'Kata sandi min 6 karakter.';
      case 'invalid-email':         return 'Format email tidak valid.';
      default:                      return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}