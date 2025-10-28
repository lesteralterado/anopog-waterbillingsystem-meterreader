import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_section.dart';
import './widgets/camera_capture_section.dart';
import './widgets/gps_location_section.dart';
import './widgets/homeowner_info_card.dart';
import './widgets/notes_section.dart';
import './widgets/reading_input_section.dart';

class MeterReadingEntry extends StatefulWidget {
  const MeterReadingEntry({super.key});

  @override
  State<MeterReadingEntry> createState() => _MeterReadingEntryState();
}

class _MeterReadingEntryState extends State<MeterReadingEntry> {
  final TextEditingController _readingController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock homeowner data
  final Map<String, dynamic> _homeownerData = {
    "id": 1,
    "name": "Maria Santos",
    "address": "123 Sampaguita Street, Purok 1, Barangay San Jose",
    "accountNumber": "WM-2024-001234",
    "previousReading": 145.5,
    "lastReadingDate": "12/05/2024",
    "meterType": "Digital Water Meter",
    "connectionStatus": "Active",
  };

  double _currentReading = 0.0;
  XFile? _capturedImage;
  Position? _gpsLocation;
  bool _isReadingValid = false;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _readingController.addListener(_onReadingChanged);
    _notesController.addListener(_onNotesChanged);
    _autoSaveTimer();
  }

  @override
  void dispose() {
    _readingController.removeListener(_onReadingChanged);
    _notesController.removeListener(_onNotesChanged);
    _readingController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onReadingChanged() {
    final text = _readingController.text;
    if (text.isNotEmpty) {
      final reading = double.tryParse(text) ?? 0.0;
      setState(() {
        _currentReading = reading;
        _isReadingValid =
            reading > (_homeownerData['previousReading'] as double? ?? 0.0);
        _hasUnsavedChanges = true;
      });
    } else {
      setState(() {
        _currentReading = 0.0;
        _isReadingValid = false;
        _hasUnsavedChanges = false;
      });
    }
  }

  void _onNotesChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  void _onImageCaptured(XFile? image) {
    setState(() {
      _capturedImage = image;
      _hasUnsavedChanges = true;
    });
  }

  void _onLocationCaptured(Position? position) {
    setState(() {
      _gpsLocation = position;
      _hasUnsavedChanges = true;
    });
  }

  void _autoSaveTimer() {
    // Auto-save functionality to prevent data loss
    Future.delayed(const Duration(minutes: 2), () {
      if (_hasUnsavedChanges && mounted) {
        _saveToLocalStorage();
        _autoSaveTimer();
      }
    });
  }

  void _saveToLocalStorage() {
    // Save current state to local storage for offline capability
    final readingData = {
      'homeownerId': _homeownerData['id'],
      'currentReading': _currentReading,
      'notes': _notesController.text,
      'hasImage': _capturedImage != null,
      'hasLocation': _gpsLocation != null,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'draft',
    };

    // In a real app, this would save to SharedPreferences or local database
    debugPrint('Auto-saved reading data: $readingData');
  }

  Future<void> _saveReading() async {
    if (!_isReadingValid) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      final readingData = {
        'homeownerId': _homeownerData['id'],
        'accountNumber': _homeownerData['accountNumber'],
        'previousReading': _homeownerData['previousReading'],
        'currentReading': _currentReading,
        'consumption':
            _currentReading - (_homeownerData['previousReading'] as double),
        'notes': _notesController.text,
        'imagePath': _capturedImage?.path,
        'gpsLocation': _gpsLocation != null
            ? {
                'latitude': _gpsLocation!.latitude,
                'longitude': _gpsLocation!.longitude,
                'accuracy': _gpsLocation!.accuracy,
              }
            : null,
        'timestamp': DateTime.now().toIso8601String(),
        'readingType': 'actual',
        'status': 'completed',
      };

      // In a real app, this would send to API and save to local database
      debugPrint('Saved reading data: $readingData');

      setState(() {
        _hasUnsavedChanges = false;
      });

      Fluttertoast.showToast(
        msg: "Reading saved successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Navigate to billing receipt generation
      Navigator.pushReplacementNamed(context, '/billing-receipt-generation');
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save reading. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _saveAsEstimated() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final estimatedReading = (_homeownerData['previousReading'] as double) +
          15.0; // Average consumption

      final readingData = {
        'homeownerId': _homeownerData['id'],
        'accountNumber': _homeownerData['accountNumber'],
        'previousReading': _homeownerData['previousReading'],
        'currentReading': estimatedReading,
        'consumption': 15.0,
        'notes':
            '${_notesController.text}\nEstimated reading based on average consumption.',
        'imagePath': _capturedImage?.path,
        'gpsLocation': _gpsLocation != null
            ? {
                'latitude': _gpsLocation!.latitude,
                'longitude': _gpsLocation!.longitude,
                'accuracy': _gpsLocation!.accuracy,
              }
            : null,
        'timestamp': DateTime.now().toIso8601String(),
        'readingType': 'estimated',
        'status': 'completed',
      };

      debugPrint('Saved estimated reading: $readingData');

      setState(() {
        _hasUnsavedChanges = false;
      });

      Fluttertoast.showToast(
        msg: "Estimated reading saved successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );

      Navigator.pushReplacementNamed(context, '/billing-receipt-generation');
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save estimated reading.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _reportIssue() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report Issue',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select the type of issue:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            ...[
              'Meter damaged/broken',
              'Access denied by homeowner',
              'Meter location inaccessible',
              'Meter reading unclear',
              'Suspected meter tampering',
              'Other technical issue',
            ].map((issue) => ListTile(
                  title: Text(
                    issue,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  onTap: () => Navigator.pop(context, issue),
                  contentPadding: EdgeInsets.zero,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _isSaving = true;
      });

      try {
        await Future.delayed(const Duration(seconds: 1));

        final issueReport = {
          'homeownerId': _homeownerData['id'],
          'accountNumber': _homeownerData['accountNumber'],
          'issueType': result,
          'description': _notesController.text,
          'imagePath': _capturedImage?.path,
          'gpsLocation': _gpsLocation != null
              ? {
                  'latitude': _gpsLocation!.latitude,
                  'longitude': _gpsLocation!.longitude,
                  'accuracy': _gpsLocation!.accuracy,
                }
              : null,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'reported',
          'priority': 'medium',
        };

        debugPrint('Issue reported: $issueReport');

        setState(() {
          _hasUnsavedChanges = false;
        });

        Fluttertoast.showToast(
          msg: "Issue reported successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        );

        Navigator.pushReplacementNamed(context, '/meter-reading-list');
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Failed to report issue.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unsaved Changes',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You have unsaved changes. Do you want to save them before leaving?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Discard',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Save',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveReading();
    }

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Meter Reading Entry',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
          elevation: 2,
          leading: IconButton(
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop && mounted) {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          actions: [
            if (_hasUnsavedChanges)
              Container(
                margin: EdgeInsets.only(right: 4.w),
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'sync_problem',
                      color: AppTheme.lightTheme.colorScheme.onSecondary,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Unsaved',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 1.h),
                    HomeownerInfoCard(homeownerData: _homeownerData),
                    ReadingInputSection(
                      controller: _readingController,
                      previousReading:
                          _homeownerData['previousReading'] as double,
                      onReadingChanged: (reading) {
                        setState(() {
                          _currentReading = reading;
                        });
                      },
                    ),
                    CameraCaptureSection(
                      onImageCaptured: _onImageCaptured,
                    ),
                    GpsLocationSection(
                      onLocationCaptured: _onLocationCaptured,
                    ),
                    NotesSection(
                      controller: _notesController,
                      onNoteChanged: (note) {
                        setState(() {
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    SizedBox(height: 10.h), // Space for bottom action bar
                  ],
                ),
              ),
            ),
            ActionButtonsSection(
              onSaveReading: _saveReading,
              onSaveAsEstimated: _saveAsEstimated,
              onReportIssue: _reportIssue,
              isReadingValid: _isReadingValid,
              isSaving: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
