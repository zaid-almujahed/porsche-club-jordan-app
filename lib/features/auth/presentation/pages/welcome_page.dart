//The main page the user lands on when opening the app

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pcj_v4/core/routing/app_router.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const String _welcome = 'Welcome';
  static const String _subtitle =
      'Exclusive access to excellence. Connect with the ultimate '
      'performance community.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/bgimage.jpg',
            fit: BoxFit.cover,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return const ColoredBox(color: AppColors.canvas);
                },
          ),
          const ColoredBox(color: Color(0xC9000000)),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double horizontalPadding = AppLayout.horizontalPadding(
                  constraints.maxWidth,
                );

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppSpacing.xxl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (AppSpacing.xxl * 2),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppLayout.maxContentWidth,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 170),
                              child: Image.asset(
                                'assets/images/porsche_club_jordan_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (
                                      BuildContext context,
                                      Object error,
                                      StackTrace? stackTrace,
                                    ) {
                                      return const SizedBox(
                                        height: 120,
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: AppColors.textFaint,
                                          size: 42,
                                        ),
                                      );
                                    },
                              ),
                            ),
                            const SizedBox(height: 50),
                            Text(
                              _welcome,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.pageTitle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _subtitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 50),

                            //ACTION BUTTONS
                            PrimaryActionButton(
                              label: 'Join the Club',
                              onPressed: () =>
                                  context.push(AppRoutes.registerPersonal),
                              height: 64,
                            ),
                            const SizedBox(height: 12),
                            SecondaryActionButton(
                              label: 'Sign In',
                              onPressed: () => context.push(AppRoutes.signIn),
                              height: 64,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
