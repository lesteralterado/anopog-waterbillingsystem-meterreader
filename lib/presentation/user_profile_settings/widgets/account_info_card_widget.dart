import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountInfoCardWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AccountInfoCardWidget({
    super.key,
    required this.userData,
    required this.onDataChanged,
  });

  @override
  State<AccountInfoCardWidget> createState() => _AccountInfoCardWidgetState();
}

class _AccountInfoCardWidgetState extends State<AccountInfoCardWidget> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userData["name"] as String? ?? "");
    _phoneController =
        TextEditingController(text: widget.userData["phone"] as String? ?? "");
    _emailController =
        TextEditingController(text: widget.userData["email"] as String? ?? "");
    _emergencyContactController = TextEditingController(
        text: widget.userData["emergencyContact"] as String? ?? "");
    _emergencyPhoneController = TextEditingController(
        text: widget.userData["emergencyPhone"] as String? ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedData = Map<String, dynamic>.from(widget.userData);
    updatedData["name"] = _nameController.text;
    updatedData["phone"] = _phoneController.text;
    updatedData["email"] = _emailController.text;
    updatedData["emergencyContact"] = _emergencyContactController.text;
    updatedData["emergencyPhone"] = _emergencyPhoneController.text;

    widget.onDataChanged(updatedData);
    setState(() {
      _isEditing = false;
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Account Information",
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_isEditing) {
                      _saveChanges();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
                  icon: CustomIconWidget(
                    iconName: _isEditing ? 'save' : 'edit',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildInfoField(
              label: "Full Name",
              controller: _nameController,
              icon: 'person',
            ),
            SizedBox(height: 2.h),
            _buildInfoField(
              label: "Phone Number",
              controller: _phoneController,
              icon: 'phone',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 2.h),
            _buildInfoField(
              label: "Email Address",
              controller: _emailController,
              icon: 'email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 2.h),
            _buildInfoField(
              label: "Emergency Contact",
              controller: _emergencyContactController,
              icon: 'contact_emergency',
            ),
            SizedBox(height: 2.h),
            _buildInfoField(
              label: "Emergency Phone",
              controller: _emergencyPhoneController,
              icon: 'phone_in_talk',
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required String icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.5.h),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: icon,
                color: _isEditing
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                size: 5.w,
              ),
            ),
            filled: true,
            fillColor: _isEditing
                ? AppTheme.lightTheme.colorScheme.surface
                : AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: _isEditing
                ? AppTheme.lightTheme.colorScheme.onSurface
                : AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
