// lib/models/enums.dart
enum ProductType { Sale, Rent, Exchange }

enum ProductCondition { New, LikeNew, Good, Fair, Used }

enum OrderStatus {
  Pending,
  Confirmed,
  Processing,
  Shipped,
  Delivered,
  Cancelled,
  Returned,
}

enum PaymentMethod { CashOnDelivery, CreditCard, DebitCard, Wallet, Paymob }

enum PaymentStatus { Pending, Paid, Failed, Refunded }

enum ExchangeStatus { Pending, Accepted, Rejected, Completed, Cancelled }

enum NotificationType {
  ExchangeOffer,
  OrderUpdate,
  DeliveryUpdate,
  Message,
  Review,
  System,
}

enum DeliveryStatus {
  Pending,
  PickedUp,
  InTransit,
  OutForDelivery,
  Delivered,
  Failed,
}
