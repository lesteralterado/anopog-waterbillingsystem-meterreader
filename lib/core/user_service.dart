import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'config.dart';
import 'connectivity_service.dart';

class UserService {
  final Dio _dio;
  final ConnectivityService _connectivityService = ConnectivityService();

  UserService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: Config.apiBaseUrl));

  /// Authenticates a user via the login API.
  /// Returns the user data if successful, null otherwise.
  Future<Map<String, dynamic>?> login(String username, String password) async {
    if (!_connectivityService.isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _dio.post(
        '/api/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = Map<String, dynamic>.from(response.data);
        final user = Map<String, dynamic>.from(responseData['user']);
        // Debug: Print user data to understand API response structure
        debugPrint('Login API Response: $responseData');
        debugPrint('User object: $user');
        debugPrint('Role object: ${user['role']}');
        debugPrint('Role ID: ${user['role_id']}');

        // Check if role is Meter-Reader (check both role.name and role_id)
        final roleName = user['role']?['name'];
        final roleId = user['role_id'];
        debugPrint('Extracted roleName: $roleName, roleId: $roleId');

        if ((roleName == 'Meter-Reader' || roleName == 'Meter Reader') ||
            (roleId == 'Meter-Reader' || roleId == 'Meter Reader' || roleId == 2)) {
          return user;
        } else {
          debugPrint('Role check failed. Expected Meter-Reader or Meter Reader, got roleName: $roleName, roleId: $roleId');
          throw Exception('Access denied. Only Meter Readers can log in.');
        }
      } else {
        throw Exception('Invalid credentials');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Login failed: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Fetches all users from the API.
  /// Returns a list of user maps.
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    if (!_connectivityService.isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _dio.get('/api/users');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch users');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Fetch users failed: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Fetches and filters consumers (users with role "Consumers").
  Future<List<Map<String, dynamic>>> fetchConsumers() async {
    final users = await fetchUsers();
    return users.where((user) {
      final role = user['role'];
      return role != null && role['name'] == 'Consumers';
    }).toList();
  }

  /// Fetches consumers grouped by purok from the new API endpoint.
  Future<List<Map<String, dynamic>>> fetchConsumersByPurok() async {
    if (!_connectivityService.isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _dio.get('/api/consumers-by-purok');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch consumers by purok');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Fetch consumers by purok failed: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Fetches billing data from the backend API.
  Future<Map<String, dynamic>> fetchBillingData() async {
    if (!_connectivityService.isOnline) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _dio.get('/api/billing');

      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception('Failed to fetch billing data');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Fetch billing data failed: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}