import 'package:flutter/material.dart';

import '../../domain/entities/sale_summary.dart';

class SaleTotalBar extends StatelessWidget {
  const SaleTotalBar({super.key, required this.summary, this.action});

  final SaleSummary summary;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${summary.totalItems} productos',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '\$${summary.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}
