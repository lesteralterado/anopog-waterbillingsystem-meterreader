import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommunicationOptionsWidget extends StatelessWidget {
  final Map<String, dynamic> receiptData;
  final VoidCallback onGeneratePDF;
  final VoidCallback onSendSMS;
  final VoidCallback onSendEmail;
  final VoidCallback onPrintReceipt;
  final bool isProcessing;

  const CommunicationOptionsWidget({
    super.key,
    required this.receiptData,
    required this.onGeneratePDF,
    required this.onSendSMS,
    required this.onSendEmail,
    required this.onPrintReceipt,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Communication Options',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  icon: 'picture_as_pdf',
                  label: 'Generate PDF',
                  color: AppTheme.lightTheme.colorScheme.error,
                  onTap: onGeneratePDF,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildOptionButton(
                  icon: 'sms',
                  label: 'Send SMS',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  onTap: onSendSMS,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  icon: 'email',
                  label: 'Send Email',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  onTap: onSendEmail,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildOptionButton(
                  icon: 'print',
                  label: 'Print Receipt',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  onTap: onPrintReceipt,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSummaryInfo(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: isProcessing
              ? AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isProcessing
                ? AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3)
                : color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isProcessing
                  ? AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.4)
                  : color,
              size: 7.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isProcessing
                    ? AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.4)
                    : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Homeowner:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              Flexible(
                child: Text(
                  receiptData["homeownerName"] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              Text(
                '₱${receiptData["totalAmount"]}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due Date:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              Text(
                receiptData["dueDate"] as String,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
