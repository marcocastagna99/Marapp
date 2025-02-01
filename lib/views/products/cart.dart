import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marapp/views/orders/address_view.dart';
import 'package:marapp/views/orders/order_management.dart';

import '../orders/book_day.dart';

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
  @override
  void initState() {
    super.initState();
    _getCartData();
  }

  Future<void> _getCartData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("Utente non autenticato. Nessun carrello da caricare.");
        return;
      }

      final cartRef = FirebaseFirestore.instance.collection('cart').doc(
          user.uid);
      final docSnapshot = await cartRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          if (data['userId'] == user.uid) {
            if (data['cartItems'] is List) {
              List<Map<String, dynamic>> fetchedItems = List<
                  Map<String, dynamic>>.from(data['cartItems']);

              // Aggiungi il percorso dell'immagine da assets
              for (var item in fetchedItems) {
                final productRef = FirebaseFirestore.instance.collection(
                    'products').doc(item['productId']);
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
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(
          widget.userId);

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



  Future<void> proceedWithOrder(BuildContext context) async {
    bool isValid = await _quantityControl();

    if (!isValid) {
      return; // Se le quantità non sono valide, esci
    }

    DateTime? selectedDate  = await showDatePickerDialog(context, DateTime.now());
    //updateDailyLimit(selectedDate!, cartItems);

    bool result = await checkPreparationLimit(selectedDate!, cartItems);
    if (!result) {
      // Show the snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Too busy on that day. Please choose another day or reduce your cart items.'),
          duration: Duration(seconds: 3), // Set the duration of the message
        ),
      );
      return;
    }



    if (selectedDate != null) {
      //da fare per dopo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddressSearch(
                  selectedDate: selectedDate), // Passa la data selezionata se necessaria
        ),
      );
    }
  }

  Future<bool> _quantityControl() async {
    try {
      bool allValid = true; // Assume all quantities are valid

      // Loop through cart items
      for (var item in cartItems) {
        final productId = item['productId'];
        final quantity = item['quantity'];

        // Get product data from Firestore
        final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
        final productSnapshot = await productRef.get();

        if (productSnapshot.exists) {
          final productData = productSnapshot.data();
          if (productData != null && productData['limitPerOrder'] != null) {
            final limitPerOrder = productData['limitPerOrder'];

            // If quantity exceeds limit, update the quantity and return false
            if (quantity > limitPerOrder) {
              setState(() {
                item['quantity'] = limitPerOrder; // Set quantity to the limit
              });

              // Show feedback message to the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('The quantity for ${item['name']} has been limited to $limitPerOrder'),
                ),
              );

              allValid = false; // Mark as invalid if limit exceeded
            }
          }
        }
      }

      // Return true if all items have valid quantities, false otherwise
      return allValid;
    } catch (e) {
      print("Error accessing Firestore: $e");
      return false;
    }
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
                style: TextStyle(fontSize: 24),
              ),
            )
                : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];

                return ListTile(
                  leading: item['imageUrl'] != null &&
                      item['imageUrl'].isNotEmpty
                      ? Image.asset(
                    item['imageUrl'],
                    width: 70, // Dimensione maggiore per l'immagine
                    height: 70,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, size: 70),
                  // Icona di fallback più grande
                  title: Text(
                    item['name'] ?? 'Nome prodotto non disponibile',
                    style: const TextStyle(
                        fontSize: 18), // Aumenta la dimensione del testo
                  ),
                  subtitle: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 30),
                        // Icona più grande per rimuovere
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
                      Text(
                        'Quantity: ${item['quantity']}',
                        style: const TextStyle(
                            fontSize: 18), // Aumenta la dimensione del testo della quantità
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 30),
                        // Icona più grande per aggiungere
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
                  trailing: Text(
                    '€${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18), // Aumenta la dimensione del testo del prezzo
                  ),
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
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight
                              .bold), // Aumenta la dimensione del testo
                        ),
                        Text(
                          '€${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight
                              .bold), // Aumenta la dimensione del testo
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
                              backgroundColor: Colors.red,
                              // Colore rosso per "Cancel"
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancel the order',
                              style: TextStyle(
                                  fontSize: 16), // Aumenta la dimensione del testo
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => proceedWithOrder(context),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Proceed with order',
                              style: TextStyle(
                                  fontSize: 15), // Aumenta la dimensione del testo
                            ),
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