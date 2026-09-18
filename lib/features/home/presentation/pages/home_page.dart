import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/home_feed.dart';
import 'package:pcj_v4/shared/domain/entities/user.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/home_controller.dart';
import '../widgets/event_season_list.dart';
import '../widgets/offer_tiles.dart';
import '../widgets/popular_shop_items.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.controller, this.user});

  final HomeController controller;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Home'),
      bottomNavigationBar: const AppBottomNavigation(selected: AppSection.home),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            bottomPadding:
                AppLayout.navigationBarHeight + AppSpacing.pageBottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Welcome back,\n${user?.name ?? 'Member'}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 66),
                AsyncStateView<HomeFeed>(
                  state: controller.state,
                  onRetry: () => controller.load(force: true),
                  builder: (BuildContext context, HomeFeed feed) {
                    return _HomeFeedContent(feed: feed);
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

class _HomeFeedContent extends StatelessWidget {
  const _HomeFeedContent({required this.feed});

  final HomeFeed feed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (feed.featuredEvent != null) ...<Widget>[
          const SectionTitleRow(title: 'Featured Event'),
          const SizedBox(height: AppSpacing.md),
          FeaturedEvent(
            event: feed.featuredEvent!,
            onPressed: () => context.push(
              AppRoutes.eventDetailsLocation(feed.featuredEvent!.id),
              extra: feed.featuredEvent,
            ),
          ),
          const SizedBox(height: 66),
        ],
        SectionTitleRow(
          title: 'This Season',
          actionLabel: 'All Events ›',
          onActionPressed: () => context.go(AppRoutes.events),
        ),
        const SizedBox(height: AppSpacing.md),
        if (feed.seasonEvents.isEmpty)
          const _EmptySection(label: 'No upcoming events.')
        else
          ThisSeasonList(events: feed.seasonEvents),
        const SizedBox(height: 66),
        SectionTitleRow(
          title: 'Popular Items',
          actionLabel: 'Visit Shop ›',
          onActionPressed: () => context.go(AppRoutes.shop),
        ),
        const SizedBox(height: AppSpacing.md),
        if (feed.popularProducts.isEmpty)
          const _EmptySection(label: 'No popular items.')
        else
          PopularItems(products: feed.popularProducts),
        const SizedBox(height: 66),
        SectionTitleRow(
          title: 'Exclusive Offers',
          actionLabel: 'All Offers ›',
          onActionPressed: () => context.go(AppRoutes.offers),
        ),
        const SizedBox(height: AppSpacing.md),
        if (feed.featuredOffers.isEmpty)
          const _EmptySection(label: 'No featured offers.')
        else
          for (
            int index = 0;
            index < feed.featuredOffers.length;
            index++
          ) ...<Widget>[
            OfferTile(
              offer: feed.featuredOffers[index],
              onTap: () => context.go(AppRoutes.offers),
            ),
            if (index != feed.featuredOffers.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyLarge,
      ),
    );
  }
}
