import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  // Convenience alias: supplies label 'See All'
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (actionLabel != null || onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll ?? onAction,
                child: Text(
                  actionLabel ?? 'See All',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      );
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      );
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color get _color => switch (status.toLowerCase()) {
        'confirmed' || 'approved' || 'completed' => AppColors.success,
        'pending' => AppColors.warning,
        'cancelled' || 'declined' => AppColors.error,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(
          status[0].toUpperCase() + status.substring(1),
          style: TextStyle(
            color: _color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      );
}
