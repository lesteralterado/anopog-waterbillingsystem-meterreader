import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdvancedFilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const AdvancedFilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onFiltersApplied,
  });

  @override
  State<AdvancedFilterBottomSheet> createState() =>
      _AdvancedFilterBottomSheetState();
}

class _AdvancedFilterBottomSheetState extends State<AdvancedFilterBottomSheet> {
  late Map<String, dynamic> _filters;
  final TextEditingController _minReadingController = TextEditingController();
  final TextEditingController _maxReadingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _minReadingController.text = _filters['minReading']?.toString() ?? '';
    _maxReadingController.text = _filters['maxReading']?.toString() ?? '';
  }

  @override
  void dispose() {
    _minReadingController.dispose();
    _maxReadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Advanced Filters',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Purok Selection'),
                  _buildPurokFilter(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Billing Status'),
                  _buildStatusFilter(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Reading Range (m³)'),
                  _buildReadingRangeFilter(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Date Range'),
                  _buildDateRangeFilter(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPurokFilter() {
    final puroks = [
      'All Puroks',
      'Purok 1',
      'Purok 2',
      'Purok 3',
      'Purok 4',
      'Purok 5',
      'Purok 6',
      'Purok 7',
      'Purok 8'
    ];

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: puroks.map((purok) {
          final isSelected = _filters['selectedPurok'] == purok;
          return FilterChip(
            label: Text(purok),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _filters['selectedPurok'] = selected ? purok : null;
              });
            },
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            selectedColor:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
            labelStyle: TextStyle(
              fontSize: 12.sp,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      'All Status',
      'Completed',
      'Pending Billing',
      'Sent',
      'Paid'
    ];

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: statuses.map((status) {
          final isSelected = _filters['selectedStatus'] == status;
          return FilterChip(
            label: Text(status),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _filters['selectedStatus'] = selected ? status : null;
              });
            },
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            selectedColor: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.2),
            checkmarkColor: AppTheme.lightTheme.colorScheme.secondary,
            labelStyle: TextStyle(
              fontSize: 12.sp,
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReadingRangeFilter() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _minReadingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Min Reading',
                hintText: '0.0',
                suffixText: 'm³',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _filters['minReading'] = double.tryParse(value);
              },
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'to',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: TextField(
              controller: _maxReadingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Max Reading',
                hintText: '999.9',
                suffixText: 'm³',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _filters['maxReading'] = double.tryParse(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _selectStartDate(),
              icon: CustomIconWidget(
                iconName: 'calendar_today',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: Text(
                _filters['startDate'] != null
                    ? _formatDate(_filters['startDate'])
                    : 'Start Date',
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _selectEndDate(),
              icon: CustomIconWidget(
                iconName: 'calendar_today',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: Text(
                _filters['endDate'] != null
                    ? _formatDate(_filters['endDate'])
                    : 'End Date',
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _filters['startDate'] ?? DateTime.now().subtract(Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _filters['startDate'] = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filters['endDate'] ?? DateTime.now(),
      firstDate: _filters['startDate'] ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _filters['endDate'] = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
      _minReadingController.clear();
      _maxReadingController.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }
}
