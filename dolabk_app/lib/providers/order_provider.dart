// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  // ignore: unused_field
  final OrderService _orderService;

  bool _isLoading = false;
  String? _error;

  OrderProvider(this._orderService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
