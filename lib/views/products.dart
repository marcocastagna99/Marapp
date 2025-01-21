import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marapp/views/productDetailView.dart';
import 'cart.dart'; // Import del file cart.dart

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  ProductsViewState createState() => ProductsViewState();
}

class ProductsViewState extends State<ProductsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _cartItems = [];

  // Funzione per aggiungere prodotti al carrello
  void _addToCart(String name, double price) {
    setState(() {
      bool isProductInCart = false;

      for (var item in _cartItems) {
        if (item['name'] == name) {
          item['quantity'] += 1;
          isProductInCart = true;
          break;
        }
      }

      if (!isProductInCart) {
        _cartItems.add({"name": name, "quantity": 1, "price": price});
      }
    });
  }

  // Funzione per aggiornare il carrello (aggiungi o rimuovi prodotti)
  void _updateCart(String name, int quantityChange) {
    setState(() {
      for (var item in _cartItems) {
        if (item['name'] == name) {
          item['quantity'] += quantityChange;

          // Se la quantità scende a 0, rimuovi l'articolo
          if (item['quantity'] <= 0) {
            _cartItems.remove(item);
          }
          break;
        }
      }
    });
  }

  // Funzione per navigare alla pagina del dettaglio prodotto
  void _navigateToProductDetail(String name, double price, String description, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailView(name: name, price: price, description: description, imageUrl: imageUrl, addToCart: _addToCart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];

              String name = documentSnapshot['name'];
              double price = (documentSnapshot['price'] as num).toDouble();
              String description = documentSnapshot['description'];
              String imageUrl = documentSnapshot['imageUrl'];

              return ListTile(
                leading: Image.asset(
                  'assets/$imageUrl',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                title: Text(name, style: Theme.of(context).textTheme.bodyLarge),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('€${price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 5),
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                onTap: () {
                  _navigateToProductDetail(name, price, description, imageUrl); // Vai ai dettagli
                },
                trailing: IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF76B6FE)),
                  onPressed: () {
                    _addToCart(name, price); // Aggiungi al carrello
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviga verso la schermata del carrello
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartView(cartItems: _cartItems, updateCart: _updateCart),
            ),
          );
        },
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
        foregroundColor: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        child: Stack(
          children: [
            const Icon(Icons.shopping_cart),
            if (_cartItems.isNotEmpty) ...[
              Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    (_cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int))).toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
