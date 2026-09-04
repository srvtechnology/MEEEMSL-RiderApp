import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeem_rider/core/widgets/custom_card.dart';

void main() {
  group('CustomCard ListTile ink & background tests', () {
    testWidgets('CustomCard wrapping ListTile with onTap does not throw assertion error and handles tap',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCard(
              child: ListTile(
                title: const Text('Account Details'),
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Account Details'), findsOneWidget);
      await tester.tap(find.text('Account Details'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('CustomCard wrapping multiple ListTiles and SwitchListTile works properly',
        (WidgetTester tester) async {
      bool tile1Tapped = false;
      bool switchVal = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CustomCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('Documents & Verification'),
                        subtitle: const Text('ID, Driver License'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          tile1Tapped = true;
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        value: switchVal,
                        onChanged: (val) {
                          setState(() {
                            switchVal = val;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Documents & Verification'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);

      await tester.tap(find.text('Documents & Verification'));
      await tester.pumpAndSettle();
      expect(tile1Tapped, isTrue);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(switchVal, isTrue);
    });

    testWidgets('CustomCard wrapping ListTile with tileColor and custom styling renders without error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCard(
              child: ListTile(
                tileColor: Colors.blue.withAlpha(50),
                leading: const Icon(Icons.star),
                title: const Text('Highlighted Tile'),
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Highlighted Tile'), findsOneWidget);
    });

    testWidgets('CustomCard with its own onTap fires tap event correctly',
        (WidgetTester tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCard(
              onTap: () {
                cardTapped = true;
              },
              child: const Text('Clickable Card'),
            ),
          ),
        ),
      );

      expect(find.text('Clickable Card'), findsOneWidget);
      await tester.tap(find.text('Clickable Card'));
      await tester.pumpAndSettle();
      expect(cardTapped, isTrue);
    });

    testWidgets('CustomCard applies custom backgroundColor, border and dark mode correctly',
        (WidgetTester tester) async {
      const customBg = Color(0xFF123456);
      final customBorder = Border.all(color: Colors.red, width: 2);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: CustomCard(
              backgroundColor: customBg,
              border: customBorder,
              child: ListTile(
                title: const Text('Dark Card Tile'),
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Dark Card Tile'), findsOneWidget);

      final materialWidget = tester.widget<Material>(
        find.descendant(
          of: find.byType(CustomCard),
          matching: find.byType(Material),
        ).first,
      );

      expect(materialWidget.color, customBg);
      expect(materialWidget.shape, isA<RoundedRectangleBorder>());
      final shape = materialWidget.shape as RoundedRectangleBorder;
      expect(shape.side.color, Colors.red);
      expect(shape.side.width, 2.0);
    });
  });
}
