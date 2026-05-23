import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


class FirebaseImage extends StatelessWidget {
  final String?  imageUrl;   // URL dari Firestore
  final String   assetPath;  // fallback assets lokal
  final double?  width;
  final double?  height;
  final BoxFit   fit;
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
    Widget img;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Dari Firebase Storage
      img = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => Container(
          width: width, height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF1F4529),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Image.asset(
          assetPath,
          width: width, height: height, fit: fit,
          errorBuilder: (_, __, ___) => Container(
            width: width, height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.image,
                color: Colors.grey),
          ),
        ),
      );
    } else {
      // Dari assets lokal
      img = Image.asset(
        assetPath,
        width: width, height: height, fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width, height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image,
              color: Colors.grey),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }
}