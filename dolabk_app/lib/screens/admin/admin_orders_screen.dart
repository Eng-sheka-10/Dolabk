// lib/screens/admin/admin_orders_screen.dart
import 'package:dolabk_app/models/enums.dart';
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../services/admin_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../../core/theme/app_theme.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _adminService = getIt<AdminService>();

  bool _isLoading = true;
  List<dynamic> _orders = [];
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final response = await _adminService.getOrders(
        status: OrderStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == (_filterStatus ?? '').toLowerCase(),
        ),
        page: 1,
        pageSize: 50,
      );

      if (response.success) {
        setState(() {
          _orders = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Management')),
      body: Column(
        children: [
          // Status Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterStatus == null,
                  onSelected: (selected) {
                    setState(() => _filterStatus = null);
                    _loadOrders();
                  },
                ),
                const SizedBox(width: 8),
                ...[
                  'Pending',
                  'Confirmed',
                  'Shipped',
                  'Delivered',
                  'Cancelled',
                ].map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: _filterStatus == status,
                      onSelected: (selected) {
                        setState(
                          () => _filterStatus = selected ? status : null,
                        );
                        _loadOrders();
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Loading orders...')
                : _orders.isEmpty
                ? const EmptyState(
                    message: 'No orders found',
                    icon: Icons.shopping_bag_outlined,
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order.orderNumber ?? order.id?.substring(0, 8) ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    StatusBadge(
                                      type: order.status ?? 'Pending',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Customer: ${order.user?.fullName ?? 'N/A'}',
                                ),
                                Text('Date: ${order.createdAt ?? 'N/A'}'),
                                Text(
                                  'Total: \$${(order.totalAmount ?? 0).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
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
