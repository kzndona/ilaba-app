import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({required this.order});

  /// Format date to human-readable format with time
  String _formatDate(String? dateString) {
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
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      return '${months[date.month - 1]} ${date.day}, ${date.year} • ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return dateString;
    }
  }

  /// Format currency consistently (always 2 decimals)
  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₱0.00';
    if (amount is String) {
      return '₱${(double.tryParse(amount) ?? 0).toStringAsFixed(2)}';
    } else if (amount is num) {
      return '₱${(amount as num).toDouble().toStringAsFixed(2)}';
    } else if (amount is Map) {
      // Handle Map case - return default
      return '₱0.00';
    }
    return '₱0.00';
  }

  /// Format JSON label to readable text (e.g., 'subtotal_products' -> 'Subtotal (Products)')
  String _formatLabel(String label) {
    return label
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ')
        .replaceAllMapped(
          RegExp(r'\(([^)]+)\)'),
          (match) => '(${match.group(1)?.toLowerCase()})',
        );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId = order['id'];
    final status = order['status'] ?? 'N/A';
    final createdAt = _formatDate(order['created_at']);
    final breakdown = order['breakdown'] as Map<String, dynamic>? ?? {};
    final handling = order['handling'] as Map<String, dynamic>? ?? {};
    final cancellation = order['cancellation'] as Map<String, dynamic>?;
    final totalAmount = _formatCurrency(order['total_amount']);

    // Parse breakdown structure
    final breakdownItems = (breakdown['items'] as List?) ?? [];
    final breakdownBaskets = (breakdown['baskets'] as List?) ?? [];
    final breakdownFees = (breakdown['fees'] as List?) ?? [];
    final breakdownDiscounts = (breakdown['discounts'] as List?) ?? [];
    final breakdownSummary =
        (breakdown['summary'] as Map<String, dynamic>?) ?? {};
    final breakdownPayment =
        (breakdown['payment'] as Map<String, dynamic>?) ?? {};
    final breakdownAuditLog = (breakdown['audit_log'] as List?) ?? [];

    // Parse handling
    final pickupData = (handling['pickup'] as Map<String, dynamic>?) ?? {};
    final deliveryData = (handling['delivery'] as Map<String, dynamic>?) ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${orderId.toString().substring(0, 8)}'),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 Order Summary Card - Modern multi-column
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalAmount,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    color: _getStatusColor(status),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(height: 0.8, color: Colors.grey[200]),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactInfoItem(
                          context,
                          Icons.calendar_today_outlined,
                          'Created',
                          createdAt,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCompactInfoItem(
                          context,
                          Icons.receipt_outlined,
                          'Order ID',
                          orderId.toString().substring(0, 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🛍️ Product Items Section
            if (breakdownItems.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                Icons.shopping_bag_outlined,
                'Products',
                breakdownItems.length.toString(),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemCount = breakdownItems.length;
                  final isMultiColumn = constraints.maxWidth > 600;
                  final crossAxisCount = isMultiColumn ? 2 : 1;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: isMultiColumn ? 1.8 : 2.5,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final item =
                          breakdownItems[index] as Map<String, dynamic>;
                      return Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product_name'] ?? 'Unknown Product',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Qty: ${item['quantity'] ?? 0}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                  ),
                                  Text(
                                    _formatCurrency(item['unit_price']),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Spacer(),
                                  Text(
                                    _formatCurrency(item['subtotal']),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.green[700],
                                        ),
                                  ),
                                ],
                              ),
                              if (item['discount'] != null &&
                                  item['discount'] is num &&
                                  (item['discount'] as num) > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '-${_formatCurrency(item['discount'])}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // 🧺 Laundry Baskets Section
            if (breakdownBaskets.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                Icons.local_laundry_service_outlined,
                'Laundry Baskets',
                breakdownBaskets.length.toString(),
              ),
              const SizedBox(height: 8),
              ...breakdownBaskets.asMap().entries.map((entry) {
                final basket = entry.value as Map<String, dynamic>;
                final services = (basket['services'] as List?) ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey[200]!, width: 0.8),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Basket #${basket['basket_number'] ?? 'N/A'}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  basket['status'],
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                (basket['status'] ?? 'N/A')
                                    .toString()
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _getStatusColor(basket['status']),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 10,
                          runSpacing: 5,
                          children: [
                            if (basket['weight'] != null)
                              _buildMetricChip(
                                Icons.scale,
                                '${basket['weight']} kg',
                                Colors.orange,
                              ),
                            if (basket['total'] != null)
                              _buildMetricChip(
                                Icons.attach_money,
                                _formatCurrency(basket['total']),
                                Colors.green,
                              ),
                          ],
                        ),
                        if (basket['basket_notes'] != null &&
                            (basket['basket_notes'] as String).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.note_outlined,
                                  size: 13,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    basket['basket_notes'] ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (services.isNotEmpty) ...[
                          const SizedBox(height: 9),
                          Text(
                            'Services',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: 6),
                          ...services.map((service) {
                            final svc = service as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.blue[200]!,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        svc['service_name'] ?? 'Unknown',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(svc['total']),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.green[700],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // 📋 Fees & Discounts Section - Multi-column
            if (breakdownFees.isNotEmpty || breakdownDiscounts.isNotEmpty) ...[
              if (breakdownFees.isNotEmpty &&
                  breakdownDiscounts.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context,
                            Icons.receipt_long_outlined,
                            'Fees',
                            '',
                          ),
                          const SizedBox(height: 8),
                          ...breakdownFees.map((fee) {
                            final f = fee as Map<String, dynamic>;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 0.5,
                                ),
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
                                          f['description'] ?? 'Fee',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(f['amount']),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.amber[900],
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Type: ${_formatLabel(f['type'] ?? 'Unknown')}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context,
                            Icons.local_offer_outlined,
                            'Discounts',
                            '',
                          ),
                          const SizedBox(height: 8),
                          ...breakdownDiscounts.map((discount) {
                            final d = discount as Map<String, dynamic>;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 0.5,
                                ),
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
                                          d['value'] == 'percentage'
                                              ? '${(d['value'])} off'
                                              : '${_formatCurrency(d['value'])} off',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        '-${_formatCurrency(d['applied_amount'] ?? 0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.red[700],
                                            ),
                                      ),
                                    ],
                                  ),
                                  if (d['reason'] != null) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      _formatLabel(
                                        d['reason'] ?? 'Applied discount',
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else if (breakdownFees.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  Icons.receipt_long_outlined,
                  'Fees',
                  '',
                ),
                const SizedBox(height: 8),
                ...breakdownFees.map((fee) {
                  final f = fee as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.grey[200]!, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f['description'] ?? 'Fee',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Type: ${_formatLabel(f['type'] ?? 'Unknown')}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(f['amount']),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.amber[900],
                              ),
                        ),
                      ],
                    ),
                  );
                }),
              ] else if (breakdownDiscounts.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  Icons.local_offer_outlined,
                  'Discounts Applied',
                  '',
                ),
                const SizedBox(height: 8),
                ...breakdownDiscounts.map((discount) {
                  final d = discount as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.grey[200]!, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['value'] == 'percentage'
                                    ? '${(d['value'])} off'
                                    : '${_formatCurrency(d['value'])} off',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                              ),
                              if (d['reason'] != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  _formatLabel(d['reason']),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '-${_formatCurrency(d['applied_amount'] ?? 0)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.red[700],
                              ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
            ],

            // 💰 Order Summary Section
            _buildSectionHeader(
              context,
              Icons.receipt_long_outlined,
              'Summary',
              '',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.grey[200]!, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(
                    context,
                    'Products',
                    _formatCurrency(breakdownSummary['subtotal_products']),
                    isHighlight: false,
                  ),
                  _buildSummaryRow(
                    context,
                    'Services',
                    _formatCurrency(breakdownSummary['subtotal_services']),
                    isHighlight: false,
                  ),
                  if ((breakdownSummary['handling'] ?? 0) > 0)
                    _buildSummaryRow(
                      context,
                      'Handling',
                      _formatCurrency(breakdownSummary['handling']),
                      isHighlight: false,
                    ),
                  if ((breakdownSummary['service_fee'] ?? 0) > 0)
                    _buildSummaryRow(
                      context,
                      'Service Fee',
                      _formatCurrency(breakdownSummary['service_fee']),
                      isHighlight: false,
                    ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 0.8,
                    color: Colors.grey[200],
                  ),
                  _buildSummaryRow(
                    context,
                    'Subtotal',
                    _formatCurrency(
                      (breakdownSummary['subtotal_products'] ?? 0) +
                          (breakdownSummary['subtotal_services'] ?? 0),
                    ),
                    isHighlight: true,
                  ),
                  if ((breakdownSummary['discounts'] ?? 0) > 0)
                    _buildSummaryRow(
                      context,
                      'Discounts',
                      '-${_formatCurrency(breakdownSummary['discounts'])}',
                      isHighlight: true,
                      isNegative: true,
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Colors.grey[200]!, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'VAT (${(breakdownSummary['vat_rate'] ?? 12).toStringAsFixed(0)}%)',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                            ),
                            Text(
                              _formatCurrency(breakdownSummary['vat_amount']),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Inclusive',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey[600], fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 0.8,
                    color: Colors.grey[200],
                  ),
                  _buildSummaryRow(
                    context,
                    'TOTAL',
                    _formatCurrency(breakdownSummary['grand_total']),
                    isHighlight: true,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 💳 Payment Section
            if (breakdownPayment.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                Icons.payment_outlined,
                'Payment',
                '',
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.grey[200]!, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Method',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatLabel(
                              (breakdownPayment['method'] ?? 'Unknown')
                                  .toString(),
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      context,
                      'Paid Amount',
                      _formatCurrency(breakdownPayment['amount_paid']),
                    ),
                    if ((breakdownPayment['change'] ?? 0) > 0)
                      _buildSummaryRow(
                        context,
                        'Change',
                        _formatCurrency(breakdownPayment['change']),
                        isNegative: true,
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                breakdownPayment['payment_status'],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatLabel(
                                (breakdownPayment['payment_status'] ?? 'N/A')
                                    .toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (breakdownPayment['reference_number'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              size: 15,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ref #',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                  ),
                                  Text(
                                    breakdownPayment['reference_number'] ?? '',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 📍 Handling Section - Multi-column
            if (pickupData.isNotEmpty || deliveryData.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                Icons.local_shipping_outlined,
                'Fulfillment',
                '',
              ),
              const SizedBox(height: 8),
              if (pickupData.isNotEmpty && deliveryData.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildHandlingCard(
                        context,
                        'Pickup',
                        pickupData,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildHandlingCard(
                        context,
                        'Delivery',
                        deliveryData,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                if (pickupData.isNotEmpty)
                  _buildHandlingCard(
                    context,
                    'Pickup',
                    pickupData,
                    Colors.blue,
                  ),
                if (deliveryData.isNotEmpty)
                  _buildHandlingCard(
                    context,
                    'Delivery',
                    deliveryData,
                    Colors.purple,
                  ),
              ],
              const SizedBox(height: 20),
            ],

            // ⛔ Cancellation Section
            if (cancellation != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.grey[200]!, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Colors.red[700],
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Order Cancelled',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reason: ${_formatLabel(cancellation['reason'] ?? 'N/A')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (cancellation['notes'] != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Notes: ${cancellation['notes']}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Refund: ${_formatLabel((cancellation['refund_status'] ?? 'N/A').toString())}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 📝 Audit Log Timeline - Compact
            if (breakdownAuditLog.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                Icons.history_outlined,
                'Activity Timeline',
                '',
              ),
              const SizedBox(height: 8),
              ...breakdownAuditLog.asMap().entries.map((entry) {
                final log = entry.value as Map<String, dynamic>;
                final action = _formatLabel(log['action'] ?? 'Unknown');
                final timestamp = _formatDate(log['timestamp'] ?? '');

                return Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.blue[700],
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 11,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  timestamp,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                            if (log['changed_by'] != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'By: ${log['changed_by']}',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.grey[900],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMetricChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
    String badge,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const Spacer(),
        if (badge.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHandlingCard(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
    MaterialColor color,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[200]!, width: 0.8),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (data['status'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      _formatLabel(data['status'].toString()),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(data['status']),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            if (data['address'] != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.grey[300]!, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                          ),
                          Text(
                            data['address'],
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
            ],
            if (data['notes'] != null &&
                (data['notes'] as String).isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.grey[300]!, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 12,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        data['notes'],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
            ],
            if (data['started_at'] != null || data['completed_at'] != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.grey[300]!, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['started_at'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Started: ${_formatDate(data['started_at'])}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                    if (data['completed_at'] != null)
                      Text(
                        'Completed: ${_formatDate(data['completed_at'])}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(fontSize: 11),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = true,
    bool isNegative = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isTotal || isHighlight
                  ? FontWeight.w700
                  : (isHighlight ? FontWeight.w600 : FontWeight.normal),
              fontSize: isTotal ? 16 : (isHighlight ? 15 : 13),
              color: isHighlight ? Colors.grey[800] : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isTotal
                  ? FontWeight.w800
                  : (isHighlight || isNegative
                        ? FontWeight.w700
                        : FontWeight.w600),
              color: isNegative
                  ? Colors.red[700]
                  : (isTotal
                        ? Colors.green[700]
                        : (isHighlight ? Colors.grey[800] : Colors.grey[700])),
              fontSize: isTotal ? 16 : (isHighlight ? 15 : 13),
            ),
          ),
        ],
      ),
    );
  }
}
