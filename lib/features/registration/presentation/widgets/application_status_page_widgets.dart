import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class ApplicationStatusPanel extends StatelessWidget {
  const ApplicationStatusPanel({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.paragraphs,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return GradientPanel(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 30),
      child: Column(
        children: <Widget>[
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.canvas,
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.appBar, size: 34),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTextStyles.appBarTitle.copyWith(
              fontSize: 28,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (int index = 0; index < paragraphs.length; index++) ...<Widget>[
            Text(
              paragraphs[index],
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(height: 1.05),
            ),
            if (index != paragraphs.length - 1)
              const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}
