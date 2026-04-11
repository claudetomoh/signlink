import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class EventTile extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onSignUp;
  final bool isSignedUp;

  const EventTile({
    super.key,
    required this.event,
    this.onTap,
    this.onSignUp,
    this.isSignedUp = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image banner
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLG)),
                child: Container(
                  height: 130,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (event.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: event.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.image_not_supported_rounded, color: AppColors.textSecondary),
                          ),
                        ),
                      // Date badge
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppHelpers.relativeDate(event.date).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Text(AppHelpers.formatDateTime(event.date), style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(event.location, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    if (event.capacity != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: event.capacityPercent,
                                backgroundColor: AppColors.border,
                                color: AppColors.primary,
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${event.signedUpCount}/${event.capacity}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    ],
                    if (onSignUp != null && !event.isPast) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: isSignedUp ? null : onSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSignedUp ? AppColors.success : AppColors.primary,
                          ),
                          child: Text(isSignedUp ? 'Signed Up' : 'Sign Up', style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
