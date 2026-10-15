import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuchiGoLogoWidget extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool showText;
  final BoxFit fit;

  const SuchiGoLogoWidget({
    super.key,
    this.size = 140,
    this.showTagline = true,
    this.showText = true,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/splash_logo.png',
      width: size.w,
      height: size.w,
      fit: fit,
    );
  }
}
