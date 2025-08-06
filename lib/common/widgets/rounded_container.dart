import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool blur;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final void Function()? onTap;

  const RoundedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(15),
    this.blur = true,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 15,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.mediumGrey.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? AppColors.mediumGrey.withValues(alpha: .1),
          ),
        ),
        child: child,
      ),
    );

    if (blur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: container,
        ),
      );
    } else {
      return container;
    }
  }
}
