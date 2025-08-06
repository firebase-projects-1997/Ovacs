import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum SnackBarType { success, error, warning, info }

void showAppSnackBar(
  BuildContext context,
  String? message, {
  SnackBarType type = SnackBarType.error,
  Duration duration = const Duration(seconds: 2),
}) {
  Color backgroundColor;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = AppColors.green;
      break;
    case SnackBarType.error:
      backgroundColor = AppColors.red;
      break;
    case SnackBarType.warning:
      backgroundColor = AppColors.orange;
      break;
    case SnackBarType.info:
      backgroundColor = AppColors.blue;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message ?? '',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: AppColors.pureWhite),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
    ),
  );
}
