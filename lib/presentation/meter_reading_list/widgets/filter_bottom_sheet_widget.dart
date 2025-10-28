import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final ValueChanged<Map<String, dynamic>>? onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Completed',
    'Issue',
    'Overdue'
  ];
  final List<String> _streetOptions = [
    'All',
    'Main Street',
    'Oak Avenue',
    'Pine Road',
    'Maple Drive',
    'Cedar Lane'
  ];
  final List<String> _paymentStatusOptions = [
    'All',
    'Paid',
    'Unpaid',
    'Overdue'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Filter Options',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filter
                  _buildFilterSection(
                    context,
                    'Reading Status',
                    _statusOptions,
                    _filters['status'] as String? ?? 'All',
                    (value) => setState(() => _filters['status'] = value),
                  ),

                  SizedBox(height: 2.h),

                  // Street Filter
                  _buildFilterSection(
                    context,
                    'Street',
                    _streetOptions,
                    _filters['street'] as String? ?? 'All',
                    (value) => setState(() => _filters['street'] = value),
                  ),

                  SizedBox(height: 2.h),

                  // Payment Status Filter
                  _buildFilterSection(
                    context,
                    'Payment Status',
                    _paymentStatusOptions,
                    _filters['paymentStatus'] as String? ?? 'All',
                    (value) =>
                        setState(() => _filters['paymentStatus'] = value),
                  ),

                  SizedBox(height: 2.h),

                  // Date Range Filter
                  _buildDateRangeSection(context),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    String title,
    List<String> options,
    String selectedValue,
    ValueChanged<String> onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return FilterChip(
              label: Text(
                option,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final startDate = _filters['startDate'] as DateTime?;
    final endDate = _filters['endDate'] as DateTime?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Date Range',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(context, true),
                icon: CustomIconWidget(
                  iconName: 'calendar_today',
                  color: colorScheme.primary,
                  size: 18,
                ),
                label: Text(
                  startDate != null
                      ? '${startDate.day}/${startDate.month}/${startDate.year}'
                      : 'Start Date',
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(context, false),
                icon: CustomIconWidget(
                  iconName: 'calendar_today',
                  color: colorScheme.primary,
                  size: 18,
                ),
                label: Text(
                  endDate != null
                      ? '${endDate.day}/${endDate.month}/${endDate.year}'
                      : 'End Date',
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ),
          ],
        ),
        if (startDate != null || endDate != null) ...[
          SizedBox(height: 1.h),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _filters.remove('startDate');
                _filters.remove('endDate');
              });
            },
            icon: CustomIconWidget(
              iconName: 'clear',
              color: colorScheme.error,
              size: 16,
            ),
            label: Text(
              'Clear Date Range',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _filters['startDate'] = picked;
        } else {
          _filters['endDate'] = picked;
        }
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _filters['status'] = 'All';
      _filters['street'] = 'All';
      _filters['paymentStatus'] = 'All';
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged?.call(_filters);
    Navigator.pop(context);
  }
}
