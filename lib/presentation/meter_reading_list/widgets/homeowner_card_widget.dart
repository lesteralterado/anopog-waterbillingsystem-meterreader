import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class HomeownerCardWidget extends StatelessWidget {
  final Map<String, dynamic> homeowner;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onViewHistory;
  final VoidCallback? onMarkIssue;
  final VoidCallback? onSkipReading;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const HomeownerCardWidget({
    super.key,
    required this.homeowner,
    this.onTap,
    this.onCall,
    this.onViewHistory,
    this.onMarkIssue,
    this.onSkipReading,
    this.isSelected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final status = homeowner['status'] as String? ?? 'pending';
    final statusColor = _getStatusColor(status, colorScheme);
    final statusBgColor = statusColor.withValues(alpha: 0.1);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(homeowner['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onCall?.call(),
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              icon: Icons.phone,
              label: 'Call',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onViewHistory?.call(),
              backgroundColor: colorScheme.tertiary,
              foregroundColor: colorScheme.onTertiary,
              icon: Icons.history,
              label: 'History',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onMarkIssue?.call(),
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Icons.warning,
              label: 'Issue',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onSkipReading?.call(),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.skip_next,
              label: 'Skip',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isSelected)
                        Container(
                          margin: EdgeInsets.only(right: 2.w),
                          child: CustomIconWidget(
                            iconName: 'check_circle',
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'House ${homeowner['houseNumber'] ?? 'N/A'}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    homeowner['name'] as String? ?? 'Unknown Homeowner',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    homeowner['address'] as String? ?? 'No address provided',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Previous Reading',
                          '${homeowner['previousReading'] ?? 0} m³',
                          Icons.water_drop_outlined,
                          colorScheme,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Due Date',
                          homeowner['dueDate'] as String? ?? 'Not set',
                          Icons.calendar_today_outlined,
                          colorScheme,
                        ),
                      ),
                    ],
                  ),
                  if (homeowner['meterNumber'] != null) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'speed',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Meter: ${homeowner['meterNumber']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon.toString().split('.').last,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 14,
            ),
            SizedBox(width: 1.w),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'issue':
        return colorScheme.error;
      case 'overdue':
        return Colors.red;
      default:
        return colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }
}
