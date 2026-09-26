import 'dart:convert';
import 'dart:io' as io;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pcj_v4/core/theme/app_theme.dart';
import 'package:pcj_v4/core/errors/app_exception.dart';
import 'package:pcj_v4/core/state/async_state.dart';
import 'package:pcj_v4/shared/domain/entities/event.dart';

enum AppSection { home, events, shop, offers, profile }

class PorscheAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PorscheAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.showNotifications = false,
    this.showCart = false,
    this.showClose = false,
    this.showEdit = false,
    this.onBack,
    this.onNotificationsPressed,
    this.onCartPressed,
    this.onClose,
    this.onEdit,
    this.unreadNotificationCount,
  });

  final String title;
  final bool showBack;
  final bool showNotifications;
  final bool showCart;
  final bool showClose;
  final bool showEdit;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onCartPressed;
  final VoidCallback? onClose;
  final VoidCallback? onEdit;
  final ValueListenable<int>? unreadNotificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(69);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBar,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      leading: showBack
          ? IconButton(
              onPressed:
                  onBack ??
                  () {
                    // Redirected routes can be the first page in the stack.
                    // Never pop the root route into a blank navigator.
                    if (context.canPop()) context.pop();
                  },
              icon: const Icon(
                Icons.arrow_back,
                size: 22,
                color: AppColors.textPrimary,
              ),
            )
          : showCart
          ? IconButton(
              onPressed: onCartPressed ?? () {},
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 23,
                color: AppColors.textPrimary,
              ),
            )
          : null,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(title.toUpperCase(), style: AppTextStyles.appBarTitle),
      ),
      actions: <Widget>[
        if (showNotifications)
          _NotificationButton(
            onPressed: onNotificationsPressed ?? () {},
            unreadCount: unreadNotificationCount,
          ),
        if (showClose)
          IconButton(
            tooltip: 'Cancel registration',
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              size: 25,
              color: AppColors.textPrimary,
            ),
          ),
        if (showEdit)
          IconButton(
            tooltip: 'Edit application',
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 23,
              color: AppColors.textPrimary,
            ),
          ),
        if (showNotifications || showClose || showEdit)
          const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: const Color(0xFF353534), height: 1.0),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.onPressed,
    required this.unreadCount,
  });

  final VoidCallback onPressed;
  final ValueListenable<int>? unreadCount;

  @override
  Widget build(BuildContext context) {
    final ValueListenable<int>? count = unreadCount;
    if (count == null) return _buildButton(0);
    return ValueListenableBuilder<int>(
      valueListenable: count,
      builder: (BuildContext context, int value, Widget? child) {
        return _buildButton(value);
      },
    );
  }

  Widget _buildButton(int unreadCount) {
    final bool hasUnread = unreadCount > 0;
    return IconButton(
      tooltip: hasUnread
          ? 'Notifications, $unreadCount unread'
          : 'Notifications',
      onPressed: onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          const Icon(
            Icons.notifications_none,
            size: 23,
            color: AppColors.textPrimary,
          ),
          if (hasUnread)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                key: const ValueKey<String>('unread-notifications-dot'),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primaryBright,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.appBar, width: 1.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppPageBody extends StatelessWidget {
  const AppPageBody({
    super.key,
    required this.child,
    this.topPadding = AppSpacing.xl,
    this.bottomPadding = AppSpacing.pageBottom,
    this.onRefresh,
  });

  final Widget child;
  final double topPadding;
  final double bottomPadding;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalPadding = AppLayout.horizontalPadding(
          constraints.maxWidth,
        );

        final Widget scrollView = SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: onRefresh == null
              ? null
              : const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.maxContentWidth,
              ),
              child: child,
            ),
          ),
        );

        if (onRefresh == null) return scrollView;
        return RefreshIndicator(
          color: AppColors.primaryBright,
          backgroundColor: AppColors.panelDark,
          displacement: 24,
          edgeOffset: AppSpacing.xs,
          elevation: 0,
          strokeWidth: 2.2,
          onRefresh: onRefresh!,
          child: scrollView,
        );
      },
    );
  }
}

