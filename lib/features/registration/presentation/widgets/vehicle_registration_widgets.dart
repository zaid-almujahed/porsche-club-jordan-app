import 'dart:io';

import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import 'form_widgets.dart';

class LicensePhotoCard extends StatelessWidget {
  const LicensePhotoCard({
    super.key,
    required this.placeholderImagePath,
    required this.onAddPhotoPressed,
    this.selectedImagePath,
    this.isLoading = false,
    this.errorText,
  });

  final String placeholderImagePath;
  final String? selectedImagePath;
  final bool isLoading;
  final String? errorText;
  final VoidCallback? onAddPhotoPressed;

  @override
  Widget build(BuildContext context) {
    return RegistrationFormPanel(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const RegistrationRequiredLabel(label: 'License Photo', fontSize: 20),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            "Upload a clear picture of your driver's license. "
            'Maximum file size is 5 MB.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 350 / 289,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.panelDark,
                border: Border.all(color: const Color(0xFF5E3F3C)),
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (selectedImagePath == null)
                    Opacity(
                      opacity: 0.38,
                      child: AppAssetImage(
                        path: placeholderImagePath,
                        fallbackIcon: Icons.directions_car_outlined,
                        fallbackLabel: 'Vehicle photo',
                      ),
                    )
                  else
                    Image.file(
                      File(selectedImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                      ),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0x20000000), Color(0x50000000)],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white,
                          size: 34,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SizedBox(
                          height: 38,
                          child: FilledButton(
                            onPressed: isLoading ? null : onAddPhotoPressed,
                            style: AppButtonStyles.pill(horizontalPadding: 14),
                            child: isLoading
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    selectedImagePath == null
                                        ? 'Add Photo'
                                        : 'Change Photo',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          selectedImagePath == null
                              ? 'No photo chosen'
                              : 'Photo selected',
                          style: TextStyle(
                            color: AppColors.textFaint,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (errorText != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorText!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}

class VehicleDetailsForm extends StatelessWidget {
  const VehicleDetailsForm({
    super.key,
    required this.yearController,
    required this.modelController,
  });

  final TextEditingController yearController;
  final TextEditingController modelController;

  @override
  Widget build(BuildContext context) {
    return RegistrationFormPanel(
      child: Column(
        children: <Widget>[
          RegistrationTextField(
            controller: modelController,
            label: 'VEHICLE MODEL',
            hintText: 'enter model',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.xxl),
          RegistrationTextField(
            controller: yearController,
            label: 'YEAR',
            hintText: 'YYYY',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }
}

class VehicleIdentificationForm extends StatelessWidget {
  const VehicleIdentificationForm({
    super.key,
    required this.vinController,
    required this.licensePlateController,
  });

  final TextEditingController vinController;
  final TextEditingController licensePlateController;

  @override
  Widget build(BuildContext context) {
    return RegistrationFormPanel(
      child: Column(
        children: <Widget>[
          RegistrationTextField(
            controller: vinController,
            label: 'VEHICLE IDENTIFICATION NUMBER (VIN)',
            hintText: '10- or 17-character VIN',
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.xxl),
          RegistrationTextField(
            controller: licensePlateController,
            label: 'LICENSE PLATE',
            hintText: 'e.g. 01-23456',
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
