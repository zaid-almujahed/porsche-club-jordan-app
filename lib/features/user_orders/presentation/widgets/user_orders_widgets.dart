import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import 'user_orders_styles.dart';

class OrdersTabs extends StatelessWidget {
  const OrdersTabs({
    super.key,
    required this.showActive,
    required this.onSelected,
  });

  final bool showActive;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.1)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _OrdersTab(
              label: 'ACTIVE',
              isSelected: showActive,
              onTap: () => onSelected(true),
            ),
          ),
          Expanded(
            child: _OrdersTab(
              label: 'PAST',
              isSelected: !showActive,
              onTap: () => onSelected(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : const Color(0x66FBFCFF),
                fontSize: 18,
                height: 1.6,
                letterSpacing: 0.45,
              ),
            ),
          ),
          if (isSelected)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(
                color: AppColors.primaryBright,
                child: SizedBox(height: 2.25),
              ),
            ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.imagePath,
    required this.orderId,
    required this.productName,
    required this.status,
    required this.deliveryDate,
    required this.total,
    required this.accentColor,
  });

  final String imagePath;
  final String orderId;
  final String productName;
  final String status;
  final String deliveryDate;
  final String total;
  final Color accentColor;

  static const BorderRadius _cardRadius = BorderRadius.only(
    topRight: Radius.circular(AppRadii.large),
    bottomRight: Radius.circular(AppRadii.large),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0x331A1A1A),
            Color(0xCC000000),
            Color(0x8C000000),
            Color(0x191A1A1A),
          ],
        ),
        border: Border.all(color: AppColors.inputBorder, width: 1.1),
        borderRadius: _cardRadius,
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ColoredBox(
              color: accentColor,
              child: const SizedBox(width: 4.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(27),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 2.34,
                  child: ColoredBox(
                    color: AppColors.panel,
                    child: AppAssetImage(
                      path: imagePath,
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                      fallbackIcon: Icons.checkroom,
                    ),
                  ),
                ),
                const SizedBox(height: 27),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(orderId, style: OrderStyles.orderId),
                          const SizedBox(height: 4),
                          Text(productName, style: OrderStyles.productName),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatusBadge(label: status),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(
                  height: 1,
                  thickness: 1.1,
                  color: AppColors.border,
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _OrderValue(
                        label: 'Est. Delivery',
                        value: deliveryDate,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _OrderValue(
                        label: 'Total',
                        value: total,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            Color(0x331A1A1A),
            Color(0xCC000000),
            Color(0x8C000000),
            Color(0x191A1A1A),
          ],
        ),
        border: Border.all(color: AppColors.cardBorder, width: 1.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.5, vertical: 4.5),
        child: Text(label, style: OrderStyles.badge),
      ),
    );
  }
}

class _OrderValue extends StatelessWidget {
  const _OrderValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment crossAxisAlignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final TextAlign textAlign = alignEnd ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: <Widget>[
        Text(label, textAlign: textAlign, style: OrderStyles.metaLabel),
        const SizedBox(height: 4.5),
        Text(value, textAlign: textAlign, style: OrderStyles.metaValue),
      ],
    );
  }
}
