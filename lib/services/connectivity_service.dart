import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // Check if connected to any network
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // For mobile, wifi, ethernet, we assume internet is available
      // For more precise checking, you could ping a server
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // If connectivity check fails, assume no internet
      return false;
    }
  }

  /// Get current connectivity status
  static Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Listen to connectivity changes
  static Stream<ConnectivityResult> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }
}
