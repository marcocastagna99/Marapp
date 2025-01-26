import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Authentication
import 'package:flutter/material.dart';
import 'package:marapp/views/products/productDetailView.dart';
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
  TextEditingController _searchController = TextEditingController(); // Controller per la barra di ricerca
  String _searchQuery = ""; // Variabile per la query di ricerca
  final FocusNode _focusNode = FocusNode();
  String _sortOption = 'Price Ascending';


  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text
            .toLowerCase(); // Aggiorna la query ogni volta che cambia
      });
    });
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
  void _addToCart(String productId, double price, String name,
      int quantity) async {
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
            'quantity': quantity, // Usa la quantità passata
            'price': price, // Salva il prezzo per ogni prodotto
            'name': name, // Salva il nome del prodotto
          });
        }

        await cartRef.update({'cartItems': cartItemsList});
      } else {
        // Se il carrello non esiste, crealo con il prodotto, il suo prezzo e nome
        await cartRef.set({
          'cartItems': [
            {
              'productId': productId,
              'quantity': quantity, // Usa la quantità passata
              'price': price, // Aggiungi il prezzo
              'name': name, // Aggiungi il nome
            }
          ]
        });
      }

      _loadCart(); // Ricarica i dati del carrello
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  void _navigateToProductDetail(String productId, double price,
      String description, String imageUrl, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailView(
              productId: productId,
              price: price,
              description: description,
              imageUrl: imageUrl,
              addToCart: (productId, price, name, quantity) {
                _addToCart(productId, price, name,
                    quantity); // Pass both productId and quantity
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

  Stream<QuerySnapshot> _getFilteredProducts() {
    Query query = _firestore.collection('products');

    if (_searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThan: _searchQuery + 'z');
    }

    if (_sortOption == 'Price Ascending') {
      query = query.orderBy('price');
    } else if (_sortOption == 'Price Descending') {
      query = query.orderBy('price', descending: true);
    } else if (_sortOption == 'Name Ascending') {
      query = query.orderBy('name');
    } else if (_sortOption == 'Name Descending') {
      query = query.orderBy('name', descending: true);
    }

    return query.snapshots();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Theme
            .of(context)
            .appBarTheme
            .backgroundColor,
        iconTheme: Theme
            .of(context)
            .appBarTheme
            .iconTheme,
        titleTextStyle: Theme
            .of(context)
            .appBarTheme
            .titleTextStyle,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase(); // Aggiorna la ricerca
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = ''; // Rimuove il testo nella ricerca
                      _searchController.clear(); // Pulisce il TextField
                    });
                    _focusNode.unfocus(); // Rimuove il focus dalla barra di ricerca
                  },
                )
                    : null, // Mostra la "x" solo se c'è del testo
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200], // Colore di sfondo a seconda del tema
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none, // Rimuove il bordo di default
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: _focusNode.hasFocus
                        ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[300]!
                        : Colors.blue)
                        : Colors.transparent, // Bordo solo quando il focus è attivo
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!, // Colore del bordo per il tema abilitato
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black, // Colore del testo a seconda del tema
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _sortOption,
              onChanged: (String? newValue) {
                setState(() {
                  _sortOption = newValue!;
                });
              },
              items: <String>[
                'Price Ascending',
                'Price Descending',
                'Name Ascending',
                'Name Descending',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Something went wrong, please try again.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filtra i prodotti in base alla query di ricerca
                final filteredProducts = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .where((product) {
                  final productName = product['name'].toLowerCase();
                  return productName.contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final productId = snapshot.data!.docs[index].id;
                    final name = product['name'] ?? "No Name";
                    final price = (product['price'] as num).toDouble();
                    final description = product['description'] ??
                        "No Description";
                    final imageUrl = product['imageUrl'];

                    return Card(
                      elevation: 5.0,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          _navigateToProductDetail(
                            productId,
                            price,
                            description,
                            imageUrl,
                            name,
                          );
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          constraints: const BoxConstraints(minHeight: 180),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  'assets/$imageUrl',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '€${price.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Adatta la larghezza al contenuto
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        int quantity = 1;
                                        _addToCart(productId, price, name, quantity);

                                        ScaffoldMessenger.of(context).clearSnackBars();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Product added to cart successfully!'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF76B6FE),
                                          borderRadius: BorderRadius.circular(12.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 6.0,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 28.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _listenToCartUpdates(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading cart data.'));
                      }

                      List<Map<String, dynamic>> cartItems = snapshot.data ??
                          [];

                      return CartView(
                        cartItems: cartItems,
                        userId: userId,
                        updateCart: (String productId, int quantityChange) {
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
        backgroundColor: Theme
            .of(context)
            .floatingActionButtonTheme
            .backgroundColor,
        foregroundColor: Theme
            .of(context)
            .floatingActionButtonTheme
            .foregroundColor,
        child: Stack(
          children: [
            const Icon(Icons.shopping_cart),
            StreamBuilder<int>(
              stream: _getTotalCartQuantityStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }

                // Controlla se il valore è maggiore di zero per mostrare il badge
                if (snapshot.data == 0) {
                  return const SizedBox(); // Non mostra nulla se il numero è zero
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