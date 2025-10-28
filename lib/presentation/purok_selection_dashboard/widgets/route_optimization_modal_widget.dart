import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RouteOptimizationModalWidget extends StatelessWidget {
  final List<Map<String, dynamic>> optimizedRoute;
  final VoidCallback onStartRoute;

  const RouteOptimizationModalWidget({
    super.key,
    required this.optimizedRoute,
    required this.onStartRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 70.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'route',
                color: colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Optimized Route',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Suggested reading sequence based on GPS efficiency',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'This route can save you approximately 25 minutes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: ListView.separated(
              itemCount: optimizedRoute.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final purok = optimizedRoute[index];
                final isFirst = index == 0;
                final isLast = index == optimizedRoute.length - 1;

                return _buildRouteItem(
                  context,
                  purok: purok,
                  stepNumber: index + 1,
                  isFirst: isFirst,
                  isLast: isLast,
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onStartRoute();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'navigation',
                        color: colorScheme.onPrimary,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text('Start Route'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(
    BuildContext context, {
    required Map<String, dynamic> purok,
    required int stepNumber,
    required bool isFirst,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String status = purok['status'] as String;
    final Color statusColor = _getStatusColor(status, colorScheme);

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: isFirst ? colorScheme.primary : statusColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  stepNumber.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 4.h,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
          ],
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      purok['name'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${purok['completionPercentage']}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${purok['totalMeters']} meters • Est. ${purok['estimatedTime']} min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
}
