// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final String? imageUrl;
  int quantity;
  int? rentalDays;
  DateTime? rentalStartDate;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
    this.rentalDays,
    this.rentalStartDate,
  });

  double get totalPrice => price * quantity * (rentalDays ?? 1);
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere(
      (i) => i.productId == item.productId,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
