import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pic_pulse/models/photo.dart';
import 'package:pic_pulse/screens/photo_detail_screen.dart';

void main() {
  group('PhotoDetailScreen', () {
    late Photo testPhoto;

    setUp(() {
      testPhoto = Photo(
        id: '1',
        url: 'https://example.com/photo1.jpg',
        description: 'Beautiful mountain landscape with snow-capped peaks',
        location: 'Swiss Alps, Switzerland',
        createdBy: 'John Doe',
        createdAt: DateTime(2023, 1, 15, 10, 30),
        takenAt: DateTime(2022, 12, 25, 14, 45),
      );
    });

    Widget createTestWidget() {
      return MaterialApp(home: PhotoDetailScreen(photo: testPhoto));
    }

    testWidgets('should display photo with correct aspect ratio', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AspectRatio), findsOneWidget);
      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, equals(16 / 9));
    });

    testWidgets('should display photo location with location icon', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Swiss Alps, Switzerland'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('should display creator with person icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Created by John Doe'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display description section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Description'), findsOneWidget);
      expect(
        find.text('Beautiful mountain landscape with snow-capped peaks'),
        findsOneWidget,
      );
    });

    testWidgets('should display photo information card', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Photo Information'), findsOneWidget);
      expect(find.text('Taken at'), findsOneWidget);
      expect(find.text('Created at'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should format dates correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for formatted date strings
      expect(find.textContaining('25/12/2022 at 14:45'), findsOneWidget);
      expect(find.textContaining('15/1/2023 at 10:30'), findsOneWidget);
    });

    testWidgets('should have scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have app bar with correct title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Photo Details'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display all photo information in correct order', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Check that all elements are present
      expect(find.text('Swiss Alps, Switzerland'), findsOneWidget);
      expect(find.text('Created by John Doe'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(
        find.text('Beautiful mountain landscape with snow-capped peaks'),
        findsOneWidget,
      );
      expect(find.text('Photo Information'), findsOneWidget);
    });

    testWidgets('should handle long descriptions correctly', (tester) async {
      final longDescriptionPhoto = Photo(
        id: '2',
        url: 'https://example.com/photo2.jpg',
        description:
            'This is a very long description that should be displayed properly in the detail screen without any issues or text overflow problems.',
        location: 'Test Location',
        createdBy: 'Test Creator',
        createdAt: DateTime(2023, 1, 1),
        takenAt: DateTime(2022, 12, 1),
      );

      await tester.pumpWidget(
        MaterialApp(home: PhotoDetailScreen(photo: longDescriptionPhoto)),
      );

      expect(
        find.text(
          'This is a very long description that should be displayed properly in the detail screen without any issues or text overflow problems.',
        ),
        findsOneWidget,
      );
    });
  });
}
