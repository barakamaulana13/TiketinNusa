import 'package:get/get.dart';
import 'package:tiketinnusa/app/services/firebase_service.dart';

class PengaturanController extends GetxController {
  // Singleton accessor
  static PengaturanController get to => Get.find();

  // ── STATE ──────────────────────────────────────────────
  final selectedLanguage  = 'Indonesia'.obs;
  final isNotificationOn  = true.obs;
  final isLoading         = false.obs;
  final name              = 'Memuat...'.obs;
  final email             = ''.obs;
  final phone             = ''.obs;

  // ── LIFECYCLE ──────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadProfil();
  }

bool get isTamu => FirebaseService.to.isTamu;

  // ── FIREBASE ───────────────────────────────────────────
  Future<void> loadProfil() async {
    isLoading.value = true;
    try {
      final data = await FirebaseService.to.getProfil();
      if (data != null) {
        name.value  = data['nama']  ?? '';
        email.value = data['email'] ?? '';
        phone.value = data['phone'] ?? '';
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> updateProfile(
      String newName, String newEmail, String newPhone) async {
    await FirebaseService.to.updateProfil(newName, newEmail, newPhone);
    name.value  = newName;
    email.value = newEmail;
    phone.value = newPhone;
  }

  // ── BAHASA ─────────────────────────────────────────────
 void setLanguage(String lang) {
  selectedLanguage.value = lang;
  update(); 
}

// Begitu juga updateProfile:
Future<void> updateProfil(
    String newName, String newEmail, String newPhone) async {
  await FirebaseService.to.updateProfil(newName, newEmail, newPhone);
  name.value  = newName;
  email.value = newEmail;
  phone.value = newPhone;
  update(); 
}

  String t(String key) =>
      _tr[selectedLanguage.value]?[key] ?? key;

  // ── TERJEMAHAN ─────────────────────────────────────────
  final Map<String, Map<String, String>> _tr = {
    'Indonesia': {
      // Umum
      'app_title'       : 'TiketinNusa',
      'search_hint'     : 'Cari destinasi...',
      'view_all'        : 'Lihat Semua',
      'save'            : 'Simpan',
      'close'           : 'Tutup',
      'cancel'          : 'Batal',
      'delete'          : 'Hapus',
      'logout'          : 'Keluar',
      'save_changes'    : 'Simpan Perubahan',
      'book_now'        : 'Booking Sekarang',
      // Beranda
      'home_greeting'   : 'Halo, Mau Liburan Kemana?',
      'home_subtitle'   : 'Temukan destinasi impianmu dan nikmati perjalanan tak terlupakan bersama kami.',
      'ticket_menu'     : 'Pesan Tiket Masuk',
      'popular'         : 'Wisata Alam Terpopuler',
      // Kategori
      'cat_mountain'    : 'Gunung',
      'cat_waterfall'   : 'Air Terjun',
      'cat_beach'       : 'Pantai',
      'cat_lake'        : 'Danau',
      // Bottom nav
      'nav_home'        : 'Beranda',
      'nav_ticket'      : 'Tiket',
      'nav_saved'       : 'Simpan',
      'nav_settings'    : 'Pengaturan',
      // Tiket
      'no_ticket'       : 'Belum Ada Riwayat Tiket',
      'start_order'     : 'Mulai Pesan',
      'visit_date'      : 'Kunjungan',
      'receipt_title'   : 'E-STRUK PEMBAYARAN',
      // Keranjang
      'no_saved'        : 'Anda Belum Menyimpan Apapun',
      'find_now'        : 'Cari Sekarang',
      // Notifikasi
      'notif_title'     : 'Notifikasi',
      'no_notif'        : 'Tidak ada notifikasi',
      // Pengaturan
      'settings'        : 'Pengaturan',
      'acc_info'        : 'Informasi Akun',
      'notif'           : 'Notifikasi',
      'lang'            : 'Bahasa',
      'choose_lang'     : 'Pilih Bahasa',
      // Profil
      'profile_title'   : 'Informasi Akun',
      'about'           : 'Tentang',
      'full_name'       : 'Nama Lengkap',
      'email_label'     : 'E-Mail',
      'phone_label'     : 'Nomor Telepon',
      'edit_profile'    : 'Edit Profil',
      'delete_account'  : 'Hapus Akun',
      'delete_confirm'  : 'Apakah Anda yakin ingin menghapus akun?',
      // Booking
      'total_cost'      : 'Total Biaya :',
      'online_fee'      : 'Includes Online Activations (2.0%)',
      'next'            : 'Berikutnya',
      'confirm_pay'     : 'Konfirmasi Bayar',
      'entry_date'      : 'Tanggal Masuk',
      'exit_date'       : 'Tanggal Keluar',
      'qty'             : 'Jumlah Pemesanan',
      'full_name_input' : 'Masukkan Nama',
      'phone_input'     : 'Masukkan Nomor Handphone',
      'address_input'   : 'Masukkan Alamat Rumah',
      'country'         : 'Negara',
      'gender'          : 'Gender',
      'select_bank'     : 'Pilih Bank / Jaringan',
      'pay_success'     : 'Booking Berhasil!',
      'finish'          : 'Selesai',
      // Detail wisata
      'access_route'    : 'Jalur Akses',
      'tariff_info'     : 'Informasi Tarif',
      'weekday_wni'     : 'WNI - Hari Kerja',
      'weekend_wni'     : 'WNI - Akhir Pekan',
      'weekday_wna'     : 'WNA - Hari Kerja',
      'weekend_wna'     : 'WNA - Akhir Pekan',
      'free'            : 'Gratis',
      // Login & Register
      'welcome'         : 'Selamat Datang!',
      'login_sub'       : 'Silahkan Masuk Ke Akun Anda',
      'register_sub'    : 'Silahkan Daftar Akun Anda',
      'email_hint'      : 'E-Mail',
      'password_hint'   : 'Kata Sandi',
      'forgot_pass'     : 'Lupa Kata Sandi?',
      'login_btn'       : 'Masuk',
      'or_login_with'   : 'Atau Masuk Dengan',
      'no_account'      : 'Belum punya akun? ',
      'register_link'   : 'Daftar',
      'register_btn'    : 'Daftar',
      'or_register_with': 'Atau Daftar Dengan',
      'have_account'    : 'Sudah punya akun? ',
      'login_link'      : 'Masuk',
      'confirm_pass'    : 'Konfirmasi Kata Sandi',
    },
    'English': {
      // Umum
      'app_title'       : 'TiketinNusa',
      'search_hint'     : 'Search destination...',
      'view_all'        : 'View All',
      'save'            : 'Save',
      'close'           : 'Close',
      'cancel'          : 'Cancel',
      'delete'          : 'Delete',
      'logout'          : 'Logout',
      'save_changes'    : 'Save Changes',
      'book_now'        : 'Book Now',
      // Beranda
      'home_greeting'   : 'Hello, Where to Vacation?',
      'home_subtitle'   : 'Find your dream destination and enjoy an unforgettable journey with us.',
      'ticket_menu'     : 'Buy Entry Ticket',
      'popular'         : 'Most Popular Nature Tourism',
      // Kategori
      'cat_mountain'    : 'Mountain',
      'cat_waterfall'   : 'Waterfall',
      'cat_beach'       : 'Beach',
      'cat_lake'        : 'Lake',
      // Bottom nav
      'nav_home'        : 'Home',
      'nav_ticket'      : 'Tickets',
      'nav_saved'       : 'Saved',
      'nav_settings'    : 'Settings',
      // Tiket
      'no_ticket'       : 'No Ticket History Yet',
      'start_order'     : 'Start Ordering',
      'visit_date'      : 'Visit',
      'receipt_title'   : 'PAYMENT RECEIPT',
      // Keranjang
      'no_saved'        : 'You Have Not Saved Anything',
      'find_now'        : 'Find Now',
      // Notifikasi
      'notif_title'     : 'Notifications',
      'no_notif'        : 'No notifications',
      // Pengaturan
      'settings'        : 'Settings',
      'acc_info'        : 'Account Information',
      'notif'           : 'Notifications',
      'lang'            : 'Language',
      'choose_lang'     : 'Select Language',
      // Profil
      'profile_title'   : 'Account Information',
      'about'           : 'About',
      'full_name'       : 'Full Name',
      'email_label'     : 'E-Mail',
      'phone_label'     : 'Phone Number',
      'edit_profile'    : 'Edit Profile',
      'delete_account'  : 'Delete Account',
      'delete_confirm'  : 'Are you sure you want to delete your account?',
      // Booking
      'total_cost'      : 'Total Cost:',
      'online_fee'      : 'Includes Online Activations (2.0%)',
      'next'            : 'Next',
      'confirm_pay'     : 'Confirm Payment',
      'entry_date'      : 'Entry Date',
      'exit_date'       : 'Exit Date',
      'qty'             : 'Number of Orders',
      'full_name_input' : 'Enter Name',
      'phone_input'     : 'Enter Phone Number',
      'address_input'   : 'Enter Home Address',
      'country'         : 'Country',
      'gender'          : 'Gender',
      'select_bank'     : 'Select Bank / Network',
      'pay_success'     : 'Booking Successful!',
      'finish'          : 'Done',
      // Detail wisata
      'access_route'    : 'Access Route',
      'tariff_info'     : 'Tariff Information',
      'weekday_wni'     : 'Local - Weekday',
      'weekend_wni'     : 'Local - Weekend',
      'weekday_wna'     : 'Foreign - Weekday',
      'weekend_wna'     : 'Foreign - Weekend',
      'free'            : 'Free',
      // Login & Register
      'welcome'         : 'Welcome!',
      'login_sub'       : 'Please Login to Your Account',
      'register_sub'    : 'Please Register Your Account',
      'email_hint'      : 'E-Mail',
      'password_hint'   : 'Password',
      'forgot_pass'     : 'Forgot Password?',
      'login_btn'       : 'Login',
      'or_login_with'   : 'Or Login With',
      'no_account'      : "Don't have an account? ",
      'register_link'   : 'Register',
      'register_btn'    : 'Register',
      'or_register_with': 'Or Register With',
      'have_account'    : 'Already have an account? ',
      'login_link'      : 'Login',
      'confirm_pass'    : 'Confirm Password',
    },
  };
}