class GradientPanel extends StatelessWidget {
  const GradientPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = AppRadii.medium,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: AppDecorations.panel(radius: radius),
      child: child,
    );
  }
}

class AppAssetImage extends StatelessWidget {
  const AppAssetImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackLabel,
  });

  final String path;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final IconData fallbackIcon;
  final String? fallbackLabel;

  @override
  Widget build(BuildContext context) {
    if (path.trim().isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: _buildFallback(
          context,
          StateError('No image path was supplied.'),
          null,
        ),
      );
    }

    final bool isRemote =
        path.startsWith('http://') || path.startsWith('https://');
    final bool isDataImage =
        path.startsWith('data:image/') && path.contains(',');
    final bool isAbsoluteFile =
        path.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);

    final Widget image;
    if (isDataImage) {
      try {
        image = Image.memory(
          base64Decode(path.substring(path.indexOf(',') + 1)),
          fit: fit,
          errorBuilder: _buildFallback,
        );
      } on FormatException catch (error, stackTrace) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: _buildFallback(context, error, stackTrace),
        );
      }
    } else if (isRemote) {
      image = Image.network(path, fit: fit, errorBuilder: _buildFallback);
    } else if (isAbsoluteFile) {
      image = Image.file(io.File(path), fit: fit, errorBuilder: _buildFallback);
    } else {
      image = Image.asset(path, fit: fit, errorBuilder: _buildFallback);
    }

    return ClipRRect(borderRadius: borderRadius, child: image);
  }

  Widget _buildFallback(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF242424), Color(0xFF080808)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(fallbackIcon, color: AppColors.textFaint, size: 42),
            if (fallbackLabel != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                fallbackLabel!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.state,
    required this.builder,
    this.onRetry,
    this.isEmpty,
    this.emptyMessage = 'Nothing is currently available.',
  });

  final AsyncState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final T? data = state.data;

    if (state.isLoading && data == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: SizedBox.square(
            dimension: 30,
            child: CircularProgressIndicator(
              color: AppColors.primaryBright,
              strokeWidth: 2.2,
            ),
          ),
        ),
      );
    }

    if (state.hasError && data == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              readableError(state.error!),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: 160,
                child: PrimaryActionButton(
                  label: 'Try Again',
                  onPressed: onRetry,
                  height: 48,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (data == null) return const SizedBox.shrink();

    if (isEmpty?.call(data) ?? false) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge,
        ),
      );
    }

    // Pull-to-refresh already supplies progress feedback. Keeping the current
    // content in place avoids the generic full-width loading bar flashing over
    // every refreshed section.
    return builder(context, data);
  }
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 64,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: isLoading
          ? FilledButton(
              onPressed: null,
              style: AppButtonStyles.primary.copyWith(
                backgroundColor: const WidgetStatePropertyAll<Color>(
                  AppColors.primary,
                ),
              ),
              child: const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              ),
            )
          : icon == null
          ? FilledButton(
              onPressed: onPressed,
              style: AppButtonStyles.primary,
              child: Text(label, style: AppTextStyles.button),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              style: AppButtonStyles.primary,
              icon: Icon(icon, size: 19),
              label: Text(label, style: AppTextStyles.button),
            ),
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 64,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: AppButtonStyles.secondary,
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }
}

class SectionTitleRow extends StatelessWidget {
  const SectionTitleRow({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
            if (actionLabel != null)
              TextButton(
                onPressed: onActionPressed,
                child: Text(
                  actionLabel!.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        const Divider(color: AppColors.textMuted, height: 0.5, thickness: 0.5),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label.copyWith(color: color),
        ),
      ],
    );
  }
}

class MemberSummaryCard extends StatelessWidget {
  const MemberSummaryCard({
    super.key,
    required this.avatarPath,
    required this.memberName,
    required this.memberId,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    this.statusNote,
    this.showEditButton = false,
    this.onEditPressed,
  });

