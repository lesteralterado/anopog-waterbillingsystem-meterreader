import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricLoginWidget extends StatefulWidget {
  final VoidCallback? onBiometricLogin;
  final bool isEnabled;

  const BiometricLoginWidget({
    super.key,
    this.onBiometricLogin,
    this.isEnabled = false,
  });

  @override
  State<BiometricLoginWidget> createState() => _BiometricLoginWidgetState();
}

class _BiometricLoginWidgetState extends State<BiometricLoginWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricLogin() async {
    if (!widget.isEnabled || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate biometric authentication process
      await Future.delayed(const Duration(milliseconds: 1500));

      if (widget.onBiometricLogin != null) {
        widget.onBiometricLogin!();
      }
    } catch (e) {
      // Handle biometric authentication error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Biometric authentication failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!widget.isEnabled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 3.h),

        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Biometric Login Button
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: _handleBiometricLogin,
                child: Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isProcessing
                        ? SizedBox(
                            width: 6.w,
                            height: 6.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'fingerprint',
                            color: colorScheme.primary,
                            size: 8.w,
                          ),
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 2.h),

        // Biometric Login Text
        Text(
          _isProcessing ? 'Authenticating...' : 'Use Biometric Login',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
