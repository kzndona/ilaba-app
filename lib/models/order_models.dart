/// Web API compatible order models
/// Matches the backend order structure for /api/orders/transactional-create
library;

// ============================================================================
// BREAKDOWN MODELS
// ============================================================================

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double unitCost;
  final double subtotal;
  final Map<String, dynamic> discount;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost,
    required this.subtotal,
    this.discount = const {'amount': 0, 'reason': null},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'unit_cost': unitCost,
      'subtotal': subtotal,
      'discount': discount,
    };
  }
}

class OrderService {
  final String id;
  final String serviceId;
  final String serviceName;
  final bool isPremium;
  final int multiplier;
  final double ratePerKg;
  final double subtotal;
  final String status;
  final String? startedAt;
  final String? completedAt;
  final String? completedBy;
  final int? durationInMinutes;

  OrderService({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.isPremium,
    required this.multiplier,
    required this.ratePerKg,
    required this.subtotal,
    this.status = 'pending',
    this.startedAt,
    this.completedAt,
    this.completedBy,
    this.durationInMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'service_name': serviceName,
      'is_premium': isPremium,
      'multiplier': multiplier,
      'rate_per_kg': ratePerKg,
      'subtotal': subtotal,
      'status': status,
      'started_at': startedAt,
      'completed_at': completedAt,
      'completed_by': completedBy,
      'duration_in_minutes': durationInMinutes,
    };
  }
}

class OrderBasket {
  final int basketNumber;
  final double weight;
  final String? basketNotes;
  final List<OrderService> services;
  final double total;

  OrderBasket({
    required this.basketNumber,
    required this.weight,
    required this.services,
    required this.total,
    this.basketNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'basket_number': basketNumber,
      'weight': weight,
      'basket_notes': basketNotes,
      'services': services.map((s) => s.toJson()).toList(),
      'total': total,
    };
  }
}

class OrderFee {
  final String id;
  final String type;
  final String description;
  final double amount;

  OrderFee({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'amount': amount,
    };
  }
}

class PaymentTotals {
  final double productSubtotal;
  final double basketSubtotal;
  final double serviceFee;
  final double handlingFee;
  final double taxRate;
  final double taxIncluded;
  final double total;

  PaymentTotals({
    required this.productSubtotal,
    required this.basketSubtotal,
    required this.serviceFee,
    required this.handlingFee,
    required this.taxRate,
    required this.taxIncluded,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_subtotal': productSubtotal,
      'basket_subtotal': basketSubtotal,
      'service_fee': serviceFee,
      'handling_fee': handlingFee,
      'tax_rate': taxRate,
      'tax_included': taxIncluded,
      'total': total,
    };
  }
}

class GCashReceipt {
  final String? screenshotUrl;
  final String? transactionId;
  final bool verified;

  GCashReceipt({this.screenshotUrl, this.transactionId, this.verified = false});

  Map<String, dynamic> toJson() {
    return {
      'screenshot_url': screenshotUrl,
      'transaction_id': transactionId,
      'verified': verified,
    };
  }
}

class OrderPayment {
  final String method;
  final String paymentStatus;
  final double amountPaid;
  final double changeAmount;
  final String? completedAt;
  final GCashReceipt gcashReceipt;

  OrderPayment({
    required this.method,
    required this.paymentStatus,
    required this.amountPaid,
    this.changeAmount = 0,
    this.completedAt,
    required this.gcashReceipt,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'payment_status': paymentStatus,
      'amount_paid': amountPaid,
      'change_amount': changeAmount,
      'completed_at': completedAt,
      'gcash_receipt': gcashReceipt.toJson(),
    };
  }
}

class AuditLogEntry {
  final String timestamp;
  final String? changedBy;
  final String action;
  final Map<String, dynamic> details;

  AuditLogEntry({
    required this.timestamp,
    this.changedBy,
    required this.action,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'changed_by': changedBy,
      'action': action,
      'details': details,
    };
  }
}

class OrderBreakdown {
  final List<OrderItem> items;
  final List<OrderBasket> baskets;
  final List<OrderFee> fees;
  final PaymentTotals totals;
  final OrderPayment payment;
  final List<AuditLogEntry> auditLog;

  OrderBreakdown({
    required this.items,
    required this.baskets,
    required this.fees,
    required this.totals,
    required this.payment,
    required this.auditLog,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'baskets': baskets.map((b) => b.toJson()).toList(),
      'fees': fees.map((f) => f.toJson()).toList(),
      'totals': totals.toJson(),
      'payment': payment.toJson(),
      'audit_log': auditLog.map((a) => a.toJson()).toList(),
    };
  }
}

// ============================================================================
// HANDLING MODELS
// ============================================================================

class HandlingLocation {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final String status;
  final String? startedAt;
  final String? completedAt;
  final String? completedBy;
  final int? durationInMinutes;

  HandlingLocation({
    this.address,
    this.latitude,
    this.longitude,
    this.notes,
    this.status = 'pending',
    this.startedAt,
    this.completedAt,
    this.completedBy,
    this.durationInMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'status': status,
      'started_at': startedAt,
      'completed_at': completedAt,
      'completed_by': completedBy,
      'duration_in_minutes': durationInMinutes,
    };
  }
}

class OrderHandling {
  final HandlingLocation pickup;
  final HandlingLocation delivery;

  OrderHandling({required this.pickup, required this.delivery});

  Map<String, dynamic> toJson() {
    return {'pickup': pickup.toJson(), 'delivery': delivery.toJson()};
  }
}

// ============================================================================
// ORDER PAYLOAD MODELS
// ============================================================================

class CustomerData {
  final String id;
  final String phoneNumber;
  final String emailAddress;

  CustomerData({
    required this.id,
    required this.phoneNumber,
    required this.emailAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'email_address': emailAddress,
    };
  }
}

class CreateOrderPayload {
  final String source;
  final String customerId;
  final String? cashierId;
  final String status;
  final double totalAmount;
  final String? orderNote;
  final OrderBreakdown breakdown;
  final OrderHandling handling;

  CreateOrderPayload({
    required this.source,
    required this.customerId,
    required this.breakdown,
    required this.handling,
    required this.totalAmount,
    this.cashierId,
    this.status = 'pending',
    this.orderNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'customer_id': customerId,
      'cashier_id': cashierId,
      'status': status,
      'total_amount': totalAmount,
      'order_note': orderNote,
      'breakdown': breakdown.toJson(),
      'handling': handling.toJson(),
    };
  }
}

class CreateOrderRequest {
  final CustomerData customer;
  final CreateOrderPayload orderPayload;

  CreateOrderRequest({required this.customer, required this.orderPayload});

  Map<String, dynamic> toJson() {
    return {
      'customer': customer.toJson(),
      'orderPayload': orderPayload.toJson(),
    };
  }
}

class CreateOrderResponse {
  final bool success;
  final String orderId;
  final Map<String, dynamic>? order;
  final String? error;
  final List<Map<String, dynamic>>? insufficientItems;

  CreateOrderResponse({
    required this.success,
    required this.orderId,
    this.order,
    this.error,
    this.insufficientItems,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      success: json['success'] as bool,
      orderId: json['orderId'] as String? ?? '',
      order: json['order'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      insufficientItems: (json['insufficientItems'] as List?)
          ?.cast<Map<String, dynamic>>(),
    );
  }
}
