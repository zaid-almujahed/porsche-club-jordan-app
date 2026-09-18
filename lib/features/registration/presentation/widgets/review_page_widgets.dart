import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.title,
    required this.child,
    required this.onEdit,
  });

  final String title;
  final Widget child;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GradientPanel(
      padding: const EdgeInsets.all(27),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 27),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: 17,
                ),
                label: Text(
                  'EDIT',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

class PersonalInformation extends StatelessWidget {
  const PersonalInformation({
    super.key,
    required this.imagePath,
    required this.fullName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.city,
  });

  final String? imagePath;
  final String fullName;
  final String dateOfBirth;
  final String phoneNumber;
  final String city;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ReviewImage(
          imagePath: imagePath,
          width: 108,
          height: 108,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          fallbackIcon: Icons.person_outline,
        ),
        const SizedBox(height: 38),
        _ReviewDetail(label: 'FULL NAME', value: fullName),
        _ReviewDetail(label: 'DATE OF BIRTH', value: dateOfBirth),
        _ReviewDetail(label: 'PHONE NUMBER', value: phoneNumber),
        _ReviewDetail(label: 'CITY', value: city),
      ],
    );
  }
}

class VehicleInformation extends StatelessWidget {
  const VehicleInformation({
    super.key,
    required this.imagePath,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.vin,
  });

  final String? imagePath;
  final String model;
  final String year;
  final String licensePlate;
  final String vin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 342 / 253,
          child: _ReviewImage(
            imagePath: imagePath,
            borderRadius: BorderRadius.circular(AppRadii.small),
            fallbackIcon: Icons.directions_car_outlined,
          ),
        ),
        const SizedBox(height: 28),
        _ReviewDetail(label: 'MODEL', value: model),
        _ReviewDetail(label: 'YEAR', value: year),
        _ReviewDetail(
          label: 'LICENSE PLATE',
          value: licensePlate,
          compact: true,
        ),
        _ReviewDetail(label: 'VIN', value: vin, monospace: true),
      ],
    );
  }
}

class _ReviewImage extends StatelessWidget {
  const _ReviewImage({
    required this.imagePath,
    required this.borderRadius,
    required this.fallbackIcon,
    this.width,
    this.height,
  });

  final String? imagePath;
  final BorderRadius borderRadius;
  final IconData fallbackIcon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: imagePath == null
            ? ColoredBox(
                color: AppColors.panelDark,
                child: Icon(fallbackIcon, color: AppColors.textMuted),
              )
            : Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: AppColors.panelDark,
                  child: Icon(fallbackIcon, color: AppColors.textMuted),
                ),
              ),
      ),
    );
  }
}

class _ReviewDetail extends StatelessWidget {
  const _ReviewDetail({
    required this.label,
    required this.value,
    this.compact = false,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool compact;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final Widget valueWidget = Text(
      value,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: compact ? 13 : 20,
        fontWeight: compact ? FontWeight.w600 : FontWeight.w400,
        fontFamily: monospace ? 'JetBrains Mono' : AppTextStyles.fontFamily,
        letterSpacing: monospace ? 0.8 : 0,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          if (compact)
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: valueWidget,
              ),
            )
          else
            valueWidget,
        ],
      ),
    );
  }
}

class AgreementPanel extends StatelessWidget {
  const AgreementPanel({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    const TextSpan(
                      text:
                          'By checking this box, I confirm that all provided '
                          'information is accurate and I agree to abide by the ',
                    ),
                    TextSpan(
                      text: 'Rules and Regulations',
                      style: AppTextStyles.body.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' of Porsche Club Jordan.'),
                  ],
                ),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Container(
            width: 56,
            constraints: const BoxConstraints(minHeight: 126),
            color: AppColors.border,
            alignment: Alignment.center,
            child: Checkbox(
              value: value,
              onChanged: (bool? nextValue) {
                onChanged(nextValue ?? false);
              },
              activeColor: AppColors.panelDark,
              checkColor: AppColors.primaryBright,
              side: const BorderSide(color: AppColors.panelDark, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}
