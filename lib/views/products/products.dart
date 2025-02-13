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
  List<Map<String, dynamic>> _allProducts = []; // Lista per tutti i prodotti
  List<Map<String, dynamic>> _filteredProducts = []; // Lista per i prodotti filtrati
  TextEditingController _searchController = TextEditingController(); // Controller per la barra di ricerca
  String _searchQuery = ""; // Variabile per la query di ricerca
  final FocusNode _focusNode = FocusNode();
  String _sortOption = '----';
  Set<String> _categories = {}; // Per memorizzare le categorie uniche
  String _selectedCategory = 'All'; // Categoria selezionata


  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadProducts();
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

  Future<void> _loadProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      final products = snapshot.docs.map((doc) {
        final product = doc.data() as Map<String, dynamic>;
        product['id'] = doc.id;  // Aggiungi l'ID del prodotto
        return product;
      }).where((product) => product['available'] == true).toList(); // Filtra solo quelli disponibili

      setState(() {
        _allProducts = products;
        _filteredProducts = products; // Inizialmente, tutti i prodotti sono filtrati
        _extractCategories();
      });
    } catch (e) {
      print("Error loading products: $e");
    }
  }


  void _extractCategories() {
    _categories = {'All', ..._allProducts.map((product) => product['category'] as String).toSet()};
    setState(() {}); // Aggiorna la UI con le categorie disponibili

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
      int quantity, int prepTime) async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(userId);
      final cartDoc = await cartRef.get();
      CollectionReference limitsCollection = FirebaseFirestore.instance.collection('limits');
      DocumentSnapshot limitsDoc = await limitsCollection.doc('limits').get();

      // Recupera il valore di maxTimePerDay dalla collection 'limits'
      int maxTimePerDay = limitsDoc['maxTimePerDay'] ?? 500;

      if (cartDoc.exists) {
        List cartItemsList = List.from(cartDoc['cartItems']);

        // Somma i prepTime dei prodotti nel carrello (senza considerare la quantità)
        int totalPrepTime = cartItemsList.fold(0, (sum, item) => sum + item['prepTime'] as int);

        // Controlla se il nuovo prodotto supera il limite di prepTime
        if (totalPrepTime + prepTime > maxTimePerDay) {
          // Se il limite è superato, mostra uno snackbar
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Product limit reached"))
          );
          return; // Non aggiungere il prodotto al carrello
        }

        var existingProduct = cartItemsList.firstWhere(
              (item) => item['productId'] == productId,
          orElse: () => null,
        );

        if (existingProduct != null) {
          // Se il prodotto esiste, aggiorna la quantità
          existingProduct['quantity'] += quantity;
        } else {
          // Se il prodotto non esiste, aggiungi un nuovo prodotto
          cartItemsList.add({
            'productId': productId,
            'quantity': quantity,
            'price': price,
            'name': name,
            'prepTime': prepTime,
          });
        }

        // Aggiorna il carrello nel Firestore
        await cartRef.update({'cartItems': cartItemsList});
      } else {
        // Se il carrello non esiste, crealo con il nuovo prodotto
        await cartRef.set({
          'cartItems': [
            {
              'productId': productId,
              'quantity': quantity,
              'price': price,
              'name': name,
              'prepTime': prepTime,
            }
          ]
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added to cart successfully!'),
          duration: const Duration(seconds: 2),
        ),
      );
      _loadCart(); // Ricarica il carrello dopo l'aggiunta
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  void _navigateToProductDetail(String productId, double price,
      String description, String imageUrl, String name, int prepTime, int limit) {
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
                    quantity, prepTime); // Pass both productId and quantity
              },
              name: name,
              maxQuantity: limit,
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

  void _filterProducts() {
    List<Map<String, dynamic>> filtered = _allProducts;

    // Filtraggio per categoria (se selezionata)
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) {
        return product['category'] == _selectedCategory;
      }).toList();
    }

    // Filtraggio per nome prodotto
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final productName = product['name'].toLowerCase();
        return productName.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Ordinamento
    if (_sortOption == 'Price Ascending') {
      filtered.sort((a, b) => (a['price'] as num).compareTo(b['price']));
    } else if (_sortOption == 'Price Descending') {
      filtered.sort((a, b) => (b['price'] as num).compareTo(a['price']));
    } else if (_sortOption == 'Name Ascending') {
      filtered.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (_sortOption == 'Name Descending') {
      filtered.sort((a, b) => b['name'].compareTo(a['name']));
    }

    setState(() {
      _filteredProducts = filtered; // Aggiorna i prodotti filtrati
    });
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
                  _filterProducts(); // Riflitra i prodotti
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
                    _filterProducts(); // Riflitra i prodotti
                  },
                )
                    : null,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: _focusNode.hasFocus
                        ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue[300]!
                        : Colors.blue)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centra la riga
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _sortOption = newValue!;
                        _filterProducts(); // Riflitra i prodotti dopo la modifica del filtro
                      });
                    },
                    alignment: Alignment.center,  // Centra il testo nel DropdownButton
                    items: <String>[
                      '----',
                      'Price Ascending',
                      'Price Descending',
                      'Name Ascending',
                      'Name Descending',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, textAlign: TextAlign.center),  // Centra il testo del menu
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 40), // Spazio tra i due dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                        _filterProducts(); // Riflitra i prodotti in base alla categoria selezionata
                      });
                    },
                    alignment: Alignment.center,  // Centra il testo nel DropdownButton
                    items: _categories.map<DropdownMenuItem<String>>((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, textAlign: TextAlign.center),  // Centra il testo del menu
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),


          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final name = product['name'] ?? "No Name";  // Fallback se il nome è nullo
                final price = (product['price'] as num?)?.toDouble() ?? 0.0;  // Fallback se il prezzo è nullo
                final description = product['description'] ?? "No Description";  // Fallback se la descrizione è nulla
                final imageUrl = product['imageUrl'] ?? 'default_image.jpg';  // Fallback se l'immagine è nulla
                final id = product['id'] ?? 'defaultId';  // Fallback se l'id è nullo
                final prepTime = (product['timePreparation'] as num?)?.toInt() ?? 0;
                final limit = (product['limitPerOrder'] as num?)?.toInt() ?? 0;


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
                      // Verifica se l'id è valido prima di navigare
                      if (id != 'defaultId') {
                        _navigateToProductDetail(id, price, description, imageUrl, name, prepTime, limit);
                      } else {
                        // Gestisci l'errore nel caso in cui l'id sia nullo
                        print("Errore: ID prodotto mancante");
                      }
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    int quantity = 1;
                                    _addToCart(product['id'], price, name, quantity, prepTime);

                                    ScaffoldMessenger.of(context).clearSnackBars();
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