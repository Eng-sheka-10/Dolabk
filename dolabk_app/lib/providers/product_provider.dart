// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  // ignore: unused_field
  final ProductService _productService;

  bool _isLoading = false;
  String? _error;

  ProductProvider(this._productService);

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
