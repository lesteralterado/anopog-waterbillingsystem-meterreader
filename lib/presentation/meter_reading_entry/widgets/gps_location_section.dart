import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GpsLocationSection extends StatefulWidget {
  final ValueChanged<Position?>? onLocationCaptured;

  const GpsLocationSection({
    super.key,
    this.onLocationCaptured,
  });

  @override
  State<GpsLocationSection> createState() => _GpsLocationSectionState();
}

class _GpsLocationSectionState extends State<GpsLocationSection> {
  Position? _currentPosition;
  bool _isCapturingLocation = false;
  String _locationStatus = 'Location not captured';
  double _accuracy = 0.0;

  Future<bool> _requestLocationPermission() async {
    if (kIsWeb) {
      return await Geolocator.isLocationServiceEnabled();
    }

    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isCapturingLocation = true;
      _locationStatus = 'Capturing location...';
    });

    try {
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        setState(() {
          _isCapturingLocation = false;
          _locationStatus = 'Location permission denied';
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isCapturingLocation = false;
          _locationStatus = 'Location services disabled';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _accuracy = position.accuracy;
        _isCapturingLocation = false;
        _locationStatus = 'Location captured successfully';
      });

      widget.onLocationCaptured?.call(position);
    } catch (e) {
      setState(() {
        _isCapturingLocation = false;
        _locationStatus = 'Failed to capture location';
      });
    }
  }

  String _getAccuracyStatus() {
    if (_accuracy == 0.0) return 'Unknown';
    if (_accuracy <= 5) return 'Excellent';
    if (_accuracy <= 10) return 'Good';
    if (_accuracy <= 20) return 'Fair';
    return 'Poor';
  }

  Color _getAccuracyColor() {
    if (_accuracy == 0.0)
      return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.5);
    if (_accuracy <= 5) return Colors.green;
    if (_accuracy <= 10) return Colors.lightGreen;
    if (_accuracy <= 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'GPS Location',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: _isCapturingLocation
                          ? 'hourglass_empty'
                          : _currentPosition != null
                              ? 'check_circle'
                              : 'location_off',
                      color: _isCapturingLocation
                          ? AppTheme.lightTheme.colorScheme.primary
                          : _currentPosition != null
                              ? Colors.green
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        _locationStatus,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_currentPosition != null) ...[
                  SizedBox(height: 2.h),
                  _buildLocationInfo('Latitude',
                      _currentPosition!.latitude.toStringAsFixed(6)),
                  SizedBox(height: 1.h),
                  _buildLocationInfo('Longitude',
                      _currentPosition!.longitude.toStringAsFixed(6)),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Accuracy:',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getAccuracyColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${_accuracy.toStringAsFixed(1)}m (${_getAccuracyStatus()})',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: _getAccuracyColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCapturingLocation ? null : _captureLocation,
              icon: _isCapturingLocation
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : CustomIconWidget(
                      iconName:
                          _currentPosition != null ? 'refresh' : 'my_location',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 20,
                    ),
              label: Text(
                _isCapturingLocation
                    ? 'Capturing...'
                    : _currentPosition != null
                        ? 'Update Location'
                        : 'Capture Location',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
