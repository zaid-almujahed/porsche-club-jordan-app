import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/vehicle.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class PersonalDetailsPanel extends StatelessWidget {
  const PersonalDetailsPanel({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.cityController,
    required this.dateOfBirthController,
    required this.avatarUrl,
    required this.isUploading,
    this.onChangePhoto,
    this.onDateOfBirthPressed,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController dateOfBirthController;
  final String? avatarUrl;
  final bool isUploading;
  final VoidCallback? onChangePhoto;
  final VoidCallback? onDateOfBirthPressed;

  @override
  Widget build(BuildContext context) {
    return GradientPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Personal Details',
            style: AppTextStyles.pageTitle.copyWith(fontSize: 27),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: 108,
              height: 108,
              child: AppAssetImage(
                path: avatarUrl ?? '',
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.pill),
                ),
                fallbackIcon: Icons.person_outline,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: OutlinedButton(
              onPressed: isUploading ? null : onChangePhoto,
              child: Text(
                isUploading ? 'Uploading...' : 'Change Photo',
                style: AppTextStyles.label,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _ProfileTextField(
            label: 'FULL NAME',
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            hintText: 'e.g. Ferdinand Porsche',
          ),
          const SizedBox(height: 26),
          _ProfileTextField(
            label: 'EMAIL ADDRESS',
            controller: emailController,
            readOnly: true,
            suffixIcon: Icons.lock_outline,
            helperText: 'Your email address cannot be changed here.',
          ),
          const SizedBox(height: 26),
          _ProfileTextField(
            label: 'PHONE NUMBER',
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 26),
          _ProfileTextField(
            label: 'CITY',
            controller: cityController,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 26),
          _ProfileTextField(
            label: 'DATE OF BIRTH',
            controller: dateOfBirthController,
            readOnly: true,
            onTap: onDateOfBirthPressed,
            suffixIcon: Icons.calendar_month_outlined,
            hintText: 'YYYY-MM-DD',
          ),
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.helperText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTextStyles.input,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            suffixIcon: suffixIcon == null
                ? null
                : Icon(suffixIcon, color: AppColors.textMuted, size: 20),
            filled: false,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1.25),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1.25),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class VehiclesPanel extends StatelessWidget {
  const VehiclesPanel({
    super.key,
    required this.vehicles,
    required this.onDeleteVehicle,
    this.onAddVehicle,
  });

  final List<Vehicle> vehicles;
  final ValueChanged<String> onDeleteVehicle;
  final VoidCallback? onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return GradientPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'My Vehicles',
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 27),
                ),
              ),
              SizedBox(
                height: 42,
                child: FilledButton.icon(
                  onPressed: onAddVehicle,
                  style: AppButtonStyles.compact(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('ADD VEHICLE', style: AppTextStyles.label),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: 28),
          if (vehicles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Text(
                'No vehicles are registered.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
            )
          else
            for (int index = 0; index < vehicles.length; index++) ...<Widget>[
              _VehicleTile(
                vehicle: vehicles[index],
                onDelete: () => onDeleteVehicle(vehicles[index].id),
              ),
              if (index != vehicles.length - 1) const SizedBox(height: 28),
            ],
        ],
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.vehicle, required this.onDelete});

  final Vehicle vehicle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 108,
            height: 108,
            child: AppAssetImage(
              path: vehicle.imageUrl ?? '',
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              fallbackIcon: Icons.directions_car_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    vehicle.model,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 23),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${vehicle.year} · ${vehicle.exteriorColor}',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'VIN: ${vehicle.vin}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.primaryBright,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
