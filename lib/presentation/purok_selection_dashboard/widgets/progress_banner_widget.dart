import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProgressBannerWidget extends StatelessWidget {
  final int targetReadings;
  final int completedReadings;

  const ProgressBannerWidget({
    super.key,
    required this.targetReadings,
    required this.completedReadings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double progressPercentage =
        targetReadings > 0 ? (completedReadings / targetReadings) * 100 : 0.0;

    final String motivationalMessage =
        _getMotivationalMessage(progressPercentage);

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary.withValues(alpha: 0.1),
            colorScheme.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '$completedReadings of $targetReadings readings',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getProgressColor(progressPercentage)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progressPercentage.toInt()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _getProgressColor(progressPercentage),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(progressPercentage)),
            minHeight: 8,
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: _getMotivationalIcon(progressPercentage),
                color: _getProgressColor(progressPercentage),
                size: 18,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  motivationalMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getMotivationalMessage(double percentage) {
    if (percentage >= 100) {
      return 'Excellent work! All readings completed for today!';
    } else if (percentage >= 80) {
      return 'Great progress! You\'re almost done for the day!';
    } else if (percentage >= 50) {
      return 'Good work! Keep going to reach your daily target!';
    } else if (percentage >= 25) {
      return 'You\'re making progress! Stay focused on your goal!';
    } else {
      return 'Let\'s get started! Every reading counts towards your goal!';
    }
  }

  String _getMotivationalIcon(double percentage) {
    if (percentage >= 100) return 'celebration';
    if (percentage >= 80) return 'trending_up';
    if (percentage >= 50) return 'thumb_up';
    if (percentage >= 25) return 'schedule';
    return 'play_arrow';
  }
}
