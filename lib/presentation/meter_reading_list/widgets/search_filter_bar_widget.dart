import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchFilterBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final List<String> activeFilters;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onClearFilters;

  const SearchFilterBarWidget({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.activeFilters = const [],
    this.onFilterPressed,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search by name, address, or meter number...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged?.call('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                      )
                    : IconButton(
                        onPressed: onFilterPressed,
                        icon: CustomIconWidget(
                          iconName: 'tune',
                          color: activeFilters.isNotEmpty
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
            ),
          ),

          // Active Filters
          if (activeFilters.isNotEmpty) ...[
            SizedBox(height: 1.h),
            SizedBox(
              height: 5.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activeFilters.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      margin: EdgeInsets.only(right: 2.w),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'clear_all',
                              color: colorScheme.error,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Clear All',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        onSelected: (_) => onClearFilters?.call(),
                        backgroundColor: colorScheme.error.withOpacity(0.1),
                        side: BorderSide(
                          color: colorScheme.error.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }

                  final filter = activeFilters[index - 1];
                  return Container(
                    margin: EdgeInsets.only(right: 2.w),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: true,
                      onSelected: (_) {
                        // Handle individual filter removal
                      },
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      selectedColor: colorScheme.primary.withOpacity(0.1),
                      side: BorderSide(
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      deleteIcon: CustomIconWidget(
                        iconName: 'close',
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      onDeleted: () {
                        // Handle filter removal
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
