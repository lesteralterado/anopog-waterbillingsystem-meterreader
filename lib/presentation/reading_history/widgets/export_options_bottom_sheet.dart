import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportOptionsBottomSheet extends StatefulWidget {
  final Function(String format, DateTime? startDate, DateTime? endDate)
      onExport;

  const ExportOptionsBottomSheet({
    super.key,
    required this.onExport,
  });

  @override
  State<ExportOptionsBottomSheet> createState() =>
      _ExportOptionsBottomSheetState();
}

class _ExportOptionsBottomSheetState extends State<ExportOptionsBottomSheet> {
  String _selectedFormat = 'CSV';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
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
                  'Export Options',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
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
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Format',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildFormatOption(
                      'CSV', 'Comma-separated values file', Icons.table_chart),
                  _buildFormatOption(
                      'PDF', 'Portable document format', Icons.picture_as_pdf),
                  SizedBox(height: 3.h),
                  Text(
                    'Date Range',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectStartDate,
                          icon: CustomIconWidget(
                            iconName: 'calendar_today',
                            size: 20,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          label: Text(
                            _startDate != null
                                ? _formatDate(_startDate!)
                                : 'Start Date',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectEndDate,
                          icon: CustomIconWidget(
                            iconName: 'calendar_today',
                            size: 20,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          label: Text(
                            _endDate != null
                                ? _formatDate(_endDate!)
                                : 'End Date',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _setQuickDateRange('today'),
                          child:
                              Text('Today', style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _setQuickDateRange('week'),
                          child: Text('This Week',
                              style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _setQuickDateRange('month'),
                          child: Text('This Month',
                              style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          size: 20,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Export will include all readings within the selected date range.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    onPressed: _exportData,
                    child: Text('Export $_selectedFormat'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String format, String description, IconData icon) {
    final isSelected = _selectedFormat == format;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFormat = format;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: icon.toString().split('.').last,
                  size: 24,
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      format,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                CustomIconWidget(
                  iconName: 'check_circle',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _setQuickDateRange(String range) {
    final now = DateTime.now();
    setState(() {
      switch (range) {
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          _startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  void _exportData() {
    widget.onExport(_selectedFormat, _startDate, _endDate);
    Navigator.pop(context);
  }
}
