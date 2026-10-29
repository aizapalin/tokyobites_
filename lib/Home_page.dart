import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cart_controller.dart';
import 'food_api.dart' show FoodApiPage;
import 'food_card.dart';
import 'menu_data.dart';
import 'order_tracking_page.dart';
import 'tokyo_theme.dart';

class AppDestination {
  const AppDestination(
    this.label,
    this.icon,
    this.selectedIcon, {
    required this.screenIndex,
  });

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final int screenIndex;
}

const List<AppDestination> drawerDestinations = [
  AppDestination(
    'Home',
    Icon(Icons.home_outlined),
    Icon(Icons.home),
    screenIndex: 0,
  ),
  AppDestination(
    'Data Catalog',
    Icon(Icons.inventory_2_outlined),
    Icon(Icons.inventory_2),
    screenIndex: 7,
  ),
  AppDestination(
    'Profile',
    Icon(Icons.person_outline),
    Icon(Icons.person),
    screenIndex: 4,
  ),
  AppDestination(
    'Settings',
    Icon(Icons.settings_outlined),
    Icon(Icons.settings),
    screenIndex: 5,
  ),
  AppDestination(
    'Transaction History',
    Icon(Icons.history_outlined),
    Icon(Icons.history),
    screenIndex: 6,
  ),
];

