import 'dart:io';

import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';

import 'form_widgets.dart';

class ProfilePhotoCard extends StatelessWidget {
  const ProfilePhotoCard({
    super.key,
    required this.onAddPhotoPressed,
    this.imagePath,
    this.isLoading = false,
    this.errorText,
  });

  final String? imagePath;
  final bool isLoading;
  final String? errorText;
  final VoidCallback? onAddPhotoPressed;

  @override
  Widget build(BuildContext context) {
    return RegistrationFormPanel(
      child: Column(
        children: <Widget>[
          Container(
            width: 126,
            height: 126,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.canvas,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: imagePath == null
                ? const Icon(
                    Icons.person_outline_rounded,
                    size: 52,
                    color: AppColors.textMuted,
                  )
                : Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      size: 44,
                      color: AppColors.textMuted,
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Profile Photo',
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This photo will be used for your digital membership card. '
            'A clear, front-facing portrait is required.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'JPG or PNG • Max 5MB • 500×500px min',
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: isLoading ? null : onAddPhotoPressed,
              style: AppButtonStyles.compact(
                backgroundColor: AppColors.primary,
              ),
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      imagePath == null ? 'Add Photo' : 'Change Photo',
                      style: AppTextStyles.button,
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

class PersonalDetailsForm extends StatelessWidget {
  const PersonalDetailsForm({
    super.key,
    required this.fullNameController,
    required this.phoneController,
    required this.cityController,
    required this.dateOfBirthController,
    required this.onDateOfBirthPressed,
  });

  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController dateOfBirthController;
  final VoidCallback onDateOfBirthPressed;

  @override
  Widget build(BuildContext context) {
    return RegistrationFormPanel(
      child: Column(
        children: <Widget>[
          RegistrationTextField(
            controller: fullNameController,
            label: 'FULL NAME',
            hintText: 'e.g. Ferdinand Porsche',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: <String>[AutofillHints.name],
          ),
          const SizedBox(height: 26),
          RegistrationTextField(
            controller: phoneController,
            label: 'PHONE NUMBER',
            hintText: 'Phone number',
            prefixText: '+962  ',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: <String>[AutofillHints.telephoneNumber],
          ),
          const SizedBox(height: 26),
          RegistrationTextField(
            controller: cityController,
            label: 'CITY',
            hintText: 'e.g. Amman',
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: <String>[AutofillHints.addressCity],
          ),
          const SizedBox(height: 26),
          RegistrationTextField(
            controller: dateOfBirthController,
            label: 'DATE OF BIRTH',
            hintText: 'e.g. 01/01/1980',
            keyboardType: TextInputType.datetime,
            textInputAction: TextInputAction.next,
            suffixIcon: Icons.calendar_month_outlined,
            readOnly: true,
            onTap: onDateOfBirthPressed,
          ),
        ],
      ),
    );
  }
}
