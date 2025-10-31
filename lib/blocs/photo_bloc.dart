import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/photo_service.dart';
import '../models/photo.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'photo_event.dart';
import 'photo_state.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final PhotoService _photoService;
  List<Photo>? _originalPhotos; // Store original photos before search

  // Static reference to photos per page from constants
  static const int photosPerPage = ApiConstants.photosPerPage;

  PhotoBloc({required PhotoService photoService})
    : _photoService = photoService,
      super(const PhotoInitial()) {
    on<LoadPhotos>(_onLoadPhotos);
    on<SearchPhotos>(_onSearchPhotos);
    on<ClearSearch>(_onClearSearch);
    on<RefreshPhotos>(_onRefreshPhotos);
    on<LoadMorePhotos>(_onLoadMorePhotos);
    on<GoToPage>(_onGoToPage);
  }

  Future<void> _onLoadPhotos(LoadPhotos event, Emitter<PhotoState> emit) async {
    emit(const PhotoLoading());

    try {
      final response = await _photoService.getPhotos();

      if (response.isSuccess && response.data != null) {
        final allPhotos = response.data!;
        _originalPhotos = allPhotos; // Store original photos
        final photosPerPage = PhotoBloc.photosPerPage;
        final totalPages = (allPhotos.length / photosPerPage).ceil();
        final firstPagePhotos = allPhotos.take(photosPerPage).toList();

        emit(
          PhotoLoaded(
            photos: firstPagePhotos,
            currentPage: 1,
            totalPages: totalPages,
            hasMorePages: totalPages > 1,
          ),
        );
      } else {
        emit(PhotoError(response.error ?? 'Unable to load photos'));
      }
    } catch (e) {
      emit(PhotoError('Something went wrong'));
    }
  }

  Future<void> _onSearchPhotos(
    SearchPhotos event,
    Emitter<PhotoState> emit,
  ) async {
    if (event.keyword.isEmpty) {
      add(const ClearSearch());
      return;
    }

    emit(const PhotoLoading());

    try {
      final response = await _photoService.searchPhotos(event.keyword);

      if (response.isSuccess && response.data != null) {
        final allPhotos = response.data!;
        final photosPerPage = PhotoBloc.photosPerPage;
        final totalPages = (allPhotos.length / photosPerPage).ceil();
        final firstPagePhotos = allPhotos.take(photosPerPage).toList();

        emit(
          PhotoLoaded(
            photos: firstPagePhotos,
            searchKeyword: event.keyword,
            isSearching: true,
            currentPage: 1,
            totalPages: totalPages,
            hasMorePages: totalPages > 1,
          ),
        );
      } else {
        emit(PhotoError(response.error ?? 'Unable to search photos'));
      }
    } catch (e) {
      emit(PhotoError('Something went wrong'));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<PhotoState> emit,
  ) async {
    // Don't emit loading state - just restore original photos instantly
    if (_originalPhotos != null) {
      final allPhotos = _originalPhotos!;
      final photosPerPage = PhotoBloc.photosPerPage;
      final totalPages = (allPhotos.length / photosPerPage).ceil();
      final firstPagePhotos = allPhotos.take(photosPerPage).toList();

      emit(
        PhotoLoaded(
          photos: firstPagePhotos,
          currentPage: 1,
          totalPages: totalPages,
          hasMorePages: totalPages > 1,
        ),
      );
    } else {
      // Fallback to API call if no original photos stored
      emit(const PhotoLoading());

      try {
        final response = await _photoService.getPhotos();

        if (response.isSuccess && response.data != null) {
          final allPhotos = response.data!;
          _originalPhotos = allPhotos; // Store for future use
          final photosPerPage = PhotoBloc.photosPerPage;
          final totalPages = (allPhotos.length / photosPerPage).ceil();
          final firstPagePhotos = allPhotos.take(photosPerPage).toList();

          emit(
            PhotoLoaded(
              photos: firstPagePhotos,
              currentPage: 1,
              totalPages: totalPages,
              hasMorePages: totalPages > 1,
            ),
          );
        } else {
          emit(PhotoError(response.error ?? 'Unable to load photos'));
        }
      } catch (e) {
        emit(PhotoError('Something went wrong'));
      }
    }
  }

  Future<void> _onRefreshPhotos(
    RefreshPhotos event,
    Emitter<PhotoState> emit,
  ) async {
    emit(const PhotoLoading());

    try {
      final response = await _photoService.getPhotos();

      if (response.isSuccess && response.data != null) {
        final allPhotos = response.data!;
        _originalPhotos = allPhotos; // Store original photos
        final photosPerPage = PhotoBloc.photosPerPage;
        final totalPages = (allPhotos.length / photosPerPage).ceil();
        final firstPagePhotos = allPhotos.take(photosPerPage).toList();

        emit(
          PhotoLoaded(
            photos: firstPagePhotos,
            currentPage: 1,
            totalPages: totalPages,
            hasMorePages: totalPages > 1,
          ),
        );
      } else {
        emit(PhotoError(response.error ?? 'Unable to refresh photos'));
      }
    } catch (e) {
      emit(PhotoError('Something went wrong'));
    }
  }

  Future<void> _onLoadMorePhotos(
    LoadMorePhotos event,
    Emitter<PhotoState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PhotoLoaded ||
        currentState.isLoadingMore ||
        !currentState.hasMorePages) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final response = await _photoService.getPhotos();

      if (response.isSuccess && response.data != null) {
        final allPhotos = response.data!;
        final photosPerPage = PhotoBloc.photosPerPage;
        final nextPage = currentState.currentPage + 1;
        final startIndex = (nextPage - 1) * photosPerPage;
        final newPhotos = allPhotos
            .skip(startIndex)
            .take(photosPerPage)
            .toList();

        final updatedPhotos = [...currentState.photos, ...newPhotos];
        final totalPages = (allPhotos.length / photosPerPage).ceil();

        emit(
          PhotoLoaded(
            photos: updatedPhotos,
            searchKeyword: currentState.searchKeyword,
            isSearching: currentState.isSearching,
            currentPage: nextPage,
            totalPages: totalPages,
            hasMorePages: nextPage < totalPages,
            isLoadingMore: false,
          ),
        );
      } else {
        emit(PhotoError(response.error ?? 'Unable to load more photos'));
      }
    } catch (e) {
      emit(PhotoError('Something went wrong'));
    }
  }

  Future<void> _onGoToPage(GoToPage event, Emitter<PhotoState> emit) async {
    final currentState = state;
    if (currentState is! PhotoLoaded) return;

    try {
      ApiResponse<List<Photo>> response;

      // If we're searching, get search results, otherwise get all photos
      if (currentState.isSearching && currentState.searchKeyword != null) {
        response = await _photoService.searchPhotos(
          currentState.searchKeyword!,
        );
      } else {
        response = await _photoService.getPhotos();
      }

      if (response.isSuccess && response.data != null) {
        final allPhotos = response.data!;
        final photosPerPage = PhotoBloc.photosPerPage;
        final totalPages = (allPhotos.length / photosPerPage).ceil();

        // Validate page number
        if (event.page < 1 || event.page > totalPages) return;

        final startIndex = (event.page - 1) * photosPerPage;
        final pagePhotos = allPhotos
            .skip(startIndex)
            .take(photosPerPage)
            .toList();

        emit(
          PhotoLoaded(
            photos: pagePhotos,
            searchKeyword: currentState.searchKeyword,
            isSearching: currentState.isSearching,
            currentPage: event.page,
            totalPages: totalPages,
            hasMorePages: event.page < totalPages,
            isLoadingMore: false,
          ),
        );
      } else {
        emit(PhotoError(response.error ?? 'Unable to load page'));
      }
    } catch (e) {
      emit(PhotoError('Something went wrong'));
    }
  }
}
