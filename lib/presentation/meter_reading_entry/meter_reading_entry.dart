import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';

import '../../core/app_export.dart';
import './widgets/action_buttons_section.dart';
import './widgets/camera_capture_section.dart';
import './widgets/gps_location_section.dart';
import './widgets/homeowner_info_card.dart';
import './widgets/notes_section.dart';
import './widgets/reading_input_section.dart';
import '../../core/meter_reading_service.dart';
import '../../core/connectivity_service.dart';
import '../../core/offline_sync_service.dart';

class MeterReadingEntry extends StatefulWidget {
  const MeterReadingEntry({super.key});

  @override
  State<MeterReadingEntry> createState() => _MeterReadingEntryState();
}

class _MeterReadingEntryState extends State<MeterReadingEntry> {
  final TextEditingController _readingController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineSyncService _offlineSyncService = OfflineSyncService();

  // Homeowner data - can be passed from route arguments or use mock data
  Map<String, dynamic> _homeownerData = {
    "id": 1,
    "name": "Loading...",
    "address": "Loading...",
    "accountNumber": "Loading...",
    "previousReading": 0.0,
    "lastReadingDate": "Loading...",
    "meterType": "Digital Water Meter",
    "connectionStatus": "Active",
  };

  bool _dataLoaded = false;

  double _currentReading = 0.0;
  XFile? _capturedImage;
  Position? _gpsLocation;
  bool _isReadingValid = false;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _isOnline = true;
  int _pendingReadingsCount = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('MeterReadingEntry initState called');

    // Initialize homeowner data from route arguments or use mock data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      debugPrint('ModalRoute: $route');
      debugPrint('Route settings: ${route?.settings}');
      debugPrint('Route arguments: ${route?.settings.arguments}');

      final args = route?.settings.arguments as Map<String, dynamic>?;
      debugPrint('MeterReadingEntry received args: $args');

      if (args != null && args.isNotEmpty) {
        // Use passed homeowner data
        _homeownerData = Map<String, dynamic>.from(args);
        debugPrint('Using passed homeowner data: $_homeownerData');
        debugPrint('Homeowner name: ${_homeownerData['name']}');
        debugPrint('Homeowner address: ${_homeownerData['address']}');
      } else {
        // Fallback to mock data
        _homeownerData = {
          "id": 1,
          "name": "Maria Santos",
          "address": "123 Sampaguita Street, Purok 1, Barangay San Jose",
          "accountNumber": "WM-2024-001234",
          "previousReading": 145.5,
          "lastReadingDate": "12/05/2024",
          "meterType": "Digital Water Meter",
          "connectionStatus": "Active",
        };
        debugPrint('Using mock homeowner data (no args provided)');
      }

