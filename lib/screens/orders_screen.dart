import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ilaba/providers/auth_provider.dart';
import 'package:ilaba/screens/order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _activeOrdersFuture;
  late Future<List<Map<String, dynamic>>> _orderHistoryFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final authProvider = context.read<AuthProvider>();
    final customerId = authProvider.currentUser?.id;

    if (customerId != null) {
      _activeOrdersFuture = _fetchActiveOrders(customerId);
      _orderHistoryFuture = _fetchOrderHistory(customerId);
    } else {
      _activeOrdersFuture = Future.value([]);
      _orderHistoryFuture = Future.value([]);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchActiveOrders(
    String customerId,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      final orders = await supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .neq('status', 'completed')
          .neq('status', 'cancelled')
          .order('created_at', ascending: false);

      // Orders now have all data in JSON columns (breakdown, handling)
      return orders.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ Error fetching active orders: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrderHistory(
    String customerId,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      final orders = await supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      // Orders now have all data in JSON columns (breakdown, handling)
      // No need for additional fetches
      return orders.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ Error fetching order history: $e');
      rethrow;
    }
  }

  String _getOrderStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Processing';
      case 'pick-up':
        return 'Pick-up';
      case 'delivering':
        return 'Delivering';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'pick-up':
        return Colors.indigo;
      case 'delivering':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.hourglass_top;
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.local_laundry_service;
      case 'pick-up':
        return Icons.local_shipping;
      case 'delivering':
        return Icons.delivery_dining;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(String? dateString, {bool includeTime = false}) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      if (includeTime) {
        final period = date.hour >= 12 ? 'PM' : 'AM';
        final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
        return '${months[date.month - 1]} ${date.day} • ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
      }
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₱0.00';
    final value = amount is String
        ? double.tryParse(amount) ?? 0
        : (amount as num).toDouble();
    return '₱${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.pink.shade400,
          labelColor: Colors.pink.shade400,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Active'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildActiveOrdersTab(), _buildOrderHistoryTab()],
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _activeOrdersFuture,
      builder: (context, snapshot) => _buildOrdersList(
        snapshot,
        isPink: true,
        emptyTitle: 'No Active Orders',
        emptyDesc: 'All your orders are completed',
      ),
    );
  }

  Widget _buildOrderHistoryTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _orderHistoryFuture,
      builder: (context, snapshot) => _buildOrdersList(
        snapshot,
        isPink: false,
        emptyTitle: 'No Orders Yet',
        emptyDesc: 'Start booking laundry services today',
      ),
    );
  }

  Widget _buildOrdersList(
    AsyncSnapshot<List<Map<String, dynamic>>> snapshot, {
    required bool isPink,
    required String emptyTitle,
    required String emptyDesc,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isPink ? Colors.pink.shade400 : Colors.blue.shade400,
          ),
        ),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to load orders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => setState(() => _loadOrders()),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final orders = snapshot.data ?? [];

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPink ? Colors.pink.shade100 : Colors.blue.shade100,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 50,
                color: isPink ? Colors.pink.shade400 : Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              emptyDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return isPink
            ? _buildActiveOrderCard(order)
            : _buildHistoryOrderCard(order);
      },
    );
  }

  Widget _buildActiveOrderCard(Map<String, dynamic> order) {
    final color = Colors.pink.shade400;
    final orderId = order['id'];
    final status = order['status'] ?? 'processing';
    final baskets = order['baskets'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: color.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${orderId.toString().substring(0, 8)}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getOrderStatusLabel(status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildServiceTimeline(baskets),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryOrderCard(Map<String, dynamic> order) {
    final color = Colors.blue.shade400;
    final orderId = order['id'];
    final status = order['status'] ?? 'pending';
    final createdAt = _formatDate(order['created_at'], includeTime: true);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 0,
        color: color.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    'Order #${orderId.toString().substring(0, 8)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    createdAt,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward, size: 16, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTimeline(List baskets) {
    if (baskets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(baskets.length, (basketIndex) {
        final basket = baskets[basketIndex];
        final basketServices = basket['services'] as List? ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (basketIndex > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  color: Colors.pink.shade200.withOpacity(0.15),
                  height: 1,
                ),
              ),
            Row(
              children: [
                Icon(
                  Icons.local_laundry_service_outlined,
                  size: 18,
                  color: Colors.pink.shade400,
                ),
                const SizedBox(width: 8),
                Text(
                  'Basket #${basket['basket_number']}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(basket['status']).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (basket['status'] ?? 'N/A').toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(basket['status']),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (basketServices.isNotEmpty)
              Column(
                children: List.generate(basketServices.length, (serviceIndex) {
                  final service = basketServices[serviceIndex];
                  final serviceName = service['services']?['name'] ?? 'Service';
                  final serviceStatus = service['status'] ?? 'pending';
                  final isCompleted = serviceStatus == 'completed';
                  final isInProgress = serviceStatus == 'in_progress';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(
                                  serviceStatus,
                                ).withOpacity(0.2),
                                border: Border.all(
                                  color: _getStatusColor(serviceStatus),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_rounded
                                      : _getStatusIcon(serviceStatus),
                                  size: 12,
                                  color: _getStatusColor(serviceStatus),
                                ),
                              ),
                            ),
                            if (serviceIndex < basketServices.length - 1)
                              Container(
                                width: 2,
                                height: 40,
                                color: _getStatusColor(
                                  serviceStatus,
                                ).withOpacity(0.3),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                serviceStatus,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        serviceName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isInProgress)
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _getStatusColor(serviceStatus),
                                              ),
                                        ),
                                      ),
                                    if (isCompleted)
                                      Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: _getStatusColor(serviceStatus),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Amount: ${_formatCurrency(service['subtotal'])}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
          ],
        );
      }),
    );
  }
}
