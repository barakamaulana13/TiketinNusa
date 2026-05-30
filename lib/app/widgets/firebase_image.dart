import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FirebaseImage extends StatelessWidget {
  final String? imageUrl; // URL dari Firestore
  final String assetPath; // fallback assets lokal
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const FirebaseImage({
    super.key,
    required this.assetPath,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final String url = imageUrl?.trim() ?? '';

    // Validasi: harus dimulai dengan http/https dan bukan base64
    final bool isNetworkImage =
        (url.startsWith('http://') || url.startsWith('https://')) &&
        !url.startsWith('data:') &&
        url.length < 500;

    Widget img;

    if (isNetworkImage) {
      img = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => _fallbackAsset(),
      );
    } else {
      img = _fallbackAsset();
    }

    return borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: img)
        : img;
  }

  Widget _fallbackAsset() {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image),
      ),
    );
  }
}