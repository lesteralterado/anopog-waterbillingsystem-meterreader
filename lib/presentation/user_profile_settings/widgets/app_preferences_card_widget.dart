import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppPreferencesCardWidget extends StatefulWidget {
  final Map<String, dynamic> preferences;
  final Function(Map<String, dynamic>) onPreferencesChanged;

  const AppPreferencesCardWidget({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
  });

  @override
  State<AppPreferencesCardWidget> createState() =>
      _AppPreferencesCardWidgetState();
}

class _AppPreferencesCardWidgetState extends State<AppPreferencesCardWidget> {
  late Map<String, dynamic> _currentPreferences;

  @override
  void initState() {
    super.initState();
    _currentPreferences = Map<String, dynamic>.from(widget.preferences);
  }

  void _updatePreference(String key, dynamic value) {
    setState(() {
      _currentPreferences[key] = value;
    });
    widget.onPreferencesChanged(_currentPreferences);
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
              "App Preferences",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSwitchTile(
              title: "Push Notifications",
              subtitle: "Receive app notifications",
              icon: 'notifications',
              value: _currentPreferences["pushNotifications"] as bool? ?? true,
              onChanged: (value) =>
                  _updatePreference("pushNotifications", value),
            ),
            _buildSwitchTile(
              title: "SMS Delivery Confirmations",
              subtitle: "Get SMS delivery status",
              icon: 'sms',
              value: _currentPreferences["smsConfirmations"] as bool? ?? true,
              onChanged: (value) =>
                  _updatePreference("smsConfirmations", value),
            ),
            _buildSwitchTile(
              title: "Billing Reminders",
              subtitle: "Remind about pending bills",
              icon: 'receipt',
              value: _currentPreferences["billingReminders"] as bool? ?? true,
              onChanged: (value) =>
                  _updatePreference("billingReminders", value),
            ),
            _buildSwitchTile(
              title: "Auto Sync",
              subtitle: "Automatically sync data",
              icon: 'sync',
              value: _currentPreferences["autoSync"] as bool? ?? true,
              onChanged: (value) => _updatePreference("autoSync", value),
            ),
            SizedBox(height: 2.h),
            _buildDropdownTile(
              title: "Sync Frequency",
              subtitle: "How often to sync data",
              icon: 'schedule',
              value: _currentPreferences["syncFrequency"] as String? ??
                  "Every 30 minutes",
              items: [
                "Every 15 minutes",
                "Every 30 minutes",
                "Every hour",
                "Every 4 hours",
                "Manual only"
              ],
              onChanged: (value) => _updatePreference("syncFrequency", value),
            ),
            SizedBox(height: 1.h),
            _buildDropdownTile(
              title: "Camera Quality",
              subtitle: "Photo capture quality",
              icon: 'camera_alt',
              value: _currentPreferences["cameraQuality"] as String? ?? "High",
              items: ["Low", "Medium", "High", "Ultra"],
              onChanged: (value) => _updatePreference("cameraQuality", value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required String icon,
    required bool value,
    required ValueChanged<bool> onChanged,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.secondary,
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
                SizedBox(height: 0.5.h),
                DropdownButtonFormField<String>(
                  value: value,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    filled: true,
                    fillColor: AppTheme.lightTheme.colorScheme.surface,
                  ),
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
