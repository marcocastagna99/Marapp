import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Authentication
import 'package:flutter/material.dart';
import 'package:marapp/views/productDetailView.dart';
import 'cart.dart'; // Import the cart.dart

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  ProductsViewState createState() => ProductsViewState();
}

class ProductsViewState extends State<ProductsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId; // Declare userId

  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();  // Load the user ID on initialization
  }

  void _loadUserId() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      setState(() {
        userId = user.uid; // Set the user ID
      });
      await _createEmptyCartIfNotExists(); // Crea il carrello vuoto, se necessario
      _loadCart(); // Load cart data after setting the user ID
    } else {
      // Handle the case where the user is not logged in
      print("User is not logged in");
    }
  }

  Future<void> _createEmptyCartIfNotExists() async {
    if (userId == null) {
      print("User ID is null. Cannot create cart.");
      return;
    }

    final cartRef = _firestore.collection('cart').doc(userId);
    final cartDoc = await cartRef.get();

    if (!cartDoc.exists) {
      try {
        // Crea il documento del carrello vuoto con il campo userId
        await cartRef.set({
          'cartItems': [],
          'userId': userId, // Aggiungi il campo userId
        });
        print("Created empty cart for user $userId");
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          print("Error creating cart: Permission denied");
        } else {
          rethrow; // Rethrow other errors
        }
      }
    }
  }

  // Function to load cart data from Firebase
  void _loadCart() async {
    try {
      final cartRef = _firestore.collection('cart').doc(userId);
      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        setState(() {
          _cartItems = List<Map<String, dynamic>>.from(cartDoc['cartItems']);
        });
        print("Carrello caricato con successo per l'utente: $userId");
        print("Dati del carrello: $_cartItems");
      } else {
        print("Nessun carrello trovato per l'utente $userId");
      }
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  // Function to add product to cart
  void _addToCart(String productId, double price, String name, int quantity) async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(userId);
      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        List cartItemsList = List.from(cartDoc['cartItems']);
        var existingProduct = cartItemsList.firstWhere(
              (item) => item['productId'] == productId,
          orElse: () => null,
        );

        if (existingProduct != null) {
          // Se il prodotto esiste, aggiorna la quantità
          existingProduct['quantity'] += quantity;
        } else {
          // Se il prodotto non esiste, aggiungi un nuovo elemento con la quantità
          cartItemsList.add({
            'productId': productId,
            'quantity': quantity,  // Usa la quantità passata
            'price': price,  // Salva il prezzo per ogni prodotto
            'name': name,    // Salva il nome del prodotto
          });
        }

        await cartRef.update({'cartItems': cartItemsList});
      } else {
        // Se il carrello non esiste, crealo con il prodotto, il suo prezzo e nome
        await cartRef.set({
          'cartItems': [
            {
              'productId': productId,
              'quantity': quantity,  // Usa la quantità passata
              'price': price,  // Aggiungi il prezzo
              'name': name,    // Aggiungi il nome
            }
          ]
        });
      }

      _loadCart(); // Ricarica i dati del carrello
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  void _navigateToProductDetail(String productId, double price, String description, String imageUrl, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailView(
          productId: productId,
          price: price,
          description: description,
          imageUrl: imageUrl,
          addToCart: (productId, price, name, quantity) {
            _addToCart(productId, price, name, quantity); // Pass both productId and quantity
          },
          name: name,
        ),
      ),
    );
  }

  Stream<int> _getTotalCartQuantityStream() {
    try {
      // Stream per ascoltare le modifiche al carrello dell'utente
      return FirebaseFirestore.instance
          .collection('cart')
          .doc(userId)
          .snapshots()
          .map((cartDoc) {
        if (cartDoc.exists) {
          List cartItems = cartDoc['cartItems'] ?? [];
          // Somma le quantità dei prodotti nel carrello
          int totalQuantity = cartItems.fold<int>(
            0,
                (sum, item) => sum + (item['quantity'] as int),
          );
          return totalQuantity;
        } else {
          return 0; // Carrello vuoto
        }
      });
    } catch (e) {
      print("Error fetching cart stream: $e");
      return Stream.value(0); // Stream che restituisce 0 in caso di errore
    }
  }

  Stream<List<Map<String, dynamic>>> _listenToCartUpdates() {
    return _firestore
        .collection('cart')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        List cartItems = snapshot['cartItems'] ?? [];
        return List<Map<String, dynamic>>.from(cartItems);
      } else {
        return [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            return const Center(child: Text('Something went wrong, please try again.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];

              String productId = documentSnapshot.id; // Product ID
              String name = documentSnapshot['name'] ?? "No Name";
              double price = (documentSnapshot['price'] as num).toDouble();
              String description = documentSnapshot['description'] ?? "No Description";
              String imageUrl = documentSnapshot['imageUrl'];

              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'assets/$imageUrl',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
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
                    _navigateToProductDetail(productId, price, description, imageUrl, name); // Pass 'name'
                  },
                  trailing: GestureDetector(
                    onTap: () {
                      int quantity = 1; // Aumenta la quantità
                      _addToCart(productId, price, name, quantity); // Aggiungi il prodotto al carrello
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF76B6FE), // Colore di sfondo
                        borderRadius: BorderRadius.circular(12.0), // Angoli arrotondati
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white, // Colore dell'icona
                        size: 28.0, // Dimensione dell'icona
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StreamBuilder<List<Map<String, dynamic>>>(
                stream: _listenToCartUpdates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading cart data.'));
                  }

                  List<Map<String, dynamic>> cartItems = snapshot.data ?? [];

                  return CartView(
                    cartItems: cartItems, // Passa gli articoli aggiornati
                    userId: userId, // Passa l'ID dell'utente
                    updateCart: (String productId, int quantityChange) {
                      // Funzione di aggiornamento del carrello
                      setState(() {
                        var existingItem = cartItems.firstWhere(
                              (item) => item['productId'] == productId,
                          orElse: () => {},
                        );

                        if (existingItem.isNotEmpty) {
                          existingItem['quantity'] += quantityChange;
                        } else {
                          cartItems.add({
                            'productId': productId,
                            'quantity': quantityChange,
                          });
                        }
                      });
                    },
                  );
                },
              ),
            ),
          );
        },
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
        foregroundColor: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        child: Stack(
          children: [
            const Icon(Icons.shopping_cart),
            StreamBuilder<int>(
              stream: _getTotalCartQuantityStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }

                return Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      snapshot.data.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
