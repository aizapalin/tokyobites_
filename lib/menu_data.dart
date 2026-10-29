class FoodItem {
  const FoodItem({
    required this.name,
    required this.description,
    required this.price,
    required this.imageAsset,
    required this.category,
  });

  final String name;
  final String description;
  final double price;
  final String imageAsset;
  final String category;

  String get priceLabel => '₱${price.toStringAsFixed(2)}';
}

class MealPlan {
  const MealPlan({
    required this.name,
    required this.priceLabel,
    required this.perks,
    required this.price,
    required this.mainCount,
    required this.dessertCount,
  });

  final String name;
  final String priceLabel;
  final List<String> perks;
  final double price;
  final int mainCount;
  final int dessertCount;
}

const List<FoodItem> tokyoBitesMenu = [
  FoodItem(
    name: 'Okonomiyaki',
    description: 'Savory Japanese pancake with cabbage, meat, and sauce.',
    price: 150,
    imageAsset: 'assets/food/okonomiyaki.jpg',
    category: 'Main Dishes',
  ),
  FoodItem(
    name: 'Karaage',
    description: 'Japanese fried chicken, crispy and juicy.',
    price: 130,
    imageAsset: 'assets/food/karaage.jpg',
    category: 'Main Dishes',
  ),
  FoodItem(
    name: 'Yakitori',
    description: 'Grilled skewered chicken with savory sauce.',
    price: 120,
    imageAsset: 'assets/food/yakitori.jpg',
    category: 'Main Dishes',
  ),
  FoodItem(
    name: 'Tonkatsu',
    description: 'Crispy breaded pork cutlet with savory sauce.',
    price: 180,
    imageAsset: 'assets/food/tonkatsu.jpg',
    category: 'Main Dishes',
  ),
  FoodItem(
    name: 'Udon',
    description: 'Thick Japanese noodles in a savory broth.',
    price: 160,
    imageAsset: 'assets/food/udon.jpg',
    category: 'Main Dishes',
  ),
  FoodItem(
    name: 'Ramen',
    description: 'Rich and flavorful Japanese noodle soup.',
    price: 170,
    imageAsset: 'assets/food/ramen.jpg',
    category: 'Main Dishes',
  ),
  FoodItem(
    name: 'Matcha Ice Cream',
    description: 'Refreshing green tea flavored ice cream.',
    price: 100,
    imageAsset: 'assets/food/matchaicecream.jpg',
    category: 'Desserts',
  ),
  FoodItem(
    name: 'Mochi',
    description: 'Chewy rice cake filled with sweet red bean paste.',
    price: 90,
    imageAsset: 'assets/food/mochi.jpg',
    category: 'Desserts',
  ),
  FoodItem(
    name: 'Mitarashi Dango',
    description: 'Skewered rice dumplings glazed with sweet soy sauce.',
    price: 80,
    imageAsset: 'assets/food/mitarashi_dango.jpg',
    category: 'Desserts',
  ),
  FoodItem(
    name: 'Senbei',
    description: 'Crispy Japanese rice crackers with savory flavor.',
    price: 70,
    imageAsset: 'assets/food/senbei.jpg',
    category: 'Desserts',
  ),
  FoodItem(
    name: 'Dorayaki',
    description: 'Fluffy pancakes filled with sweet red bean paste.',
    price: 110,
    imageAsset: 'assets/food/dorayaki.jpg',
    category: 'Desserts',
  ),
  FoodItem(
    name: 'Takoyaki',
    description:
        'Ball-shaped snack filled with pieces of octopus and served with sauce.',
    price: 120,
    imageAsset: 'assets/food/takoyaki.jpg',
    category: 'Desserts',
  ),
  FoodItem(
    name: 'Anmitsu',
    description:
        'Traditional Japanese dessert with agar jelly, sweet red beans, and fruit.',
    price: 100,
    imageAsset: 'assets/food/anmitsu.jpg',
    category: 'Desserts',
  ),
  FoodItem(
    name: 'Yokan',
    description:
        'Sweet jellied dessert made from red bean paste, agar, and sugar.',
    price: 90,
    imageAsset: 'assets/food/yokan.jpg',
    category: 'Desserts',
  ),
];

const List<MealPlan> tokyoBitesMealPlans = [
  MealPlan(
    name: 'Solo Set',
    priceLabel: '₱299.00',
    perks: ['1 Main Dish', '1 Dessert', 'Free Drink'],
    price: 299,
    mainCount: 1,
    dessertCount: 1,
  ),
  MealPlan(
    name: 'Family Set',
    priceLabel: '₱899.00',
    perks: ['3 Main Dishes', '3 Desserts', 'Free Drinks'],
    price: 899,
    mainCount: 3,
    dessertCount: 3,
  ),
  MealPlan(
    name: 'Party Set',
    priceLabel: '₱1499.00',
    perks: ['5 Main Dishes', '5 Desserts', 'Free Drinks'],
    price: 1499,
    mainCount: 5,
    dessertCount: 5,
  ),
];

List<FoodItem> get tokyoMainDishes => tokyoBitesMenu
    .where((FoodItem item) => item.category == 'Main Dishes')
    .toList();

List<FoodItem> get tokyoDesserts => tokyoBitesMenu
    .where((FoodItem item) => item.category == 'Desserts')
    .toList();
