import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BulkActionsFabWidget extends StatelessWidget {
  final bool isMultiSelectMode;
  final int selectedCount;
  final VoidCallback? onExportList;
  final VoidCallback? onMarkMultipleComplete;
  final VoidCallback? onToggleMultiSelect;

  const BulkActionsFabWidget({
    super.key,
    required this.isMultiSelectMode,
    required this.selectedCount,
    this.onExportList,
    this.onMarkMultipleComplete,
    this.onToggleMultiSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isMultiSelectMode) {
      return _buildMultiSelectFab(context, theme, colorScheme);
    } else {
      return _buildNormalFab(context, theme, colorScheme);
    }
  }

  Widget _buildNormalFab(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "export_fab",
          onPressed: onExportList,
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          child: CustomIconWidget(
            iconName: 'file_download',
            color: colorScheme.onSecondary,
            size: 24,
          ),
        ),
        SizedBox(height: 2.h),
        FloatingActionButton(
          heroTag: "multi_select_fab",
          onPressed: onToggleMultiSelect,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          child: CustomIconWidget(
            iconName: 'checklist',
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectFab(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected count indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$selectedCount selected',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mark Complete button
              FloatingActionButton.small(
                heroTag: "mark_complete_fab",
                onPressed: selectedCount > 0 ? onMarkMultipleComplete : null,
                backgroundColor: selectedCount > 0
                    ? Colors.green
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: selectedCount > 0
                    ? Colors.white
                    : colorScheme.onSurface.withValues(alpha: 0.4),
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: selectedCount > 0
                      ? Colors.white
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
              ),

              SizedBox(width: 2.w),

              // Export selected button
              FloatingActionButton.small(
                heroTag: "export_selected_fab",
                onPressed: selectedCount > 0 ? onExportList : null,
                backgroundColor: selectedCount > 0
                    ? colorScheme.secondary
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: selectedCount > 0
                    ? colorScheme.onSecondary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
                child: CustomIconWidget(
                  iconName: 'file_download',
                  color: selectedCount > 0
                      ? colorScheme.onSecondary
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
              ),

              SizedBox(width: 2.w),

              // Cancel multi-select button
              FloatingActionButton.small(
                heroTag: "cancel_multi_select_fab",
                onPressed: onToggleMultiSelect,
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                child: CustomIconWidget(
                  iconName: 'close',
                  color: colorScheme.onError,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
