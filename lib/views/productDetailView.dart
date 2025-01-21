import 'package:flutter/material.dart';

class ProductDetailView extends StatelessWidget {
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final Function(String, double) addToCart;

  const ProductDetailView({
    super.key,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.addToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/$imageUrl',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              '€${price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addToCart(name, price); // Aggiungi al carrello
                Navigator.pop(context); // Torna indietro
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
