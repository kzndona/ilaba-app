/// Order Models for Mobile Booking Flow
/// Adapted from POS system with mobile-specific customizations
///
/// Key design decisions:
/// - Per-ORDER staff service fee (₱40 flat)
/// - Services are toggles (no weight multipliers, except iron)
/// - VAT 12% inclusive
/// - Automatic basket creation when weight > 8kg
/// - GCash receipt upload is REQUIRED before submission
/// - Time slot: 11am-3pm only
/// - Delivery address required for delivery handling

// ============================================================================
// ENUMS & CONSTANTS
// ============================================================================

enum PaymentMethod { cash, gcash }

enum HandlingType { pickup, delivery }

enum LoyaltyTier { tier1, tier2 }

enum TimeSlot {
  slot11to12, // 11:00 AM - 12:00 PM
  slot12to1, // 12:00 PM - 1:00 PM
  slot1to2, // 1:00 PM - 2:00 PM
  slot2to3, // 2:00 PM - 3:00 PM
}

extension TimeSlotExtension on TimeSlot {
  String get label {
    switch (this) {
      case TimeSlot.slot11to12:
        return '11:00 AM - 12:00 PM';
      case TimeSlot.slot12to1:
        return '12:00 PM - 1:00 PM';
      case TimeSlot.slot1to2:
        return '1:00 PM - 2:00 PM';
      case TimeSlot.slot2to3:
        return '2:00 PM - 3:00 PM';
    }
  }

  String get startTime {
    switch (this) {
      case TimeSlot.slot11to12:
        return '11:00';
      case TimeSlot.slot12to1:
        return '12:00';
      case TimeSlot.slot1to2:
        return '13:00';
      case TimeSlot.slot2to3:
        return '14:00';
    }
  }
}

// ============================================================================
// BASKET & SERVICES
// ============================================================================

/// Services configuration per basket
/// All services are toggles (on/off) except iron which has weight
class BasketServices {
  final String wash; // "off" | "basic" | "premium"
  final String dry; // "off" | "basic" | "premium"
  final bool spin; // true = on, false = off
  final int ironWeightKg; // 0 (off) | 2-8kg
  final bool fold; // true = on, false = off
  final int additionalDryMinutes; // 0+ minutes in 8-minute increments
  final int plasticBags; // quantity

  BasketServices({
    this.wash = 'off',
    this.dry = 'off',
    this.spin = false,
    this.ironWeightKg = 0,
    this.fold = false,
    this.additionalDryMinutes = 0,
    this.plasticBags = 0,
  });

  BasketServices copyWith({
    String? wash,
    String? dry,
    bool? spin,
    int? ironWeightKg,
    bool? fold,
    int? additionalDryMinutes,
    int? plasticBags,
  }) {
    return BasketServices(
      wash: wash ?? this.wash,
      dry: dry ?? this.dry,
      spin: spin ?? this.spin,
      ironWeightKg: ironWeightKg ?? this.ironWeightKg,
      fold: fold ?? this.fold,
      additionalDryMinutes: additionalDryMinutes ?? this.additionalDryMinutes,
      plasticBags: plasticBags ?? this.plasticBags,
    );
  }

  Map<String, dynamic> toJson() => {
    'wash': wash,
    'dry': dry,
    'spin': spin,
    'iron_weight_kg': ironWeightKg,
    'fold': fold,
    'additional_dry_minutes': additionalDryMinutes,
    'plastic_bags': plasticBags,
  };

  factory BasketServices.fromJson(Map<String, dynamic> json) {
    return BasketServices(
      wash: json['wash'] as String? ?? 'off',
      dry: json['dry'] as String? ?? 'off',
      spin: json['spin'] as bool? ?? false,
      ironWeightKg: json['iron_weight_kg'] as int? ?? 0,
      fold: json['fold'] as bool? ?? false,
      additionalDryMinutes: json['additional_dry_minutes'] as int? ?? 0,
      plasticBags: json['plastic_bags'] as int? ?? 0,
    );
  }
}

/// Single laundry basket with services
class Basket {
  final int basketNumber; // 1, 2, 3...
  final double weightKg; // 0-8kg per basket
  final BasketServices services;
  final String notes; // Per-basket laundry notes
  double subtotal = 0; // Calculated price

  Basket({
    required this.basketNumber,
    required this.weightKg,
    required this.services,
    this.notes = '',
  });

