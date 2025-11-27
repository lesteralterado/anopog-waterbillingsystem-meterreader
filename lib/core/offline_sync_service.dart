import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'connectivity_service.dart';
import 'database_helper.dart';
import 'meter_reading_service.dart';
import 'app_export.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final MeterReadingService _meterReadingService = MeterReadingService();

  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _syncTimer;

  Future<void> initialize() async {
    await _connectivityService.initialize();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline) {
        _startSyncTimer();
      } else {
        _stopSyncTimer();
      }
    });

    // Start sync if already online
    if (_connectivityService.isOnline) {
      _startSyncTimer();
    }
  }



  Future<void> queueReading({
    required int userId,
    required double readingValue,
    DateTime? readingDate,
    String? imagePath,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? notes,
  }) async {
    final readingData = {
      'user_id': userId,
      'reading_value': readingValue,
      'reading_date': readingDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'image_path': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    await _dbHelper.insertPendingReading(readingData);

    // Try to sync immediately if online
    if (_connectivityService.isOnline) {
      _syncPendingReadings();
    }
  }

  Future<int> getPendingReadingsCount() async {
    return await _dbHelper.getPendingReadingsCount();
  }

  Future<List<Map<String, dynamic>>> getAllPendingReadings() async {
    return await _dbHelper.getAllPendingReadings();
  }

  Future<void> retryFailedReadings() async {
    // Reset failed readings to pending status
    final failedReadings = await _dbHelper.getAllPendingReadings();
    for (final reading in failedReadings) {
      if (reading['status'] == 'failed') {
        await _dbHelper.updateReadingStatus(reading['id'], 'pending');
      }
    }

    // Try to sync if online
    if (_connectivityService.isOnline) {
      _syncPendingReadings();
    }
  }

  void _startSyncTimer() {
    _stopSyncTimer();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _syncPendingReadings();
    });
    _syncPendingReadings();
  }

  void _stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> _syncPendingReadings() async {
    if (!_connectivityService.isOnline) return;

    try {
      final pendingReadings = await _dbHelper.getPendingReadings();

      for (final reading in pendingReadings) {
        try {
          // Update status to uploading
          await _dbHelper.updateReadingStatus(reading['id'], 'uploading');

          // Prepare data for upload
          final userId = reading['user_id'] as int;
          final readingValue = parseDouble(reading['reading_value']);
          final readingDate = reading['reading_date'] != null
              ? DateTime.parse(reading['reading_date'])
              : DateTime.now();

          File? imageFile;
          if (reading['image_path'] != null) {
            final imagePath = reading['image_path'] as String;
            if (File(imagePath).existsSync()) {
              imageFile = File(imagePath);
            }
          }

          Map<String, double>? gpsLocation;
          if (reading['latitude'] != null && reading['longitude'] != null) {
            final lat = tryParseNullableDouble(reading['latitude']);
            final lng = tryParseNullableDouble(reading['longitude']);
            final acc = tryParseNullableDouble(reading['accuracy']);
            if (lat != null && lng != null) {
              gpsLocation = {
                'latitude': lat,
                'longitude': lng,
                if (acc != null) 'accuracy': acc,
              };
            }
          }

          // Upload to server
          await _meterReadingService.uploadReading(
            userId: userId,
            readingValue: readingValue,
            readingDate: readingDate,
            imageFile: imageFile,
            gpsLocation: gpsLocation,
            notes: reading['notes'] as String?,
          );

          // Delete from local database on success
          await _dbHelper.deleteReading(reading['id']);

          debugPrint('Successfully synced reading ${reading['id']}');
        } catch (e) {
          // Mark as failed and continue with next reading
          await _dbHelper.updateReadingStatus(reading['id'], 'failed');
          debugPrint('Failed to sync reading ${reading['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error during sync: $e');
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _stopSyncTimer();
    _connectivityService.dispose();
  }
}