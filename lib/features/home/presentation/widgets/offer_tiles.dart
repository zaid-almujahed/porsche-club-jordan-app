import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/offer.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class OfferTile extends StatelessWidget {
  const OfferTile({super.key, required this.offer, this.onTap});

  final Offer offer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panelDark,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 82),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 48,
                  height: 48,
                  child: AppAssetImage(
                    path: offer.logoUrl ?? '',
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    fallbackIcon: Icons.business,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        offer.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(height: 1.25),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        offer.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textFaint,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
