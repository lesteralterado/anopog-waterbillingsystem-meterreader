import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/user_service.dart';
import '../../core/database_helper.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/barangay_logo_widget.dart';
import './widgets/biometric_login_widget.dart';
import './widgets/login_form_widget.dart';
// import 'widgets/barangay_logo_widget.dart';
// import 'widgets/biometric_login_widget.dart';
// import 'widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final UserService _userService = UserService();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  bool _biometricEnabled = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    // Simulate checking biometric availability
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _biometricEnabled = true; // Enable for demo purposes
      });
    }
  }

  Future<void> _loadSavedCredentials() async {
    // Simulate loading saved credentials
    await Future.delayed(const Duration(milliseconds: 300));
    // For demo, we could pre-fill with last used username
  }

  Future<void> _fetchAndStoreConsumers() async {
    try {
      final consumers = await _userService.fetchConsumers();
      await _databaseHelper.deleteAllConsumers(); // Clear old data
      for (final consumer in consumers) {
        final consumerData = {
          DatabaseHelper.columnConsumerId: consumer['id'],
          DatabaseHelper.columnUsername: consumer['username'],
          DatabaseHelper.columnRoleId: consumer['role_id'],
          DatabaseHelper.columnPurok: consumer['purok'],
          DatabaseHelper.columnMeterNumber: consumer['meter_number'],
          DatabaseHelper.columnFullName: consumer['full_name'],
          DatabaseHelper.columnAddress: consumer['address'],
          DatabaseHelper.columnPhone: consumer['phone'],
          DatabaseHelper.columnEmail: consumer['email'],
          DatabaseHelper.columnRoleName: consumer['role']?['name'],
          DatabaseHelper.columnCreatedAt: DateTime.now().toIso8601String(),
        };
        await _databaseHelper.insertConsumer(consumerData);
      }
    } catch (e) {
      // Silently fail - consumers can be fetched later
      debugPrint('Failed to fetch consumers: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Authenticate via API
      final user = await _userService.login(username, password);

      if (user != null) {
        // Fetch and store consumers in background
        _fetchAndStoreConsumers();

        // Success - provide success haptic feedback
        HapticFeedback.heavyImpact();

        // Navigate to dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(
              context, '/purok-selection-dashboard');
        }
        return;
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      // Provide error haptic feedback
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    // Simulate biometric authentication success
    HapticFeedback.heavyImpact();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/purok-selection-dashboard');
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text(
          'Please contact your barangay administrator to reset your password.\n\nAdmin Contact: admin@barangay.gov.ph\nPhone: (02) 123-4567',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),

                  // Barangay Logo
                  const BarangayLogoWidget(),

                  SizedBox(height: 6.h),

                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      margin: EdgeInsets.only(bottom: 3.h),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error_outline',
                            color: colorScheme.error,
                            size: 5.w,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Login Form
                  LoginFormWidget(
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    isLoading: _isLoading,
                    onLogin: _handleLogin,
                    onForgotPassword: _handleForgotPassword,
                  ),

                  // Biometric Login
                  BiometricLoginWidget(
                    isEnabled: _biometricEnabled && !_isLoading,
                    onBiometricLogin: _handleBiometricLogin,
                  ),

                  SizedBox(height: 4.h),

                  // Demo Credentials Info
                  // Container(
                  //   width: double.infinity,
                  //   padding: EdgeInsets.all(3.w),
                  //   decoration: BoxDecoration(
                  //     color: colorScheme.primary.withValues(alpha: 0.05),
                  //     borderRadius: BorderRadius.circular(8),
                  //     border: Border.all(
                  //       color: colorScheme.primary.withValues(alpha: 0.2),
                  //     ),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           CustomIconWidget(
                  //             iconName: 'info_outline',
                  //             color: colorScheme.primary,
                  //             size: 4.w,
                  //           ),
                  //           SizedBox(width: 2.w),
                  //           Text(
                  //             'Demo Credentials',
                  //             style: theme.textTheme.labelMedium?.copyWith(
                  //               color: colorScheme.primary,
                  //               fontWeight: FontWeight.w600,
                  //               fontSize: 11.sp,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       SizedBox(height: 1.h),
                  //       Text(
                  //         'Admin: admin / admin123\nReader: reader01 / reader123\nSupervisor: supervisor / super123',
                  //         style: theme.textTheme.bodySmall?.copyWith(
                  //           color: colorScheme.onSurface.withValues(alpha: 0.7),
                  //           fontSize: 10.sp,
                  //           height: 1.4,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
