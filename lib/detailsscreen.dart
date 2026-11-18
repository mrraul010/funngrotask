import 'package:flutter/material.dart';
import 'package:funngroapp/earnings/model/earnings_viewmodel.dart';

class DetailScreen extends StatelessWidget {
  final EarningDetail detail;

  const DetailScreen({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earning Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.projectTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Company: ${detail.companyName}'),
            const SizedBox(height: 8),
            Text('Amount: ₹${detail.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Status: ${detail.status}'),
          ],
        ),
      ),
    );
  }
}
