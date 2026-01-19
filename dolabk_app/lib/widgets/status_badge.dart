// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String type;
  final bool small;

  const StatusBadge({Key? key, required this.type, this.small = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (type.toLowerCase()) {
      case 'sale':
        color = AppTheme.primaryGreen;
        label = 'Sale';
        break;
      case 'rent':
        color = AppTheme.lightBlue;
        label = 'Rent';
        break;
      case 'exchange':
        color = AppTheme.orange;
        label = 'Exchange';
        break;
      case 'pending':
        color = AppTheme.orange;
        label = 'Pending';
        break;
      case 'confirmed':
        color = AppTheme.lightBlue;
        label = 'Confirmed';
        break;
      case 'shipped':
        color = Colors.purple;
        label = 'Shipped';
        break;
      case 'delivered':
        color = AppTheme.primaryGreen;
        label = 'Delivered';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = AppTheme.darkGray;
        label = type;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
