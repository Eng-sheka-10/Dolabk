// lib/screens/admin/admin_products_screen.dart
import 'package:dolabk_app/models/enums.dart';
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../services/admin_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../../core/theme/app_theme.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _adminService = getIt<AdminService>();

  bool _isLoading = true;
  List<dynamic> _products = [];
  String? _filterType;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final response = await _adminService.getProducts(
        type: ProductType.values.firstWhere(
          (e) => e.name.toLowerCase() == (_filterType ?? '').toLowerCase(),
        ),
        isApproved: _filterStatus == 'approved'
            ? true
            : _filterStatus == 'pending'
            ? false
            : null,
        page: 1,
        pageSize: 50,
      );

      if (response.success) {
        setState(() {
          _products = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _adminService.deleteProduct(
          int.parse(productId),
        );
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          _loadProducts();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Management')),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Types'),
                  selected: _filterType == null,
                  onSelected: (selected) {
                    setState(() => _filterType = null);
                    _loadProducts();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Sale'),
                  selected: _filterType == 'Sale',
                  onSelected: (selected) {
                    setState(() => _filterType = selected ? 'Sale' : null);
                    _loadProducts();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Rent'),
                  selected: _filterType == 'Rent',
                  onSelected: (selected) {
                    setState(() => _filterType = selected ? 'Rent' : null);
                    _loadProducts();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Exchange'),
                  selected: _filterType == 'Exchange',
                  onSelected: (selected) {
                    setState(() => _filterType = selected ? 'Exchange' : null);
                    _loadProducts();
                  },
                ),
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _filterStatus == 'pending',
                  onSelected: (selected) {
                    setState(() => _filterStatus = selected ? 'pending' : null);
                    _loadProducts();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Approved'),
                  selected: _filterStatus == 'approved',
                  onSelected: (selected) {
                    setState(
                      () => _filterStatus = selected ? 'approved' : null,
                    );
                    _loadProducts();
                  },
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Loading products...')
                : _products.isEmpty
                ? const EmptyState(
                    message: 'No products found',
                    icon: Icons.inventory_2_outlined,
                  )
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: product.images?.isNotEmpty == true
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.images!.first.imageUrl ?? '',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 60,
                                        height: 60,
                                        color: AppTheme.softGray,
                                        child: const Icon(Icons.image),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: AppTheme.softGray,
                                    child: const Icon(Icons.image),
                                  ),
                            title: Text(product.name ?? 'Product'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seller: ${product.user?.fullName ?? 'N/A'}',
                                ),
                                Text(
                                  'Price: \$${(product.price ?? 0).toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StatusBadge(type: product.type ?? 'Sale'),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteProduct(product.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
