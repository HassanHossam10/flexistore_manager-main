import 'package:flutter/material.dart';
import '../data/inventory_ffi.dart';
import '../models/product.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<InventoryStats> _statsFuture;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _statsFuture = InventoryFFI.instance.getStats();
      _productsFuture = InventoryFFI.instance.getProducts();
    });
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Product', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${product.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await InventoryFFI.instance.deleteProduct(product.id);
              _refreshData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProductFormDialog([Product? product]) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    final categoryCtrl = TextEditingController(text: product?.category ?? 'Electronics');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toString() ?? '');
    int selectedTrend = product?.trend ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(isEditing ? 'Edit Product' : 'Add Product', style: const TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Product Name', labelStyle: TextStyle(color: Colors.white54)),
                  ),
                  TextField(
                    controller: skuCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'SKU', labelStyle: TextStyle(color: Colors.white54)),
                  ),
                  TextField(
                    controller: categoryCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.white54)),
                  ),
                  TextField(
                    controller: stockCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Stock', labelStyle: TextStyle(color: Colors.white54)),
                  ),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Trend: ', style: TextStyle(color: Colors.white54)),
                      DropdownButton<int>(
                        value: selectedTrend,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Up')),
                          DropdownMenuItem(value: 0, child: Text('Neutral')),
                          DropdownMenuItem(value: -1, child: Text('Down')),
                        ],
                        onChanged: (val) => setDialogState(() => selectedTrend = val ?? 0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newProduct = Product(
                    id: product?.id ?? 0,
                    name: nameCtrl.text.isEmpty ? 'Unknown' : nameCtrl.text,
                    sku: skuCtrl.text.isEmpty ? 'SKU-000' : skuCtrl.text,
                    category: categoryCtrl.text.isEmpty ? 'Other' : categoryCtrl.text,
                    stock: int.tryParse(stockCtrl.text) ?? 0,
                    price: double.tryParse(priceCtrl.text) ?? 0.0,
                    trend: selectedTrend,
                  );

                  Navigator.of(ctx).pop();
                  if (isEditing) {
                    await InventoryFFI.instance.updateProduct(newProduct);
                  } else {
                    await InventoryFFI.instance.addProduct(newProduct);
                  }
                  _refreshData();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7)),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Uses AppShell's background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your products and stock levels',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showProductFormDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7), // Purple
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stat Cards
            FutureBuilder<InventoryStats>(
              future: _statsFuture,
              builder: (context, snapshot) {
                final stats = snapshot.data ?? InventoryStats(totalProducts: 0, lowStockItems: 0, totalValue: 0);
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Products',
                        value: stats.totalProducts.toString(),
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Low Stock Items',
                        value: stats.lowStockItems.toString(),
                        icon: Icons.warning_amber_rounded,
                        iconColor: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Inventory Value',
                        value: '\$${stats.totalValue.toStringAsFixed(2)}',
                        icon: Icons.trending_up,
                        iconColor: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search by product name or SKU...',
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'All Categories',
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                        items: ['All Categories', 'Electronics', 'Audio', 'Accessories', 'Peripherals']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data Table
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              clipBehavior: Clip.antiAlias,
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
                    );
                  }
                  
                  final products = snapshot.data ?? [];
                  
                  return DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF334155).withOpacity(0.5)),
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: 60,
                    horizontalMargin: 24,
                    columnSpacing: 24,
                    dividerThickness: 1,
                    columns: const [
                      DataColumn(label: Text('Product', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('SKU', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Category', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Stock', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Price', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Trend', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
                    ],
                    rows: products.map((product) => _buildDataRow(product)).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(Product product) {
    final categoryColor = const Color(0xFF3B82F6);
    final isLowStock = product.stock <= 10;
    final stockColor = isLowStock ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    
    IconData trendIcon;
    Color trendColor;
    if (product.trend > 0) {
      trendIcon = Icons.trending_up;
      trendColor = const Color(0xFF10B981);
    } else if (product.trend < 0) {
      trendIcon = Icons.trending_down;
      trendColor = const Color(0xFFEF4444);
    } else {
      trendIcon = Icons.remove;
      trendColor = Colors.white54;
    }

    return DataRow(
      cells: [
        DataCell(Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        DataCell(Text(product.sku, style: const TextStyle(color: Colors.white54))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              product.category,
              style: TextStyle(color: categoryColor, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: stockColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${product.stock} units',
              style: TextStyle(color: stockColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        DataCell(Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
        DataCell(Icon(trendIcon, color: trendColor, size: 20)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                color: Colors.white54,
                hoverColor: Colors.white,
                onPressed: () {},
                splashRadius: 20,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: Colors.white54,
                hoverColor: Colors.white,
                onPressed: () => _showProductFormDialog(product),
                splashRadius: 20,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: const Color(0xFFEF4444).withOpacity(0.7),
                hoverColor: const Color(0xFFEF4444),
                onPressed: () => _showDeleteDialog(product),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
