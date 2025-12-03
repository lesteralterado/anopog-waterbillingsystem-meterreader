import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'connectivity_service.dart';

class MeterReadingService {
  final Dio _dio;
  final ConnectivityService _connectivityService = ConnectivityService();

  MeterReadingService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: Config.apiBaseUrl));

  /// Fetches the latest two meter readings for a user.
  /// Returns a map with 'present' (most recent) and 'previous' (one before that) readings.
  Future<Map<String, dynamic>?> fetchLatestReadings(int userId) async {
    if (userId <= 0) throw ArgumentError('Invalid userId');

    try {
      final resp = await _dio.get('/api/readings/latest/$userId');

      if (resp.statusCode != null &&
          resp.statusCode! >= 200 &&
          resp.statusCode! < 300) {
        return Map<String, dynamic>.from(resp.data ?? {});
      }

      throw Exception('Server responded with status ${resp.statusCode}');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Fetch failed: ${e.response?.statusCode} ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

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

    // If offline, signal caller so it can queue the reading locally.
    if (!_connectivityService.isOnline) {
      throw StateError('offline');
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
      // Rethrow and let callers decide whether to queue locally.
      if (e.response != null) {
        throw Exception(
            'Upload failed: ${e.response?.statusCode} ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
