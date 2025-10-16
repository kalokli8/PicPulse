import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pic_pulse/blocs/photo_bloc.dart';
import 'package:pic_pulse/blocs/photo_state.dart';
import 'package:pic_pulse/models/photo.dart';
import 'package:pic_pulse/models/api_response.dart';
import 'package:pic_pulse/screens/photo_list_screen.dart';
import 'package:pic_pulse/services/photo_service.dart';

import 'photo_list_screen_test.mocks.dart';

@GenerateMocks([PhotoService])
void main() {
  group('PhotoListScreen', () {
    late MockPhotoService mockPhotoService;

    setUp(() {
      mockPhotoService = MockPhotoService();
    });

    Widget createTestWidget(PhotoState initialState) {
      return MaterialApp(
        home: BlocProvider<PhotoBloc>(
          create: (context) =>
              PhotoBloc(photoService: mockPhotoService)..emit(initialState),
          child: const PhotoListScreen(),
        ),
      );
    }

    group('Loading State', () {
      testWidgets('should show loading indicator when in loading state', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(const PhotoLoading()));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets(
        'should show error message and retry button when in error state',
        (tester) async {
          await tester.pumpWidget(
            createTestWidget(const PhotoError('Network error')),
          );

          expect(find.text('Network error'), findsOneWidget);
          expect(find.text('Retry'), findsOneWidget);
          expect(find.byIcon(Icons.error_outline), findsOneWidget);
        },
      );

      testWidgets('should call RefreshPhotos when retry button is tapped', (
        tester,
      ) async {
        when(
          mockPhotoService.getPhotos(),
        ).thenAnswer((_) async => ApiResponse.success([]));

        await tester.pumpWidget(
          createTestWidget(const PhotoError('Network error')),
        );
        await tester.tap(find.text('Retry'));
        await tester.pump();

        verify(mockPhotoService.getPhotos()).called(1);
      });
    });

    group('Loaded State', () {
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

      testWidgets('should display photos in grid when loaded', (tester) async {
        await tester.pumpWidget(
          createTestWidget(PhotoLoaded(photos: testPhotos)),
        );

        expect(find.byType(GridView), findsOneWidget);
        expect(find.text('Test Location 1'), findsOneWidget);
        expect(find.text('Test Location 2'), findsOneWidget);
        expect(find.text('by Test Creator 1'), findsOneWidget);
        expect(find.text('by Test Creator 2'), findsOneWidget);
      });

      testWidgets('should show empty state when no photos', (tester) async {
        await tester.pumpWidget(
          createTestWidget(const PhotoLoaded(photos: [])),
        );

        expect(find.text('No photos available'), findsOneWidget);
        expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      });

      testWidgets(
        'should show search empty state when searching with no results',
        (tester) async {
          await tester.pumpWidget(
            createTestWidget(
              const PhotoLoaded(
                photos: [],
                searchKeyword: 'nonexistent',
                isSearching: true,
              ),
            ),
          );

          expect(
            find.text('No photos found for "nonexistent"'),
            findsOneWidget,
          );
          expect(find.text('Clear Search'), findsOneWidget);
          expect(find.byIcon(Icons.search_off), findsOneWidget);
        },
      );
    });

    group('Search Functionality', () {
      testWidgets('should have search bar with correct hint text', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(const PhotoInitial()));

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search photos by keyword...'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('should show clear button when text is entered', (
        tester,
      ) async {
        await tester.pumpWidget(createTestWidget(const PhotoInitial()));

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump();

        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('should clear search when clear button is tapped', (
        tester,
      ) async {
        when(
          mockPhotoService.getPhotos(),
        ).thenAnswer((_) async => ApiResponse.success([]));

        await tester.pumpWidget(createTestWidget(const PhotoInitial()));

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump();
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        expect(find.text(''), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should navigate to detail screen when photo is tapped', (
        tester,
      ) async {
        final testPhoto = Photo(
          id: '1',
          url: 'https://example.com/photo1.jpg',
          description: 'Test photo',
          location: 'Test Location',
          createdBy: 'Test Creator',
          createdAt: DateTime(2023, 1, 1),
          takenAt: DateTime(2022, 12, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<PhotoBloc>(
              create: (context) =>
                  PhotoBloc(photoService: mockPhotoService)
                    ..emit(PhotoLoaded(photos: [testPhoto])),
              child: const PhotoListScreen(),
            ),
            routes: {
              '/detail': (context) =>
                  const Scaffold(body: Text('Detail Screen')),
            },
          ),
        );

        await tester.tap(find.text('Test Location'));
        await tester.pumpAndSettle();

        expect(find.text('Detail Screen'), findsOneWidget);
      });
    });
  });
}
