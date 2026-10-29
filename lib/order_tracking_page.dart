import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cart_controller.dart';
import 'tokyo_theme.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({
    super.key,
    required this.cart,
    required this.orderId,
  });

  final CartController cart;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (BuildContext context, Widget? child) {
        final PlacedOrder order = cart.orders.firstWhere(
          (PlacedOrder item) => item.id == orderId,
        );
        final bool delivered =
            order.statusIndex >= orderTrackingStages.length - 1;

        return Scaffold(
          backgroundColor: TokyoTheme.background,
          appBar: AppBar(
            title: Text(
              'Track ${order.id}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: TokyoTheme.primary,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: TokyoTheme.cardLight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${order.status}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: TokyoTheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Placed ${formatOrderDate(order.placedAt)}',
                        style: const TextStyle(color: TokyoTheme.textMedium),
                      ),
                      Text(
                        'Total: ₱${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(color: TokyoTheme.cream),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...List<Widget>.generate(orderTrackingStages.length, (int index) {
                final bool reached = index <= order.statusIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        reached
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: reached
                            ? TokyoTheme.primary
                            : TokyoTheme.textMedium,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderTrackingStages[index],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: reached
                                    ? TokyoTheme.cream
                                    : TokyoTheme.textMedium,
                              ),
                            ),
                            if (index < orderTrackingStages.length - 1)
                              Container(
                                margin: const EdgeInsets.only(left: 2, top: 4),
                                height: 18,
                                width: 2,
                                color: reached
                                    ? TokyoTheme.primary
                                    : TokyoTheme.elevated,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              const Text(
                'This status updates on this device only. It is not live kitchen tracking.',
                style: TextStyle(color: TokyoTheme.textMedium, fontSize: 12),
              ),
              const SizedBox(height: 16),
              if (!delivered)
                FilledButton(
                  onPressed: () => cart.advanceOrderStatus(order.id),
                  child: const Text('Next Status'),
                ),
            ],
          ),
        );
      },
    );
  }
}
