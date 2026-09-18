import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/vehicle.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class VehicleSelection extends StatelessWidget {
  const VehicleSelection({
    super.key,
    required this.vehicles,
    required this.selectedVehicle,
    required this.onChanged,
  });

  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final ValueChanged<Vehicle?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 1.25),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Vehicle>(
          isExpanded: true,
          value: vehicles.contains(selectedVehicle) ? selectedVehicle : null,
          hint: const Text('Select a registered vehicle'),
          dropdownColor: AppColors.panel,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          style: AppTextStyles.input,
          onChanged: vehicles.isEmpty ? null : onChanged,
          items: vehicles.map((Vehicle vehicle) {
            return DropdownMenuItem<Vehicle>(
              value: vehicle,
              child: Text(
                vehicle.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class PriceSummary extends StatelessWidget {
  const PriceSummary({
    super.key,
    required this.basePrice,
    required this.guestsPrice,
    required this.total,
    required this.currency,
  });

  final double basePrice;
  final double guestsPrice;
  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Column(
        children: <Widget>[
          SummaryRow(
            label: 'Base Registration',
            value: basePrice <= 0
                ? 'FREE'
                : AppFormatters.money(basePrice, currency),
          ),
          const SizedBox(height: AppSpacing.sm),
          SummaryRow(
            label: 'Guests',
            value: AppFormatters.money(guestsPrice, currency),
            muted: guestsPrice == 0,
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(color: Color(0x66FFFFFF)),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Text(
                'Total',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    total <= 0 ? 'FREE' : AppFormatters.money(total, currency),
                    style: AppTextStyles.pageTitle.copyWith(
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: muted ? const Color(0x99FFFFFF) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class BasePriceBanner extends StatelessWidget {
  const BasePriceBanner({
    super.key,
    required this.amount,
    required this.currency,
  });

  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text('BASE REGISTRATION', style: AppTextStyles.label),
          ),
          Text(
            amount <= 0 ? 'FREE' : AppFormatters.money(amount, currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class GuestPanel extends StatelessWidget {
  const GuestPanel({
    super.key,
    required this.count,
    required this.limit,
    required this.guestFee,
    required this.currency,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int count;
  final int limit;
  final double guestFee;
  final String currency;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return GradientPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text('Number of Guests', style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            guestFee <= 0
                ? 'You may register up to $limit guests at no additional cost.'
                : 'Up to $limit guests. Each guest costs '
                      '${AppFormatters.money(guestFee, currency)}.',
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'For everyone’s safety, guests who are not included in this '
            'registration will not be permitted entry to the event.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 40),
          Container(
            height: 58,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primary, width: 1.25),
              ),
            ),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: count == 0 ? null : onDecrement,
                  color: AppColors.textSecondary,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 28,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: count >= limit ? null : onIncrement,
                  color: AppColors.textSecondary,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
