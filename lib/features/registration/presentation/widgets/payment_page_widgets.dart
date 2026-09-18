import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';

class MembershipFee extends StatelessWidget {
  const MembershipFee({
    super.key,
    required this.amount,
    required this.currency,
  });

  final double? amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('MEMBERSHIP FEE', style: AppTextStyles.label),
              SizedBox(height: AppSpacing.xs),
              Text('Annual\nMembership', style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
        Text(
          amount == null
              ? 'Fee\npending'
              : AppFormatters.money(amount!, currency).replaceFirst(' ', '\n'),
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 29,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.label,
    required this.selected,
    this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 88,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: <Widget>[
                const Icon(Icons.credit_card, color: AppColors.primaryBright),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? AppColors.primaryBright
                      : AppColors.textFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
