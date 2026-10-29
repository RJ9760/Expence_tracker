import 'package:flutter/material.dart';

enum PaymentMethod {
  cash('Cash', Icons.payments_rounded),
  card('Card', Icons.credit_card_rounded),
  upi('UPI', Icons.qr_code_rounded),
  bank('Bank', Icons.account_balance_rounded),
  other('Other', Icons.more_horiz_rounded);

  const PaymentMethod(this.label, this.icon);
  final String label;
  final IconData icon;
}
