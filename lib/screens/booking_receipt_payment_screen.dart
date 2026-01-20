import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ilaba/providers/booking_state_provider.dart';
import 'package:ilaba/providers/auth_provider.dart';
import 'package:ilaba/services/order_payload_builder.dart';
import 'package:ilaba/services/order_creation_service.dart';
import 'package:ilaba/models/order_models.dart';
import 'package:ilaba/screens/order_success_screen.dart';

class BookingReceiptPaymentScreen extends StatefulWidget {
  const BookingReceiptPaymentScreen({super.key});

  @override
  State<BookingReceiptPaymentScreen> createState() =>
      _BookingReceiptPaymentScreenState();
}

class _BookingReceiptPaymentScreenState
    extends State<BookingReceiptPaymentScreen> {
  bool _gcashPaymentConfirmed = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingStateNotifier, AuthProvider>(
      builder: (context, bookingState, authState, _) {
        final receipt = bookingState.computeReceipt();
        final colorScheme = Theme.of(context).colorScheme;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Receipt & Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Receipt Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'ORDER SUMMARY',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Products
                        if (receipt.productLines.isNotEmpty) ...[
                          const Text(
                            'Products:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...receipt.productLines.map((line) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                        '${line.name} x${line.qty}'),
                                  ),
                                  Text(
                                    '₱${line.lineTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text(
                                '₱${receipt.productSubtotal.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                        ],

                        // Services
                        if (receipt.basketLines.isNotEmpty) ...[
                          const Text(
                            'Laundry Services:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...receipt.basketLines.map((line) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${line.name} (${line.weightKg}kg)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '₱${line.total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      top: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if ((line.breakdown['wash'] ?? 0) > 0)
                                          Text(
                                            'Wash: ₱${(line.breakdown['wash'] ?? 0).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        if ((line.breakdown['dry'] ?? 0) > 0)
                                          Text(
                                            'Dry: ₱${(line.breakdown['dry'] ?? 0).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        if ((line.breakdown['spin'] ?? 0) > 0)
                                          Text(
                                            'Spin: ₱${(line.breakdown['spin'] ?? 0).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        if ((line.breakdown['iron'] ?? 0) > 0)
                                          Text(
                                            'Iron: ₱${(line.breakdown['iron'] ?? 0).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        if ((line.breakdown['fold'] ?? 0) > 0)
                                          Text(
                                            'Fold: ₱${(line.breakdown['fold'] ?? 0).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text(
                                '₱${receipt.basketSubtotal.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                        ],

                        // Fees
                        if (receipt.serviceFee > 0)
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Service Fee:'),
                              Text(
                                '₱${receipt.serviceFee.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        if (receipt.handlingFee > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Delivery Fee:'),
                              Text(
                                '₱${receipt.handlingFee.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ],

                        if (receipt.serviceFee > 0 ||
                            receipt.handlingFee > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tax (12%):'),
                              Text(
                                '₱${receipt.tax.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Total
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₱${receipt.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // GCash Payment Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'GCash Payment',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please complete the following steps:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStepItem(
                              '1',
                              'Open your GCash app',
                              colorScheme,
                            ),
                            const SizedBox(height: 12),
                            _buildStepItem(
                              '2',
                              'Send ₱${receipt.total.toStringAsFixed(2)} to the store',
                              colorScheme,
                            ),
                            const SizedBox(height: 12),
                            _buildStepItem(
                              '3',
                              'Take a screenshot of the confirmation',
                              colorScheme,
                            ),
                            const SizedBox(height: 12),
                            _buildStepItem(
                              '4',
                              'Check the box below to confirm',
                              colorScheme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _gcashPaymentConfirmed,
                        onChanged: (bool? value) {
                          setState(() {
                            _gcashPaymentConfirmed = value ?? false;
                          });
                        },
                        title: const Text(
                          'I have completed the GCash payment',
                          style: TextStyle(fontSize: 12),
                        ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity:
                            ListTileControlAffinity.leading,
                        dense: true,
                        fillColor: WidgetStatePropertyAll(
                          colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: (_gcashPaymentConfirmed && !_isSubmitting)
                      ? () => _submitOrder(
                            context,
                            bookingState,
                            authState,
                            receipt,
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Submit Order'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepItem(
    String number,
    String text,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _submitOrder(
    BuildContext context,
    BookingStateNotifier bookingState,
    AuthProvider authState,
    ReceiptSummary receipt,
  ) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      if (authState.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final user = authState.currentUser!;

      // Build breakdown and handling using the builder service
      final breakdown = OrderPayloadBuilder.buildBreakdown(
        orderProductCounts: bookingState.orderProductCounts,
        products: bookingState.products,
        baskets: bookingState.baskets,
        services: bookingState.services,
        includeDelivery: bookingState.handling.deliver,
      );

      final handling = OrderPayloadBuilder.buildHandling(
        pickupEnabled: bookingState.handling.pickup,
        pickupAddress: bookingState.handling.pickupAddress,
        deliveryEnabled: bookingState.handling.deliver,
        deliveryAddress: bookingState.handling.deliveryAddress,
        instructions: bookingState.handling.instructions,
      );

      // Create order payload
      final orderPayload = CreateOrderPayload(
        source: 'app',
        customerId: user.id,
        breakdown: breakdown,
        handling: handling,
        totalAmount: receipt.total,
        cashierId: null,
        status: 'pending',
        orderNote: bookingState.handling.instructions.isNotEmpty
            ? bookingState.handling.instructions
            : null,
      );

      // Create request
      final request = CreateOrderRequest(
        customer: CustomerData(
          id: user.id,
          phoneNumber: user.phoneNumber,
          emailAddress: user.emailAddress ?? '',
        ),
        orderPayload: orderPayload,
      );

      // Submit order
      final orderService = OrderCreationServiceImpl();
      final response = await orderService.createOrder(request);

      if (!mounted) return;

      if (response.success) {
        // Reset booking state
        bookingState.resetForNewOrder();

        // Navigate to success screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(
              orderId: response.orderId,
              totalAmount: receipt.total,
              customerName: '${user.firstName} ${user.lastName}',
              customerEmail: user.emailAddress,
            ),
          ),
        );
      } else {
        _showErrorDialog(
          response.error ?? 'Failed to create order',
          response.insufficientItems,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          e.toString().replaceAll('Exception: ', ''),
          null,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorDialog(String message, List<Map<String, dynamic>>? insufficientItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Submission Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (insufficientItems != null && insufficientItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Unavailable Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...insufficientItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${item['productName']} - Requested: ${item['requested']}, Available: ${item['available']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
