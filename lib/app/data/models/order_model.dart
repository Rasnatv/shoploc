import 'address_model.dart';
import 'order_item_model.dart';

class OrderTrackingStep {
  final String title;
  final String subtitle;
  final String timestamp;
  final bool isCompleted;
  final bool isCurrent;

  const OrderTrackingStep({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isCompleted,
    this.isCurrent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp,
      'isCompleted': isCompleted,
      'isCurrent': isCurrent,
    };
  }

  factory OrderTrackingStep.fromMap(Map<String, dynamic> map) {
    return OrderTrackingStep(
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      timestamp: map['timestamp']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
      isCurrent: map['isCurrent'] == true,
    );
  }
}

class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final AddressModel shippingAddress;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double couponDiscount;
  final String? couponCode;
  final double totalAmount;
  final String paymentMethod;
  final String status; // 'Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'
  final DateTime createdAt;
  final List<OrderTrackingStep> trackingSteps;

  const OrderModel({
    required this.id,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.couponDiscount,
    this.couponCode,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.trackingSteps,
  });

  OrderModel copyWith({
    String? id,
    List<OrderItemModel>? items,
    AddressModel? shippingAddress,
    double? subtotal,
    double? discount,
    double? deliveryFee,
    double? couponDiscount,
    String? couponCode,
    double? totalAmount,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
    List<OrderTrackingStep>? trackingSteps,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      couponCode: couponCode ?? this.couponCode,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      trackingSteps: trackingSteps ?? this.trackingSteps,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((x) => x.toMap()).toList(),
      'shippingAddress': shippingAddress.toMap(),
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'couponDiscount': couponDiscount,
      'couponCode': couponCode,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'trackingSteps': trackingSteps.map((x) => x.toMap()).toList(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString() ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((x) => OrderItemModel.fromMap(Map<String, dynamic>.from(x as Map)))
              .toList() ??
          [],
      shippingAddress: AddressModel.fromMap(
          Map<String, dynamic>.from(map['shippingAddress'] as Map)),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      couponDiscount: (map['couponDiscount'] as num?)?.toDouble() ?? 0.0,
      couponCode: map['couponCode']?.toString(),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod']?.toString() ?? 'Cash on Delivery',
      status: map['status']?.toString() ?? 'Pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      trackingSteps: (map['trackingSteps'] as List<dynamic>?)
              ?.map((x) => OrderTrackingStep.fromMap(Map<String, dynamic>.from(x as Map)))
              .toList() ??
          [],
    );
  }
}

