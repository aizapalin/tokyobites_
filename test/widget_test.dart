import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokyobites/food_api.dart';
import 'package:tokyobites/food_card.dart';
import 'package:tokyobites/Home_page.dart' show RewardsStampCard;
import 'package:tokyobites/login_page.dart';

void main() {
  testWidgets('RewardsStampCard renders stamp count correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RewardsStampCard(stampCount: 6),
        ),
      ),
    );

    expect(find.text('TOKYO BITES REWARDS'), findsOneWidget);
    expect(find.text('6 / 10 Stamps'), findsOneWidget);
    expect(find.text('4 more stamps until your reward!'), findsOneWidget);
  });

  testWidgets('QuantitySelector triggers plus and minus callbacks',
      (WidgetTester tester) async {
    int count = 1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return QuantitySelector(
                quantity: count,
                onMinus: () => setState(() => count--),
                onPlus: () => setState(() => count++),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(count, 2);
  });

  group('Data Catalog - JSON Mapping & Model', () {
    test('maps JSON array from REST API into FoodItem objects', () {
      const String jsonString = '''
      [
        {
          "id": 1,
          "category": "Main Dishes",
          "name": "Okonomiyaki",
          "description": "Savory Japanese pancake with cabbage, meat, and sauce.",
          "price": 150.0,
          "imageAsset": "assets/food/okonomiyaki.jpg",
          "isAvailable": true
        },
        {
          "id": 2,
          "category": "Desserts",
          "name": "Matcha Ice Cream",
          "description": "Refreshing green tea ice cream.",
          "price": 100.0,
          "imageAsset": "assets/food/matchaicecream.jpg",
          "isAvailable": false
        }
      ]
      ''';

      final FoodData foodData = foodDataFromJson(jsonString);

      expect(foodData.data.length, 2);
      expect(foodData.data[0].id, 1);
      expect(foodData.data[0].name, 'Okonomiyaki');
      expect(foodData.data[0].category, 'Main Dishes');
      expect(foodData.data[0].price, 150.0);
      expect(foodData.data[0].priceLabel, '₱150.00');
      expect(foodData.data[0].imageAsset, 'assets/food/okonomiyaki.jpg');
      expect(foodData.data[0].isAvailable, isTrue);

      expect(foodData.data[1].id, 2);
      expect(foodData.data[1].name, 'Matcha Ice Cream');
      expect(foodData.data[1].isAvailable, isFalse);
    });

    test('maps Fakestore API JSON format with title and image fields', () {
      const String fakeStoreJson = '''
      [
        {
          "id": 10,
          "title": "SanDisk SSD PLUS 1TB Internal SSD",
          "price": 109,
          "description": "Easy upgrade for faster boot up, shutdown, application load and response.",
          "category": "electronics",
          "image": "https://fakestoreapi.com/img/61U7T1koQqL._AC_SX679_.jpg"
        }
      ]
      ''';

      final FoodData foodData = foodDataFromJson(fakeStoreJson);

      expect(foodData.data.length, 1);
      final FoodItem item = foodData.data.first;
      expect(item.id, 10);
      expect(item.name, 'SanDisk SSD PLUS 1TB Internal SSD');
      expect(item.title, 'SanDisk SSD PLUS 1TB Internal SSD');
      expect(item.price, 109.0);
      expect(item.category, 'electronics');
      expect(item.imageAsset,
          'https://fakestoreapi.com/img/61U7T1koQqL._AC_SX679_.jpg');
      expect(item.isAvailable, isTrue);
    });
  });

  group('Data Catalog - Search Filtering', () {
    test('filters products case-insensitively by name and restores full list on clear', () {
      final List<FoodItem> catalog = [
        FoodItem(
          id: 1,
          category: 'Main Dishes',
          name: 'Okonomiyaki',
          description: 'Savory pancake',
          price: 150,
          imageAsset: 'assets/food/okonomiyaki.jpg',
          isAvailable: true,
        ),
        FoodItem(
          id: 2,
          category: 'Main Dishes',
          name: 'Tonkatsu',
          description: 'Pork cutlet',
          price: 180,
          imageAsset: 'assets/food/tonkatsu.jpg',
          isAvailable: true,
        ),
        FoodItem(
          id: 3,
          category: 'Desserts',
          name: 'Mochi',
          description: 'Sweet rice cake',
          price: 90,
          imageAsset: 'assets/food/mochi.jpg',
          isAvailable: true,
        ),
      ];

      // Case-insensitive search for 'okono'
      String query = 'oKoNo'.toLowerCase().trim();
      List<FoodItem> filtered = catalog
          .where((item) =>
              item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query))
          .toList();
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Okonomiyaki');

      // Case-insensitive search for 'desserts'
      query = 'desserts'.toLowerCase().trim();
      filtered = catalog
          .where((item) =>
              item.name.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query))
          .toList();
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Mochi');

      // Clear search restores all items
      query = ''.trim();
      filtered = query.isEmpty
          ? catalog
          : catalog
              .where((item) =>
                  item.name.toLowerCase().contains(query) ||
                  item.category.toLowerCase().contains(query))
              .toList();
      expect(filtered.length, 3);
    });
  });

  group('Data Catalog - UI Widget Test', () {
    testWidgets('FoodApiPage mounts and renders search field and title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FoodApiPage(showAppBar: true),
        ),
      );

      // Verify that FoodApiPage renders AppBar and Search TextField
      expect(find.text('Data Catalog'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets(
        'FoodApiPage displays products and filters dynamically with search input',
        (WidgetTester tester) async {
      final sampleData = FoodData(
        data: [
          FoodItem(
            id: 1,
            category: 'Main Dishes',
            name: 'Okonomiyaki',
            description: 'Savory Japanese pancake',
            price: 150.0,
            imageAsset: 'assets/food/okonomiyaki.jpg',
            isAvailable: true,
          ),
          FoodItem(
            id: 2,
            category: 'Desserts',
            name: 'Matcha Ice Cream',
            description: 'Green tea ice cream',
            price: 100.0,
            imageAsset: 'assets/food/matchaicecream.jpg',
            isAvailable: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FoodApiPage(
            showAppBar: true,
            initialData: sampleData,
          ),
        ),
      );

      // Verify both items are rendered
      expect(find.text('Okonomiyaki'), findsOneWidget);
      expect(find.text('Matcha Ice Cream'), findsOneWidget);
      expect(find.text('All Products (2)'), findsOneWidget);

      // Enter search query 'okono'
      await tester.enterText(find.byType(TextField), 'okono');
      await tester.pump();

      // Only Okonomiyaki should remain visible
      expect(find.text('Okonomiyaki'), findsOneWidget);
      expect(find.text('Matcha Ice Cream'), findsNothing);
      expect(find.text('Search Results (1)'), findsOneWidget);

      // Tap clear icon to restore all products
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Both products should be visible again
      expect(find.text('Okonomiyaki'), findsOneWidget);
      expect(find.text('Matcha Ice Cream'), findsOneWidget);
      expect(find.text('All Products (2)'), findsOneWidget);
    });
  });

  group('Authentication - LoginPage UI Tests', () {
    testWidgets('LoginPage renders elements and toggles to registration mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // Verify branding and initial sign in UI
      expect(find.text('TokyoBites'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
      expect(find.text('Register now'), findsOneWidget);

      // Scroll to Register now and tap to switch to registration mode
      await tester.ensureVisible(find.text('Register now'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Register now'));
      await tester.pumpAndSettle();

      // Verify registration mode elements
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);

      // Scroll to Sign in and tap to toggle back
      await tester.ensureVisible(find.text('Sign in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsOneWidget);

      // Tap Sign In with empty fields to verify validation message
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Please enter your email address.'), findsOneWidget);
    });
  });
}


