// lib/models/payment_model.dart
import 'package:dolabk_app/models/enums.dart';

class Payment {
  final int id;
  final int orderId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final DateTime? paidAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['orderId'],
      amount: (json['amount'] ?? 0).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['method'],
        orElse: () => PaymentMethod.CashOnDelivery,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.Pending,
      ),
      transactionId: json['transactionId'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }
}
