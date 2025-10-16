import 'package:flutter_test/flutter_test.dart';
import 'package:pic_pulse/models/photo.dart';
import 'package:pic_pulse/services/search_service.dart';

void main() {
  group('SearchService', () {
    late List<Photo> testPhotos;

    setUp(() {
      testPhotos = [
        Photo(
          id: '1',
          url: 'https://example.com/photo1.jpg',
          description: 'Beautiful mountain landscape',
          location: 'Switzerland',
          createdBy: 'John Doe',
          createdAt: DateTime(2023, 1, 1),
          takenAt: DateTime(2022, 12, 1),
        ),
        Photo(
          id: '2',
          url: 'https://example.com/photo2.jpg',
          description: 'Ocean waves crashing',
          location: 'California',
          createdBy: 'Jane Smith',
          createdAt: DateTime(2023, 1, 2),
          takenAt: DateTime(2022, 12, 2),
        ),
        Photo(
          id: '3',
          url: 'https://example.com/photo3.jpg',
          description: 'City skyline at night',
          location: 'New York',
          createdBy: 'Bob Wilson',
          createdAt: DateTime(2023, 1, 3),
          takenAt: DateTime(2022, 12, 3),
        ),
      ];
    });

    group('searchPhotos', () {
      test('should return all photos when keyword is empty', () {
        final result = SearchService.searchPhotos(testPhotos, '');
        expect(result, equals(testPhotos));
      });

      test('should return photos matching description', () {
        final result = SearchService.searchPhotos(testPhotos, 'mountain');
        expect(result.length, equals(1));
        expect(result.first.id, equals('1'));
      });

      test('should return photos matching location', () {
        final result = SearchService.searchPhotos(testPhotos, 'California');
        expect(result.length, equals(1));
        expect(result.first.id, equals('2'));
      });

      test('should return photos matching creator', () {
        final result = SearchService.searchPhotos(testPhotos, 'Jane');
        expect(result.length, equals(1));
        expect(result.first.id, equals('2'));
      });

      test('should return empty list when no matches', () {
        final result = SearchService.searchPhotos(testPhotos, 'nonexistent');
        expect(result, isEmpty);
      });

      test('should perform exact word matching', () {
        // Add support and sport as descriptions for some photos
        final testPhotosWithPorts = [
          ...testPhotos,
          Photo(
            id: '4',
            url: 'https://example.com/photo4.jpg',
            description: 'Shoreline with strong support',
            location: 'Harbor',
            createdBy: 'Alan Port',
            createdAt: DateTime(2023, 1, 4),
            takenAt: DateTime(2022, 12, 4),
          ),
          Photo(
            id: '5',
            url: 'https://example.com/photo5.jpg',
            description: 'Kids playing sport at the port',
            location: 'Dock',
            createdBy: 'Betty Sport',
            createdAt: DateTime(2023, 1, 5),
            takenAt: DateTime(2022, 12, 5),
          ),
        ];

        final result = SearchService.searchPhotos(testPhotosWithPorts, 'port');
        // Should match 'Alan Port' and 'at the port' but not 'support' or 'sport'
        expect(result.length, equals(2));
        expect(result.any((photo) => photo.id == '4'), isTrue); // Alan Port
        expect(result.any((photo) => photo.id == '5'), isTrue); // at the port
      });

      test('should perform case-insensitive search', () {
        final result = SearchService.searchPhotos(testPhotos, 'MOUNTAIN');
        expect(result.length, equals(1));
        expect(result.first.id, equals('1'));
      });

      test('should handle special characters in search', () {
        final result = SearchService.searchPhotos(testPhotos, 'mountain!');
        expect(result, isEmpty);
      });

      test('should handle very long search terms', () {
        final longSearchTerm = 'a' * 1000;
        final result = SearchService.searchPhotos(testPhotos, longSearchTerm);
        expect(result, isEmpty);
      });

      test('should handle empty photo list', () {
        final result = SearchService.searchPhotos([], 'test');
        expect(result, isEmpty);
      });
    });

    group('sortPhotosByDate', () {
      test('should sort photos by creation date descending', () {
        final result = SearchService.sortPhotosByDate(testPhotos);
        expect(result.first.id, equals('3')); // Most recent
        expect(result.last.id, equals('1')); // Oldest
      });

      test('should handle photos with same creation date', () {
        final sameDatePhotos = [
          Photo(
            id: '1',
            url: 'https://example.com/photo1.jpg',
            description: 'Photo 1',
            location: 'Location 1',
            createdBy: 'Creator 1',
            createdAt: DateTime(2023, 1, 1),
            takenAt: DateTime(2022, 12, 1),
          ),
          Photo(
            id: '2',
            url: 'https://example.com/photo2.jpg',
            description: 'Photo 2',
            location: 'Location 2',
            createdBy: 'Creator 2',
            createdAt: DateTime(2023, 1, 1), // Same date
            takenAt: DateTime(2022, 12, 2),
          ),
        ];

        final result = SearchService.sortPhotosByDate(sameDatePhotos);
        expect(result.length, equals(2));
        // Should maintain original order for same dates
      });
    });
  });
}
