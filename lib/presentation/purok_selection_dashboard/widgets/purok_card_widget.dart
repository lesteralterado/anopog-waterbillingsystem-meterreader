import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PurokCardWidget extends StatelessWidget {
  final Map<String, dynamic> purokData;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PurokCardWidget({
    super.key,
    required this.purokData,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String status = purokData['status'] as String;
    final double completionPercentage =
        (purokData['completionPercentage'] as num).toDouble();
    final int totalMeters = purokData['totalMeters'] as int;
    final int completedMeters = purokData['completedMeters'] as int;

    Color statusColor = _getStatusColor(status, colorScheme);
    Color cardColor = colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      purokData['name'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: _getStatusIcon(status),
                      color: statusColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                '$totalMeters meters total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: completionPercentage / 100,
                      backgroundColor:
                          colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 6,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${completionPercentage.toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                '$completedMeters of $totalMeters completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Last read: ${purokData['lastReadingDate'] as String}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 10.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'not_started':
      default:
        return colorScheme.outline;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return 'check_circle';
      case 'in_progress':
        return 'schedule';
      case 'overdue':
        return 'warning';
      case 'not_started':
      default:
        return 'radio_button_unchecked';
    }
  }
}
