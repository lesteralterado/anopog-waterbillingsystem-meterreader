import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SecuritySettingsCardWidget extends StatefulWidget {
  final Map<String, dynamic> securitySettings;
  final Function(Map<String, dynamic>) onSecurityChanged;

  const SecuritySettingsCardWidget({
    super.key,
    required this.securitySettings,
    required this.onSecurityChanged,
  });

  @override
  State<SecuritySettingsCardWidget> createState() =>
      _SecuritySettingsCardWidgetState();
}

class _SecuritySettingsCardWidgetState
    extends State<SecuritySettingsCardWidget> {
  late Map<String, dynamic> _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = Map<String, dynamic>.from(widget.securitySettings);
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      _currentSettings[key] = value;
    });
    widget.onSecurityChanged(_currentSettings);
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Change Password",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Current Password",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm New Password",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
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
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  // Simulate password change
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password changed successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Passwords do not match"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Change Password"),
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
              "Security Settings",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            _buildActionTile(
              title: "Change Password",
              subtitle: "Update your account password",
              icon: 'lock',
              onTap: _showChangePasswordDialog,
            ),
            _buildSwitchTile(
              title: "Biometric Authentication",
              subtitle: "Use fingerprint or face unlock",
              icon: 'fingerprint',
              value: _currentSettings["biometricEnabled"] as bool? ?? false,
              onChanged: (value) => _updateSetting("biometricEnabled", value),
            ),
            _buildDropdownTile(
              title: "Session Timeout",
              subtitle: "Auto-logout after inactivity",
              icon: 'timer',
              value:
                  _currentSettings["sessionTimeout"] as String? ?? "30 minutes",
              items: ["15 minutes", "30 minutes", "1 hour", "2 hours", "Never"],
              onChanged: (value) => _updateSetting("sessionTimeout", value),
            ),
            SizedBox(height: 1.h),
            _buildSwitchTile(
              title: "Two-Factor Authentication",
              subtitle: "Extra security with SMS codes",
              icon: 'security',
              value: _currentSettings["twoFactorEnabled"] as bool? ?? false,
              onChanged: (value) => _updateSetting("twoFactorEnabled", value),
            ),
            _buildSwitchTile(
              title: "Login Notifications",
              subtitle: "Get notified of new logins",
              icon: 'notification_important',
              value: _currentSettings["loginNotifications"] as bool? ?? true,
              onChanged: (value) => _updateSetting("loginNotifications", value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2.w),
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: icon,
                    color: AppTheme.lightTheme.colorScheme.error,
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
              color: AppTheme.lightTheme.colorScheme.tertiary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.tertiary,
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
