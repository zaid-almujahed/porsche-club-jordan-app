import 'package:flutter/material.dart';

import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/utils/app_formatters.dart';
import 'package:pcj_v4/features/notifications/domain/entities/member_notification.dart';
import 'package:pcj_v4/shared/widgets/app_widgets.dart';

import '../controllers/notifications_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const PorscheAppBar(title: 'Notifications', showBack: true),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          return AppPageBody(
            topPadding: AppSpacing.section,
            onRefresh: () => controller.load(force: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Stay up to date',
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 30),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${controller.unreadCount} unread notification'
                  '${controller.unreadCount == 1 ? '' : 's'}',
                  style: AppTextStyles.bodyLarge,
                ),
                if (controller.unreadCount > 0) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 210,
                      child: SecondaryActionButton(
                        label: controller.isMarkingAllRead
                            ? 'Marking All...'
                            : 'Mark All as Read',
                        onPressed: controller.isMarkingAllRead
                            ? null
                            : controller.markAllAsRead,
                        height: 46,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                _NotificationTabs(
                  showAll: controller.showAll,
                  onUnreadPressed: controller.showUnread,
                  onAllPressed: controller.showAllNotifications,
                ),
                if (controller.actionError != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    readableError(controller.actionError!),
                    style: AppTextStyles.body.copyWith(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AsyncStateView<List<MemberNotification>>(
                  state: controller.state,
                  onRetry: () => controller.load(force: true),
                  isEmpty: (List<MemberNotification> values) => values.isEmpty,
                  emptyMessage: controller.showAll
                      ? 'No notifications are available.'
                      : 'You are all caught up.',
                  builder:
                      (BuildContext context, List<MemberNotification> values) {
                        return Column(
                          children: <Widget>[
                            for (
                              int index = 0;
                              index < values.length;
                              index++
                            ) ...<Widget>[
                              _NotificationCard(
                                notification: values[index],
                                isMarkingRead: controller.isMarkingRead(
                                  values[index].id,
                                ),
                                onTap: () =>
                                    controller.markAsRead(values[index]),
                              ),
                              if (index != values.length - 1)
                                const SizedBox(height: AppSpacing.md),
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

class _NotificationTabs extends StatelessWidget {
  const _NotificationTabs({
    required this.showAll,
    required this.onUnreadPressed,
    required this.onAllPressed,
  });

  final bool showAll;
  final VoidCallback onUnreadPressed;
  final VoidCallback onAllPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _TabButton(
              label: 'Unread',
              selected: !showAll,
              onPressed: onUnreadPressed,
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'All Notifications',
              selected: showAll,
              onPressed: onAllPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: FilledButton(
        onPressed: onPressed,
        style: AppButtonStyles.compact(
          backgroundColor: selected ? AppColors.primary : Colors.transparent,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label.toUpperCase(), style: AppTextStyles.label),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isMarkingRead,
    required this.onTap,
  });

  final MemberNotification notification;
  final bool isMarkingRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: !notification.isRead,
      label: notification.isRead
          ? null
          : 'Mark ${notification.title} as read',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        onTap: notification.isRead || isMarkingRead ? null : onTap,
        child: GradientPanel(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(_icon, color: _color, size: 23),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          notification.title,
                          style: AppTextStyles.sectionTitle,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          AppFormatters.dateAndTime(notification.sentAt),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textFaint,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isMarkingRead)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryBright,
                      ),
                    )
                  else if (notification.isRead)
                    const StatusBadge(
                      label: 'READ',
                      color: AppColors.textFaint,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(notification.message, style: AppTextStyles.bodyLarge),
              if (!notification.isRead && !isMarkingRead) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    const Icon(
                      Icons.touch_app_outlined,
                      size: 16,
                      color: AppColors.textFaint,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Tap to mark as read',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textFaint,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (notification.type) {
    MemberNotificationType.event => Icons.event_available_outlined,
    MemberNotificationType.membership => Icons.verified_user_outlined,
    MemberNotificationType.marketplace => Icons.shopping_bag_outlined,
    MemberNotificationType.offer => Icons.local_offer_outlined,
    MemberNotificationType.system => Icons.notifications_outlined,
  };

  Color get _color => switch (notification.type) {
    MemberNotificationType.membership => AppColors.success,
    MemberNotificationType.event => AppColors.primaryBright,
    MemberNotificationType.marketplace => AppColors.warning,
    MemberNotificationType.offer => AppColors.primary,
    MemberNotificationType.system => AppColors.textSecondary,
  };
}
