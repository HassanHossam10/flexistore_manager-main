class InventoryStats {
  final int totalProducts;
  final int lowStockItems;
  final double totalValue;

  InventoryStats({
    required this.totalProducts,
    required this.lowStockItems,
    required this.totalValue,
  });

  factory InventoryStats.fromJson(Map<String, dynamic> json) {
    return InventoryStats(
      totalProducts: json['total_products'] ?? 0,
      lowStockItems: json['low_stock_items'] ?? 0,
      totalValue: (json['total_value'] ?? 0).toDouble(),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String sku;
  final String category;
  final int stock;
  final double price;
  final int trend; // 1 for up, -1 for down, 0 for neutral

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.stock,
    required this.price,
    required this.trend,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      trend: json['trend'] ?? 0,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? sku,
    String? category,
    int? stock,
    double? price,
    int? trend,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      trend: trend ?? this.trend,
    );
  }
}
