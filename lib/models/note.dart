class Tovar {
  final int id; 
  final String name;
  final String url;
  final int price;
  final String description;

  Tovar({
    required this.id,
    required this.name,
    required this.url,
    required this.price,
    required this.description,
  });

  factory Tovar.fromJson(Map<String, dynamic> json) {
  return Tovar(
    id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : json['id'] as int, 
    name: json['name']?.toString() ?? '',
    url: json['url']?.toString() ?? '',
    price: (json['price'] is String) ? int.tryParse(json['price']) ?? 0 : (json['price'] as int? ?? 0),
    description: json['description']?.toString() ?? '',
  );
}

  Map<String, dynamic> toJson() => {
        'id': id, 
        'name': name,
        'url': url,
        'price': price,
        'description': description,
      };

  // Добавляем метод copyWith
  Tovar copyWith({
    int? id,
    String? name,
    String? url,
    int? price,
    String? description,
  }) {
    return Tovar(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      price: price ?? this.price,
      description: description ?? this.description,
    );
  }
}