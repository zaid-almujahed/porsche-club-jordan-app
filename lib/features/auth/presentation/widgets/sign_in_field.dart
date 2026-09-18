import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';

class SignInField extends StatelessWidget {
  const SignInField({
    super.key,
    required this.label,
    required this.hintText,
    this.labelTrailing,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.onSubmitted,
    this.controller,
  });

  final String label;
  final String hintText;
  final Widget? labelTrailing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Text(label, style: AppTextStyles.label)),
            if (labelTrailing != null) ...<Widget>[
              const SizedBox(width: AppSpacing.md),
              labelTrailing!,
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onFieldSubmitted: onSubmitted,
          style: AppTextStyles.input,
          cursorColor: AppColors.primaryBright,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}
