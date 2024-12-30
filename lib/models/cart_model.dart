class CartModel {
  final int id; 
  final String url;
  final int price;
  final int count;

  CartModel({
    required this.id,
    required this.url,
    required this.price,
    required this.count,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? 0,
      url: json['image_url'] ?? '',
      price: json['price'] ?? 0,
      count: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': url,
      'price': price,
      'quantity': count,
    };
  }
}