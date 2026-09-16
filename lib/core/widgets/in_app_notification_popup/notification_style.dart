import 'package:flutter/material.dart';

class NotificationStyle {
  final IconData icon;
  final Color color;

  const NotificationStyle({required this.icon, required this.color});

  static NotificationStyle getStyleForType(int type) {
    switch (type) {
      case 1: // BranchUpdate
        return const NotificationStyle(
          icon: Icons.storefront_rounded,
          color: Color(0xFF00C853),
        ); // Green
      case 2: // SubscriptionUpdate
        return const NotificationStyle(
          icon: Icons.card_membership_rounded,
          color: Color(0xFF8E24AA),
        ); // Purple
      case 3: // PaymentUpdate
        return const NotificationStyle(
          icon: Icons.payments_rounded,
          color: Color(0xFF1E88E5),
        ); // Blue
      case 4: // SystemAlert
        return const NotificationStyle(
          icon: Icons.warning_amber_rounded,
          color: Color(0xFFE53935),
        ); // Red
      case 5: // BranchPackagesUpdate
        return const NotificationStyle(
          icon: Icons.inventory_2_rounded,
          color: Color(0xFFFB8C00),
        ); // Orange
      case 0: // General
      default:
        return const NotificationStyle(
          icon: Icons.notifications_none_rounded,
          color: Color(0xFF00C853),
        ); // Green
    }
  }
}
