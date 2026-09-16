import 'package:cached_network_image/cached_network_image.dart';
import 'package:qrattendance/core/extensions/ext_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/core/widgets/app_asset.dart';

class AppImage extends StatefulWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    this.borderRadius,
    this.width,
    this.height,
    this.fit,
    this.showprogressIndicator = true,
    this.useMemCache = true,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit? fit;
  final bool showprogressIndicator;
  final bool useMemCache;

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  @override
  void initState() {
    super.initState();
    // Force cache size increase safely here so it works even on Hot Reload
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        150 * 1024 * 1024; // 150 MB
  }

  String _getCacheKey(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}${uri.path}';
    } catch (e) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        fit: widget.fit ?? BoxFit.fill,
        width: widget.width,
        height: widget.height,
        // Compress image in RAM to save memory and keep 50+ images in LRU Cache
        memCacheWidth: widget.useMemCache
            ? (widget.width != null && widget.width!.isFinite
                  ? (widget.width! * 2).toInt()
                  : 800)
            : null,
        imageUrl: widget.imageUrl,
        cacheKey: _getCacheKey(widget.imageUrl),
        // Eliminate visual flashing when loading from cache (instant pop-in)
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) {
          if (!widget.showprogressIndicator) return const SizedBox();
          return Center(
            child: SpinKitFadingCircle(
              color: context.colorScheme.primary,
              size: 30.h,
            ),
          );
        },
        errorWidget: (context, url, error) {
          return Container(
            color: Colors.black,
            padding: EdgeInsets.all(5.h),
            child: const AppAsset(assetName: 'divido'),
          );
        },
      ),
    );
  }
}
