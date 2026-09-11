import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/core/widgets/swipe_button.dart';

void main() {
  group('SwipeButton Widget Tests', () {
    testWidgets('renders initial state with label and arrow icon at origin', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: SwipeButton(
                text: 'Swipe to Confirm',
                onSwiped: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Swipe to Confirm'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('triggers onSwiped when dragged past threshold', (WidgetTester tester) async {
      bool swiped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: SwipeButton(
                text: 'Swipe to Start Delivery',
                onSwiped: () {
                  swiped = true;
                },
              ),
            ),
          ),
        ),
      );

      final thumb = find.descendant(
        of: find.byType(SwipeButton),
        matching: find.byType(GestureDetector),
      );
      expect(thumb, findsOneWidget);

      // Drag across the button
      await tester.drag(thumb, const Offset(300, 0));
      await tester.pumpAndSettle();

      expect(swiped, isTrue);
    });

    testWidgets('resets position when dragged below threshold', (WidgetTester tester) async {
      bool swiped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: SwipeButton(
                text: 'Swipe to Start Delivery',
                onSwiped: () {
                  swiped = true;
                },
              ),
            ),
          ),
        ),
      );

      final thumb = find.descendant(
        of: find.byType(SwipeButton),
        matching: find.byType(GestureDetector),
      );

      // Drag only a little bit (below 70%)
      await tester.drag(thumb, const Offset(50, 0));
      await tester.pumpAndSettle();

      expect(swiped, isFalse);
    });

    testWidgets('resets thumb position when widget text changes', (WidgetTester tester) async {
      bool swiped = false;
      String currentText = 'Swipe to Confirm Items Picked Up';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      SwipeButton(
                        text: currentText,
                        onSwiped: () {
                          swiped = true;
                          setState(() {
                            currentText = 'Swipe to Start Delivery to Customer';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

      final thumb = find.descendant(
        of: find.byType(SwipeButton),
        matching: find.byType(GestureDetector),
      );
      // Drag past threshold
      await tester.drag(thumb, const Offset(300, 0));
      await tester.pumpAndSettle();

      expect(swiped, isTrue);
      // After text change, button should show the new text and be ready for next swipe
      expect(find.text('Swipe to Start Delivery to Customer'), findsOneWidget);

      // Now drag again for the next milestone
      bool secondSwiped = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      SwipeButton(
                        text: 'Swipe to Start Delivery to Customer',
                        onSwiped: () {
                          secondSwiped = true;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(
        find.descendant(of: find.byType(SwipeButton), matching: find.byType(GestureDetector)),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();
      expect(secondSwiped, isTrue);
    });

    testWidgets('shows loading spinner and disables drag when isLoading is true', (WidgetTester tester) async {
      bool swiped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: SwipeButton(
                text: 'Swipe to Confirm',
                isLoading: true,
                onSwiped: () {
                  swiped = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Attempt drag while loading
      await tester.drag(
        find.descendant(of: find.byType(SwipeButton), matching: find.byType(GestureDetector)),
        const Offset(300, 0),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(swiped, isFalse);
    });

    testWidgets('resets drag position if loading completes with failure', (WidgetTester tester) async {
      bool isLoading = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 360,
                  child: Column(
                    children: [
                      SwipeButton(
                        text: 'Swipe to Advance',
                        isLoading: isLoading,
                        onSwiped: () {
                          setState(() {
                            isLoading = true;
                          });
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: const Text('Simulate Error'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

      final thumb = find.descendant(
        of: find.byType(SwipeButton),
        matching: find.byType(GestureDetector),
      );

      // Drag to trigger swipe and set isLoading = true
      await tester.drag(thumb, const Offset(300, 0));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Tap simulate error button (loading turns false)
      await tester.tap(find.text('Simulate Error'));
      await tester.pumpAndSettle();

      // Button should reset and be draggable again
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });
  });
}
