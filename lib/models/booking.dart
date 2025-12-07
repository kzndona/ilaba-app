class BookingService {
  final String name;
  final int quantity;
  final bool isPremium;

  BookingService({
    required this.name,
    required this.quantity,
    required this.isPremium,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) {
    return BookingService(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      isPremium: json['is_premium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'is_premium': isPremium,
    };
  }
}

class Booking {
  final String id;
  final String userId;
  final String status; // pending, confirmed, in_progress, completed, cancelled
  final int weightKg;
  final List<BookingService> services;
  final List<String> addOns; // fold, iron, eco_bag, etc.
  final String pickupAddress;
  final String? deliveryAddress;
  final DateTime pickupDate;
  final DateTime? deliveryDate;
  final double totalPrice;
  final String paymentMethod; // cash, card, online
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.status,
    required this.weightKg,
    required this.services,
    required this.addOns,
    required this.pickupAddress,
    this.deliveryAddress,
    required this.pickupDate,
    this.deliveryDate,
    required this.totalPrice,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.completedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      weightKg: json['weight_kg'] as int,
      services: (json['services'] as List<dynamic>)
          .map((s) => BookingService.fromJson(s as Map<String, dynamic>))
          .toList(),
      addOns: List<String>.from(json['add_ons'] as List<dynamic>? ?? []),
      pickupAddress: json['pickup_address'] as String,
      deliveryAddress: json['delivery_address'] as String?,
      pickupDate: DateTime.parse(json['pickup_date'] as String),
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'] as String)
          : null,
      totalPrice: (json['total_price'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'weight_kg': weightKg,
      'services': services.map((s) => s.toJson()).toList(),
      'add_ons': addOns,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'pickup_date': pickupDate.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? status,
    int? weightKg,
    List<BookingService>? services,
    List<String>? addOns,
    String? pickupAddress,
    String? deliveryAddress,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    double? totalPrice,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      weightKg: weightKg ?? this.weightKg,
      services: services ?? this.services,
      addOns: addOns ?? this.addOns,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