const List<AppDestination> barDestinations = [
  AppDestination(
    'Home',
    Icon(Icons.home_outlined),
    Icon(Icons.home),
    screenIndex: 0,
  ),
  AppDestination(
    'Menu',
    Icon(Icons.restaurant_menu_outlined),
    Icon(Icons.restaurant_menu),
    screenIndex: 1,
  ),
  AppDestination(
    'Orders',
    Icon(Icons.receipt_long_outlined),
    Icon(Icons.receipt_long),
    screenIndex: 2,
  ),
  AppDestination(
    'Cart',
    Icon(Icons.shopping_cart_outlined),
    Icon(Icons.shopping_cart),
    screenIndex: 3,
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final CartController cart = CartController();
  int screenIndex = 0;

  @override
  void dispose() {
    cart.dispose();
    super.dispose();
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  int? get drawerSelectedIndex {
    final int index = drawerDestinations.indexWhere(
      (AppDestination destination) => destination.screenIndex == screenIndex,
    );
    if (index < 0) {
      return null;
    }
    return index;
  }

  void openMealSetSheet() {
    showCustomMealSetSheet(
      context: context,
      onAddToCart: (FoodItem setItem, int quantity) {
        cart.addItem(setItem, quantity);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $quantity × ${setItem.name} to cart'),
          ),
        );
      },
    );
  }

  void openTracking(PlacedOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return OrderTrackingPage(cart: cart, orderId: order.id);
        },
      ),
    );
  }

  void openFoodSheet(FoodItem item) {
    showFoodQuantitySheet(
      context: context,
      item: item,
      onAddToCart: (int quantity) {
        cart.addItem(item, quantity);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $quantity × ${item.name} to cart'),
          ),
        );
      },
    );
  }

  String get _appBarTitle {
    switch (screenIndex) {
      case 1:
        return 'Menu';
      case 2:
        return 'My Orders';
      case 3:
        return 'Cart';
      case 4:
        return 'Profile';
      case 5:
        return 'Settings';
      case 6:
        return 'Transaction History';
      case 7:
        return 'Data Catalog';
      default:
        return 'Tokyo Bites';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: TokyoTheme.background,
          appBar: AppBar(
            leading: screenIndex > 3
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back to Home',
                    onPressed: () => handleScreenChanged(0),
                  )
                : null,
            title: Text(
              _appBarTitle,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: TokyoTheme.primary,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Cart',
                onPressed: () => handleScreenChanged(3),
                icon: Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text('${cart.itemCount}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              ),
            ],
          ),
          drawer: NavigationDrawer(
            onDestinationSelected: (int selectedDrawerIndex) {
              handleScreenChanged(
                drawerDestinations[selectedDrawerIndex].screenIndex,
              );
            },
            selectedIndex: drawerSelectedIndex,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tokyo Bites',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TokyoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Every Bite, A Twist of Tokyo!',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: TokyoTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              ...drawerDestinations.map((AppDestination destination) {
                return NavigationDrawerDestination(
                  label: Text(destination.label),
                  icon: destination.icon,
                  selectedIcon: destination.selectedIcon,
                );
              }),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: TokyoTheme.primary),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted && Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: screenIndex,
            children: [
              _HomeTab(
                stampCount: cart.stampCount,
                onExploreMenu: () => handleScreenChanged(1),
                onOrderNow: () => handleScreenChanged(1),
                onFoodTap: openFoodSheet,
                onCustomizeMealSet: openMealSetSheet,
              ),
              _MenuTab(
                onFoodTap: openFoodSheet,
                onCustomizeMealSet: openMealSetSheet,
              ),
              _OrdersTab(
                orders: cart.orders,
                onTrackOrder: openTracking,
              ),
              _CartTab(
                cart: cart,
                onBrowseMenu: () => handleScreenChanged(1),
              ),
              _ProfileTab(stampCount: cart.stampCount),
              const _SettingsTab(),
              _TransactionHistoryTab(
                orders: cart.orders,
                onExploreMenu: () => handleScreenChanged(1),
                onTrackOrder: openTracking,
              ),
              const FoodApiPage(showAppBar: false),
            ],
          ),
          floatingActionButton: screenIndex <= 1
              ? FloatingActionButton.extended(
                  onPressed: () {
                    if (screenIndex == 0) {
                      handleScreenChanged(1);
                    } else {
                      openFoodSheet(tokyoBitesMenu.first);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(screenIndex == 0 ? 'Order Now' : 'Add Dish'),
                )
              : null,
          bottomNavigationBar: screenIndex > 3
              ? null
              : NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                screenIndex = index;
              });
            },
            indicatorColor: TokyoTheme.primary.withValues(alpha: 0.28),
            selectedIndex: screenIndex,
            destinations: [
              NavigationDestination(
                selectedIcon: barDestinations[0].selectedIcon,
                icon: barDestinations[0].icon,
                label: barDestinations[0].label,
              ),
              NavigationDestination(
                selectedIcon: barDestinations[1].selectedIcon,
                icon: barDestinations[1].icon,
                label: barDestinations[1].label,
              ),
              NavigationDestination(
                selectedIcon: barDestinations[2].selectedIcon,
                icon: Badge(
                  isLabelVisible: cart.orders.isNotEmpty,
                  label: Text('${cart.orders.length}'),
                  child: barDestinations[2].icon,
                ),
                label: barDestinations[2].label,
              ),
              NavigationDestination(
                selectedIcon: barDestinations[3].selectedIcon,
                icon: Badge(
                  isLabelVisible: cart.itemCount > 0,
                  label: Text('${cart.itemCount}'),
                  child: barDestinations[3].icon,
                ),
                label: barDestinations[3].label,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// Featured Menu Carousel Component
// ============================================================================

/// Featured dish browser that pages through real [FoodItem] entries.
/// Left/right arrows change the current dish; [FoodCard] keeps the
/// official Card + InkWell + FilledButton ordering interaction.
class FeaturedMenuCarousel extends StatefulWidget {
  const FeaturedMenuCarousel({
    super.key,
    required this.title,
    required this.items,
    required this.onFoodTap,
  });

  final String title;
  final List<FoodItem> items;
  final void Function(FoodItem item) onFoodTap;

  @override
  State<FeaturedMenuCarousel> createState() => _FeaturedMenuCarouselState();
}

class _FeaturedMenuCarouselState extends State<FeaturedMenuCarousel> {
  int dishIndex = 0;

  void showPrevious() {
    if (widget.items.isEmpty) {
      return;
    }
    setState(() {
      dishIndex = (dishIndex - 1 + widget.items.length) % widget.items.length;
    });
  }

  void showNext() {
    if (widget.items.isEmpty) {
      return;
    }
    setState(() {
      dishIndex = (dishIndex + 1) % widget.items.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final FoodItem currentDish = widget.items[dishIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: TokyoTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              tooltip: 'Previous',
              onPressed: showPrevious,
              style: IconButton.styleFrom(
                backgroundColor: TokyoTheme.elevated,
                foregroundColor: TokyoTheme.primary,
              ),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: FoodCard(
                item: currentDish,
                imageHeight: 210,
                onTap: () => widget.onFoodTap(currentDish),
                onAddToCart: () => widget.onFoodTap(currentDish),
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Next',
              onPressed: showNext,
              style: IconButton.styleFrom(
                backgroundColor: TokyoTheme.elevated,
                foregroundColor: TokyoTheme.primary,
              ),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Text(
          '${dishIndex + 1} / ${widget.items.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: TokyoTheme.textMedium,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Rewards Stamp Card Component
// ============================================================================

class RewardsStampCard extends StatelessWidget {
  const RewardsStampCard({
    super.key,
    required this.stampCount,
    this.compact = false,
  });

  final int stampCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final int remaining = (CartController.stampGoal - stampCount).clamp(
      0,
      CartController.stampGoal,
    );

    return Card(
      color: TokyoTheme.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOKYO BITES REWARDS',
              style: GoogleFonts.poppins(
                fontSize: compact ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: TokyoTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<Widget>.generate(CartController.stampGoal, (
                int index,
              ) {
                final bool filled = index < stampCount;
                return Icon(
                  filled ? Icons.circle : Icons.circle_outlined,
                  size: compact ? 16 : 20,
                  color: filled ? TokyoTheme.primary : TokyoTheme.textMedium,
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              '$stampCount / ${CartController.stampGoal} Stamps',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: TokyoTheme.cream,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              remaining == 0
                  ? 'Stamp card complete. Reward rule pending confirmation.'
                  : '$remaining more stamps until your reward!',
              style: const TextStyle(
                color: TokyoTheme.textMedium,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.stampCount,
    required this.onExploreMenu,
    required this.onOrderNow,
    required this.onFoodTap,
    required this.onCustomizeMealSet,
  });

  final int stampCount;
  final VoidCallback onExploreMenu;
  final VoidCallback onOrderNow;
  final void Function(FoodItem item) onFoodTap;
  final VoidCallback onCustomizeMealSet;

  @override
  Widget build(BuildContext context) {
    final List<FoodItem> mains = tokyoBitesMenu
        .where((FoodItem item) => item.category == 'Main Dishes')
        .toList();
    final List<FoodItem> desserts = tokyoBitesMenu
        .where((FoodItem item) => item.category == 'Desserts')
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  'assets/food/japan.jpg',
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 210,
                  width: double.infinity,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Every Bite, A Twist of Tokyo!',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: TokyoTheme.cream,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Experience authentic Japanese street foods prepared with love and flavor.',
                        style: TextStyle(color: TokyoTheme.secondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onExploreMenu,
                  child: const Text('Explore Menu'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: onOrderNow,
                  child: const Text('Order Now'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: RewardsStampCard(stampCount: stampCount, compact: true),
        ),
        const SizedBox(height: 28),
        FeaturedMenuCarousel(
          title: 'Main Dishes',
          items: mains,
          onFoodTap: onFoodTap,
        ),
        const SizedBox(height: 24),
        FeaturedMenuCarousel(
          title: 'Desserts',
          items: desserts,
          onFoodTap: onFoodTap,
        ),
        const SizedBox(height: 24),
        Text(
          'Our Meal Plans',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: TokyoTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...tokyoBitesMealPlans.map((MealPlan plan) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
            color: TokyoTheme.cardLight,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    plan.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: TokyoTheme.cream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.priceLabel,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: TokyoTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...plan.perks.map(
                    (String perk) => Text(
                      perk,
                      style: const TextStyle(color: TokyoTheme.textMedium),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onCustomizeMealSet,
                    child: const Text('Customize Set'),
                  ),
                ],
              ),
            ),
          ),
          );
        }),
      ],
    );
  }
}

class _MenuTab extends StatelessWidget {
  const _MenuTab({
    required this.onFoodTap,
    required this.onCustomizeMealSet,
  });

  final void Function(FoodItem item) onFoodTap;
  final VoidCallback onCustomizeMealSet;

  @override
  Widget build(BuildContext context) {
    final List<FoodItem> mains = tokyoBitesMenu
        .where((FoodItem item) => item.category == 'Main Dishes')
        .toList();
    final List<FoodItem> desserts = tokyoBitesMenu
        .where((FoodItem item) => item.category == 'Desserts')
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        Card(
          color: TokyoTheme.cardLight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Custom Meal Set',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TokyoTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Build a Solo, Family, or Party set from real Tokyo Twist mains and desserts, then add it to cart.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TokyoTheme.textMedium),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onCustomizeMealSet,
                  child: const Text('Customize Meal Set'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Main Dishes',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: TokyoTheme.primary,
          ),
        ),
        ...mains.map((FoodItem item) {
          return FoodCard(
            item: item,
            onTap: () => onFoodTap(item),
            onAddToCart: () => onFoodTap(item),
          );
        }),
        const SizedBox(height: 16),
        Text(
          'Desserts',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: TokyoTheme.primary,
          ),
        ),
        ...desserts.map((FoodItem item) {
          return FoodCard(
            item: item,
            onTap: () => onFoodTap(item),
            onAddToCart: () => onFoodTap(item),
          );
        }),
      ],
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({
    required this.orders,
    required this.onTrackOrder,
  });

  final List<PlacedOrder> orders;
  final void Function(PlacedOrder order) onTrackOrder;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No orders yet. Add dishes from the menu to place your first Tokyo Bites order.',
            textAlign: TextAlign.center,
            style: TextStyle(color: TokyoTheme.textMedium),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        final PlacedOrder order = orders[index];
        return Card(
          clipBehavior: Clip.hardEdge,
          color: TokyoTheme.cardLight,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: () => onTrackOrder(order),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: TokyoTheme.cream,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TokyoTheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TokyoTheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          order.status,
                          style: const TextStyle(
                            color: TokyoTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatOrderDate(order.placedAt),
                    style: const TextStyle(
                      color: TokyoTheme.textMedium,
                      fontSize: 12,
                    ),
                  ),
                  const Divider(height: 16),
                  ...order.lines.map((CartLine line) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${line.quantity} × ${line.item.name}',
                            style: const TextStyle(color: TokyoTheme.cream),
                          ),
                          Text(
                            '₱${line.lineTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: TokyoTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ₱${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: TokyoTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => onTrackOrder(order),
                        icon: const Icon(Icons.local_shipping_outlined, size: 18),
                        label: const Text('Track Order'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartTab extends StatelessWidget {
  const _CartTab({
    required this.cart,
    required this.onBrowseMenu,
  });

  final CartController cart;
  final VoidCallback onBrowseMenu;

  @override
  Widget build(BuildContext context) {
    if (cart.lines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your cart is empty.',
                style: TextStyle(color: TokyoTheme.textMedium),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onBrowseMenu,
                child: const Text('Browse Menu'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: cart.lines.length,
            itemBuilder: (BuildContext context, int index) {
              final CartLine line = cart.lines[index];
              return Card(
                color: TokyoTheme.cardLight,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      line.item.imageAsset,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(line.item.name),
                  subtitle: Text(
                    '${line.quantity} × ${line.item.priceLabel}',
                  ),
                  trailing: IconButton(
                    onPressed: () => cart.removeLine(line.item),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total: ₱${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TokyoTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final bool placed = cart.checkout();
                      if (placed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed. Check the Orders tab.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.stampCount});

  final int stampCount;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: TokyoTheme.cardLight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: TokyoTheme.secondary,
                  child: Icon(
                    Icons.ramen_dining,
                    color: TokyoTheme.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tokyo Bites Guest',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Signed in',
                  style: const TextStyle(color: TokyoTheme.textMedium),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        RewardsStampCard(stampCount: stampCount, compact: false),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          color: TokyoTheme.cardLight,
          child: ListTile(
            leading: Icon(Icons.color_lens_outlined, color: TokyoTheme.primary),
            title: Text('Theme'),
            subtitle: Text('Dark Tokyo Twist orange, peach, and cream'),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}

class _TransactionHistoryTab extends StatelessWidget {
  const _TransactionHistoryTab({
    required this.orders,
    required this.onExploreMenu,
    required this.onTrackOrder,
  });

  final List<PlacedOrder> orders;
  final VoidCallback onExploreMenu;
  final void Function(PlacedOrder order) onTrackOrder;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: TokyoTheme.textMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'No Transaction History',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: TokyoTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your completed checkout orders will be recorded here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: TokyoTheme.textMedium),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onExploreMenu,
                child: const Text('Browse Menu'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: orders.length,
      itemBuilder: (BuildContext context, int index) {
        final PlacedOrder order = orders[index];
        return Card(
          clipBehavior: Clip.hardEdge,
          color: TokyoTheme.cardLight,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: () => onTrackOrder(order),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaction #${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: TokyoTheme.cream,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TokyoTheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: TokyoTheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          order.status,
                          style: const TextStyle(
                            color: TokyoTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${formatOrderDate(order.placedAt)}',
                    style: const TextStyle(
                      color: TokyoTheme.textMedium,
                      fontSize: 12,
                    ),
                  ),
                  const Divider(height: 16),
                  const Text(
                    'Items Purchased:',
                    style: TextStyle(
                      color: TokyoTheme.textMedium,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...order.lines.map((CartLine line) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${line.quantity} × ${line.item.name}',
                              style: const TextStyle(color: TokyoTheme.cream),
                            ),
                          ),
                          Text(
                            '₱${line.lineTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: TokyoTheme.textMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ₱${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: TokyoTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => onTrackOrder(order),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View Tracking'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
