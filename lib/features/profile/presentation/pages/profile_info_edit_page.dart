import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/profile_controller.dart';
import '../widgets/profile_edit_widgets.dart';

class ProfileInfoEditPage extends StatelessWidget {
  const ProfileInfoEditPage({
    super.key,
    required this.controller,
    this.onAddVehicle,
  });

  final ProfileController controller;
  final VoidCallback? onAddVehicle;

  Future<void> _save(BuildContext context) async {
    final bool saved = await controller.saveProfile();
    if (saved && context.mounted && context.canPop()) context.pop();
  }

  Future<void> _pickDateOfBirth(BuildContext context, User user) async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: user.dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (selected != null) controller.setDateOfBirth(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(
          title: 'Edit Profile',
          showBack: true
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: 36,
            child: AsyncStateView<User>(
              state: controller.profile,
              onRetry: () => controller.load(force: true),
              builder: (BuildContext context, User user) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text('Edit Profile', style: AppTextStyles.pageTitle),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Update your personal details and manage your garage.',
                      style: AppTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PersonalDetailsPanel(
                      nameController: controller.nameController,
                      emailController: controller.emailController,
                      phoneController: controller.phoneController,
                      cityController: controller.cityController,
                      dateOfBirthController:
                          controller.dateOfBirthController,
                      avatarUrl: user.avatarUrl,
                      isUploading: controller.isUploadingAvatar,
                      onChangePhoto: controller.changeAvatar,
                      onDateOfBirthPressed: () =>
                          _pickDateOfBirth(context, user),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    VehiclesPanel(
                      vehicles: controller.vehicles,
                      onDeleteVehicle: controller.deleteVehicle,
                      onAddVehicle: onAddVehicle,
                    ),
                    if (controller.actionError != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        readableError(controller.actionError!),
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryActionButton(
                      label: controller.isSaving ? 'Saving...' : 'Save Changes',
                      onPressed: controller.isSaving
                          ? null
                          : () => _save(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SecondaryActionButton(
                      label: 'Cancel',
                      onPressed: () {
                        if (context.canPop()) context.pop();
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
