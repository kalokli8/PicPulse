import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/photo.dart';
import '../utils/constants.dart';
import 'search_service.dart';
import 'photo_cache_service.dart';
import 'connectivity_service.dart';

class PhotoService {
  late final Dio _dio;
  List<Photo>? _cachedPhotos;

  PhotoService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  /// Get all photos from the API with offline-first approach
  Future<ApiResponse<List<Photo>>> getPhotos() async {
    try {
      // Check internet connectivity first
      final hasInternet = await ConnectivityService.hasInternetConnection();

      if (!hasInternet) {
        // No internet - try to get cached photos (even if expired)
        if (PhotoCacheService.hasCachedPhotos()) {
          final cachedPhotos = PhotoCacheService.getCachedPhotos();
          _cachedPhotos = cachedPhotos;
          return ApiResponse.success(
            cachedPhotos,
            statusCode: 200, // Use 200 to indicate cached data
          );
        } else {
          return ApiResponse.error(
            'No internet connection',
            statusCode: 0, // Custom code for no internet
          );
        }
      }

      // Has internet - check if we should use cached data or fetch fresh
      if (PhotoCacheService.shouldUseCachedPhotos()) {
        // Cache is valid, use cached data for better performance
        final cachedPhotos = PhotoCacheService.getCachedPhotos();
        _cachedPhotos = cachedPhotos;
        return ApiResponse.success(
          cachedPhotos,
          statusCode: 200, // Use 200 to indicate cached data
        );
      }

      // Cache is invalid or doesn't exist - fetch from API
      final response = await _dio.get(ApiConstants.photosEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final photos = data.map((json) => Photo.fromJson(json)).toList();

        // Cache photos locally for offline access
        await PhotoCacheService.cachePhotos(photos);

        // Cache photos and sort by creation date
        _cachedPhotos = SearchService.sortPhotosByDate(photos);

        return ApiResponse.success(
          _cachedPhotos!,
          statusCode: response.statusCode,
        );
      } else {
        // API error - always return error, don't mask with cache
        return ApiResponse.error(
          'Server error',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Network error - use cache as fallback (even if stale for offline scenarios)
      if (PhotoCacheService.hasCachedPhotos()) {
        final cachedPhotos = PhotoCacheService.getCachedPhotos();
        _cachedPhotos = cachedPhotos;
        return ApiResponse.success(
          cachedPhotos,
          statusCode: 200, // Use 200 to indicate cached data
        );
      }

      return _handleDioError(e);
    } catch (e) {
      // Unexpected error - always return error, don't mask with cache
      return ApiResponse.error('Something went wrong');
    }
  }

  /// Search photos by keyword (uses cached data if available)
  Future<ApiResponse<List<Photo>>> searchPhotos(String keyword) async {
    // First, try to search in cached photos
    if (_cachedPhotos != null) {
      final filteredPhotos = SearchService.searchPhotos(
        _cachedPhotos!,
        keyword,
      );
      return ApiResponse.success(filteredPhotos);
    }

    // If no cached photos in memory, try to get from Hive cache
    if (PhotoCacheService.hasCachedPhotos()) {
      final cachedPhotos = PhotoCacheService.searchCachedPhotos(keyword);
      return ApiResponse.success(cachedPhotos);
    }

    // Otherwise, fetch all photos first, then search
    final response = await getPhotos();
    if (response.isSuccess && response.data != null) {
      final filteredPhotos = SearchService.searchPhotos(
        response.data!,
        keyword,
      );
      return ApiResponse.success(filteredPhotos);
    }

    return response;
  }

  /// Handle Dio errors and convert to ApiResponse
  ApiResponse<T> _handleDioError<T>(DioException error) {
    String errorMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Response timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage = 'Server error';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Connection error';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Network error';
        break;
    }

    return ApiResponse.error(
      errorMessage,
      statusCode: error.response?.statusCode,
    );
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
