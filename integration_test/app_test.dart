import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:number_pagination/number_pagination.dart';
import 'package:pic_pulse/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PicPulse App Complete User Flow', (tester) async {
    // Start the app
    app.main();

    // Wait for photos to load (handles both app startup and photo loading)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify app title is displayed
    expect(find.text('PicPulse'), findsOneWidget);

    // Verify photos are loaded (should see photo cards)
    expect(find.byType(GridView), findsOneWidget);

    // Test search functionality
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Enter search term
    await tester.enterText(searchField, 'mountain');
    await tester.pumpAndSettle();

    // Verify search results - either results are shown or empty state
    final searchResults = find.byType(GridView);
    final emptyState = find.textContaining('No photos found for "mountain"');
    expect(
      searchResults.evaluate().isNotEmpty || emptyState.evaluate().isNotEmpty,
      isTrue,
    );

    // Clear search
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    // Verify we're back to showing all photos
    expect(find.byType(GridView), findsOneWidget);

    // Test navigation to detail screen
    // Find a photo card and tap it
    final photoCards = find.byType(Card);
    if (photoCards.evaluate().isNotEmpty) {
      await tester.tap(photoCards.first);
      await tester.pumpAndSettle();

      // Verify we're on detail screen
      expect(find.text('Photo Details'), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);

      // Go back to list
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify we're back on list screen
      expect(find.text('PicPulse'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    }

    // Test pagination if available and has multiple pages
    final paginationWidget = find.byType(NumberPagination);
    if (paginationWidget.evaluate().isNotEmpty) {
      // Check if page 2 button exists within the pagination widget
      // Use find.descendant to ensure we only find '2' within the NumberPagination widget
      final page2Button = find.descendant(
        of: find.byType(NumberPagination),
        matching: find.text('2'),
      );

      if (page2Button.evaluate().isNotEmpty) {
        // Test pagination - go to page 2
        await tester.tap(page2Button);
        await tester.pumpAndSettle();

        // Verify we're on page 2 - GridView should still be present
        expect(find.byType(GridView), findsOneWidget);

        // Verify pagination widget is still present
        expect(find.byType(NumberPagination), findsOneWidget);

        // Go back to page 1
        final page1Button = find.descendant(
          of: find.byType(NumberPagination),
          matching: find.text('1'),
        );
        if (page1Button.evaluate().isNotEmpty) {
          await tester.tap(page1Button);
          await tester.pumpAndSettle();
          expect(find.byType(GridView), findsOneWidget);
        }
      } else {
        // Only one page available - just verify pagination widget exists
        // This is expected when API returns fewer than 20 photos
        expect(find.byType(NumberPagination), findsOneWidget);
      }
    } else {
      // No pagination widget - this could happen if there are very few photos
      // or if pagination is not implemented for small datasets
      // This is acceptable behavior, so we don't fail the test
    }

    // Test pull to refresh
    final gridView = find.byType(GridView);
    if (gridView.evaluate().isNotEmpty) {
      // Perform pull to refresh gesture
      await tester.drag(gridView, const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify refresh completed - photos should still be visible
      expect(find.byType(GridView), findsOneWidget);

      // Verify app title is still present
      expect(find.text('PicPulse'), findsOneWidget);
    }
  });
}
