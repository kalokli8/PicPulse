import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PreloadedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PreloadedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Use CachedNetworkImage with optimized settings for instant loading
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: 300,
      memCacheHeight: 300,
      maxWidthDiskCache: 600,
      maxHeightDiskCache: 600,
      fadeInDuration: Duration.zero,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error, color: Colors.grey),
      ),
    );
  }
}
