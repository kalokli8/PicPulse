import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pic_pulse/blocs/photo_bloc.dart';
import 'package:pic_pulse/blocs/photo_event.dart';
import 'package:pic_pulse/blocs/photo_state.dart';
import 'package:pic_pulse/models/photo.dart';
import 'package:pic_pulse/models/api_response.dart';
import 'package:pic_pulse/services/photo_service.dart';

import 'photo_bloc_test.mocks.dart';

@GenerateMocks([PhotoService])
void main() {
  group('PhotoBloc', () {
    late PhotoBloc photoBloc;
    late MockPhotoService mockPhotoService;

    setUp(() {
      mockPhotoService = MockPhotoService();
      photoBloc = PhotoBloc(photoService: mockPhotoService);
    });

    tearDown(() {
      photoBloc.close();
    });

    group('LoadPhotos', () {
      final testPhotos = [
        Photo(
          id: '1',
          url: 'https://example.com/photo1.jpg',
          description: 'Test photo 1',
          location: 'Test Location 1',
          createdBy: 'Test Creator 1',
          createdAt: DateTime(2023, 1, 1),
          takenAt: DateTime(2022, 12, 1),
        ),
        Photo(
          id: '2',
          url: 'https://example.com/photo2.jpg',
          description: 'Test photo 2',
          location: 'Test Location 2',
          createdBy: 'Test Creator 2',
          createdAt: DateTime(2023, 1, 2),
          takenAt: DateTime(2022, 12, 2),
        ),
      ];

      blocTest<PhotoBloc, PhotoState>(
        'emits [PhotoLoading, PhotoLoaded] when LoadPhotos is added successfully',
        build: () {
          when(
            mockPhotoService.getPhotos(),
          ).thenAnswer((_) async => ApiResponse.success(testPhotos));
          return photoBloc;
        },
        act: (bloc) => bloc.add(const LoadPhotos()),
        expect: () => [
          const PhotoLoading(),
          PhotoLoaded(
            photos: testPhotos.take(20).toList(),
            currentPage: 1,
            totalPages: 1,
            hasMorePages: false,
          ),
        ],
      );

      blocTest<PhotoBloc, PhotoState>(
        'emits [PhotoLoading, PhotoError] when LoadPhotos fails',
        build: () {
          when(
            mockPhotoService.getPhotos(),
          ).thenAnswer((_) async => ApiResponse.error('Network error'));
          return photoBloc;
        },
        act: (bloc) => bloc.add(const LoadPhotos()),
        expect: () => [const PhotoLoading(), const PhotoError('Network error')],
      );
    });

    group('SearchPhotos', () {
      final testPhotos = [
        Photo(
          id: '1',
          url: 'https://example.com/photo1.jpg',
          description: 'Mountain landscape',
          location: 'Switzerland',
          createdBy: 'John Doe',
          createdAt: DateTime(2023, 1, 1),
          takenAt: DateTime(2022, 12, 1),
        ),
        Photo(
          id: '2',
          url: 'https://example.com/photo2.jpg',
          description: 'Ocean waves',
          location: 'California',
          createdBy: 'Jane Smith',
          createdAt: DateTime(2023, 1, 2),
          takenAt: DateTime(2022, 12, 2),
        ),
      ];

      blocTest<PhotoBloc, PhotoState>(
        'emits [PhotoLoading, PhotoLoaded] when SearchPhotos is added successfully',
        build: () {
          when(
            mockPhotoService.searchPhotos('mountain'),
          ).thenAnswer((_) async => ApiResponse.success([testPhotos[0]]));
          return photoBloc;
        },
        act: (bloc) => bloc.add(const SearchPhotos('mountain')),
        expect: () => [
          const PhotoLoading(),
          PhotoLoaded(
            photos: [testPhotos[0]],
            searchKeyword: 'mountain',
            isSearching: true,
            currentPage: 1,
            totalPages: 1,
            hasMorePages: false,
          ),
        ],
      );

      blocTest<PhotoBloc, PhotoState>(
        'calls ClearSearch when keyword is empty',
        build: () {
          when(
            mockPhotoService.getPhotos(),
          ).thenAnswer((_) async => ApiResponse.success(testPhotos));
          return photoBloc;
        },
        act: (bloc) => bloc.add(const SearchPhotos('')),
        expect: () => [
          const PhotoLoading(),
          PhotoLoaded(
            photos: testPhotos.take(20).toList(),
            currentPage: 1,
            totalPages: 1,
            hasMorePages: false,
          ),
        ],
      );
    });

    group('ClearSearch', () {
      final testPhotos = [
        Photo(
          id: '1',
          url: 'https://example.com/photo1.jpg',
          description: 'Test photo',
          location: 'Test Location',
          createdBy: 'Test Creator',
          createdAt: DateTime(2023, 1, 1),
          takenAt: DateTime(2022, 12, 1),
        ),
      ];

      blocTest<PhotoBloc, PhotoState>(
        'emits [PhotoLoading, PhotoLoaded] when ClearSearch is added',
        build: () {
          when(
            mockPhotoService.getPhotos(),
          ).thenAnswer((_) async => ApiResponse.success(testPhotos));
          return photoBloc;
        },
        act: (bloc) => bloc.add(const ClearSearch()),
        expect: () => [
          const PhotoLoading(),
          PhotoLoaded(
            photos: testPhotos.take(20).toList(),
            currentPage: 1,
            totalPages: 1,
            hasMorePages: false,
          ),
        ],
      );
    });

    group('RefreshPhotos', () {
      final testPhotos = [
        Photo(
          id: '1',
          url: 'https://example.com/photo1.jpg',
          description: 'Test photo',
          location: 'Test Location',
          createdBy: 'Test Creator',
          createdAt: DateTime(2023, 1, 1),
          takenAt: DateTime(2022, 12, 1),
        ),
      ];

      blocTest<PhotoBloc, PhotoState>(
        'emits [PhotoLoading, PhotoLoaded] when RefreshPhotos is added',
        build: () {
          when(
            mockPhotoService.getPhotos(),
          ).thenAnswer((_) async => ApiResponse.success(testPhotos));
          return photoBloc;
        },
        act: (bloc) => bloc.add(const RefreshPhotos()),
        expect: () => [
          const PhotoLoading(),
          PhotoLoaded(
            photos: testPhotos.take(20).toList(),
            currentPage: 1,
            totalPages: 1,
            hasMorePages: false,
          ),
        ],
      );
    });
  });
}
