import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String name;
  final int quantity;
  final int price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'price': price,
  };
}

class Order {
  final int id;
  final String user; 
  final int total;
  final String status;
  final List<OrderItem>? items;
  final Timestamp timestamp;
  final String userId;

  Order({
    required this.id,
    required this.user,
    required this.total,
    required this.status,
    this.items,
    required this.timestamp,
    required this.userId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem>? itemsList;
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['order_id'],
      user: json['user_id'], 
      total: json['total'],
      status: json['status'],
      items: itemsList,
      timestamp: json['timestamp'] ?? Timestamp.now(),
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'order_id': id,
    'user_id': user, 
    'total': total,
    'status': status,
    'items': items?.map((item) => item.toJson()).toList(),
  };
}