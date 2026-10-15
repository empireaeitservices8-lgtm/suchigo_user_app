import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? textColor;
  final Color? disabledTextColor;
  final TextStyle? textStyle;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? showBorder;
  final Color? borderColor;
  final double? borderWidth;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final BoxShadow? shadow;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.textColor,
    this.disabledTextColor,
    this.textStyle,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.width,
    this.padding,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.showBorder,
    this.borderColor,
    this.borderWidth,
    this.gradient,
    this.boxShadow,
    this.shadow,
  });

  factory AppButton.curvedButton({
    Key? key,
    required String text,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Color? backgroundColor,
    Color? textColor,
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    double? height,
    double? width,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool? showBorder,
    Color? borderColor,
  }) {
    return AppButton(
      key: key,
      text: text,
      onTap: onTap ?? onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      backgroundColor: backgroundColor,
      textColor: textColor,
      textStyle: textStyle,
      fontSize: fontSize,
      fontWeight: fontWeight,
      padding: padding,
      height: height,
      width: width,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      showBorder: showBorder,
      borderColor: borderColor,
      borderRadius: 44.r,
    );
  }

  factory AppButton.squareButton({
    Key? key,
    required String text,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Color? backgroundColor,
    Color? textColor,
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    double? height,
    double? width,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool? showBorder,
    Color? borderColor,
  }) {
    return AppButton(
      key: key,
      text: text,
      onTap: onTap ?? onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      backgroundColor: backgroundColor,
      textColor: textColor,
      textStyle: textStyle,
      fontSize: fontSize,
      fontWeight: fontWeight,
      padding: padding,
      height: height,
      width: width,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      showBorder: showBorder,
      borderColor: borderColor,
      borderRadius: 0,
    );
  }

  factory AppButton.outlined({
    Key? key,
    required String text,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Color? borderColor,
    Color? textColor,
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    double? height,
    double? width,
    double? borderRadius,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return AppButton(
      key: key,
      text: text,
      onTap: onTap ?? onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      backgroundColor: Colors.transparent,
      showBorder: true,
      borderColor: borderColor ?? const Color(0xFF166534),
      textColor: textColor ?? const Color(0xFF166534),
      textStyle: textStyle,
      fontSize: fontSize,
      fontWeight: fontWeight,
      padding: padding,
      height: height,
      width: width,
      borderRadius: borderRadius ?? 16.r,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  factory AppButton.gradient({
    Key? key,
    required String text,
    required Gradient gradient,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Color? textColor,
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    double? height,
    double? width,
    double? borderRadius,
    Widget? prefixIcon,
    Widget? suffixIcon,
    List<BoxShadow>? boxShadow,
  }) {
    return AppButton(
      key: key,
      text: text,
      gradient: gradient,
      onTap: onTap ?? onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      textColor: textColor ?? Colors.white,
      textStyle: textStyle,
      fontSize: fontSize,
      fontWeight: fontWeight,
      padding: padding,
      height: height,
      width: width,
      borderRadius: borderRadius ?? 28.r,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      boxShadow: boxShadow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = onTap ?? onPressed;
    final bool canTap = isEnabled && !isLoading && effectiveOnTap != null;

    final Color defaultBg = const Color(0xFF166534);
    final Color defaultDisabledBg = const Color(0xFFE2E8F0);
    final Color defaultText = Colors.white;
    final Color defaultDisabledText = const Color(0xFF94A3B8);

    final Color effectiveBg = isEnabled
        ? (backgroundColor ?? defaultBg)
        : (disabledBackgroundColor ?? defaultDisabledBg);

    final Color effectiveTextColor = isEnabled
        ? (textColor ?? defaultText)
        : (disabledTextColor ?? defaultDisabledText);

    final double effectiveRadius = borderRadius ?? 16.r;

    Border? border;
    if (showBorder == true || borderColor != null) {
      border = Border.all(
        color: borderColor ?? const Color(0xFFE2E8F0),
        width: borderWidth ?? 1.2,
      );
    }

    List<BoxShadow>? effectiveShadows;
    if (boxShadow != null) {
      effectiveShadows = boxShadow;
    } else if (shadow != null) {
      effectiveShadows = [shadow!];
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? effectiveOnTap : null,
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height ?? 52.h,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: gradient == null ? effectiveBg : null,
            gradient: isEnabled ? gradient : null,
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: border,
            boxShadow: canTap ? effectiveShadows : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22.h,
                    height: 22.h,
                    child: CircularProgressIndicator(
                      color: effectiveTextColor,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (prefixIcon != null) ...[
                        prefixIcon!,
                        SizedBox(width: 6.w),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: textStyle ??
                              TextStyle(
                                fontSize: fontSize ?? 16.sp,
                                fontWeight: fontWeight ?? FontWeight.w700,
                                color: effectiveTextColor,
                                letterSpacing: 0.3,
                              ),
                        ),
                      ),
                      if (suffixIcon != null) ...[
                        SizedBox(width: 6.w),
                        suffixIcon!,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
