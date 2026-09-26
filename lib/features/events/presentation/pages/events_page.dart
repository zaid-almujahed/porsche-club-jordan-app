import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/routing/app_router.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';
import 'package:pcj_v4/shared/widgets/app_search_field.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/events_controller.dart';
import '../widgets/event_page_widgets.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({
    super.key,
    required this.controller,
    this.unreadNotificationCount,
  });

  final EventsController controller;
  final ValueListenable<int>? unreadNotificationCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.canvas,
      appBar: PorscheAppBar(
        title: 'Events',
        showNotifications: true,
        unreadNotificationCount: unreadNotificationCount,
        onNotificationsPressed: () => context.push(AppRoutes.notifications),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: AppSpacing.section,
            bottomPadding:
                AppLayout.navigationBarHeight + AppSpacing.pageBottom,
            onRefresh: () => controller.load(force: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppSearchField(
                  controller: controller.searchController,
                  hintText: 'Search events',
                  onChanged: controller.search,
                  onClear: controller.clearSearch,
                ),
                const SizedBox(height: AppSpacing.xl),
                AsyncStateView<List<Event>>(
                  state: controller.events,
                  onRetry: () => controller.load(force: true),
                  builder: (BuildContext context, List<Event> events) {
                    Event? featured;
                    for (final Event event in events) {
                      if (event.isFeatured) {
                        featured = event;
                        break;
                      }
                    }
                    final Event? featuredEvent =
                        featured ?? (events.isEmpty ? null : events.first);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (featuredEvent != null) ...<Widget>[
                          FeaturedEvent(
                            event: featuredEvent,
                            onPressed: () => context.push(
                              AppRoutes.eventDetailsLocation(featuredEvent.id),
                              extra: featuredEvent,
                            ),
                          ),
                          const SizedBox(height: 38),
                        ],
                        if (controller.categories.isNotEmpty)
                          CategoryFilters(
                            categories: controller.categories,
                            selectedCategory: controller.selectedCategory,
                            onSelected: controller.selectCategory,
                          ),
                        const SizedBox(height: 42),
                        SectionTitleRow(title: controller.sectionTitle),
                        const SizedBox(height: 28),
                        if (events.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Text(
                              controller.hasSearchQuery
                                  ? 'No events match your search.'
                                  : controller.selectedCategory ==
                                        EventsController.pastCategory
                                  ? 'No past events are available.'
                                  : 'No upcoming events are available.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyLarge,
                            ),
                          )
                        else
                          UpcomingEventsCarousel(upcomingEvents: events),
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
