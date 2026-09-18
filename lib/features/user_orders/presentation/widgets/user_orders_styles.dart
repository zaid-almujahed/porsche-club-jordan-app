import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';

abstract final class OrderStyles {
  static const TextStyle orderId = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Colors.white,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 1.35,
  );

  static const TextStyle productName = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textSecondary,
    fontSize: 20.3,
    fontWeight: FontWeight.w600,
    height: 1.6,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Colors.white,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 1.35,
  );

  static const TextStyle metaLabel = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Color(0xFFC8C6C5),
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 1.35,
  );

  static const TextStyle metaValue = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textSecondary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.6,
  );
}
