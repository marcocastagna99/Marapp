import 'package:flutter/material.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  CartViewState createState() => CartViewState();
}

class CartViewState extends State<CartView> {
  final List<CartItem> _cartItems = [];

  void _addItem(CartItem item) {
    setState(() {
      _cartItems.add(item);
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
    });
  }

  void _updateItemQuantity(CartItem item, int quantity) {
    setState(() {
      item.quantity = quantity;
    });
  }

  double _getTotalPrice() {
    return _cartItems.fold(0, (total, item) => total + item.price * item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Price: \$${item.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (item.quantity > 1) {
                            _updateItemQuantity(item, item.quantity - 1);
                          } else {
                            _removeItem(item);
                          }
                        },
                      ),
                      Text(item.quantity.toString()),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _updateItemQuantity(item, item.quantity + 1);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: \$${_getTotalPrice().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Implement checkout functionality here
              },
              child: Text('Checkout'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new item to the cart for demonstration purposes
          _addItem(CartItem(name: 'Item ${_cartItems.length + 1}', price: 10.0));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}