  Basket copyWith({
    int? basketNumber,
    double? weightKg,
    BasketServices? services,
    String? notes,
    double? subtotal,
  }) {
    final newBasket = Basket(
      basketNumber: basketNumber ?? this.basketNumber,
      weightKg: weightKg ?? this.weightKg,
      services: services ?? this.services,
      notes: notes ?? this.notes,
    );
    newBasket.subtotal = subtotal ?? this.subtotal;
    return newBasket;
  }

  Map<String, dynamic> toJson() => {
    'basket_number': basketNumber,
    'weight_kg': weightKg,
    'services': services.toJson(),
    'notes': notes,
    'subtotal': subtotal,
  };

  factory Basket.fromJson(Map<String, dynamic> json) {
    final basket = Basket(
      basketNumber: json['basket_number'] as int,
      weightKg: (json['weight_kg'] as num).toDouble(),
      services: BasketServices.fromJson(
        json['services'] as Map<String, dynamic>? ?? {},
      ),
      notes: json['notes'] as String? ?? '',
    );
    basket.subtotal = (json['subtotal'] as num?)?.toDouble() ?? 0;
    return basket;
  }
}

// ============================================================================
// PRODUCTS
// ============================================================================

/// Product for ordering
class Product {
  final String id;
  final String itemName;
  final double unitPrice;
  final int quantityInStock;
  final String? imageUrl;

  Product({
    required this.id,
    required this.itemName,
    required this.unitPrice,
    required this.quantityInStock,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'item_name': itemName,
    'unit_price': unitPrice,
    'quantity_in_stock': quantityInStock,
    'image_url': imageUrl,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      itemName: json['item_name'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantityInStock: ((json['quantity'] as num?) ?? 0).toInt(),
      imageUrl: json['image_url'] as String?,
    );
  }
}

/// Item in order (product with quantity)
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'unit_price': unitPrice,
    'subtotal': totalPrice,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
    );
  }
}

// ============================================================================
// SERVICES
// ============================================================================

/// Service definition from database
class Service {
  final String id;
  final String serviceType; // "wash" | "dry" | "spin" | "iron" | "fold"
  final String name;
  final String? tier; // "basic" | "premium" (for wash/dry only)
  final double basePrice;
  final String? description; // Service description for customers
  final int? baseDurationMinutes;
  final bool isActive;

  Service({
    required this.id,
    required this.serviceType,
    required this.name,
    this.tier,
    required this.basePrice,
    this.description,
    this.baseDurationMinutes,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'service_type': serviceType,
    'name': name,
    'tier': tier,
    'base_price': basePrice,
    'description': description,
    'base_duration_minutes': baseDurationMinutes,
    'is_active': isActive,
  };

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      serviceType: json['service_type'] as String,
      name: json['name'] as String,
      tier: json['tier'] as String?,
      basePrice: (json['base_price'] as num).toDouble(),
      description: json['description'] as String?,
      baseDurationMinutes: json['base_duration_minutes'] as int?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

// ============================================================================
// FEES
// ============================================================================

/// Single fee item
class Fee {
  final String type; // "staff_service_fee" | "delivery_fee" | "vat"
  final double amount;
  final String description;

  Fee({required this.type, required this.amount, required this.description});

  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'description': description,
  };

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
    );
  }
}

// ============================================================================
// ORDER BREAKDOWN
// ============================================================================

/// Complete order breakdown (JSONB in database)
class OrderSummary {
  final double subtotalProducts; // Sum of all product line totals
  final double subtotalBaskets; // Sum of all basket subtotals
  final double staffServiceFee; // ₱40 if any basket has services
  final double deliveryFee; // 0 if pickup, ₱50+ if delivery
  final double subtotalBeforeVat; // products + baskets + staff fee + delivery
  final double vatAmount; // 12% inclusive
  final double loyaltyDiscount; // Amount deducted from total
  final double total; // Final amount to pay

  OrderSummary({
    this.subtotalProducts = 0,
    this.subtotalBaskets = 0,
    this.staffServiceFee = 0,
    this.deliveryFee = 0,
    this.subtotalBeforeVat = 0,
    this.vatAmount = 0,
    this.loyaltyDiscount = 0,
    this.total = 0,
  });

