import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color canvas = Color(0xFF1A1A1A);
  static const Color appBar = Color(0xFF010205);
  static const Color panel = Color(0xFF131313);
  static const Color panelDark = Color(0xFF080808);
  static const Color primary = Color(0xFFB12B28);
  static const Color primaryBright = Color(0xFFD12B2E);
  static const Color success = Color(0xFF7EE69A);
  static const Color warning = Color(0xFFF5ED5B);
  static const Color danger = Color(0xFFFF2028);

  static const Color textPrimary = Color(0xFFFBFCFF);
  static const Color textSecondary = Color(0xFFE5E2E1);
  static const Color textMuted = Color(0xBFFBFCFF);
  static const Color textFaint = Color(0x7FFBFCFF);
  static const Color inputText = Color(0xFF010205);

  static const Color border = Color(0xFF353534);
  static const Color cardBorder = Color(0x33FBFCFF);
  static const Color inputBorder = Color(0xFF2C2C2C);
  static const Color inputFill = Color(0x7FC8C6C5);
  static const Color required = Color(0xCEFB0004);
}

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double section = 40;
  static const double pageBottom = 48;
}

abstract final class AppRadii {
  static const double small = 4;
  static const double medium = 12;
  static const double large = 24;
  static const double pill = 999;
}

abstract final class AppLayout {
  static const double maxContentWidth = 560;
  static const double navigationBarHeight = 72;

  static double horizontalPadding(double screenWidth) {
    if (screenWidth < 360) return 16;
    if (screenWidth < 600) return 20;
    return 32;
  }
}

abstract final class AppTextStyles {
  static const String fontFamily = 'Porsche Next';

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textSecondary,
    fontSize: 27,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1.35,
  );

  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textSecondary,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textMuted,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: 1.3,
  );

  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 1.8,
  );
}

abstract final class AppButtonStyles {
  static ButtonStyle get primary => _filled(
    backgroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.medium),
    ),
  );

  static ButtonStyle get secondary => _filled(
    backgroundColor: AppColors.appBar,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.medium),
    ),
  );

  static ButtonStyle compact({required Color backgroundColor}) {
    return _filled(
      backgroundColor: backgroundColor,
      horizontalPadding: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
    );
  }

  static ButtonStyle pill({
    Color backgroundColor = AppColors.primary,
    double horizontalPadding = 24,
  }) {
    return _filled(
      backgroundColor: backgroundColor,
      horizontalPadding: horizontalPadding,
      shape: const StadiumBorder(),
    );
  }

  static ButtonStyle _filled({
    required Color backgroundColor,
    required OutlinedBorder shape,
    double horizontalPadding = 28,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: AppColors.textPrimary,
      disabledBackgroundColor: AppColors.border,
      disabledForegroundColor: AppColors.textFaint,
      minimumSize: Size.zero,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: 0,
      shadowColor: Colors.transparent,
      textStyle: AppTextStyles.button,
      shape: shape,
    );
  }
}

abstract final class AppDecorations {
  static BoxDecoration panel({double radius = AppRadii.medium}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: <Color>[
          Color(0x331A1A1A),
          Color(0xCC000000),
          Color(0x8C000000),
          Color(0x191A1A1A),
        ],
      ),
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

abstract final class AppTheme {
  static ThemeData get dark {
    final UnderlineInputBorder inputBorder = UnderlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: const BorderSide(color: AppColors.primary, width: 1.25),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Porsche Next',
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.canvas,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.appBar,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 66,
        titleTextStyle: AppTextStyles.appBarTitle,
        shape: Border(bottom: BorderSide(color: AppColors.border, width: 3)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: AppTextStyles.input.copyWith(color: AppColors.textFaint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        constraints: const BoxConstraints(minHeight: 52),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(
            color: AppColors.primaryBright,
            width: 2,
          ),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: AppButtonStyles.primary),
    );
  }
}
