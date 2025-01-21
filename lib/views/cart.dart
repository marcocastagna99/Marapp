import 'package:flutter/material.dart';

class CartView extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(String, int) updateCart; // Funzione di aggiornamento

  const CartView({
    super.key,
    required this.cartItems,
    required this.updateCart, // Passiamo la funzione updateCart
  });

  @override
  CartViewState createState() => CartViewState();
}

class CartViewState extends State<CartView> {
  late List<Map<String, dynamic>> cartItems;

  @override
  void initState() {
    super.initState();
    cartItems = List.from(widget.cartItems); // Copia dei dati iniziali
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity']),
    );

    // Ottieni il colore dal tema
    Color bottomNavBarColor = Theme.of(context).primaryColor;
    Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          'Your cart is empty!',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];

          return ListTile(
            title: Text(item['name']),
            subtitle: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    widget.updateCart(item['name'], -1);
                    setState(() {}); // Rendi visibile il cambiamento
                  },
                ),
                Text('Quantity: ${item['quantity']}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    widget.updateCart(item['name'], 1);
                    setState(() {}); // Rendi visibile il cambiamento
                  },
                ),
              ],
            ),
            trailing: Text(
                '€${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: bottomNavBarColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total:',
              style: TextStyle(fontSize: 18, color: textColor),
            ),
            Text(
              '€${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
