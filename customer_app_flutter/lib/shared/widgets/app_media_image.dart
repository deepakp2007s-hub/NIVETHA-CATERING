import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/config/image_config.dart';
import '../../core/constants/app_colors.dart';

class AppMediaImage extends StatelessWidget {
  const AppMediaImage({
    super.key,
    this.networkUrl,
    this.assetPath,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.icon = Icons.restaurant_rounded,
    this.heroTag,
  });

  final String? networkUrl;
  final String? assetPath;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData icon;
  final String? heroTag;

  bool get hasNetworkImage => ImageConfig.httpsUrl(networkUrl) != null;

  bool get hasAssetImage {
    final path = assetPath?.trim() ?? '';
    return path.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (hasNetworkImage) {
      child = CachedNetworkImage(
        imageUrl: ImageConfig.httpsUrl(networkUrl)!,
        fit: fit,
        placeholder: (context, url) => _Placeholder(icon: icon, loading: true),
        errorWidget: (context, url, error) {
          if (hasAssetImage) {
            return Image.asset(
              assetPath!,
              fit: fit,
              errorBuilder: (context, error, stackTrace) =>
                  _Placeholder(icon: icon),
            );
          }
          return _Placeholder(icon: icon);
        },
      );
    } else if (hasAssetImage) {
      child = Image.asset(
        assetPath!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _Placeholder(icon: icon),
      );
    } else {
      child = _Placeholder(icon: icon);
    }

    if (heroTag != null && heroTag!.isNotEmpty) {
      child = Hero(tag: heroTag!, child: child);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }

    return child;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    this.loading = false,
  });

  final IconData icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceVariant,
            AppColors.backgroundSecondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondary,
                ),
              )
            : Icon(
                icon,
                color: AppColors.gold.withValues(alpha: 0.7),
                size: 36,
              ),
      ),
    );
  }
}
