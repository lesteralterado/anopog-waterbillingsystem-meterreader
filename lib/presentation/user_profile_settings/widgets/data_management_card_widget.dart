import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DataManagementCardWidget extends StatefulWidget {
  final Map<String, dynamic> dataSettings;
  final Function(Map<String, dynamic>) onDataSettingsChanged;

  const DataManagementCardWidget({
    super.key,
    required this.dataSettings,
    required this.onDataSettingsChanged,
  });

  @override
  State<DataManagementCardWidget> createState() =>
      _DataManagementCardWidgetState();
}

class _DataManagementCardWidgetState extends State<DataManagementCardWidget> {
  bool _isExporting = false;
  bool _isSyncing = false;
  bool _isClearingCache = false;

  void _exportPersonalData() async {
    setState(() {
      _isExporting = true;
    });

    // Simulate export process
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isExporting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Personal data exported successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSyncing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data synchronized successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearCache() async {
    setState(() {
      _isClearingCache = true;
    });

    // Simulate cache clearing
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isClearingCache = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cache cleared successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Clear Cache",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "This will clear all cached data including offline meter readings. Are you sure you want to continue?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCache();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: const Text("Clear Cache"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Data Management",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            _buildInfoTile(
              title: "Storage Used",
              subtitle: "245 MB of 1 GB available",
              icon: 'storage',
              value: "24.5%",
            ),
            _buildInfoTile(
              title: "Last Sync",
              subtitle: "Data synchronized",
              icon: 'sync',
              value: "2 hours ago",
            ),
            _buildInfoTile(
              title: "Offline Data",
              subtitle: "Cached meter readings",
              icon: 'offline_bolt',
              value: "127 entries",
            ),
            SizedBox(height: 2.h),
            _buildActionTile(
              title: "Export Personal Data",
              subtitle: "Download your data as CSV",
              icon: 'download',
              isLoading: _isExporting,
              onTap: _exportPersonalData,
            ),
            _buildActionTile(
              title: "Sync Data Now",
              subtitle: "Force synchronization",
              icon: 'sync',
              isLoading: _isSyncing,
              onTap: _syncData,
            ),
            _buildActionTile(
              title: "Clear Cache",
              subtitle: "Free up storage space",
              icon: 'delete_sweep',
              isLoading: _isClearingCache,
              onTap: _showClearCacheDialog,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required String icon,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
    bool isLoading = false,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(2.w),
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppTheme.lightTheme.colorScheme.error
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDestructive
                                  ? AppTheme.lightTheme.colorScheme.error
                                  : AppTheme.lightTheme.colorScheme.secondary,
                            ),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: icon,
                          color: isDestructive
                              ? AppTheme.lightTheme.colorScheme.error
                              : AppTheme.lightTheme.colorScheme.secondary,
                          size: 5.w,
                        ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? AppTheme.lightTheme.colorScheme.error
                            : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLoading)
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                  size: 5.w,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
