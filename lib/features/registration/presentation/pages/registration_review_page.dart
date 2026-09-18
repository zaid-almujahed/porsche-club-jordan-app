import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../widgets/form_widgets.dart';

import '../controllers/registration_controller.dart';
import '../widgets/review_page_widgets.dart';

class RegistrationReviewPage extends StatelessWidget {
  const RegistrationReviewPage({
    super.key,
    required this.controller,
  });

  final RegistrationController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: PorscheAppBar(title: 'Membership Application'),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const ProgressHeader(
                  pageNo: '03',
                  title: 'Review',
                  desc:
                      'Please verify your details before submitting your membership '
                      'application to Porsche Club Jordan.',
                ),
                const SizedBox(height: 54),
                ReviewCard(
                  title: 'Personal Information',
                  onEdit: () => context.go(AppRoutes.registerPersonal),
                  child: PersonalInformation(
                    imagePath: controller.profilePhoto?.path,
                    fullName: controller.fullNameController.text.trim(),
                    dateOfBirth: controller.dateOfBirthController.text.trim(),
                    phoneNumber: controller.phoneController.text.trim(),
                    city: controller.cityController.text.trim(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ReviewCard(
                  title: 'Vehicle Information',
                  onEdit: () => context.go(AppRoutes.registerVehicle),
                  child: VehicleInformation(
                    imagePath: controller.licensePhoto?.path,
                    model: controller.vehicleModelController.text.trim(),
                    year: controller.vehicleYearController.text.trim(),
                    licensePlate: controller.licensePlateController.text.trim(),
                    vin: controller.vinController.text.trim(),
                  ),
                ),
                const SizedBox(height: 54),
                AgreementPanel(
                  value: controller.isAgreementAccepted,
                  onChanged: controller.setAgreementAccepted,
                ),
                if (controller.submissionError != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    controller.submissionError!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 58),
                PrimaryActionButton(
                  label: 'Next',
                  onPressed: () {
                    if (controller.validateReview()) {
                      context.push(AppRoutes.registerPassword);
                    }
                  },
                  height: 66,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
