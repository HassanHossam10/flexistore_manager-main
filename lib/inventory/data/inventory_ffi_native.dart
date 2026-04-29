import 'dart:ffi';
import 'dart:convert';
import 'package:ffi/ffi.dart';
import '../../core/native_bridge_native.dart';
import '../../core/ffi_helpers_native.dart';
import '../models/product.dart';

typedef _GetInventoryStatsC = Pointer<Utf8> Function();
typedef _GetInventoryStatsDart = Pointer<Utf8> Function();

typedef _GetProductsC = Pointer<Utf8> Function();
typedef _GetProductsDart = Pointer<Utf8> Function();

class InventoryFFI {
  static final InventoryFFI instance = InventoryFFI._internal();

  late final _GetInventoryStatsDart _getStatsNative;
  late final _GetProductsDart _getProductsNative;
  bool _isInitialized = false;

  InventoryFFI._internal() {
    _bindFunctions();
  }

  void _bindFunctions() {
    try {
      final lib = NativeBridge().lib;
      _getStatsNative = lib.lookupFunction<_GetInventoryStatsC, _GetInventoryStatsDart>('get_inventory_stats');
      _getProductsNative = lib.lookupFunction<_GetProductsC, _GetProductsDart>('get_products');
      _isInitialized = true;
    } catch (e) {
      print('Inventory FFI Bind Error: $e');
    }
  }

  Future<InventoryStats> getStats() async {
    if (!_isInitialized) return InventoryStats(totalProducts: 0, lowStockItems: 0, totalValue: 0);
    try {
      final ptr = _getStatsNative();
      final jsonStr = parseJsonAndFree(ptr);
      final map = jsonDecode(jsonStr);
      return InventoryStats.fromJson(map);
    } catch (e) {
      print('Error parsing inventory stats: $e');
      return InventoryStats(totalProducts: 0, lowStockItems: 0, totalValue: 0);
    }
  }

  Future<List<Product>> getProducts() async {
    if (!_isInitialized) return [];
    try {
      final ptr = _getProductsNative();
      final jsonStr = parseJsonAndFree(ptr);
      final List list = jsonDecode(jsonStr);
      return list.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      print('Error parsing products: $e');
      return [];
    }
  }

  // Placeholder methods for native FFI until C++ backend implements them
  Future<bool> addProduct(Product product) async {
    print('[NATIVE STUB] addProduct called for ${product.name}');
    return true;
  }

  Future<bool> updateProduct(Product product) async {
    print('[NATIVE STUB] updateProduct called for ${product.name}');
    return true;
  }

  Future<bool> deleteProduct(int id) async {
    print('[NATIVE STUB] deleteProduct called for id $id');
    return true;
  }
}
