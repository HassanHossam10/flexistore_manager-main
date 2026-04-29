import '../models/product.dart';

class InventoryFFI {
  static final InventoryFFI instance = InventoryFFI._internal();
  InventoryFFI._internal();

  // In-memory mutable list for logical UI testing on Web
  final List<Product> _products = [
    Product(id: 1, name: 'Samsung Galaxy S24', sku: 'SAM-GS24-128', category: 'Electronics', stock: 45, price: 999.99, trend: 1),
    Product(id: 2, name: 'Wireless Earbuds Pro', sku: 'AUD-WEP-001', category: 'Audio', stock: 3, price: 159.99, trend: -1),
    Product(id: 3, name: 'Phone Case Premium', sku: 'ACC-PC-001', category: 'Accessories', stock: 120, price: 29.99, trend: 0),
    Product(id: 4, name: 'Laptop Stand Aluminum', sku: 'ACC-LS-ALU', category: 'Accessories', stock: 28, price: 89.99, trend: 1),
    Product(id: 5, name: 'Mechanical Keyboard RGB', sku: 'PER-KB-RGB', category: 'Peripherals', stock: 8, price: 129.99, trend: -1),
  ];

  int _nextId = 6;

  Future<InventoryStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    int lowStock = 0;
    double totalVal = 0.0;
    
    for (var p in _products) {
      if (p.stock <= 10) lowStock++;
      totalVal += (p.stock * p.price);
    }

    return InventoryStats(
      totalProducts: _products.length,
      lowStockItems: lowStock,
      totalValue: totalVal,
    );
  }

  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return a copy of the list so it doesn't get mutated accidentally from the outside
    return List.from(_products);
  }

  Future<bool> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newProduct = product.copyWith(id: _nextId++);
    _products.add(newProduct);
    return true;
  }

  Future<bool> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      return true;
    }
    return false;
  }

  Future<bool> deleteProduct(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final initialLength = _products.length;
    _products.removeWhere((p) => p.id == id);
    return _products.length < initialLength;
  }
}
