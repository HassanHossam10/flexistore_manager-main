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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Delete product?',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'Are you sure you want to delete "'),
                    TextSpan(text: product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const TextSpan(text: '"?\nThis action cannot be undone and will permanently remove this product from your system.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This will also delete all associated data including transaction history and analytics records.',
                        style: TextStyle(color: const Color(0xFFEF4444).withOpacity(0.9), fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await InventoryFFI.instance.deleteProduct(product.id);
                      _refreshData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Delete product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductFormDialog([Product? product]) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final barcodeCtrl = TextEditingController(text: product?.sku ?? '');
    final categoryCtrl = TextEditingController(text: product?.category ?? '');
    final costPriceCtrl = TextEditingController(text: '');
    final sellingPriceCtrl = TextEditingController(text: product?.price.toString() ?? '');
    final initialQuantityCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final lowStockThresholdCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 550,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA855F7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              isEditing ? 'Edit Product' : 'Add New Product',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF1E293B), height: 1, thickness: 1),
                  
                  // Form Fields
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Product Name'),
                          _buildTextField(nameCtrl, 'e.g., Samsung Galaxy S24'),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Barcode'),
                                    _buildTextField(barcodeCtrl, '123456789012'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Category'),
                                    Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFF334155)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: categoryCtrl.text.isEmpty ? null : categoryCtrl.text,
                                          hint: const Text('Select category', style: TextStyle(color: Colors.white54, fontSize: 14)),
                                          dropdownColor: const Color(0xFF1E293B),
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 16),
                                          isExpanded: true,
                                          items: ['Electronics', 'Audio', 'Accessories', 'Peripherals']
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setDialogState(() => categoryCtrl.text = val);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Cost Price (\$)'),
                                    _buildTextField(costPriceCtrl, '0.00'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Selling Price (\$)'),
                                    _buildTextField(sellingPriceCtrl, '0.00'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Initial Quantity'),
                                    _buildTextField(initialQuantityCtrl, '0'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Low Stock Alert Threshold', isRequired: false),
                                    _buildTextField(lowStockThresholdCtrl, '10'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Warning Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Important:', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      _buildBullet('Ensure barcode is unique'),
                                      const SizedBox(height: 4),
                                      _buildBullet('Verify pricing before saving'),
                                      const SizedBox(height: 4),
                                      _buildBullet('Set appropriate low stock threshold'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(color: Color(0xFF1E293B), height: 1, thickness: 1),
                  
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final newProduct = Product(
                                id: product?.id ?? 0,
                                name: nameCtrl.text.isEmpty ? 'Unknown' : nameCtrl.text,
                                sku: barcodeCtrl.text.isEmpty ? 'SKU-000' : barcodeCtrl.text,
                                category: categoryCtrl.text.isEmpty ? 'Other' : categoryCtrl.text,
                                stock: int.tryParse(initialQuantityCtrl.text) ?? 0,
                                price: double.tryParse(sellingPriceCtrl.text) ?? 0.0,
                                trend: product?.trend ?? 0,
                              );

                              Navigator.of(ctx).pop();
                              if (isEditing) {
                                await InventoryFFI.instance.updateProduct(newProduct);
                              } else {
                                await InventoryFFI.instance.addProduct(newProduct);
                              }
                              _refreshData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA855F7), // Purple
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: Text(isEditing ? 'Save Changes' : 'Add Product', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          children: isRequired
              ? [const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444)))]
              : [],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFA855F7)),
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12)),
      ],
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
