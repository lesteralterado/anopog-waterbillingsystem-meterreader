import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsSection extends StatelessWidget {
  final VoidCallback? onSaveReading;
  final VoidCallback? onSaveAsEstimated;
  final VoidCallback? onReportIssue;
  final bool isReadingValid;
  final bool isSaving;

  const ActionButtonsSection({
    super.key,
    this.onSaveReading,
    this.onSaveAsEstimated,
    this.onReportIssue,
    this.isReadingValid = false,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (isReadingValid && !isSaving) ? onSaveReading : null,
                icon: isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'save',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 20,
                      ),
                label: Text(
                  isSaving ? 'Saving Reading...' : 'Save Reading',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  disabledBackgroundColor: AppTheme
                      .lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.12),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isReadingValid ? 2 : 0,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            // Secondary Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSaving ? null : onSaveAsEstimated,
                    icon: CustomIconWidget(
                      iconName: 'edit_note',
                      color: isSaving
                          ? AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.38)
                          : AppTheme.lightTheme.colorScheme.secondary,
                      size: 18,
                    ),
                    label: Text(
                      'Save as\nEstimated',
                      textAlign: TextAlign.center,
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: isSaving
                            ? AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.38)
                            : AppTheme.lightTheme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: isSaving
                            ? AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.12)
                            : AppTheme.lightTheme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSaving ? null : onReportIssue,
                    icon: CustomIconWidget(
                      iconName: 'report_problem',
                      color: isSaving
                          ? AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.38)
                          : AppTheme.lightTheme.colorScheme.error,
                      size: 18,
                    ),
                    label: Text(
                      'Report\nIssue',
                      textAlign: TextAlign.center,
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: isSaving
                            ? AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.38)
                            : AppTheme.lightTheme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: isSaving
                            ? AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.12)
                            : AppTheme.lightTheme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            // Status Indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor().withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _getStatusText(),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (isSaving) return AppTheme.lightTheme.colorScheme.primary;
    if (isReadingValid) return Colors.green;
    return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
  }

  String _getStatusIcon() {
    if (isSaving) return 'hourglass_empty';
    if (isReadingValid) return 'check_circle';
    return 'info';
  }

  String _getStatusText() {
    if (isSaving) return 'Saving reading...';
    if (isReadingValid) return 'Ready to save';
    return 'Enter meter reading to continue';
  }
}
