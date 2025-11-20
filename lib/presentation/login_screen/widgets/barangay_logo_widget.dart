import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BarangayLogoWidget extends StatelessWidget {
  const BarangayLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Logo Container
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // CustomIconWidget(
                //   iconName: 'water_drop',
                //   color: colorScheme.onPrimary,
                //   size: 8.w,
                // ),
                CustomImageWidget(
                    imageUrl: "assets/images/logo.png",
                    width: 10.w,
                    height: 10.w,
                    fit: BoxFit.cover,
                  ),
                SizedBox(height: 0.5.h),
                Text(
                  'BRGY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 8.sp,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Barangay Title
        Text(
          'Barangay Meter Reader',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 1.h),

        // Subtitle
        Text(
          'Water Utility Management System',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
