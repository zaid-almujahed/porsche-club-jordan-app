import 'package:flutter/foundation.dart';
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
  const HomePage({
    super.key,
    required this.controller,
    this.user,
    this.unreadNotificationCount,
  });

  final HomeController controller;
  final User? user;
  final ValueListenable<int>? unreadNotificationCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.canvas,
      appBar: PorscheAppBar(
        title: 'Home',
        showNotifications: true,
        unreadNotificationCount: unreadNotificationCount,
        onNotificationsPressed: () => context.push(AppRoutes.notifications),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            bottomPadding:
                AppLayout.navigationBarHeight + AppSpacing.pageBottom,
            onRefresh: () => controller.load(force: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user?.name ?? 'Member',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1.12,
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
