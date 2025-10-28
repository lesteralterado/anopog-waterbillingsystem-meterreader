import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReadingHistoryCard extends StatelessWidget {
  final Map<String, dynamic> reading;
  final VoidCallback? onRegenerateReceipt;
  final VoidCallback? onResendNotification;
  final VoidCallback? onEditReading;
  final VoidCallback? onViewDetails;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const ReadingHistoryCard({
    super.key,
    required this.reading,
    this.onRegenerateReceipt,
    this.onResendNotification,
    this.onEditReading,
    this.onViewDetails,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = reading['status'] as String? ?? 'completed';
    final statusColor = _getStatusColor(status);
    final consumption = reading['consumption'] as double? ?? 0.0;
    final billingAmount = reading['billingAmount'] as double? ?? 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(reading['id']),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onRegenerateReceipt?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
              icon: Icons.receipt_long,
              label: 'Receipt',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) => onResendNotification?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onTertiary,
              icon: Icons.send,
              label: 'Resend',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (context) => onEditReading?.call(),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Card(
            elevation: isSelected ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary, width: 2)
                  : BorderSide.none,
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reading['homeownerName'] as String? ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              reading['address'] as String? ?? 'No address',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(
                            imageUrl: reading['meterPhoto'] as String? ??
                                'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
                            width: 15.w,
                            height: 15.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Reading Date',
                          reading['readingDate'] as String? ?? 'N/A',
                          Icons.calendar_today,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Consumption',
                          '${consumption.toStringAsFixed(1)} m³',
                          Icons.water_drop,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Billing Amount',
                          '₱${billingAmount.toStringAsFixed(2)}',
                          Icons.attach_money,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (reading['gpsCoordinates'] != null) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          size: 16,
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'GPS: ${reading['gpsCoordinates']}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isSelected) ...[
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon.toString().split('.').last,
          size: 16,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending billing':
        return Colors.orange;
      case 'sent':
        return Colors.blue;
      case 'paid':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }
}
