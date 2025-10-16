class ApiConstants {
  static const String baseUrl =
      'https://qchkdevhiring.blob.core.windows.net/mobile/api';
  static const String photosEndpoint = '/photos';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Pagination
  static const int photosStartingPage = 1;
  static const int photosPerPage = 20;
  static const int photosMaxLimit = 100;
}

class AppConstants {
  static const String appName = 'PicPulse';
  static const String appVersion = '1.0.0';

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
}
