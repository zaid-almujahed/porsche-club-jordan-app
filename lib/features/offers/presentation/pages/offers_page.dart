import 'package:flutter/material.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/shared/domain/entities/offer.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/offers_controller.dart';
import '../widgets/offer_widgets.dart';

class PartnerOffersPage extends StatelessWidget {
  const PartnerOffersPage({super.key, required this.controller});

  final OffersController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Offers'),
      bottomNavigationBar: const AppBottomNavigation(
        selected: AppSection.offers,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          final int selectedIndex = controller.selectedCategory == null
              ? 0
              : controller.categories.indexOf(controller.selectedCategory!);

          return AppPageBody(
            bottomPadding:
                AppLayout.navigationBarHeight + AppSpacing.pageBottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'PARTNERS & OFFERS',
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 32),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Exclusive privileges for Porsche Club Jordan members.',
                  style: AppTextStyles.bodyLarge,
                ),
                if (controller.categories.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 54),
                  OfferCategories(
                    categories: controller.categories,
                    selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                    onSelected: (int index) {
                      controller.selectCategory(controller.categories[index]);
                    },
                  ),
                ],
                const SizedBox(height: 36),
                if (controller.actionError != null) ...<Widget>[
                  Text(
                    readableError(controller.actionError!),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AsyncStateView<List<Offer>>(
                  state: controller.offers,
                  onRetry: () => controller.load(force: true),
                  isEmpty: (List<Offer> offers) => offers.isEmpty,
                  emptyMessage: 'No offers are currently available.',
                  builder: (BuildContext context, List<Offer> offers) {
                    return Column(
                      children: <Widget>[
                        for (
                          int index = 0;
                          index < offers.length;
                          index++
                        ) ...<Widget>[
                          OfferCard(
                            offer: offers[index],
                            isClaiming: controller.isClaiming(offers[index].id),
                            onTap: offers[index].isClaimed
                                ? null
                                : () => controller.claimOffer(offers[index]),
                          ),
                          if (index != offers.length - 1)
                            const SizedBox(height: AppSpacing.xl),
                        ],
                      ],
                    );
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
