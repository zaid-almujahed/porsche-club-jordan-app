import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/shared/domain/entities/offer.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

class OfferCategories extends StatelessWidget {
  const OfferCategories({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  }) : assert(categories.length > 0);

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(categories.length, (int index) {
        final bool isSelected = index == selectedIndex;

        return Expanded(
          child: InkWell(
            onTap: () {
              onSelected(index);
            },
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                categories[index].toUpperCase(),
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 16,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textFaint,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.isClaiming = false,
  });

  final Offer offer;
  final VoidCallback? onTap;
  final bool isClaiming;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panelDark,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: offer.isClaimed ? AppColors.border : AppColors.primaryBright,
          width: offer.isClaimed ? 1 : 2,
        ),
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isClaiming ? null : onTap,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2.15,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                AppAssetImage(path: offer.imageUrl),
                Positioned(
                  top: 18,
                  right: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.appBar,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.sell,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            isClaiming ? 'CLAIMING...' : offer.badgeLabel,
                            style: AppTextStyles.label,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  offer.displayPartnerName,
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (offer.title.trim().isNotEmpty &&
                    offer.title.trim().toLowerCase() !=
                        offer.displayPartnerName.toLowerCase()) ...<Widget>[
                  Text(
                    offer.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(offer.description, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        offer.location.trim().isNotEmpty
                            ? offer.location
                            : offer.expiryDate == null
                            ? 'MEMBER EXCLUSIVE'
                            : 'VALID UNTIL '
                                  '${AppFormatters.date(offer.expiryDate!)}',
                        style: AppTextStyles.label,
                      ),
                    ),
                    Text(
                      offer.isClaimed ? 'CLAIMED' : 'TAP TO CLAIM',
                      style: AppTextStyles.label.copyWith(
                        color: offer.isClaimed
                            ? AppColors.textFaint
                            : AppColors.primaryBright,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
