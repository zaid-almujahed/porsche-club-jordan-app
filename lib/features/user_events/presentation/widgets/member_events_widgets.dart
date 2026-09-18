import 'package:flutter/material.dart';
import 'package:pcj_v4/core/theme/app_theme.dart';

abstract final class MemberEventStyles {
  static const TextStyle pageTitle = TextStyle(
    fontFamily: 'Hanken Grotesk',
    color: AppColors.textSecondary,
    fontSize: 54,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.08,
  );

  static const TextStyle pageDescription = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textMuted,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle tab = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 0.45,
  );

  static const BoxDecoration cardDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: <Color>[
        Color(0x331A1A1A),
        Color(0xCC000000),
        Color(0x8C000000),
        Color(0x191A1A1A),
      ],
    ),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.cardBorder, width: 1.1),
    ),
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.medium)),
  );

  static const TextStyle status = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textSecondary,
    fontSize: 11.25,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 1.1,
  );

  static const TextStyle eventType = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textFaint,
    fontSize: 11.25,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 1.1,
  );

  static const TextStyle eventTitle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textSecondary,
    fontSize: 27,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle detailLabel = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textMuted,
    fontSize: 12.4,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 1.24,
  );

  static const TextStyle detailValue = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: AppColors.textPrimary,
    fontSize: 15.8,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const TextStyle ticketButton = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: Colors.white,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 1.35,
  );
}

class EventTabs extends StatelessWidget {
  const EventTabs({
    super.key,
    required this.showUpcoming,
    required this.onSelected,
  });

  final bool showUpcoming;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 69,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.1)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _EventTab(
              label: 'UPCOMING',
              isSelected: showUpcoming,
              onTap: () => onSelected(true),
            ),
          ),
          Expanded(
            child: _EventTab(
              label: 'PAST',
              isSelected: !showUpcoming,
              onTap: () => onSelected(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTab extends StatelessWidget {
  const _EventTab({
    required this.label,
    this.isSelected = false,
    required this.onTap,
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
              style: MemberEventStyles.tab.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : const Color(0x66FBFCFF),
              ),
            ),
          ),
          if (isSelected)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(
                color: AppColors.primary,
                child: SizedBox(height: 2.25),
              ),
            ),
        ],
      ),
    );
  }
}

class MemberEventCard extends StatelessWidget {
  const MemberEventCard({
    super.key,
    required this.status,
    required this.type,
    required this.typeIcon,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.isTicketAvailable,
    this.onTicketPressed,
    this.onCancelPressed,
    this.isCancelling = false,
  });

  final String status;
  final String type;
  final IconData typeIcon;
  final String title;
  final String date;
  final String time;
  final String location;
  final bool isTicketAvailable;
  final VoidCallback? onTicketPressed;
  final VoidCallback? onCancelPressed;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: MemberEventStyles.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(27),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                _StatusChip(label: status, isHighlighted: isTicketAvailable),
                const SizedBox(width: 13.5),
                Icon(typeIcon, size: 15, color: AppColors.textFaint),
                const SizedBox(width: 4.5),
                Text(type, style: MemberEventStyles.eventType),
              ],
            ),
            const SizedBox(height: 13.5),
            Text(title, style: MemberEventStyles.eventTitle),
            const SizedBox(height: 27),
            const Divider(
              height: 1.1,
              thickness: 1.1,
              color: Color(0x7F353534),
            ),
            const SizedBox(height: 18),
            _EventDetail(label: 'DATE', value: date),
            const SizedBox(height: 9),
            _EventDetail(label: 'TIME', value: time),
            const SizedBox(height: 9),
            _EventDetail(label: 'LOCATION', value: location),
            const SizedBox(height: 27),
            _TicketButton(
              isEnabled: isTicketAvailable,
              onPressed: onTicketPressed,
            ),
            if (onCancelPressed != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: isCancelling ? null : onCancelPressed,
                  child: Text(
                    isCancelling ? 'CANCELLING...' : 'CANCEL RSVP',
                    style: MemberEventStyles.ticketButton,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TicketButton extends StatelessWidget {
  const _TicketButton({required this.isEnabled, this.onPressed});

  final bool isEnabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: FilledButton.icon(
        onPressed: isEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF181817),
          disabledForegroundColor: const Color(0x7FFFFFFF),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          minimumSize: const Size.fromHeight(40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
        ),
        icon: const Icon(Icons.confirmation_number_outlined, size: 17),
        label: const Text('VIEW TICKET', style: MemberEventStyles.ticketButton),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isHighlighted});

  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary : const Color(0xFF181817),
        border: Border.all(color: const Color(0x4C5E3F3C), width: 1.1),
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11.25, vertical: 4.5),
        child: Text(label, style: MemberEventStyles.status),
      ),
    );
  }
}

class _EventDetail extends StatelessWidget {
  const _EventDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: MemberEventStyles.detailLabel),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: MemberEventStyles.detailValue,
          ),
        ),
      ],
    );
  }
}

class PageHeading extends StatelessWidget {
  const PageHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: 'My ', style: MemberEventStyles.pageTitle),
              TextSpan(
                text: 'Events',
                style: MemberEventStyles.pageTitle.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your registrations and access event tickets.',
          style: MemberEventStyles.pageDescription,
        ),
      ],
    );
  }
}