      // Mark data as loaded and trigger UI update
      _dataLoaded = true;
      if (mounted) {
        setState(() {});
      }
    });

    _readingController.addListener(_onReadingChanged);
    _notesController.addListener(_onNotesChanged);
    _initializeServices();
    _autoSaveTimer();
  }

  Future<void> _initializeServices() async {
    await _connectivityService.initialize();
    await _offlineSyncService.initialize();

    // Listen for connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
        _updatePendingReadingsCount();
      }
    });

    // Initial state
    setState(() {
      _isOnline = _connectivityService.isOnline;
    });
    _updatePendingReadingsCount();
  }

  Future<void> _updatePendingReadingsCount() async {
    final count = await _offlineSyncService.getPendingReadingsCount();
    if (mounted) {
      setState(() {
        _pendingReadingsCount = count;
      });
    }
  }

  @override
  void dispose() {
    _readingController.removeListener(_onReadingChanged);
    _notesController.removeListener(_onNotesChanged);
    _readingController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    _offlineSyncService.dispose();
    // Ensure camera is cleaned up (in case it was initialized)
    debugPrint('MeterReadingEntry disposed');
    super.dispose();
  }

  void _onReadingChanged() {
    final text = _readingController.text;
    if (text.isNotEmpty) {
      final reading = double.tryParse(text) ?? 0.0;
      setState(() {
        _currentReading = reading;
        _isReadingValid =
            reading > (_homeownerData['currentReading'] as double? ?? 0.0);
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
      // Validate required fields locally before sending
      final userId = _homeownerData['id'] as int?;
      if (userId == null || userId <= 0)
        throw Exception('Invalid homeowner id');

      // prepare optional image file
      File? imageFile;
      if (_capturedImage != null) {
        imageFile = File(_capturedImage!.path);
      }

      final gps = _gpsLocation != null
          ? {
              'latitude': _gpsLocation!.latitude,
              'longitude': _gpsLocation!.longitude,
              'accuracy': _gpsLocation!.accuracy,
            }
          : null;

      // If offline, queue the reading and return early
      if (!_isOnline || !_connectivityService.isOnline) {
        await _offlineSyncService.queueReading(
          userId: userId,
          readingValue: _currentReading,
          readingDate: DateTime.now(),
          imagePath: imageFile?.path,
          latitude: gps?['latitude'],
          longitude: gps?['longitude'],
          accuracy: gps?['accuracy'],
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        setState(() {
          _hasUnsavedChanges = false;
        });
        await _updatePendingReadingsCount();

        Fluttertoast.showToast(
          msg: "Reading saved offline. Will sync when online.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );

        // Return to previous screen with result so the homeowner card can be updated
        Navigator.pop(context, {
          'homeownerId': userId,
          'status': 'pending',
          'currentReading': _currentReading,
          'queued': true,
        });
        return;
      }
      // Call service to upload
      final service = MeterReadingService();
      try {
        final result = await service.uploadReading(
          userId: userId,
          readingValue: _currentReading,
          readingDate: DateTime.now(),
          imageFile: imageFile,
          gpsLocation: gps,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        debugPrint('Upload result: $result');

        setState(() {
          _hasUnsavedChanges = false;
        });

        // Update pending readings count
        await _updatePendingReadingsCount();

        // Reading uploaded successfully
        Fluttertoast.showToast(
          msg: "Reading uploaded successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Return to previous screen with result so the homeowner card can be updated
        Navigator.pop(context, {
          'homeownerId': userId,
          'status': 'completed',
          'currentReading': _currentReading,
          'receipt': result,
        });
        return;
      } catch (e) {
        // On network error, queue the reading for later sync
        debugPrint('Upload failed, queuing offline: $e');
        await _offlineSyncService.queueReading(
          userId: userId,
          readingValue: _currentReading,
          readingDate: DateTime.now(),
          imagePath: imageFile?.path,
          latitude: gps?['latitude'],
          longitude: gps?['longitude'],
          accuracy: gps?['accuracy'],
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        setState(() {
          _hasUnsavedChanges = false;
        });

        await _updatePendingReadingsCount();

        Fluttertoast.showToast(
          msg: "Reading saved offline due to network error.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );

        // Return to previous screen with result so the homeowner card can be updated
        Navigator.pop(context, {
          'homeownerId': userId,
          'status': 'pending',
          'currentReading': _currentReading,
          'queued': true,
        });
        return;
      }
    } catch (e) {
      // Outer catch for any validation/general errors
      Fluttertoast.showToast(
        msg: "Failed to save reading: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // Return to previous screen with error indication
      Navigator.pop(context, {
        'homeownerId': _homeownerData['id'] as int? ?? -1,
        'status': 'error',
        'currentReading': _currentReading,
      });
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

      final estimatedReading = parseDouble(_homeownerData['previousReading']) +
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
        resizeToAvoidBottomInset: true,
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
            // Connectivity status
            Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
              decoration: BoxDecoration(
                color: _isOnline
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: _isOnline ? 'wifi' : 'wifi_off',
                    color: _isOnline
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.error,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _isOnline
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Pending readings count
            if (_pendingReadingsCount > 0)
              Container(
                margin: EdgeInsets.only(right: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: AppTheme.lightTheme.colorScheme.onSecondary,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '$_pendingReadingsCount',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            // Unsaved changes indicator
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
        body: _dataLoaded
            ? Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 1.h),
                          HomeownerInfoCard(homeownerData: _homeownerData),
                          ReadingInputSection(
                            controller: _readingController,
                            previousReading:
                                parseDouble(_homeownerData['previousReading']),
                            currentReading:
                                parseDouble(_homeownerData['currentReading']),
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
                          SizedBox(height: 2.h),
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
              )
            : Center(
                child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
      ),
    );
  }
}
