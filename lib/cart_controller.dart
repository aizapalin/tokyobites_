import 'package:flutter/foundation.dart';
import 'menu_data.dart';

const List<String> orderTrackingStages = <String>[
  'Order Placed',
  'Preparing',
  'Ready',
  'Out for Delivery',
  'Delivered',
];

String formatOrderDate(DateTime dateTime) {
  final String month = dateTime.month.toString().padLeft(2, '0');
  final String day = dateTime.day.toString().padLeft(2, '0');
  final String hour = dateTime.hour.toString().padLeft(2, '0');
  final String minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day $hour:$minute';
}

class CartLine {
  CartLine({required this.item, required this.quantity});

  final FoodItem item;
  int quantity;

  double get lineTotal => item.price * quantity;
}

class PlacedOrder {
  PlacedOrder({
    required this.id,
    required this.lines,
    required this.total,
    required this.placedAt,
    this.statusIndex = 0,
  });

  final String id;
  final List<CartLine> lines;
  final double total;
  final DateTime placedAt;
  int statusIndex;

  String get status => orderTrackingStages[statusIndex];
}

class CartController extends ChangeNotifier {
  final List<CartLine> _lines = [];
  final List<PlacedOrder> _orders = [];
  int _stampCount = 0;

  static const int stampGoal = 10;

  List<CartLine> get lines => List.unmodifiable(_lines);
  List<PlacedOrder> get orders => List.unmodifiable(_orders);
  int get stampCount => _stampCount;

  int get itemCount =>
      _lines.fold(0, (sum, line) => sum + line.quantity);

  double get total =>
      _lines.fold(0, (sum, line) => sum + line.lineTotal);

  void addItem(FoodItem item, int quantity) {
    final existing = _lines.where((line) => line.item.name == item.name);
    if (existing.isNotEmpty) {
      existing.first.quantity += quantity;
    } else {
      _lines.add(CartLine(item: item, quantity: quantity));
    }
    notifyListeners();
  }

  void removeLine(FoodItem item) {
    _lines.removeWhere((line) => line.item.name == item.name);
    notifyListeners();
  }

  bool checkout() {
    if (_lines.isEmpty) {
      return false;
    }

    _orders.insert(
      0,
      PlacedOrder(
        id: 'TB-${_orders.length + 1}',
        lines: _lines
            .map((line) => CartLine(item: line.item, quantity: line.quantity))
            .toList(),
        total: total,
        placedAt: DateTime.now(),
      ),
    );
    if (_stampCount < stampGoal) {
      _stampCount += 1;
    }
    _lines.clear();
    notifyListeners();
    return true;
  }

  void advanceOrderStatus(String orderId) {
    for (final PlacedOrder order in _orders) {
      if (order.id == orderId &&
          order.statusIndex < orderTrackingStages.length - 1) {
        order.statusIndex += 1;
        notifyListeners();
        return;
      }
    }
  }
}