  Map<String, dynamic> toJson() => {
    'subtotal_products': subtotalProducts,
    'subtotal_baskets': subtotalBaskets,
    'staff_service_fee': staffServiceFee,
    'delivery_fee': deliveryFee,
    'subtotal_before_vat': subtotalBeforeVat,
    'vat_amount': vatAmount,
    'loyalty_discount': loyaltyDiscount,
    'total': total,
  };

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      subtotalProducts: (json['subtotal_products'] as num?)?.toDouble() ?? 0,
      subtotalBaskets: (json['subtotal_baskets'] as num?)?.toDouble() ?? 0,
      staffServiceFee: (json['staff_service_fee'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      subtotalBeforeVat: (json['subtotal_before_vat'] as num?)?.toDouble() ?? 0,
      vatAmount: (json['vat_amount'] as num?)?.toDouble() ?? 0,
      loyaltyDiscount: (json['loyalty_discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Complete breakdown with items, baskets, and summary
class OrderBreakdown {
  final List<OrderItem> items;
  final List<Basket> baskets;
  final List<Fee> fees;
  final OrderSummary summary;

  OrderBreakdown({
    this.items = const [],
    this.baskets = const [],
    this.fees = const [],
    required this.summary,
  });

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'baskets': baskets.map((e) => e.toJson()).toList(),
    'fees': fees.map((e) => e.toJson()).toList(),
    'summary': summary.toJson(),
  };

  factory OrderBreakdown.fromJson(Map<String, dynamic> json) {
    return OrderBreakdown(
      items:
          (json['items'] as List?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      baskets:
          (json['baskets'] as List?)
              ?.map((e) => Basket.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      fees:
          (json['fees'] as List?)
              ?.map((e) => Fee.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: OrderSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

// ============================================================================
// ORDER HANDLING
// ============================================================================

/// Handling configuration (pickup/delivery, payment, etc.)
class OrderHandling {
  final HandlingType handlingType; // pickup or delivery
  final String? pickupAddress; // Pickup address
  final String? deliveryAddress; // Required if delivery
  final TimeSlot? timeSlot; // 11am-3pm slots
  final String specialInstructions;
  final PaymentMethod paymentMethod;
  final double amountPaid; // For cash
  final String? gcashReference; // For GCash
  final String? gcashReceiptPath; // Path to receipt in Supabase bucket
  final bool deliveryReminderAcknowledged; // Must be true for delivery

  OrderHandling({
    required this.handlingType,
    this.pickupAddress,
    this.deliveryAddress,
    this.timeSlot,
    this.specialInstructions = '',
    required this.paymentMethod,
    required this.amountPaid,
    this.gcashReference,
    this.gcashReceiptPath,
    this.deliveryReminderAcknowledged = false,
  });

  OrderHandling copyWith({
    HandlingType? handlingType,
    String? pickupAddress,
    String? deliveryAddress,
    TimeSlot? timeSlot,
    String? specialInstructions,
    PaymentMethod? paymentMethod,
    double? amountPaid,
    String? gcashReference,
    String? gcashReceiptPath,
    bool? deliveryReminderAcknowledged,
  }) {
    return OrderHandling(
      handlingType: handlingType ?? this.handlingType,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      timeSlot: timeSlot ?? this.timeSlot,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      gcashReference: gcashReference ?? this.gcashReference,
      gcashReceiptPath: gcashReceiptPath ?? this.gcashReceiptPath,
      deliveryReminderAcknowledged: deliveryReminderAcknowledged ?? this.deliveryReminderAcknowledged,
    );
  }

  Map<String, dynamic> toJson() => {
    'pickup_address': pickupAddress ?? '',
    'delivery_address': deliveryAddress ?? '',
    'time_slot': timeSlot?.label,
    'special_instructions': specialInstructions,
    'payment_method': paymentMethod == PaymentMethod.cash ? 'cash' : 'gcash',
    'amount_paid': amountPaid,
    'gcash_reference': gcashReference,
    'delivery_reminder_acknowledged': deliveryReminderAcknowledged,
  };

  factory OrderHandling.fromJson(Map<String, dynamic> json) {
    return OrderHandling(
      handlingType: json['handling_type'] == 'delivery'
          ? HandlingType.delivery
          : HandlingType.pickup,
      pickupAddress: json['pickup_address'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      timeSlot: json['time_slot'] != null
          ? _parseTimeSlot(json['time_slot'] as String)
          : null,
      specialInstructions: json['special_instructions'] as String? ?? '',
      paymentMethod: json['payment_method'] == 'gcash'
          ? PaymentMethod.gcash
          : PaymentMethod.cash,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      gcashReference: json['gcash_reference'] as String?,
      gcashReceiptPath: json['gcash_receipt_path'] as String?,
    );
  }
}

TimeSlot? _parseTimeSlot(String label) {
  switch (label) {
    case '11:00 AM - 12:00 PM':
      return TimeSlot.slot11to12;
    case '12:00 PM - 1:00 PM':
      return TimeSlot.slot12to1;
    case '1:00 PM - 2:00 PM':
      return TimeSlot.slot1to2;
    case '2:00 PM - 3:00 PM':
      return TimeSlot.slot2to3;
    default:
      return null;
  }
}

// ============================================================================
// LOYALTY
// ============================================================================

/// Loyalty discount information
class LoyaltyDiscount {
  final LoyaltyTier? tier; // tier1 (5%) or tier2 (15%)
  final int pointsUsed;
  final double discountAmount;

  LoyaltyDiscount({this.tier, this.pointsUsed = 0, this.discountAmount = 0});

  double get discountPercent {
    if (tier == LoyaltyTier.tier1) return 0.05;
    if (tier == LoyaltyTier.tier2) return 0.15;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'discount_tier': tier?.toString().split('.').last,
    'points_used': pointsUsed,
    'discount_amount': discountAmount,
  };

  factory LoyaltyDiscount.fromJson(Map<String, dynamic> json) {
    LoyaltyTier? tier;
    final tierStr = json['discount_tier'] as String?;
    if (tierStr == 'tier1') {
      tier = LoyaltyTier.tier1;
    } else if (tierStr == 'tier2') {
      tier = LoyaltyTier.tier2;
    }

    return LoyaltyDiscount(
      tier: tier,
      pointsUsed: json['points_used'] as int? ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ============================================================================
// COMPLETE ORDER PAYLOAD (for API)
// ============================================================================

/// Complete booking order for API submission
class BookingOrder {
  final String? customerId;
  final CustomerData? customerData;
  final OrderBreakdown breakdown;
  final OrderHandling handling;
  final LoyaltyDiscount? loyalty;

  BookingOrder({
    this.customerId,
    this.customerData,
    required this.breakdown,
    required this.handling,
    this.loyalty,
  });

  Map<String, dynamic> toJson() => {
    if (customerId != null) 'customer_id': customerId,
    if (customerData != null) 'customer_data': customerData!.toJson(),
    'breakdown': breakdown.toJson(),
    'handling': handling.toJson(),
    if (handling.gcashReceiptPath != null) 'gcash_receipt_url': handling.gcashReceiptPath,
    if (loyalty != null) 'loyalty': loyalty!.toJson(),
  };

  factory BookingOrder.fromJson(Map<String, dynamic> json) {
    return BookingOrder(
      customerId: json['customer_id'] as String?,
      customerData: json['customer_data'] != null
          ? CustomerData.fromJson(json['customer_data'] as Map<String, dynamic>)
          : null,
      breakdown: OrderBreakdown.fromJson(
        json['breakdown'] as Map<String, dynamic>,
      ),
      handling: OrderHandling.fromJson(
        json['handling'] as Map<String, dynamic>,
      ),
      loyalty: json['loyalty'] != null
          ? LoyaltyDiscount.fromJson(json['loyalty'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Customer data for order
class CustomerData {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;

  CustomerData({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'email': email,
  };

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
    );
  }
}

// ============================================================================
// API RESPONSE
// ============================================================================

/// Response from order creation API
class OrderResponse {
  final bool success;
  final String? orderId;
  final OrderReceipt? receipt;
  final String? error;

  OrderResponse({
    required this.success,
    this.orderId,
    this.receipt,
    this.error,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      success: json['success'] as bool,
      orderId: json['order_id'] as String?,
      receipt: json['receipt'] != null
          ? OrderReceipt.fromJson(json['receipt'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
    );
  }
}

/// Receipt details returned from API
class OrderReceipt {
  final String orderId;
  final String customerName;
  final List<OrderItem> items;
  final List<Basket> baskets;
  final double total;
  final String paymentMethod;
  final double? change;
  final LoyaltyDiscount? loyalty;
  final int? finalLoyaltyPoints;

  OrderReceipt({
    required this.orderId,
    required this.customerName,
    required this.items,
    required this.baskets,
    required this.total,
    required this.paymentMethod,
    this.change,
    this.loyalty,
    this.finalLoyaltyPoints,
  });

  factory OrderReceipt.fromJson(Map<String, dynamic> json) {
    return OrderReceipt(
      orderId: json['order_id'] as String,
      customerName: json['customer_name'] as String,
      items:
          (json['items'] as List?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      baskets:
          (json['baskets'] as List?)
              ?.map((e) => Basket.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      change: (json['change'] as num?)?.toDouble(),
      loyalty: json['loyalty'] != null
          ? LoyaltyDiscount.fromJson(json['loyalty'] as Map<String, dynamic>)
          : null,
      finalLoyaltyPoints: json['final_loyalty_points'] as int?,
    );
  }
}
