import 'package:flutter/material.dart';

class PaymentMethodView extends StatelessWidget {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage your payment methods:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Mocked payment methods list
            ListTile(
              title: const Text('Credit Card'),
              subtitle: const Text('**** **** **** 1234'),
              leading: const Icon(Icons.credit_card),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Implement edit functionality
                },
              ),
            ),
            ListTile(
              title: const Text('PayPal'),
              subtitle: const Text('user@example.com'),
              leading: const Icon(Icons.payments),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Implement edit functionality
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement add new payment method functionality
              },
              child: const Text('Add Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}
