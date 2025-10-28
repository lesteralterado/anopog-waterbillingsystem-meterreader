import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EditableFieldsWidget extends StatelessWidget {
  final Map<String, dynamic> receiptData;
  final Function(String, dynamic) onFieldChanged;
  final Map<String, String> validationErrors;

  const EditableFieldsWidget({
    super.key,
    required this.receiptData,
    required this.onFieldChanged,
    required this.validationErrors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Edit Receipt Details',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildEditableField(
            'Billing Period',
            'billingPeriod',
            receiptData["billingPeriod"] as String,
            TextInputType.text,
          ),
          SizedBox(height: 2.h),
          _buildEditableField(
            'Rate per Cubic Meter (₱)',
            'ratePerCubicMeter',
            receiptData["ratePerCubicMeter"].toString(),
            TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 2.h),
          _buildEditableField(
            'Basic Charge (₱)',
            'basicCharge',
            receiptData["basicCharge"].toString(),
            TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 2.h),
          _buildEditableField(
            'Penalties (₱)',
            'penalties',
            receiptData["penalties"].toString(),
            TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 2.h),
          _buildEditableField(
            'Due Date (MM/DD/YYYY)',
            'dueDate',
            receiptData["dueDate"] as String,
            TextInputType.datetime,
          ),
          SizedBox(height: 2.h),
          _buildEditableField(
            'Payment Terms',
            'paymentTerms',
            receiptData["paymentTerms"] as String,
            TextInputType.multiline,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    String fieldKey,
    String initialValue,
    TextInputType inputType, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          initialValue: initialValue,
          keyboardType: inputType,
          maxLines: maxLines,
          onChanged: (value) {
            if (inputType == TextInputType.numberWithOptions(decimal: true)) {
              final numValue = double.tryParse(value) ?? 0.0;
              onFieldChanged(fieldKey, numValue);
            } else {
              onFieldChanged(fieldKey, value);
            }
          },
          inputFormatters: inputType ==
                  TextInputType.numberWithOptions(decimal: true)
              ? [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ]
              : null,
          decoration: InputDecoration(
            hintText: _getHintText(fieldKey),
            errorText: validationErrors[fieldKey],
            prefixIcon: _getPrefixIcon(fieldKey),
            suffixIcon: fieldKey.contains('Date')
                ? CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 5.w,
                  )
                : null,
          ),
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget? _getPrefixIcon(String fieldKey) {
    if (fieldKey.contains('rate') ||
        fieldKey.contains('Charge') ||
        fieldKey.contains('penalties')) {
      return Padding(
        padding: EdgeInsets.all(3.w),
        child: Text(
          '₱',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
      );
    }
    return null;
  }

  String _getHintText(String fieldKey) {
    switch (fieldKey) {
      case 'billingPeriod':
        return 'e.g., January 2025';
      case 'ratePerCubicMeter':
        return 'Enter rate per cubic meter';
      case 'basicCharge':
        return 'Enter basic charge amount';
      case 'penalties':
        return 'Enter penalty amount (if any)';
      case 'dueDate':
        return 'MM/DD/YYYY';
      case 'paymentTerms':
        return 'Enter payment terms and conditions';
      default:
        return 'Enter $fieldKey';
    }
  }
}
