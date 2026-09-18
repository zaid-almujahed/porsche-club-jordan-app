import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.pageNo,
    required this.title,
    required this.desc,
  });

  final String pageNo;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(title, maxLines: 1, style: AppTextStyles.pageTitle),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: pageNo,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const TextSpan(
                    text: '  /  04',
                    style: TextStyle(color: AppColors.textFaint),
                  ),
                ],
              ),
              style: AppTextStyles.label,
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(desc, style: AppTextStyles.bodyLarge),
        ),
      ],
    );
  }
}

class RegistrationFormPanel extends StatelessWidget {
  const RegistrationFormPanel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final bool isCompact = MediaQuery.sizeOf(context).width < 360;

    return GradientPanel(
      padding: padding ?? EdgeInsets.all(isCompact ? 18 : 26),
      child: child,
    );
  }
}

class RegistrationRequiredLabel extends StatelessWidget {
  const RegistrationRequiredLabel({
    super.key,
    required this.label,
    this.required = true,
    this.fontSize = 12,
  });

  final String label;
  final bool required;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: label),
          if (required)
            const TextSpan(
              text: '  *',
              style: TextStyle(
                color: AppColors.required,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
      style: AppTextStyles.label.copyWith(fontSize: fontSize),
    );
  }
}

class RegistrationTextField extends StatelessWidget {
  const RegistrationTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.prefixText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.validator,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final String? prefixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final IconData? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RegistrationRequiredLabel(label: label),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          obscureText: obscureText,
          style: AppTextStyles.input,
          cursorColor: AppColors.primaryBright,
          decoration: InputDecoration(
            hintText: hintText,
            filled: false,
            fillColor: Colors.transparent,
            prefixText: prefixText,
            prefixStyle: AppTextStyles.input,
            suffixIcon: suffixIcon == null
                ? null
                : Icon(suffixIcon, color: AppColors.textMuted, size: 22),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ),
      ],
    );
  }
}

class RegistrationSectionIntroduction extends StatelessWidget {
  const RegistrationSectionIntroduction({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTextStyles.body),
      ],
    );
  }
}

class RegistrationActions extends StatelessWidget {
  const RegistrationActions({
    super.key,
    required this.onNext,
    this.onBack,
    this.nextLabel = 'Next',
  });

  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Divider(),
        const SizedBox(height: 28),
        Row(
          children: <Widget>[
            if (onBack != null)
              SizedBox(
                width: 105,
                height: 48,
                child: FilledButton(
                  onPressed: onBack,
                  style: AppButtonStyles.compact(backgroundColor: Colors.black),
                  child: const Text('Back', style: AppTextStyles.button),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: 105,
              height: 48,
              child: FilledButton(
                onPressed: onNext,
                style: AppButtonStyles.compact(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(nextLabel, style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
