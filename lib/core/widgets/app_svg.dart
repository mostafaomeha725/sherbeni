import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppSVG extends StatelessWidget {
  const AppSVG({
    super.key,
    required this.assetName,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  final String assetName;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    String assetPath = assetName;
    if (!assetPath.contains('assets')) {
      assetPath = "assets/svg/$assetPath.svg";
    }

    return SvgPicture.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
      color: color,
    );
  }
}
