import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

Future<bool> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  IconData icon = Icons.help_outline_rounded,
  bool isDestructive = false,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AppDialog(
      icon: icon,
      iconColor: isDestructive ? AppColors.danger : AppColors.primaryBright,
      title: title,
      message: message,
      primaryLabel: confirmLabel,
      secondaryLabel: cancelLabel,
      onPrimaryPressed: () => Navigator.of(dialogContext).pop(true),
      onSecondaryPressed: () => Navigator.of(dialogContext).pop(false),
    ),
  );
  return result ?? false;
}

Future<void> showAppMessageDialog({
  required BuildContext context,
  required String title,
  required String message,
  String buttonLabel = 'Continue',
  IconData icon = Icons.info_outline_rounded,
  Color iconColor = AppColors.primaryBright,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => AppDialog(
      icon: icon,
      iconColor: iconColor,
      title: title,
      message: message,
      primaryLabel: buttonLabel,
      onPrimaryPressed: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

Future<String?> showAppTextInputDialog({
  required BuildContext context,
  required String title,
  required String currentValue,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  String? hintText,
  TextInputType? keyboardType,
}) async {
  final TextEditingController fieldController = TextEditingController(
    text: currentValue,
  );
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) => AppDialog(
      icon: Icons.edit_outlined,
      title: title,
      content: TextField(
        controller: fieldController,
        keyboardType: keyboardType,
        autofocus: true,
        style: AppTextStyles.input,
        decoration: InputDecoration(hintText: hintText),
        onSubmitted: (String value) {
          Navigator.of(dialogContext).pop(value.trim());
        },
      ),
      primaryLabel: confirmLabel,
      secondaryLabel: cancelLabel,
      onPrimaryPressed: () {
        Navigator.of(dialogContext).pop(fieldController.text.trim());
      },
      onSecondaryPressed: () => Navigator.of(dialogContext).pop(),
    ),
  );
  fieldController.dispose();
  return result;
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.message,
    this.content,
    this.icon,
    this.iconColor = AppColors.primaryBright,
    this.secondaryLabel,
    this.onSecondaryPressed,
  }) : assert(message != null || content != null);

  final String title;
  final String? message;
  final Widget? content;
  final IconData? icon;
  final Color iconColor;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: AppColors.panelDark,
      surfaceTintColor: AppColors.panelDark,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 430,
          maxHeight: MediaQuery.sizeOf(context).height - 64,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.panelDark,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(AppRadii.large),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(icon, color: iconColor, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text(
                  title,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (message != null)
                  Text(message!, style: AppTextStyles.bodyLarge)
                else
                  content!,
                const SizedBox(height: AppSpacing.xl),
                PrimaryActionButton(
                  label: primaryLabel,
                  onPressed: onPrimaryPressed,
                  height: 54,
                ),
                if (secondaryLabel != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryActionButton(
                    label: secondaryLabel!,
                    onPressed: onSecondaryPressed,
                    height: 54,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
