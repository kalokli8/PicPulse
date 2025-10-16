import 'package:hive_flutter/hive_flutter.dart';
import '../models/photo.dart';
import '../models/photo_adapter.dart';
import '../services/search_service.dart';

class PhotoCacheService {
  static const String _photosBoxName = 'photos_cache';
  static const String _lastFetchBoxName = 'last_fetch';
  static const String _cacheVersionBoxName = 'cache_version';

  static Box<Photo>? _photosBox;
  static Box<String>? _lastFetchBox;
  static Box<int>? _cacheVersionBox;

  static const int currentCacheVersion = 1;
  static const Duration cacheExpiration = Duration(hours: 24);

  /// Initialize Hive boxes
  static Future<void> init() async {
    // Register adapters
    Hive.registerAdapter(PhotoAdapter());

    // Open boxes
    _photosBox = await Hive.openBox<Photo>(_photosBoxName);
    _lastFetchBox = await Hive.openBox<String>(_lastFetchBoxName);
    _cacheVersionBox = await Hive.openBox<int>(_cacheVersionBoxName);

    // Check cache version and clear if outdated
    await _checkCacheVersion();
  }

  /// Check if cache is valid and not expired
  static bool isCacheValid() {
    if (_lastFetchBox == null) return false;

    final lastFetchStr = _lastFetchBox!.get('last_fetch');
    if (lastFetchStr == null) return false;

    final lastFetch = DateTime.parse(lastFetchStr);
    final now = DateTime.now();

    return now.difference(lastFetch) < cacheExpiration;
  }

  /// Check if we have cached photos
  static bool hasCachedPhotos() {
    return _photosBox?.isNotEmpty ?? false;
  }

  /// Check if we should use cached photos (has photos and cache is valid)
  static bool shouldUseCachedPhotos() {
    return hasCachedPhotos() && isCacheValid();
  }

  /// Get all cached photos
  static List<Photo> getCachedPhotos() {
    if (_photosBox == null) return [];

    final photos = _photosBox!.values.toList();
    return SearchService.sortPhotosByDate(photos);
  }

  /// Cache photos locally
  static Future<void> cachePhotos(List<Photo> photos) async {
    if (_photosBox == null) return;

    // Clear existing cache
    await _photosBox!.clear();

    // Store new photos
    for (final photo in photos) {
      await _photosBox!.put(photo.id, photo);
    }

    // Update last fetch time
    await _lastFetchBox!.put('last_fetch', DateTime.now().toIso8601String());
  }

  /// Get cached photos with search
  static List<Photo> searchCachedPhotos(String keyword) {
    final allPhotos = getCachedPhotos();
    return SearchService.searchPhotos(allPhotos, keyword);
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    await _photosBox?.clear();
    await _lastFetchBox?.clear();
    await _cacheVersionBox?.clear();
  }

  /// Check cache version and clear if outdated
  static Future<void> _checkCacheVersion() async {
    if (_cacheVersionBox == null) return;

    final storedVersion =
        _cacheVersionBox!.get('version', defaultValue: 0) ?? 0;

    if (storedVersion < currentCacheVersion) {
      // Clear cache if version is outdated
      await _photosBox?.clear();
      await _lastFetchBox?.clear();
      // Update version first, then clear version box to avoid issues
      await _cacheVersionBox!.put('version', currentCacheVersion);
    }
  }
}
