import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BatchOperationsToolbarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onMarkComplete;
  final VoidCallback? onMarkIssue;
  final VoidCallback? onExport;
  final VoidCallback? onCancel;
  final bool isAllSelected;

  const BatchOperationsToolbarWidget({
    super.key,
    required this.selectedCount,
    this.onSelectAll,
    this.onDeselectAll,
    this.onMarkComplete,
    this.onMarkIssue,
    this.onExport,
    this.onCancel,
    this.isAllSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              // Close button
              IconButton(
                onPressed: onCancel,
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
              ),

              SizedBox(width: 2.w),

              // Selected count
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$selectedCount selected',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (selectedCount > 0)
                      Text(
                        'Tap actions to apply to selected items',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),

              // Select/Deselect All
              TextButton(
                onPressed: isAllSelected ? onDeselectAll : onSelectAll,
                child: Text(
                  isAllSelected ? 'Deselect All' : 'Select All',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(width: 2.w),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mark Complete
                  IconButton(
                    onPressed: selectedCount > 0 ? onMarkComplete : null,
                    icon: CustomIconWidget(
                      iconName: 'check_circle',
                      color: selectedCount > 0
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimary.withValues(alpha: 0.4),
                      size: 24,
                    ),
                    tooltip: 'Mark as Complete',
                  ),

                  // Mark Issue
                  IconButton(
                    onPressed: selectedCount > 0 ? onMarkIssue : null,
                    icon: CustomIconWidget(
                      iconName: 'warning',
                      color: selectedCount > 0
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimary.withValues(alpha: 0.4),
                      size: 24,
                    ),
                    tooltip: 'Mark as Issue',
                  ),

                  // Export
                  IconButton(
                    onPressed: selectedCount > 0 ? onExport : null,
                    icon: CustomIconWidget(
                      iconName: 'file_download',
                      color: selectedCount > 0
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimary.withValues(alpha: 0.4),
                      size: 24,
                    ),
                    tooltip: 'Export Selected',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
