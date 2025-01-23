import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartView extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>> cartItems;
  final Function(String, int) updateCart;

  const CartView({
    super.key,
    required this.cartItems,
    required this.updateCart,
    required this.userId,
  });

  @override
  CartViewState createState() => CartViewState();
}

class CartViewState extends State<CartView> {
  List<Map<String, dynamic>> cartItems = [];

  // Non è più necessario il metodo _getImageUrl

  Future<void> _getCartData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("Utente non autenticato. Nessun carrello da caricare.");
        return;
      }

      final cartRef = FirebaseFirestore.instance.collection('cart').doc(user.uid);
      final docSnapshot = await cartRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          if (data['userId'] == user.uid) {
            if (data['cartItems'] is List) {
              List<Map<String, dynamic>> fetchedItems = List<Map<String, dynamic>>.from(data['cartItems']);

              // Aggiungi il percorso dell'immagine da assets
              for (var item in fetchedItems) {
                final productRef = FirebaseFirestore.instance.collection('products').doc(item['productId']);
                final productSnapshot = await productRef.get();
                if (productSnapshot.exists) {
                  final productData = productSnapshot.data();
                  if (productData != null && productData['imageUrl'] != null) {
                    // Usa il percorso dell'immagine direttamente da assets
                    item['imageUrl'] = 'assets/${productData['imageUrl']}';
                  }
                }
              }

              setState(() {
                cartItems = fetchedItems;
              });
            }
          }
        }
      } else {
        await cartRef.set({
          'cartItems': [],
          'userId': user.uid,
        });
        setState(() {
          cartItems = [];
        });
      }
    } catch (e) {
      print("Errore nel recupero dei dati del carrello: $e");
    }
  }

  Future<void> _saveCartToFirestore() async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(widget.userId);

      cartItems.removeWhere((item) => item['quantity'] <= 0);

      await cartRef.update({
        'cartItems': cartItems,
      });
    } catch (e) {
      print("Errore durante il salvataggio del carrello su Firestore: $e");
    }
  }

  void _clearCart() {
    setState(() {
      cartItems.clear();
    });
    _saveCartToFirestore();
  }

  @override
  void initState() {
    super.initState();
    _getCartData();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity']),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
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
                  leading: item['imageUrl'] != null && item['imageUrl'].isNotEmpty
                      ? Image.asset(
                    item['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, size: 50), // Fallback se URL immagine non esiste
                  title: Text(item['name'] ?? 'Nome prodotto non disponibile'),
                  subtitle: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          widget.updateCart(item['name'], -1);
                          setState(() {
                            item['quantity']--;
                            if (item['quantity'] <= 0) {
                              cartItems.removeAt(index);
                            }
                            _saveCartToFirestore();
                          });
                        },
                      ),
                      Text('Quantity: ${item['quantity']}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          widget.updateCart(item['name'], 1);
                          setState(() {
                            item['quantity']++;
                            _saveCartToFirestore();
                          });
                        },
                      ),
                    ],
                  ),
                  trailing: Text('€${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5, // Ombra
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Bordi arrotondati
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '€${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Colore rosso per "Cancel"
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Cancel the order'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Implementazione futura
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Proceed with order'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
