// lib/screens/cart/checkout_screen.dart
import 'package:dolabk_app/models/create_order_dto.dart';
import 'package:dolabk_app/models/enums.dart';
import 'package:dolabk_app/models/order_item_dto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../services/address_service.dart';
import '../../services/order_service.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressService = getIt<AddressService>();
  final _orderService = getIt<OrderService>();
  final _notesController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _addresses = [];
  String? _selectedAddressId;
  String _paymentMethod = 'CashOnDelivery';
  bool _isMeetAndExchange = false;
  double _shippingCost = 10.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    try {
      final response = await _addressService.getAddresses();
      if (response.success && response.data != null) {
        setState(() {
          _addresses = response.data!;
          _isLoading = false;

          // Select default address
          final defaultAddress = _addresses.firstWhere(
            (addr) => addr.isDefault == true,
            orElse: () => _addresses.isNotEmpty ? _addresses.first : null,
          );
          if (defaultAddress != null) {
            _selectedAddressId = defaultAddress.id;
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (!_isMeetAndExchange && _selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    if (_paymentMethod == 'CreditCard') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Coming Soon'),
          content: const Text('Online payment will be available soon.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final cart = Provider.of<CartProvider>(context, listen: false);

      final response = await _orderService.createOrder(
        CreateOrderDto(
          items: cart.items
              .map(
                (item) => OrderItemDto(
                  productId: int.parse(item.productId),
                  quantity: item.quantity,
                  rentalDays: item.rentalDays,
                  rentalStartDate: item.rentalStartDate,
                ),
              )
              .toList(),
          addressId: int.parse(_selectedAddressId ?? ''),
          shippingCost: _isMeetAndExchange ? 0 : _shippingCost,
          paymentMethod: PaymentMethod.CashOnDelivery,
          notes: _notesController.text,
        ),
      );

      if (!mounted) return;

      if (response.success) {
        cart.clear();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryGreen,
                  size: 32,
                ),
                SizedBox(width: 12),
                Text('Order Placed!'),
              ],
            ),
            content: const Text('Your order has been placed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/orders',
                    (route) => route.settings.name == '/home',
                  );
                },
                child: const Text('View Orders'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to place order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final totalAmount =
        cart.totalAmount + (_isMeetAndExchange ? 0 : _shippingCost);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const LoadingIndicator(message: 'Loading checkout...'),
      );
    }

    if (_isProcessing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const LoadingIndicator(message: 'Processing order...'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Options
            const Text(
              'Delivery Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Meet & Exchange'),
                    subtitle: const Text('Meet seller in person'),
                    value: _isMeetAndExchange,
                    onChanged: (value) {
                      setState(() => _isMeetAndExchange = value);
                    },
                  ),
                  if (!_isMeetAndExchange) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Delivery Address'),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/addresses');
                        },
                        child: const Text('Manage'),
                      ),
                    ),
                    ...(_addresses.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/addresses');
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Address'),
                                ),
                              ),
                            ),
                          ]
                        : _addresses.map((address) {
                            return RadioListTile<String>(
                              value: address.id,
                              groupValue: _selectedAddressId,
                              onChanged: (value) {
                                setState(() => _selectedAddressId = value);
                              },
                              title: Text(address.fullName ?? ''),
                              subtitle: Text(
                                '${address.street}, ${address.city}, ${address.state} ${address.zipCode}',
                              ),
                            );
                          }).toList()),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'CashOnDelivery',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() => _paymentMethod = value!);
                    },
                    title: const Text('Cash on Delivery'),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    value: 'CreditCard',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() => _paymentMethod = value!);
                    },
                    title: const Row(
                      children: [
                        Text('Online Payment'),
                        SizedBox(width: 8),
                        Chip(
                          label: Text(
                            'Coming Soon',
                            style: TextStyle(fontSize: 10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Notes
            const Text(
              'Order Notes (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any special instructions...',
              ),
            ),
            const SizedBox(height: 24),

            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text('\$${cart.totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping'),
                        Text(
                          _isMeetAndExchange
                              ? 'Free'
                              : '\$${_shippingCost.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CustomButton(text: 'Place Order', onPressed: _placeOrder),
            ),
          ],
        ),
      ),
    );
  }
}
