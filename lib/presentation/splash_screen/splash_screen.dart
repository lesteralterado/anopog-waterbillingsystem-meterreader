import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:barangay_meter_reader/core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isInitialized = false;
  bool _showOfflineOption = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppTheme.lightTheme.colorScheme.primary,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Initialize core services
      await _performInitializationTasks();

      // Show offline option after 5 seconds if still loading
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isInitialized && mounted) {
          setState(() {
            _showOfflineOption = true;
          });
        }
      });

      // Navigate after minimum splash duration
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      // Handle initialization errors gracefully
      if (mounted) {
        setState(() {
          _showOfflineOption = true;
        });
      }
    }
  }

  Future<void> _performInitializationTasks() async {
    try {
      // Quick initialization check - no artificial delays
      await Future.delayed(const Duration(milliseconds: 200));

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error in splash initialization: $e');
      // Still mark as initialized to allow app to continue
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _navigateToNextScreen() {
    // Check authentication status (mock implementation)
    final bool isAuthenticated = _checkAuthenticationStatus();
    final bool isNewUser = _checkIfNewUser();

    if (isAuthenticated) {
      // Authenticated meter readers go to purok selection dashboard
      Navigator.pushReplacementNamed(context, '/purok-selection-dashboard');
    } else if (isNewUser) {
      // New users see registration flow (redirect to login for now)
      Navigator.pushReplacementNamed(context, '/login-screen');
    } else {
      // Returning non-authenticated users reach login screen
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  bool _checkAuthenticationStatus() {
    // Mock authentication check
    // In real implementation, check stored tokens/credentials
    return false;
  }

  bool _checkIfNewUser() {
    // Mock new user check
    // In real implementation, check if user has completed onboarding
    return true;
  }

  void _continueOffline() {
    // Handle offline mode navigation
    Navigator.pushReplacementNamed(context, '/purok-selection-dashboard');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.primaryContainer,
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Government/Utility Logo
                              Container(
                                width: 20.w,
                                height: 20.w,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'water_drop',
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        size: 6.w,
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        'BRGY',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),

                              // App Title
                              Text(
                                'Barangay Meter Reader',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 1.h),

                              // Subtitle
                              Text(
                                'Utility Management System',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onPrimary
                                      .withValues(alpha: 0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 6.h),

                              // Loading Indicator
                              _isInitialized
                                  ? CustomIconWidget(
                                      iconName: 'check_circle',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      size: 6.w,
                                    )
                                  : SizedBox(
                                      width: 6.w,
                                      height: 6.w,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppTheme
                                              .lightTheme.colorScheme.onPrimary,
                                        ),
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                              SizedBox(height: 2.h),

                              // Status Text
                              Text(
                                _isInitialized ? 'Ready!' : 'Initializing...',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onPrimary
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Offline Option (shown after 5 seconds)
              _showOfflineOption
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.surface
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.onPrimary
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                CustomIconWidget(
                                  iconName: 'wifi_off',
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  size: 5.w,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Connection timeout',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Offline mode is available for meter reading',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onPrimary
                                        .withValues(alpha: 0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 3.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _continueOffline,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme
                                          .lightTheme.colorScheme.surface,
                                      foregroundColor: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Continue Offline',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(height: 8.h),

              // Version Info
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  'Version 1.0.0 • Philippine Local Government',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary
                        .withValues(alpha: 0.6),
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
