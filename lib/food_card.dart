import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_data.dart';
import 'tokyo_theme.dart';

// ============================================================================
// Food Card Component
// ============================================================================

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAddToCart,
    this.imageHeight = 160,
  });

  final FoodItem item;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: TokyoTheme.cardLight,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        splashColor: TokyoTheme.primary.withAlpha(30),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              item.imageAsset,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: imageHeight,
                  color: TokyoTheme.secondary,
                  child: const Icon(
                    Icons.ramen_dining,
                    size: 64,
                    color: TokyoTheme.primary,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: TokyoTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: TokyoTheme.textMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        item.priceLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TokyoTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: onAddToCart,
                            child: const Text('Add to Cart'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Quantity Selector Component & Food Item Quantity Sheet
// ============================================================================

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: quantity > 1 ? onMinus : null,
          icon: const Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton.filled(
          onPressed: onPlus,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

Future<void> showFoodQuantitySheet({
  required BuildContext context,
  required FoodItem item,
  required void Function(int quantity) onAddToCart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _FoodQuantitySheet(
          item: item,
          onAddToCart: onAddToCart,
        ),
      );
    },
  );
}

class _FoodQuantitySheet extends StatefulWidget {
  const _FoodQuantitySheet({
    required this.item,
    required this.onAddToCart,
  });

  final FoodItem item;
  final void Function(int quantity) onAddToCart;

  @override
  State<_FoodQuantitySheet> createState() => _FoodQuantitySheetState();
}

class _FoodQuantitySheetState extends State<_FoodQuantitySheet> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final double lineTotal = widget.item.price * quantity;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: TokyoTheme.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.priceLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TokyoTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quantity',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: TokyoTheme.textMedium,
              ),
            ),
            const SizedBox(height: 8),
            QuantitySelector(
              quantity: quantity,
              onMinus: () {
                setState(() {
                  quantity -= 1;
                });
              },
              onPlus: () {
                setState(() {
                  quantity += 1;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Total: ₱${lineTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TokyoTheme.darkText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onAddToCart(quantity);
                  Navigator.pop(context);
                },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Custom Meal Set Sheet Component
// ============================================================================

Future<void> showCustomMealSetSheet({
  required BuildContext context,
  required void Function(FoodItem setItem, int quantity) onAddToCart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _CustomMealSetSheet(onAddToCart: onAddToCart),
      );
    },
  );
}

class _CustomMealSetSheet extends StatefulWidget {
  const _CustomMealSetSheet({required this.onAddToCart});

  final void Function(FoodItem setItem, int quantity) onAddToCart;

  @override
  State<_CustomMealSetSheet> createState() => _CustomMealSetSheetState();
}

class _CustomMealSetSheetState extends State<_CustomMealSetSheet> {
  MealPlan selectedPlan = tokyoBitesMealPlans.first;
  final List<FoodItem?> selectedMains = <FoodItem?>[];
  final List<FoodItem?> selectedDesserts = <FoodItem?>[];
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _resetSelections();
  }

  void _resetSelections() {
    selectedMains
      ..clear()
      ..addAll(List<FoodItem?>.filled(selectedPlan.mainCount, null));
    selectedDesserts
      ..clear()
      ..addAll(List<FoodItem?>.filled(selectedPlan.dessertCount, null));
  }

  bool get isComplete {
    return selectedMains.every((FoodItem? item) => item != null) &&
        selectedDesserts.every((FoodItem? item) => item != null);
  }

  double get lineTotal => selectedPlan.price * quantity;

  Future<void> _pickDish({
    required List<FoodItem> options,
    required void Function(FoodItem item) onPicked,
  }) async {
    final FoodItem? picked = await showDialog<FoodItem>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: TokyoTheme.cardDark,
          title: const Text('Choose a dish'),
          children: options.map((FoodItem item) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item),
              child: Text('${item.name}  ${item.priceLabel}'),
            );
          }).toList(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        onPicked(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Custom Meal Set',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: TokyoTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose from the Tokyo Twist meal plans, then pick real mains and desserts. Drink is included with the set.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TokyoTheme.textMedium, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: tokyoBitesMealPlans.map((MealPlan plan) {
                final bool selected = plan.name == selectedPlan.name;
                return ChoiceChip(
                  label: Text(plan.name),
                  selected: selected,
                  selectedColor: TokyoTheme.primary,
                  onSelected: (bool value) {
                    if (!value) {
                      return;
                    }
                    setState(() {
                      selectedPlan = plan;
                      _resetSelections();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              selectedPlan.priceLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TokyoTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            ...List<Widget>.generate(selectedPlan.mainCount, (int index) {
              final FoodItem? current = selectedMains[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Choose Main ${index + 1}'),
                subtitle: Text(
                  current?.name ?? 'Tap to choose',
                  style: const TextStyle(color: TokyoTheme.textMedium),
                ),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    _pickDish(
                      options: tokyoMainDishes,
                      onPicked: (FoodItem item) {
                        selectedMains[index] = item;
                      },
                    );
                  },
                  child: const Text('Choose'),
                ),
              );
            }),
            ...List<Widget>.generate(selectedPlan.dessertCount, (int index) {
              final FoodItem? current = selectedDesserts[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Choose Dessert ${index + 1}'),
                subtitle: Text(
                  current?.name ?? 'Tap to choose',
                  style: const TextStyle(color: TokyoTheme.textMedium),
                ),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    _pickDish(
                      options: tokyoDesserts,
                      onPicked: (FoodItem item) {
                        selectedDesserts[index] = item;
                      },
                    );
                  },
                  child: const Text('Choose'),
                ),
              );
            }),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Drink'),
              subtitle: Text(
                'Free drink included with this Tokyo Twist set.',
                style: TextStyle(color: TokyoTheme.textMedium),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quantity',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            QuantitySelector(
              quantity: quantity,
              onMinus: () {
                setState(() {
                  quantity -= 1;
                });
              },
              onPlus: () {
                setState(() {
                  quantity += 1;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ₱${lineTotal.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TokyoTheme.cream,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isComplete
                  ? () {
                      final String mains = selectedMains
                          .map((FoodItem? item) => item!.name)
                          .join(', ');
                      final String desserts = selectedDesserts
                          .map((FoodItem? item) => item!.name)
                          .join(', ');
                      final FoodItem setItem = FoodItem(
                        name: selectedPlan.name,
                        description: 'Mains: $mains. Desserts: $desserts. Free drink included.',
                        price: selectedPlan.price,
                        imageAsset: selectedMains.first!.imageAsset,
                        category: 'Meal Sets',
                      );
                      widget.onAddToCart(setItem, quantity);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
