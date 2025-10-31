import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PreloadedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final bool useHighQuality;

  const PreloadedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.useHighQuality = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use CachedNetworkImage with optimized settings for list view
    // or full quality for detail view
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      // If useHighQuality is true, don't limit cache sizes (null = no limit)
      // Otherwise use optimized sizes for list view
      memCacheWidth: useHighQuality ? null : (memCacheWidth ?? 300),
      memCacheHeight: useHighQuality ? null : (memCacheHeight ?? 300),
      maxWidthDiskCache: useHighQuality ? null : (maxWidthDiskCache ?? 600),
      maxHeightDiskCache: useHighQuality ? null : (maxHeightDiskCache ?? 600),
      fadeInDuration: Duration.zero,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        // Show loading indicator only for list view (optimized loading)
        // For detail view, just show subtle placeholder since image may be cached
        child: useHighQuality
            ? null // No loading indicator for high-quality images
            : const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error, color: Colors.grey),
      ),
    );
  }
}
