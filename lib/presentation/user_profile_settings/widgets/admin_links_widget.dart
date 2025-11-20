import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdminLinksWidget extends StatelessWidget {
  const AdminLinksWidget({super.key});

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Contact Support",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Need help? Contact our support team:"),
              SizedBox(height: 2.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'phone',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  const Text("+63 912 345 6789"),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'email',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  const Text("support@barangay-meter.gov.ph"),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  const Text("Mon-Fri, 8:00 AM - 5:00 PM"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Opening email client..."),
                  ),
                );
              },
              child: const Text("Send Email"),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Privacy Policy",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 60.h,
            child: const SingleChildScrollView(
              child: Text(
                """BARANGAY METER READER PRIVACY POLICY

Last updated: September 5, 2025

1. INFORMATION WE COLLECT
We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support.

2. HOW WE USE YOUR INFORMATION
- To provide and maintain our service
- To process meter readings and billing
- To send you technical notices and support messages
- To communicate with you about products, services, and events

3. INFORMATION SHARING
We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.

4. DATA SECURITY
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

5. YOUR RIGHTS
You have the right to access, update, or delete your personal information. You may also opt out of certain communications from us.

6. CONTACT US
If you have any questions about this Privacy Policy, please contact us at privacy@barangay-meter.gov.ph

This policy is compliant with the Data Privacy Act of 2012 (Republic Act No. 10173) of the Philippines.""",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Terms of Service",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 60.h,
            child: const SingleChildScrollView(
              child: Text(
                """BARANGAY METER READER TERMS OF SERVICE

Last updated: September 5, 2025

1. ACCEPTANCE OF TERMS
By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.

2. USE LICENSE
Permission is granted to temporarily use this application for official barangay utility management purposes only.

3. DISCLAIMER
The materials in this application are provided on an 'as is' basis. The Barangay makes no warranties, expressed or implied.

4. LIMITATIONS
In no event shall the Barangay or its suppliers be liable for any damages arising out of the use or inability to use this application.

5. ACCURACY OF MATERIALS
The materials appearing in this application could include technical, typographical, or photographic errors.

6. LINKS
The Barangay has not reviewed all of the sites linked to our application and is not responsible for the contents of any such linked site.

7. MODIFICATIONS
The Barangay may revise these terms of service at any time without notice.

8. GOVERNING LAW
These terms and conditions are governed by and construed in accordance with the laws of the Philippines.""",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
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
              "Support & Information",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            _buildLinkTile(
              title: "Contact Support",
              subtitle: "Get help with the app",
              icon: 'support_agent',
              onTap: () => _showContactSupport(context),
            ),
            _buildLinkTile(
              title: "Privacy Policy",
              subtitle: "How we protect your data",
              icon: 'privacy_tip',
              onTap: () => _showPrivacyPolicy(context),
            ),
            _buildLinkTile(
              title: "Terms of Service",
              subtitle: "App usage terms and conditions",
              icon: 'description',
              onTap: () => _showTermsOfService(context),
            ),
            SizedBox(height: 2.h),
            _buildInfoTile(
              title: "App Version",
              subtitle: "Current version information",
              icon: 'info',
              value: "v1.2.3",
            ),
            _buildInfoTile(
              title: "Build Number",
              subtitle: "Internal build identifier",
              icon: 'build',
              value: "2025.09.05",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile({
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
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withOpacity(0.1),
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
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'chevron_right',
                color:
                    AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.5),
                size: 5.w,
              ),
            ],
          ),
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
              color: AppTheme.lightTheme.colorScheme.tertiary.withOpacity(0.1),
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
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
