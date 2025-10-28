import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LoginFormWidget extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const LoginFormWidget({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool _isPasswordVisible = false;
  String? _usernameError;
  String? _passwordError;

  void _validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        _usernameError = 'Username is required';
      } else if (value.length < 3) {
        _usernameError = 'Username must be at least 3 characters';
      } else {
        _usernameError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  bool get _isFormValid {
    return widget.usernameController.text.isNotEmpty &&
        widget.passwordController.text.isNotEmpty &&
        _usernameError == null &&
        _passwordError == null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Username Field
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _usernameError != null
                  ? colorScheme.error
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.usernameController,
            enabled: !widget.isLoading,
            onChanged: _validateUsername,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your username',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: _usernameError != null
                      ? colorScheme.error
                      : colorScheme.primary,
                  size: 5.w,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
            ),
          ),
        ),

        // Username Error Message
        if (_usernameError != null) ...[
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Text(
              _usernameError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],

        SizedBox(height: 2.h),

        // Password Field
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _passwordError != null
                  ? colorScheme.error
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.passwordController,
            enabled: !widget.isLoading,
            onChanged: _validatePassword,
            obscureText: !_isPasswordVisible,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_isFormValid && !widget.isLoading) {
                widget.onLogin();
              }
            },
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: _passwordError != null
                      ? colorScheme.error
                      : colorScheme.primary,
                  size: 5.w,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: widget.isLoading
                    ? null
                    : () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                icon: CustomIconWidget(
                  iconName:
                      _isPasswordVisible ? 'visibility' : 'visibility_off',
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 5.w,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
            ),
          ),
        ),

        // Password Error Message
        if (_passwordError != null) ...[
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Text(
              _passwordError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],

        SizedBox(height: 2.h),

        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.isLoading ? null : widget.onForgotPassword,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            ),
            child: Text(
              'Forgot Password?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 11.sp,
              ),
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Login Button
        SizedBox(
          height: 6.h,
          child: ElevatedButton(
            onPressed:
                (_isFormValid && !widget.isLoading) ? widget.onLogin : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor:
                  colorScheme.onSurface.withValues(alpha: 0.12),
              disabledForegroundColor:
                  colorScheme.onSurface.withValues(alpha: 0.38),
              elevation: widget.isLoading ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: 4.w,
                    width: 4.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Login',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
