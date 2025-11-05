import 'package:flutter/material.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
