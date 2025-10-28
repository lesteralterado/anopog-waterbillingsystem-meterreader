import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HistorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;
  final String hintText;

  const HistorySearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFilterPressed,
    this.hintText = 'Search by name, address, or purok...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      size: 20,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            size: 20,
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            controller.clear();
                            onChanged?.call('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onFilterPressed,
              icon: CustomIconWidget(
                iconName: 'filter_list',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              padding: EdgeInsets.all(3.w),
            ),
          ),
        ],
      ),
    );
  }
}
