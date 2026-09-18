import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/registration_controller.dart';
import '../widgets/form_widgets.dart';
import '../widgets/personal_registration_widgets.dart';

class RegistrationPersonalPage extends StatelessWidget {
  const RegistrationPersonalPage({super.key, required this.controller});

  final RegistrationController controller;

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      controller.setDateOfBirth(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Membership Application'),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: AppSpacing.lg,
            bottomPadding: AppSpacing.section,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const ProgressHeader(
                  title: 'Personal Information',
                  pageNo: '01',
                  desc:
                      'Please provide your information exactly as it appears '
                      'on official identification documents to ensure accurate '
                      'processing of your club membership.',
                ),
                const SizedBox(height: 36),
                ProfilePhotoCard(
                  imagePath: controller.profilePhoto?.path,
                  isLoading: controller.isPickingProfilePhoto,
                  errorText: controller.profilePhotoError,
                  onAddPhotoPressed: controller.pickProfilePhoto,
                ),
                const SizedBox(height: 28),
                PersonalDetailsForm(
                  fullNameController: controller.fullNameController,
                  phoneController: controller.phoneController,
                  cityController: controller.cityController,
                  dateOfBirthController: controller.dateOfBirthController,
                  onDateOfBirthPressed: () => _selectDateOfBirth(context),
                ),
                if (controller.personalFormError != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    controller.personalFormError!,
                    style: AppTextStyles.body.copyWith(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 36),
                RegistrationActions(
                  onNext: () {
                    if (controller.validatePersonalInformation()) {
                      context.push(AppRoutes.registerVehicle);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