  final String avatarPath;
  final String memberName;
  final String memberId;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final String? statusNote;
  final bool showEditButton;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    return GradientPanel(
      padding: const EdgeInsets.all(27),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isCompact = constraints.maxWidth < 300;
          final Widget avatar = Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor.withValues(alpha: 0.6)),
            ),
            child: AppAssetImage(
              path: avatarPath,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              fallbackIcon: Icons.person_outline,
            ),
          );
          final Widget editButton = IconButton.outlined(
            onPressed: onEditPressed,
            icon: const Icon(Icons.edit_outlined, size: 19),
          );
          final Widget statusBlock = Column(
            crossAxisAlignment: isCompact
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: <Widget>[
              const Text('MEMBER STATUS', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              StatusBadge(label: status, color: statusColor, icon: statusIcon),
              if (statusNote != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  statusNote!,
                  textAlign: isCompact ? TextAlign.left : TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isCompact) ...<Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[avatar, if (showEditButton) editButton],
                ),
                const SizedBox(height: AppSpacing.md),
                statusBlock,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    avatar,
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: statusBlock,
                      ),
                    ),
                    if (showEditButton) ...<Widget>[
                      const SizedBox(width: AppSpacing.xs),
                      editButton,
                    ],
                  ],
                ),
              const SizedBox(height: 28),
              if (isCompact) ...<Widget>[
                _MemberValue(
                  label: 'MEMBER NAME',
                  value: memberName,
                  alignment: CrossAxisAlignment.start,
                ),
                const SizedBox(height: AppSpacing.md),
                _MemberValue(
                  label: 'ID NUMBER',
                  value: memberId,
                  alignment: CrossAxisAlignment.start,
                  valueColor: AppColors.textFaint,
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: _MemberValue(
                        label: 'MEMBER NAME',
                        value: memberName,
                        alignment: CrossAxisAlignment.start,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: _MemberValue(
                        label: 'ID NUMBER',
                        value: memberId,
                        alignment: CrossAxisAlignment.end,
                        valueColor: AppColors.textFaint,
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MemberValue extends StatelessWidget {
  const _MemberValue({
    required this.label,
    required this.value,
    required this.alignment,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignment == CrossAxisAlignment.end
              ? TextAlign.right
              : TextAlign.left,
          style: AppTextStyles.label,
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment == CrossAxisAlignment.end
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              textAlign: alignment == CrossAxisAlignment.end
                  ? TextAlign.right
                  : TextAlign.left,
              style: TextStyle(
                color: valueColor,
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selected,
    this.onSelected,
  });

  final AppSection selected;
  final ValueChanged<AppSection>? onSelected;

  static const Map<AppSection, IconData> _icons = <AppSection, IconData>{
    AppSection.home: Icons.home,
    AppSection.events: Icons.calendar_month_outlined,
    AppSection.shop: Icons.storefront_outlined,
    AppSection.offers: Icons.handshake_outlined,
    AppSection.profile: Icons.person_outline,
  };

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xCC010205),
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: AppLayout.navigationBarHeight,
              child: Row(
                children: AppSection.values.map((AppSection section) {
                  final bool isSelected = section == selected;
                  final Color color = isSelected
                      ? AppColors.primaryBright
                      : AppColors.textFaint;

                  return Expanded(
                    child: InkWell(
                      onTap: section == selected
                          ? null
                          : () {
                              final ValueChanged<AppSection>? callback =
                                  onSelected;
                              if (callback != null) {
                                callback(section);
                              } else {
                                context.goNamed(section.name);
                              }
                            },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(_icons[section], color: color, size: 23),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            section.name.toUpperCase(),
                            style: AppTextStyles.label.copyWith(
                              color: color,
                              fontSize: 10,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeaturedEvent extends StatelessWidget {
  const FeaturedEvent({super.key, required this.event, this.onPressed});

  final Event event;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AppAssetImage(
            path: event.posterUrl,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            fallbackIcon: Icons.directions_car_outlined,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.large),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0x11000000), Color(0xB3000000)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(event.category.toUpperCase(), style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 28),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        event.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 200,
                  height: 44,
                  child: FilledButton(
                    style: AppButtonStyles.pill(),
                    onPressed: onPressed,
                    child: const Text(
                      'View Event',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
