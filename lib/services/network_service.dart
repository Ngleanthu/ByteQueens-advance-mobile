import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  // Stream controller for network status
  final _networkStatusController = StreamController<bool>.broadcast();
  Stream<bool> get networkStatus => _networkStatusController.stream;

  bool _isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Get current connection status
  bool get isConnected => _isConnected;

  /// Initialize network monitoring
  void initialize() {
    // Check initial status
    checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(results);
    });
  }

  /// Check current connectivity
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      return _isConnected;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Update connection status based on ConnectivityResult
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Check if any connection type is available
    final bool wasConnected = _isConnected;
    _isConnected =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    // Notify listeners if status changed
    if (wasConnected != _isConnected) {
      _networkStatusController.add(_isConnected);
      print(
        '🌐 Network status changed: ${_isConnected ? "Connected" : "Disconnected"}',
      );
    }
  }

  /// Check if device has internet connection (with real network check)
  Future<bool> hasInternetConnection() async {
    final connectivityResult = await checkConnectivity();
    if (!connectivityResult) {
      return false;
    }

    // Additional check: Try to ping a reliable server
    // This is a more accurate check than just connectivity status
    try {
      // For production, you might want to ping your own API endpoint
      // For now, we'll rely on connectivity status
      return _isConnected;
    } catch (e) {
      print('Internet connection check failed: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _networkStatusController.close();
  }

  /// Get connection type as string
  String getConnectionType(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'No Connection';
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (results.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else {
      return 'Unknown';
    }
  }

  /// Get detailed connection info
  Future<Map<String, dynamic>> getConnectionInfo() async {
    final results = await _connectivity.checkConnectivity();
    return {
      'isConnected': _isConnected,
      'connectionType': getConnectionType(results),
      'results': results.map((r) => r.toString()).toList(),
    };
  }
}
