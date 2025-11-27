import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_info_card_widget.dart';
import './widgets/admin_links_widget.dart';
import './widgets/app_preferences_card_widget.dart';
import './widgets/data_management_card_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/security_settings_card_widget.dart';

class UserProfileSettings extends StatefulWidget {
  const UserProfileSettings({super.key});

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings> {
  // Mock user data
  final Map<String, dynamic> _userData = {
    "id": "EMP001",
    "name": "Reynold Repdos",
    "employeeId": "BRG-2024-001",
    "phone": "+63 961 817 9619",
    "email": "reynold.repdos@barangay.gov.ph",
    "emergencyContact": "Maria Santos",
    "emergencyPhone": "+63 961 817 9619",
    "assignedPuroks": ["Purok 1", "Purok 2", "Purok 3"],
    "profileImage":
        "https://res.cloudinary.com/dhxi75eld/image/upload/v1764207443/3c49c69d-bbc6-4c3a-918a-97d636559204_xcwl0t.jpg",
    "joinDate": "January 15, 2024",
    "lastLogin": "September 5, 2025 10:30 AM",
  };

  // Mock app preferences
  Map<String, dynamic> _appPreferences = {
    "pushNotifications": true,
    "smsConfirmations": true,
    "billingReminders": true,
    "autoSync": true,
    "syncFrequency": "Every 30 minutes",
    "cameraQuality": "High",
  };

  // Mock security settings
  Map<String, dynamic> _securitySettings = {
    "biometricEnabled": false,
    "sessionTimeout": "30 minutes",
    "twoFactorEnabled": false,
    "loginNotifications": true,
  };

  // Mock data settings
  final Map<String, dynamic> _dataSettings = {
    "storageUsed": "245 MB",
    "storageTotal": "1 GB",
    "lastSync": "2 hours ago",
    "offlineEntries": 127,
  };

  void _onUserDataChanged(Map<String, dynamic> newData) {
    setState(() {
      _userData.addAll(newData);
    });
  }

  void _onPreferencesChanged(Map<String, dynamic> newPreferences) {
    setState(() {
      _appPreferences = newPreferences;
    });
  }

  void _onSecurityChanged(Map<String, dynamic> newSettings) {
    setState(() {
      _securitySettings = newSettings;
    });
  }

  void _onDataSettingsChanged(Map<String, dynamic> newSettings) {
    setState(() {
      _dataSettings.addAll(newSettings);
    });
  }

  void _onEditPhoto() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 1.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                "Change Profile Photo",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoOption(
                    icon: 'camera_alt',
                    label: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Opening camera..."),
                        ),
                      );
                    },
                  ),
                  _buildPhotoOption(
                    icon: 'photo_library',
                    label: "Gallery",
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Opening gallery..."),
                        ),
                      );
                    },
                  ),
                  _buildPhotoOption(
                    icon: 'delete',
                    label: "Remove",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _userData["profileImage"] = "";
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 3.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Logout",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to logout? Any unsaved data will be lost.",
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
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Profile Settings",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: CustomIconWidget(
              iconName: 'logout',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              ProfileHeaderWidget(
                userData: _userData,
                onEditPhoto: _onEditPhoto,
              ),
              SizedBox(height: 2.h),
              AccountInfoCardWidget(
                userData: _userData,
                onDataChanged: _onUserDataChanged,
              ),
              AppPreferencesCardWidget(
                preferences: _appPreferences,
                onPreferencesChanged: _onPreferencesChanged,
              ),
              SecuritySettingsCardWidget(
                securitySettings: _securitySettings,
                onSecurityChanged: _onSecurityChanged,
              ),
              DataManagementCardWidget(
                dataSettings: _dataSettings,
                onDataSettingsChanged: _onDataSettingsChanged,
              ),
              const AdminLinksWidget(),
              SizedBox(height: 4.h),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: ElevatedButton(
                  onPressed: _showLogoutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.error,
                    foregroundColor: AppTheme.lightTheme.colorScheme.onError,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'logout',
                        color: AppTheme.lightTheme.colorScheme.onError,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        "Logout",
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightTheme.colorScheme.onError,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
