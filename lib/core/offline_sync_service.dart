import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

import 'connectivity_service.dart';
import 'database_helper.dart';
import 'meter_reading_service.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  StreamSubscription<bool>? _connectivitySubscription;
  SendPort? _isolateSendPort;
  Isolate? _isolate;

  Future<void> initialize() async {
    await _connectivityService.initialize();

    // Spawn the background isolate
    ReceivePort receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    _isolateSendPort = await receivePort.first as SendPort;

    // Listen for connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen((isOnline) {
      _isolateSendPort?.send(isOnline ? 'online' : 'offline');
    });

    // Send initial state
    if (_connectivityService.isOnline) {
      _isolateSendPort?.send('online');
    }
  }


  static Future<void> _syncPendingReadings(DatabaseHelper dbHelper, MeterReadingService meterReadingService, bool isOnline) async {
    if (!isOnline) return;

    try {
      final pendingReadings = await dbHelper.getPendingReadings();

      for (final reading in pendingReadings) {
        try {
          // Update status to uploading
          await dbHelper.updateReadingStatus(reading['id'], 'uploading');

          // Prepare data for upload
          final userId = reading['user_id'] as int;
          final readingValue = reading['reading_value'] as double;
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
            gpsLocation = {
              'latitude': reading['latitude'] as double,
              'longitude': reading['longitude'] as double,
              if (reading['accuracy'] != null) 'accuracy': reading['accuracy'] as double,
            };
          }

          // Upload to server
          await meterReadingService.uploadReading(
            userId: userId,
            readingValue: readingValue,
            readingDate: readingDate,
            imageFile: imageFile,
            gpsLocation: gpsLocation,
            notes: reading['notes'] as String?,
          );

          // Delete from local database on success
          await dbHelper.deleteReading(reading['id']);

          debugPrint('Successfully synced reading ${reading['id']}');
        } catch (e) {
          // Mark as failed and continue with next reading
          await dbHelper.updateReadingStatus(reading['id'], 'failed');
          debugPrint('Failed to sync reading ${reading['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error during sync: $e');
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
      _isolateSendPort?.send('sync_now');
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
      _isolateSendPort?.send('sync_now');
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _isolateSendPort?.send('dispose');
    _isolate?.kill();
    _connectivityService.dispose();
  }

  static void _isolateEntry(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final dbHelper = DatabaseHelper.instance;
    final meterReadingService = MeterReadingService();

    Timer? syncTimer;
    bool isOnline = false;

    void startSyncTimer() {
      syncTimer?.cancel();
      syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _syncPendingReadings(dbHelper, meterReadingService, isOnline);
      });
      _syncPendingReadings(dbHelper, meterReadingService, isOnline);
    }

    void stopSyncTimer() {
      syncTimer?.cancel();
      syncTimer = null;
    }

    receivePort.listen((message) {
      if (message == 'online') {
        isOnline = true;
        startSyncTimer();
      } else if (message == 'offline') {
        isOnline = false;
        stopSyncTimer();
      } else if (message == 'sync_now') {
        if (isOnline) {
          _syncPendingReadings(dbHelper, meterReadingService, isOnline);
        }
      } else if (message == 'dispose') {
        stopSyncTimer();
        receivePort.close();
      }
    });
  }
}