import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _updateConnectivityStatus(results);

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    // Consider online if any connection type is available (not none)
    _isOnline = results.any((result) => result != ConnectivityResult.none);

    // Only emit if status changed
    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);
    }
  }

  void dispose() {
    _connectivityController.close();
  }
}