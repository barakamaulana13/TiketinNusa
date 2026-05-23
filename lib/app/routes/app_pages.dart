import 'package:get/get.dart';
import 'package:tiketinnusa/app/modules/splash/bindings/splash_binding.dart';
import 'package:tiketinnusa/app/modules/splash/views/splash_view.dart';
import 'package:tiketinnusa/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:tiketinnusa/app/modules/onboarding/views/onboarding_view.dart';
import 'package:tiketinnusa/app/modules/login/bindings/login_binding.dart';
import 'package:tiketinnusa/app/modules/login/views/login_view.dart';
import 'package:tiketinnusa/app/modules/registrasi/bindings/registrasi_binding.dart';
import 'package:tiketinnusa/app/modules/registrasi/views/registrasi_view.dart';
import 'package:tiketinnusa/app/modules/beranda/bindings/beranda_binding.dart';
import 'package:tiketinnusa/app/modules/beranda/views/beranda_view.dart';
import 'package:tiketinnusa/app/modules/booking/bindings/booking_binding.dart';
import 'package:tiketinnusa/app/modules/booking/views/booking_view.dart';
import 'package:tiketinnusa/app/modules/tiket/bindings/tiket_binding.dart';
import 'package:tiketinnusa/app/modules/tiket/views/tiket_view.dart';
import 'package:tiketinnusa/app/modules/keranjang/bindings/keranjang_binding.dart';
import 'package:tiketinnusa/app/modules/keranjang/views/keranjang_view.dart';
import 'package:tiketinnusa/app/modules/notifikasi/bindings/notifikasi_binding.dart';
import 'package:tiketinnusa/app/modules/notifikasi/views/notifikasi_view.dart';
import 'package:tiketinnusa/app/modules/pengaturan/bindings/pengaturan_binding.dart';
import 'package:tiketinnusa/app/modules/pengaturan/views/pengaturan_view.dart';
import 'package:tiketinnusa/app/modules/profil/bindings/profil_binding.dart';
import 'package:tiketinnusa/app/modules/profil/views/profil_view.dart';
import 'package:tiketinnusa/app/modules/detail_wisata/bindings/detail_wisata_binding.dart';
import 'package:tiketinnusa/app/modules/detail_wisata/views/detail_wisata_view.dart';
import 'package:tiketinnusa/app/modules/kategori/bindings/kategori_binding.dart';
import 'package:tiketinnusa/app/modules/kategori/views/kategori_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.SPLASH,
        page: () => const SplashView(),
        binding: SplashBinding()),
    GetPage(name: AppRoutes.ONBOARDING,
        page: () => const OnboardingView(),
        binding: OnboardingBinding()),
    GetPage(name: AppRoutes.LOGIN,
        page: () => const LoginView(),
        binding: LoginBinding()),
    GetPage(name: AppRoutes.REGISTRASI,
        page: () => const RegistrasiView(),
        binding: RegistrasiBinding()),
    GetPage(name: AppRoutes.BERANDA,
        page: () => const BerandaView(),
        binding: BerandaBinding()),
    GetPage(name: AppRoutes.BOOKING,
        page: () => const BookingView(),
        binding: BookingBinding()),
    GetPage(name: AppRoutes.TIKET,
        page: () => const TiketView(),
        binding: TiketBinding()),
    GetPage(name: AppRoutes.KERANJANG,
        page: () => const KeranjangView(),
        binding: KeranjangBinding()),
    GetPage(name: AppRoutes.NOTIFIKASI,
        page: () => const NotifikasiView(),
        binding: NotifikasiBinding()),
    GetPage(name: AppRoutes.PENGATURAN,
        page: () => const PengaturanView(),
        binding: PengaturanBinding()),
    GetPage(name: AppRoutes.PROFIL,
        page: () => const ProfilView(),
        binding: ProfilBinding()),
    GetPage(name: AppRoutes.DETAIL_WISATA,
        page: () => const DetailWisataView(),
        binding: DetailWisataBinding()),
    GetPage(name: AppRoutes.KATEGORI,      // ← BARU
        page: () => const KategoriView(),
        binding: KategoriBinding()),
  ];
}