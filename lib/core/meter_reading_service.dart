import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'connectivity_service.dart';
import 'offline_sync_service.dart';

class MeterReadingService {
  final Dio _dio;
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineSyncService _offlineSyncService = OfflineSyncService();

  MeterReadingService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: Config.apiBaseUrl));

  /// Uploads a meter reading to the backend.
  /// If offline, queues the reading for later sync.
  ///
  /// Required fields: userId, readingValue. Image is optional.
  /// Returns the parsed response JSON map on success, or null if queued for offline.
  Future<Map<String, dynamic>?> uploadReading({
    required int userId,
    required double readingValue,
    DateTime? readingDate,
    File? imageFile,
    Map<String, double>? gpsLocation,
    String? notes,
  }) async {
    if (userId <= 0) throw ArgumentError('Invalid userId');

    // Check if we're online
    if (!_connectivityService.isOnline) {
      // Queue for offline sync
      await _offlineSyncService.queueReading(
        userId: userId,
        readingValue: readingValue,
        readingDate: readingDate,
        imagePath: imageFile?.path,
        latitude: gpsLocation?['latitude'],
        longitude: gpsLocation?['longitude'],
        accuracy: gpsLocation?['accuracy'],
        notes: notes,
      );
      return null; // Indicate that reading was queued
    }

    final formMap = <String, dynamic>{
      'user_id': userId.toString(),
      'reading_value': readingValue.toString(),
    };

    if (readingDate != null) {
      formMap['reading_date'] = readingDate.toIso8601String();
    }

    if (notes != null) formMap['notes'] = notes;

    if (gpsLocation != null) {
      formMap['latitude'] = gpsLocation['latitude']?.toString();
      formMap['longitude'] = gpsLocation['longitude']?.toString();
      if (gpsLocation.containsKey('accuracy')) {
        formMap['accuracy'] = gpsLocation['accuracy']?.toString();
      }
    }

    if (imageFile != null) {
      final fileName = p.basename(imageFile.path);
      formMap['image'] =
          await MultipartFile.fromFile(imageFile.path, filename: fileName);
    }

    final formData = FormData.fromMap(formMap);

    try {
      final resp = await _dio.post('/api/meter-reading',
          data: formData,
          options: Options(headers: {"Content-Type": "multipart/form-data"}));

      if (resp.statusCode != null &&
          resp.statusCode! >= 200 &&
          resp.statusCode! < 300) {
        return Map<String, dynamic>.from(resp.data ?? {});
      }

      throw Exception('Server responded with status ${resp.statusCode}');
    } on DioException catch (e) {
      // If network error, queue for offline sync
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {

        await _offlineSyncService.queueReading(
          userId: userId,
          readingValue: readingValue,
          readingDate: readingDate,
          imagePath: imageFile?.path,
          latitude: gpsLocation?['latitude'],
          longitude: gpsLocation?['longitude'],
          accuracy: gpsLocation?['accuracy'],
          notes: notes,
        );
        return null; // Indicate that reading was queued
      }

      // Provide helpful error messages for other types of errors
      if (e.response != null) {
        throw Exception(
            'Upload failed: ${e.response?.statusCode} ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
