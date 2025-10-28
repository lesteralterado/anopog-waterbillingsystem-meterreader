import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HistoryStatisticsCard extends StatelessWidget {
  final int totalReadings;
  final double averageConsumption;
  final double collectionEfficiency;
  final String selectedPeriod;

  const HistoryStatisticsCard({
    super.key,
    required this.totalReadings,
    required this.averageConsumption,
    required this.collectionEfficiency,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'analytics',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Statistics - $selectedPeriod',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Readings',
                      totalReadings.toString(),
                      Icons.list_alt,
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 6.h,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Avg. Consumption',
                      '${averageConsumption.toStringAsFixed(1)} m³',
                      Icons.water_drop,
                      AppTheme.lightTheme.colorScheme.secondary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 6.h,
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Collection Rate',
                      '${collectionEfficiency.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      AppTheme.lightTheme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon.toString().split('.').last,
            size: 24,
            color: color,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
